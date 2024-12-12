use std::{
  env,
  ffi::OsString,
  fs::canonicalize,
  io::{self, prelude::*, ErrorKind},
  os::unix::fs as ufs,
  path::{Path, PathBuf},
  process::{Command, Stdio},
  sync::{
    atomic::{AtomicBool, Ordering::Relaxed},
    Arc, LazyLock,
  },
  time::Duration,
};
pub use tempfile::{tempdir, TempDir};
use wait_timeout::ChildExt;

pub static VIM_BIN: LazyLock<OsString> = LazyLock::new(|| {
  let default_vim = OsString::from("vim");
  let v = env::var_os("TEST_VIM").unwrap_or(default_vim.clone());
  if v.is_empty() {
    default_vim
  } else {
    v
  }
});
static TEST_NVIM: LazyLock<bool> = LazyLock::new(|| {
  PathBuf::from(&*VIM_BIN)
    .file_stem()
    .unwrap()
    .to_str()
    .unwrap()
    .contains("nvim")
});

pub fn test_vim_home() -> TempDir {
  let test_home = tempdir().unwrap();
  ufs::symlink(
    canonicalize("..").unwrap(),
    test_home
      .path()
      .join(if *TEST_NVIM { "nvim" } else { ".vim" }),
  )
  .unwrap();
  test_home
}

pub fn setup_ctrlc_handler() -> Arc<AtomicBool> {
  let interrupted = Arc::new(AtomicBool::new(false));
  let interrupted_ = Arc::clone(&interrupted);

  ctrlc::set_handler(move || {
    interrupted_.store(true, Relaxed);
    eprintln!("Received Ctrl+C");
  })
  .unwrap();

  interrupted
}

pub fn run_vim(
  args: Vec<&str>,
  output: &PathBuf,
  home: &Path,
  interrupted: &Arc<AtomicBool>,
) -> io::Result<()> {
  let mut vim = Command::new(&*VIM_BIN)
    .arg(if *TEST_NVIM {
      "--headless"
    } else {
      "--not-a-term"
    })
    .args(["-i", "NONE", "--cmd", "set noswapfile"])
    .args(args)
    .env("OUTPUT", output)
    .env("HOME", home)
    .env("XDG_CONFIG_HOME", home)
    .env("XDG_DATA_HOME", home)
    .stdin(Stdio::piped())
    .stdout(Stdio::null())
    .stderr(Stdio::piped())
    .spawn()
    .unwrap();

  let mut vim_stdin = vim.stdin.take().unwrap();
  // Prevent stalling on "Press ENTER or type command to continue"
  if let Err(e) = vim_stdin.write_all(b"\r") {
    // If we return this error, the Vim process will never be waited on in the error case,
    // resulting in `clippy::zombie_processes` lint flagging the above call to `.spawn()`.
    // To avoid stray processes, don't return this error, try to terminate the Vim process
    // but unconditionally fall through to the .wait_timeout() below
    // so that the Vim process is always waited on.
    eprintln!("Error writing to subprocess stdin: {}", e);
    if let Err(e) = vim.kill() {
      eprintln!("Error sending signal to subprocess: {}", e);
    }
  }

  let status = loop {
    let poll_interval = Duration::from_millis(200);
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

  if status.success() {
    Ok(())
  } else {
    Err(io::Error::other(format!(
      "{} failed with status: {}",
      VIM_BIN.to_string_lossy(),
      status
    )))
  }
}
