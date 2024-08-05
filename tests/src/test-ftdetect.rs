mod common;
use crate::common::*;

use fancy_regex::Regex;
use rand::{
  distributions::{Alphanumeric, DistString},
  rngs::ThreadRng,
  Rng,
};
use serde::Deserialize;
use std::{
  collections::{HashMap, HashSet},
  fs::{self, File},
  hash::{Hash, Hasher},
  io::{self, prelude::*},
};

#[derive(Clone, Debug, Default, Deserialize, Eq)]
#[serde(deny_unknown_fields)]
struct FtdetectCase {
  #[serde(default)]
  filename: String,

  #[serde(default)]
  never: String,

  #[serde(default)]
  content: String,

  #[serde(default)]
  not_justfile: bool,
}

impl PartialEq for FtdetectCase {
  fn eq(&self, other: &Self) -> bool {
    self.filename == other.filename && self.content == other.content
  }
}

impl Hash for FtdetectCase {
  fn hash<H: Hasher>(&self, state: &mut H) {
    self.filename.hash(state);
    self.content.hash(state);
  }
}

fn random_alnum(rng: &mut ThreadRng, minlen: u8, maxlen: u8) -> String {
  let len = rng.gen_range(minlen..=maxlen);
  Alphanumeric.sample_string(rng, len.into())
}

fn fuzz_filename<T: AsRef<str>>(rng: &mut ThreadRng, filename: T) -> String {
  filename
    .as_ref()
    .split_inclusive('*')
    .map(|part| part.replace('*', random_alnum(rng, 3, 8).as_str()))
    .collect()
}

fn main() -> io::Result<()> {
  let interrupted = setup_ctrlc_handler();

  let test_home = test_vim_home();
  let mut tempdirs: Vec<TempDir> = vec![tempdir().unwrap()];

  let mut rng = rand::thread_rng();

  let cases = fs::read_to_string("cases/ftdetect.yml")?;
  let cases = match serde_yaml2::from_str::<Vec<FtdetectCase>>(cases.as_str()) {
    Ok(o) => o,
    Err(e) => return Err(io::Error::other(e)),
  };

  let total = cases.len();
  let mut passed = 0;

  let mut file2case = HashMap::<String, FtdetectCase>::with_capacity(total);
  let mut unique = HashSet::<FtdetectCase>::with_capacity(total);
  for case in cases {
    if !unique.insert(case.clone()) {
      return Err(io::Error::other(format!(
        "Duplicate or contradictory test case: {:?}",
        case
      )));
    }
    let never_rx = if case.never.is_empty() {
      None
    } else {
      match Regex::new(&case.never) {
        Ok(r) => Some(r),
        Err(e) => return Err(io::Error::other(e)),
      }
    };
    let mut never_rx_tries = 0;
    let fname = loop {
      let fname_ = if case.filename.is_empty() {
        random_alnum(&mut rng, 1, 16)
      } else {
        fuzz_filename(&mut rng, &case.filename)
      };
      if let Some(r) = &never_rx {
        if r.is_match(&fname_).unwrap() {
          if never_rx_tries >= 20 {
            return Err(io::Error::other(format!(
              "Failed to find filename matching `{}` but not /{}/ after {} tries",
              &case.filename, r, never_rx_tries
            )));
          }
          never_rx_tries += 1;
          continue;
        }
      }
      break fname_;
    };
    let actual_file = tempdirs
      .iter()
      .find_map(|t| {
        let pth = t.path().join(&fname);
        if pth.exists() {
          None
        } else {
          Some(pth)
        }
      })
      .unwrap_or_else(|| {
        tempdirs.push(tempdir().unwrap());
        tempdirs[tempdirs.len() - 1].path().join(&fname)
      });
    let mut testfile = File::create_new(&actual_file)?;
    testfile.write_all(case.content.as_bytes())?;
    file2case.insert(actual_file.into_os_string().into_string().unwrap(), case);
  }

  let ftdetect_results = tempdirs[0].path().join("ftdetect_results.txt");

  let mut args = vec!["-R", "-S", "batch_ftdetect_res.vim"];
  args.extend(file2case.keys().map(|s| s.as_str()));
  run_vim(args, &ftdetect_results, test_home.path(), &interrupted)?;

  let ftdetections = fs::read_to_string(ftdetect_results)?;

  let mut current_key = "";
  for line in ftdetections.lines() {
    if line.is_empty() {
      continue;
    } else if !current_key.is_empty() {
      let filetype = match line.split_once("filetype=") {
        Some((_, ft)) => ft,
        None => {
          return Err(io::Error::other(format!(
            "expected to find \"filetype=\" in line: {:?}",
            line
          )));
        }
      };
      let case = &file2case[current_key];
      if (filetype == "just" && !case.not_justfile) || (case.not_justfile && filetype != "just") {
        passed += 1;
      } else {
        eprintln!(
          "TEST FAILED: {:?} (file {}): unexpectedly detected as '{}'",
          case, current_key, filetype
        );
      }
      current_key = "";
    } else {
      current_key = line;
    }
  }

  if passed == total {
    eprintln!("[\u{2713}] {0}/{0} ftdetect tests passed.", total);
    Ok(())
  } else {
    Err(io::Error::other(format!(
      "{}/{} tests failed.",
      total - passed,
      total
    )))
  }
}
