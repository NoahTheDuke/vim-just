use std::{
  collections::HashSet,
  env,
  ffi::OsString,
  fs::canonicalize,
  io::{self, prelude::*},
  os::unix::fs as ufs,
  path::{Path, PathBuf},
  process::{Command, Stdio},
  sync::{
    Arc, LazyLock, Mutex,
    atomic::{AtomicBool, Ordering::Relaxed},
  },
};
pub use tempfile::{TempDir, tempdir};

pub static VIM_BIN: LazyLock<OsString> = LazyLock::new(|| {
  let default_vim = OsString::from("vim");
  let v = env::var_os("TEST_VIM").unwrap_or(default_vim.clone());
  if v.is_empty() { default_vim } else { v }
});
static TEST_NVIM: LazyLock<bool> = LazyLock::new(|| {
  PathBuf::from(&*VIM_BIN)
    .file_stem()
    .unwrap()
    .to_str()
    .unwrap()
    .contains("nvim")
});

static VIM_PIDS: LazyLock<Mutex<HashSet<rustix::process::Pid>>> =
  LazyLock::new(|| Mutex::new(HashSet::new()));

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
    for pid in VIM_PIDS.lock().unwrap().iter() {
      // Vim might not quit on SIGTERM
      rustix::process::kill_process(*pid, rustix::process::Signal::KILL).unwrap();
    }
  })
  .unwrap();

  interrupted
}

pub fn run_vim(args: Vec<&str>, output: &PathBuf, home: &Path) -> io::Result<()> {
  let mut vim = match Command::new(&*VIM_BIN)
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
  {
    Ok(o) => o,
    Err(e) => {
      eprintln!("Failed to start {:?} subprocess", VIM_BIN.to_string_lossy());
      return Err(e);
    }
  };

  let vim_pid = rustix::process::Pid::from_child(&vim);
  {
    let mut vim_pid_map = VIM_PIDS.lock().unwrap();
    assert!(!vim_pid_map.contains(&vim_pid));
    vim_pid_map.insert(vim_pid);
  }

  let mut vim_stdin = vim.stdin.take().unwrap();
  // Prevent stalling on "Press ENTER or type command to continue"
  if let Err(e) = vim_stdin.write_all(b"\r") {
    // If we return this error, the Vim process will never be waited on in the error case,
    // resulting in `clippy::zombie_processes` lint flagging the above call to `.spawn()`.
    // To avoid stray processes, don't return this error, try to terminate the Vim process
    // but unconditionally fall through to the .wait_timeout() below
    // so that the Vim process is always waited on.
    eprintln!("Error writing to subprocess stdin: {e}");
    if let Err(e) = vim.kill() {
      eprintln!("Error sending signal to subprocess: {e}");
    }
  }

  let status = vim.wait()?;

  VIM_PIDS.lock().unwrap().remove(&vim_pid);

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
