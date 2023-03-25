use regex::Regex;
use scraper::{Html, Selector};
use std::{
  env,
  ffi::OsStr,
  fs, io,
  os::unix::fs as ufs,
  path::Path,
  process::{self, Command, Stdio},
};
use structopt::StructOpt;

#[derive(StructOpt)]
struct Arguments {
  #[structopt(name("PATTERN"), help("Only run tests that match <PATTERN>"))]
  filter: Option<Regex>,
}

fn main() -> io::Result<()> {
  let arguments = Arguments::from_args();

  let tempdir = tempfile::tempdir().unwrap();

  let case_dir = Path::new("cases");

  if fs::metadata(".vim").is_ok() {
    fs::remove_file(".vim").unwrap();
  }
  ufs::symlink("../", ".vim").unwrap();

  let mut cases = 0;
  let mut passed = 0;

  let mut test_cases = fs::read_dir(case_dir)?
    .map(|res| res.map(|e| e.path()))
    .collect::<Result<Vec<_>, io::Error>>()?;
  test_cases.sort_unstable();

  for case in test_cases
    .iter()
    .filter(|f| f.extension() == Some(OsStr::new("just")))
  {
    let name = case.file_stem().unwrap().to_str().unwrap();

    if let Some(filter) = &arguments.filter {
      if !filter.is_match(name) {
        continue;
      }
    }

    cases += 1;

    eprintln!("test {}…", name);

    let output = tempdir.path().join(format!("{}.output.html", name));

    let status = Command::new("vim")
      .args(["-E", "-S", "convert-to-html.vim"])
      .env("CASE", case)
      .env("OUTPUT", &output)
      .env("HOME", env::current_dir().unwrap())
      .stdout(Stdio::null())
      .status()
      .unwrap();

    if !status.success() {
      panic!("Vim failed with status: {}", status);
    }

    let html = Html::parse_document(&fs::read_to_string(&output).unwrap());

    let code_element_selector = Selector::parse("#vimCodeElement").unwrap();

    let inner = html
      .select(&code_element_selector)
      .next()
      .unwrap()
      .inner_html();

    fs::write(&output, &inner).unwrap();

    let expected = case_dir.join(format!("{}.html", name));

    if !expected.is_file() {
      eprintln!(
        "`{}` is missing, output was:\n{}",
        expected.display(),
        &inner
      );
    }

    let diff_output = Command::new("colordiff")
      .arg("--unified")
      .args(["--label", "output"])
      .arg(output)
      .args(["--label", "expected"])
      .arg(expected)
      .output()
      .unwrap();

    if diff_output.status.success() {
      eprintln!("ok");
      passed += 1;
    } else {
      if diff_output.status.code() == Some(2) {
        eprintln!("syntax highlightning mismatch:");
      } else {
        eprintln!("diff failed:");
      }
      eprint!("{}", String::from_utf8_lossy(&diff_output.stdout));
      eprint!("{}", String::from_utf8_lossy(&diff_output.stderr));
    }
  }

  fs::remove_file(".vim").unwrap();

  if passed != cases {
    process::exit(1);
  }
  Ok(())
}
