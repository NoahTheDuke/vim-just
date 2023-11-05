use std::{
  fs,
  os::unix::fs as ufs,
  sync::{
    atomic::{AtomicBool, Ordering::Relaxed},
    Arc,
  },
};

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
