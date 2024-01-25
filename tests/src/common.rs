use std::{
  env, fs,
  io::{self, ErrorKind},
  os::unix::fs as ufs,
  path::PathBuf,
  process::{Command, Stdio},
  sync::{
    atomic::{AtomicBool, Ordering::Relaxed},
    Arc,
  },
  time::Duration,
};
use wait_timeout::ChildExt;

pub fn clean_dotvim_symlink() {
  if fs::metadata(".vim").is_ok() {
    fs::remove_file(".vim").unwrap();
  }
}

pub fn create_dotvim_symlink() {
  clean_dotvim_symlink();
  ufs::symlink("../", ".vim").unwrap();
}

pub fn setup_ctrlc_handler() -> Arc<AtomicBool> {
  let interrupted = Arc::new(AtomicBool::new(false));
  let _interrupted = Arc::clone(&interrupted);

  ctrlc::set_handler(move || {
    _interrupted.store(true, Relaxed);
    eprintln!("Received Ctrl+C");
  })
  .unwrap();

  interrupted
}

pub fn run_vim(args: Vec<&str>, output: &PathBuf, interrupted: &Arc<AtomicBool>) -> io::Result<()> {
  let mut vim = Command::new("vim")
    .arg("--not-a-term")
    .args(args)
    .env("OUTPUT", output)
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

  if status.success() {
    Ok(())
  } else {
    Err(io::Error::new(
      ErrorKind::Other,
      format!("Vim failed with status: {}", status),
    ))
  }
}
