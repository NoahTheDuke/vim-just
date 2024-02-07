mod common;
use crate::common::*;

use rand::{
  self,
  distributions::{Alphanumeric, DistString},
  rngs::ThreadRng,
  Rng,
};
use serde::Deserialize;
use std::{
  collections::HashMap,
  fs,
  io::{self, ErrorKind},
};

#[derive(Debug, Default, Deserialize)]
struct FtdetectCase {
  #[serde(default)]
  filename: Option<String>,

  #[serde(default)]
  content: Option<String>,

  #[serde(default)]
  not_justfile: bool,
}

fn random_alnum(rng: &mut ThreadRng, minlen: u8, maxlen: u8) -> String {
  let len = rng.gen_range(minlen..=maxlen);
  Alphanumeric.sample_string(rng, len.into())
}

fn fuzz_filename(rng: &mut ThreadRng, filename: String) -> String {
  filename
    .split_inclusive('*')
    .map(|part| part.replace('*', random_alnum(rng, 3, 8).as_str()))
    .collect()
}

fn _main() -> io::Result<()> {
  let interrupted = setup_ctrlc_handler();

  let tempdir = tempfile::tempdir().unwrap();

  create_dotvim_symlink();

  let mut rng = rand::thread_rng();

  let cases = fs::read_to_string("cases/ftdetect.yml")?;
  let cases = match serde_yaml::from_str::<Vec<FtdetectCase>>(cases.as_str()) {
    Ok(o) => o,
    Err(e) => return Err(io::Error::new(ErrorKind::Other, e)),
  };

  let total = cases.len();
  let mut passed = 0;

  let mut file2case = HashMap::<String, FtdetectCase>::with_capacity(total);
  for case in cases {
    let fname = match &case.filename {
      Some(n) => fuzz_filename(&mut rng, n.to_string()),
      None => random_alnum(&mut rng, 1, 16),
    };
    let actual_file = tempdir.path().join(fname);
    fs::write(
      &actual_file,
      match &case.content {
        Some(t) => t,
        None => "",
      },
    )?;
    file2case.insert(actual_file.into_os_string().into_string().unwrap(), case);
  }

  let ftdetect_results = tempdir.path().join("ftdetect_results.txt");

  let mut args = vec!["-R", "-S", "batch_ftdetect_res.vim"];
  args.extend(file2case.keys().map(|s| s.as_str()));
  run_vim(args, &ftdetect_results, &interrupted)?;

  let ftdetections = fs::read_to_string(ftdetect_results)?;

  let mut current_key = "";
  for line in ftdetections.lines() {
    if line.is_empty() {
      continue;
    } else if !current_key.is_empty() {
      let filetype = match line.split_once("filetype=") {
        Some((_, ft)) => ft,
        None => {
          return Err(io::Error::new(
            ErrorKind::Other,
            format!("expected to find \"filetype=\" in line: {:?}", line),
          ))
        }
      };
      let case = file2case.get(current_key).unwrap();
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
    Err(io::Error::new(
      ErrorKind::Other,
      format!("{}/{} tests failed.", total - passed, total),
    ))
  }
}

fn main() -> io::Result<()> {
  let real_main = _main();

  // cleanup
  clean_dotvim_symlink();

  real_main
}
