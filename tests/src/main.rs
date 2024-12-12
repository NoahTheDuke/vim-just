mod common;
use crate::common::*;

use fancy_regex::Regex;
use rayon::prelude::*;
use std::{
  collections::HashMap,
  env,
  ffi::OsStr,
  fs,
  io::{self, ErrorKind},
  path::{Path, PathBuf},
  sync::{
    atomic::{AtomicU64, Ordering::Relaxed},
    Mutex,
  },
  time::Instant,
};

fn main() -> io::Result<()> {
  let filter = match env::args().nth(1).map(|s| Regex::new(&s)).transpose() {
    Ok(o) => o,
    Err(e) => {
      return Err(io::Error::other(format!(
        "Invalid regex given on command line: {}",
        e
      )));
    }
  };

  let interrupted = setup_ctrlc_handler();

  let test_home = test_vim_home();
  let tmpdir = tempdir().unwrap();

  let case_dir = Path::new("cases");

  let mut test_cases = fs::read_dir(case_dir)?
    .filter_map(
      |res: io::Result<fs::DirEntry>| -> Option<io::Result<(String, PathBuf)>> {
        match res {
          Ok(o) => {
            let p = o.path();
            let ext = p.extension();
            if ext != Some(OsStr::new("just")) {
              return None;
            }
            let name = p.file_stem().unwrap().to_str().unwrap().to_owned();
            if let Some(rx) = &filter {
              if !rx.is_match(&name).unwrap() {
                return None;
              }
            }
            Some(Ok((name, p)))
          }
          Err(e) => Some(Err(e)),
        }
      },
    )
    .collect::<Result<Vec<_>, io::Error>>()?;
  test_cases.sort_unstable();

  let total = test_cases.len();
  let mut passed = 0;

  let total_vim_time = AtomicU64::new(0);

  let res = Mutex::new(HashMap::<String, String>::with_capacity(total));
  test_cases
    .par_iter()
    .try_for_each(|(name, case)| -> io::Result<()> {
      let output = tmpdir.path().join(format!("{}.output.html", name));

      let ts = Instant::now();

      run_vim(
        vec!["-S", "convert-to-html.vim", case.to_str().unwrap()],
        &output,
        test_home.path(),
        &interrupted,
      )?;

      let vim_time = ts.elapsed().as_millis() as u64;
      total_vim_time.fetch_add(vim_time, Relaxed);

      let html = fs::read_to_string(&output)?;
      res.lock().unwrap().insert(name.to_owned(), html);

      Ok(())
    })?;

  eprintln!(
    "{} total execution time: {}s.",
    VIM_BIN.to_string_lossy(),
    total_vim_time.load(Relaxed) as f64 / 1000.0
  );

  let res = res.into_inner().unwrap();

  for (name, _) in test_cases.iter() {
    eprintln!("test {}…", name);

    let output = &res[name];

    let expected = case_dir.join(format!("{}.html", name));

    if !expected.is_file() {
      eprintln!(
        "`{}` is missing, output was:\n{}",
        expected.display(),
        output
      );
      continue;
    }

    if interrupted.load(Relaxed) {
      return Err(io::Error::new(ErrorKind::Interrupted, "interrupted!"));
    }

    let expected = fs::read_to_string(expected)?;

    let diff = similar::TextDiff::from_lines(output, &expected)
      .unified_diff()
      .header("output", "expected")
      .to_string();
    if diff.is_empty() {
      eprintln!("ok");
      passed += 1;
    } else {
      eprintln!("syntax highlighting mismatch:");
      for line in diff.lines() {
        if line.starts_with(' ') {
          eprintln!("{}", line);
          continue;
        }
        let color = if line.starts_with('+') {
          "0;32"
        } else if line.starts_with('-') {
          "0;31"
        } else if line.starts_with('@') {
          "0;36"
        } else if line == "\\ No newline at end of file" {
          "0;97"
        } else {
          unimplemented!("no defined color for line: '{}'", line);
        };
        eprintln!("\x1B[{}m{}\x1B[0m", color, line);
      }
    }
  }

  if passed == total {
    Ok(())
  } else {
    Err(io::Error::other(format!(
      "{}/{} tests failed.",
      total - passed,
      total
    )))
  }
}
