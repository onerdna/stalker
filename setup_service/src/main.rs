use std::fs::OpenOptions;
use std::{
    io::Write,
    process::{Command, Stdio},
};
use std::{
    io::{BufRead, BufReader},
    thread,
    time::Duration,
};

use anyhow::Result;
use anyhow::{anyhow, Context};
use log::{error, info};
use pretty_env_logger::formatted_builder;

const TARGET_PACKAGE: &str = "com.nekki.shadowfight";
const LOOKUP_STRING: &str = "PlatformAndDeviceUID=and_";
const USERID_FILE_PATH: &str = "/sdcard/Android/data/com.onerdna.stalker/files/.userid";

fn pid_of(package: &str) -> Result<String> {
    let output = Command::new("pidof")
        .args([package])
        .output()
        .context("failed to spawn pidof process")?;

    if !output.stderr.is_empty() {
        let stderr = String::from_utf8(output.stderr)
            .context("while trying to get UTF-8 representation of pidof stderr")?;
        Err(anyhow!(stderr))
    } else if output.stdout.is_empty() {
        Err(anyhow!("stdout of pidof is empty"))
    } else {
        Ok(String::from_utf8(output.stdout)
            .context("while trying to get UTF-8 representation of pidof stdout")?
            .trim()
            .to_string())
    }
}

fn init_logging() {
    let mut builder = formatted_builder();
    builder.filter_level(log::LevelFilter::Trace);
    builder.init();
}

fn kill_game() -> anyhow::Result<()> {
    Command::new("am")
        .args(["force-stop", TARGET_PACKAGE])
        .spawn()
        .context("while spawning am force-stop TARGET_PACKAGE")?;
    Ok(())
}

fn wait_for_game() -> Option<String> {
    let mut tries: u16 = 0;
    let result: Option<String> = loop {
        info!("waiting for process to start, tries {}", tries);
        let result = pid_of(TARGET_PACKAGE);

        if let Ok(pid) = result {
            break Some(pid);
        }
        tries += 1;
        if tries > 120 {
            break None;
        }
        thread::sleep(Duration::from_secs(1));
    };
    result
}

fn extract_userid(pid: &str) -> Result<Option<String>> {
    let arg = format!("--pid={}", pid.trim());
    let mut child = Command::new("logcat")
        .arg(arg)
        .stdout(Stdio::piped())
        .spawn()
        .context("while spawning logcat process")?;

    let stdout = child
        .stdout
        .take()
        .context("while calling stdout.take() of logcat process")?;
    let reader = BufReader::new(stdout);

    for line in reader.lines().map_while(Result::ok) {
        if line.contains(LOOKUP_STRING) {
            let start = line.find(LOOKUP_STRING).unwrap() + LOOKUP_STRING.len();
            let end = start + LOOKUP_STRING.len() + 16;
            let slice = &line[start..end.min(line.len())];

            return Ok(Some(slice.to_owned()));
        }
    }
    Ok(None)
}

fn write_userid(id: &str) -> anyhow::Result<()> {
    let mut file = OpenOptions::new()
        .read(true)
        .write(true)
        .create(true)
        .truncate(true)
        .open(USERID_FILE_PATH)
        .context("while opening .userid file")?;
    file.write_all(id.as_bytes())
        .context("while writing to .userid file")?;
    file.flush().context("while flushing .userid file")?;
    Ok(())
}

fn main() -> anyhow::Result<()> {
    init_logging();
    if let Err(e) = kill_game() {
        error!("while trying to kill the game: {}", e);
    };
    info!("killed the game");
    let pid = wait_for_game().context("timeout while waiting the game to start")?;
    info!("got PID of the game: {}", pid);
    let userid = extract_userid(&pid)?.context("unable to find userid in the logcat output")?;
    info!("extracted userid: {}", userid);
    write_userid(&userid)?;
    info!("written userid to {}", USERID_FILE_PATH);
    Ok(())
}
