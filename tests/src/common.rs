use once_cell::sync::Lazy;
use std::{
  env,
  ffi::OsString,
  fs,
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
pub use tempfile::tempdir;
use wait_timeout::ChildExt;

static VIM_BIN: Lazy<OsString> = Lazy::new(|| {
  let default_vim = OsString::from("vim");
  let v = env::var_os("TEST_VIM").unwrap_or(default_vim.clone());
  if v.is_empty() {
    default_vim
  } else {
    v
  }
});
pub static TEST_NVIM: Lazy<bool> = Lazy::new(|| {
  PathBuf::from(&*VIM_BIN)
    .file_stem()
    .unwrap()
    .to_str()
    .unwrap()
    .contains("nvim")
});
static VIM_SYMLINK: Lazy<&str> = Lazy::new(|| if *TEST_NVIM { "nvim" } else { ".vim" });

pub fn clean_dotvim_symlink() {
  if fs::metadata(*VIM_SYMLINK).is_ok() {
    fs::remove_file(*VIM_SYMLINK).unwrap();
  }
}

pub fn create_dotvim_symlink() {
  clean_dotvim_symlink();
  ufs::symlink("../", *VIM_SYMLINK).unwrap();
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
  let xdg_state_dir = tempdir().unwrap();
  let mut vim = Command::new(&*VIM_BIN)
    .arg(if *TEST_NVIM {
      "--headless"
    } else {
      "--not-a-term"
    })
    .args(["-i", "NONE", "--cmd", "set noswapfile"])
    .args(args)
    .env("OUTPUT", output)
    .env("HOME", env::current_dir().unwrap())
    .env("XDG_CONFIG_HOME", env::current_dir().unwrap())
    .env("XDG_DATA_HOME", env::current_dir().unwrap())
    .env("XDG_STATE_HOME", xdg_state_dir.path())
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
      format!(
        "{} failed with status: {}",
        if *TEST_NVIM { "Neovim" } else { "Vim" },
        status
      ),
    ))
  }
}
