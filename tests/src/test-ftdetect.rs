pub mod common;
use crate::common::*;

use rand::rngs::ThreadRng;
use regex::{Captures, Regex};
use serde::Deserialize;
use std::{
  collections::HashMap,
  env, fs,
  io::{self, ErrorKind},
  process::{Command, Stdio},
  sync::atomic::Ordering::Relaxed,
  time::Duration,
};
use wait_timeout::ChildExt;

#[derive(Debug, Default, Deserialize)]
struct FtdetectCase {
  #[serde(default)]
  filename: Option<String>,

  #[serde(default)]
  content: Option<String>,

  #[serde(default)]
  should_fail: bool,
}

fn fuzz_filename(rng: &mut ThreadRng, filename: String) -> String {
  let rx = Regex::new(r"\*").unwrap();
  rx.replace_all(filename.as_str(), |_: &Captures| random_alnum(rng, 3, 8))
    .into_owned()
}

fn _main() -> io::Result<()> {
  let interrupted = setup_ctrlc_handler();

  let tempdir = tempfile::tempdir().unwrap();

  create_dotvim_symlink();

  let mut rng = rand::thread_rng();

  let cases_json = match fs::read_to_string("cases/ftdetect.json") {
    Ok(o) => o,
    Err(e) => return Err(e),
  };
  let cases = match serde_json::from_str::<Vec<FtdetectCase>>(cases_json.as_str()) {
    Ok(o) => o,
    Err(e) => return Err(e.into()),
  };

  let total = cases.len();
  let mut passed = 0;

  let mut file2case: HashMap<String, FtdetectCase> = HashMap::with_capacity(total);
  for case in cases {
    let fname = match &case.filename {
      Some(n) => fuzz_filename(&mut rng, n.to_string()),
      None => random_alnum(&mut rng, 1, 16),
    };
    let actual_file = tempdir.path().join(fname);
    fs::write(
      &actual_file,
      match &case.content {
        Some(t) => t.clone(),
        None => "".to_string(),
      },
    )
    .unwrap();
    file2case.insert(actual_file.into_os_string().into_string().unwrap(), case);
  }

  let ftdetect_results = tempdir.path().join("ftdetect_results.txt");

  let mut vim = Command::new("vim")
    .args(["--not-a-term", "-S", "batch_ftdetect_res.vim"])
    .args(file2case.keys())
    .env("OUTPUT", &ftdetect_results)
    .env("HOME", env::current_dir().unwrap())
    .stdin(Stdio::null())
    .stdout(Stdio::null())
    .stderr(Stdio::piped())
    .spawn()
    .unwrap();

  let poll_interval = Duration::from_millis(100);
  let status = loop {
    match vim.wait_timeout(poll_interval) {
      Ok(Some(status)) => break status,
      Ok(None) => {
        if interrupted.load(Relaxed) {
          vim.kill().unwrap();
          return Err(io::Error::new(ErrorKind::Interrupted, "interrupted!"));
        }
      }
      Err(e) => {
        return Err(e);
      }
    }
  };

  if !status.success() {
    return Err(io::Error::new(
      ErrorKind::Other,
      format!("Vim failed with status: {}", status),
    ));
  }

  let ftdetections = fs::read_to_string(ftdetect_results).unwrap();

  let filetype_rx = Regex::new(r"^\s*filetype=(.*)$").unwrap();
  let mut current_key = "";
  for line in ftdetections.lines() {
    if line.is_empty() {
      continue;
    } else if !current_key.is_empty() {
      let detected_filetype_match = match filetype_rx.captures(line) {
        Some(o) => o,
        None => {
          return Err(io::Error::new(
            ErrorKind::Other,
            format!("filetype regex failed to match line: {}", line),
          ))
        }
      };
      let detected_filetype_match = match detected_filetype_match.get(1) {
        Some(o) => o,
        None => {
          return Err(io::Error::new(
            ErrorKind::Other,
            format!("filetype regex missing capture in match on line: {}", line),
          ))
        }
      };
      let filetype = detected_filetype_match.as_str();
      let case = file2case.get(current_key).unwrap();
      if (filetype == "just" && !case.should_fail) || (case.should_fail && filetype != "just") {
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
