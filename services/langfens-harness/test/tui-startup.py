"""Offline PTY startup probe; never submits a model prompt."""
import fcntl
import json
import os
from pathlib import Path
import pty
import select
import signal
import struct
import subprocess
import sys
import tempfile
import termios
import time

with tempfile.TemporaryDirectory(prefix="tui-probe-", dir=os.environ["LANGFENS_HARNESS_RUNTIME_DIR"]) as directory:
    marker = Path(directory) / "ready"
    extension = Path(directory) / "ready.mjs"
    extension.write_text(
        "import {writeFileSync} from 'node:fs';\n"
        "export default pi => pi.on('session_start', () => writeFileSync("
        + json.dumps(str(marker)) + ", 'ready'));\n"
    )
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 35, 120, 0, 0))
    container = sys.argv[1] == "--container"
    command = (
        [sys.argv[2], "run", "--rm", "--network", "none", "-it", sys.argv[3], "--offline", "--no-session", "--no-approve", "--no-extensions"]
        if container else
        [sys.argv[1], sys.argv[2], "--offline", "--no-session", "--no-approve", "--no-extensions", "--extension", str(extension)]
    )
    child = subprocess.Popen(command, stdin=slave, stdout=slave, stderr=slave, start_new_session=True)
    os.close(slave)
    output = b""
    try:
        ready = False
        started = time.monotonic()
        deadline = started + 10
        while time.monotonic() < deadline and child.poll() is None:
            readable, _, _ = select.select([master], [], [], 0.1)
            if readable:
                try:
                    output += os.read(master, 65536)
                except OSError:
                    break
            ready = (b"commands" in output and time.monotonic() - started > 1.0) if container else marker.exists()
            if ready and b"1.4.0" in output:
                break
        assert ready and b"1.4.0" in output, output.decode(errors="replace")
        assert b"HOST_" not in output and b"Network access is forbidden" not in output, output.decode(errors="replace")
        os.write(master, b"\x04")  # Empty-editor Ctrl-D, not a user/model prompt.
        child.wait(timeout=3)
        assert child.returncode == 0, output.decode(errors="replace")
        print("TUI startup OK")
    finally:
        if child.poll() is None:
            os.killpg(child.pid, signal.SIGKILL)
            child.wait()
        os.close(master)
