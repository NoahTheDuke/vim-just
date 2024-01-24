mod common;
use crate::common::*;

use clap::Parser;
use fancy_regex::Regex;
use rayon::prelude::*;
use scraper::{Html, Selector};
use std::{
  env,
  ffi::OsStr,
  fs,
  io::{self, ErrorKind},
  path::{Path, PathBuf},
  process::{Command, Stdio},
  sync::{
    atomic::{AtomicU64, Ordering::Relaxed},
    Arc,
  },
  time::{Duration, Instant},
};
use wait_timeout::ChildExt;

#[derive(Parser)]
struct Arguments {
  #[arg(name = "PATTERN", help = "Only run tests that match <PATTERN>")]
  filter: Option<Regex>,
}

fn _main() -> io::Result<()> {
  let arguments = Arguments::parse();

  let interrupted = setup_ctrlc_handler();

  let tempdir = tempfile::tempdir().unwrap();

  let case_dir = Path::new("cases");

  create_dotvim_symlink();

  let mut cases = 0;
  let mut passed = 0;

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
            if let Some(filter) = &arguments.filter {
              if !filter.is_match(&name).unwrap() {
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

  let total_vim_time = Arc::new(AtomicU64::new(0));

  test_cases.par_iter().try_for_each(|case| {
    let (name, case) = case;

    let output = tempdir.path().join(format!("{}.output.html", name));

    let ts = Instant::now();

    let mut vim = Command::new("vim")
      .args(["--not-a-term", "-S", "convert-to-html.vim"])
      .env("CASE", case)
      .env("OUTPUT", &output)
      .env("HOME", env::current_dir().unwrap())
      .stdin(Stdio::null())
      .stdout(Stdio::null())
      .stderr(Stdio::piped())
      .spawn()
      .unwrap();

    let mut poll_count = 1;
    let status = loop {
      let poll_interval = Duration::from_millis(if poll_count % 3 == 0 { 333 } else { 100 });
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
      poll_count += 1;
    };

    if !status.success() {
      return Err(io::Error::new(
        ErrorKind::Other,
        format!("Vim failed with status: {}", status),
      ));
    }

    let vim_time = ts.elapsed().as_millis() as u64;
    total_vim_time.fetch_add(vim_time, Relaxed);

    let html = Html::parse_document(&fs::read_to_string(&output).unwrap());

    let code_element_selector = Selector::parse("#vimCodeElement").unwrap();

    let inner = html
      .select(&code_element_selector)
      .next()
      .unwrap()
      .inner_html();

    fs::write(&output, inner)
  })?;

  eprintln!(
    "Vim total execution time: {}s.",
    total_vim_time.load(Relaxed) as f64 / 1000.0
  );

  for case in test_cases.iter() {
    let name = &case.0;

    cases += 1;

    eprintln!("test {}…", name);

    let output = tempdir.path().join(format!("{}.output.html", name));
    let expected = case_dir.join(format!("{}.html", name));

    if !expected.is_file() {
      let output_content = fs::read_to_string(&output).unwrap();
      eprintln!(
        "`{}` is missing, output was:\n{}",
        expected.display(),
        output_content
      );
      continue;
    }

    let diff_output_result = Command::new("colordiff")
      .arg("--unified")
      .args(["--label", "output"])
      .arg(output)
      .args(["--label", "expected"])
      .arg(expected)
      .output();

    let diff_output = match diff_output_result {
      Ok(o) => o,
      Err(e) => {
        eprintln!("Could not run colordiff: attempt failed with \"{e}\"\nIs colordiff installed and available executable on $PATH ?");
        return Err(e);
      }
    };

    if interrupted.load(Relaxed) {
      return Err(io::Error::new(ErrorKind::Interrupted, "interrupted!"));
    }

    if diff_output.status.success() {
      eprintln!("ok");
      passed += 1;
    } else {
      if diff_output.status.code() == Some(2) {
        eprintln!("syntax highlighting mismatch:");
      } else {
        eprintln!("diff failed:");
      }
      eprint!("{}", String::from_utf8_lossy(&diff_output.stdout));
      eprint!("{}", String::from_utf8_lossy(&diff_output.stderr));
    }
  }

  if passed == cases {
    Ok(())
  } else {
    Err(io::Error::new(
      ErrorKind::Other,
      format!("{}/{} tests failed.", cases - passed, cases),
    ))
  }
}

fn main() -> io::Result<()> {
  let real_main = _main();

  // cleanup
  clean_dotvim_symlink();

  real_main
}
