#!/usr/bin/env python3
"""Record docs/demo-<kit>.mp4 of a live LÖVE coding turn.

Agent workspace is /tmp/demo so the write/run stay off the repo.

Same idea as fun-coding-agent/scripts/record-demo.py: type a real task,
capture the live window (XGetImage), overlay the white-outline pointer,
and keep the mouse moving while the agent works.

    PYTHONPATH=$HOME/demo python3 scripts/record-demo.py aladdin
    PYTHONPATH=$HOME/demo python3 scripts/record-demo.py --all
"""
from __future__ import annotations

import json
import math
import os
import shutil
import signal
import socket
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LOVE_DIR = ROOT / "love2d"
WS = Path(os.environ.get("ARCADE_WORKSPACE", "/tmp/demo"))
KITS = ("ghost", "invader", "frog", "ship", "dog", "cat", "aladdin", "harry")
TITLE = "Arcade Coder"
FPS = int(os.environ.get("FPS", "15"))
MAX_SEC = float(os.environ.get("DURATION", "90"))
HOST = os.environ.get("ARCADE_HOST", "127.0.0.1")
PORT = int(os.environ.get("ARCADE_PORT", "8765"))
URL = os.environ.get("ARCADE_AGENT", f"http://{HOST}:{PORT}/")

PROMPT = "write hi.py that prints PLAYER 1 READY then HI-SCORE ARCADE CODER, then run it with python3"

os.environ.setdefault("DISPLAY", ":0.0")
os.environ.setdefault("XAUTHORITY", str(Path.home() / ".Xauthority"))
os.environ.pop("ARCADE_DEMO", None)
sys.path[:0] = [str(Path.home() / "demo")]

from record.window import WindowRecord  # noqa: E402


def find_love() -> str:
    for name in ("love", "love.exe", "lovec"):
        p = shutil.which(name)
        if p:
            return p
    extras = [
        str(Path.home() / "Downloads/squashfs-root/bin/love"),
        "/usr/bin/love",
        "/usr/local/bin/love",
        "/opt/homebrew/bin/love",
        "/Applications/love.app/Contents/MacOS/love",
    ]
    for p in extras:
        if os.path.isfile(p) and os.access(p, os.X_OK):
            return p
    print("need LÖVE 11 on PATH", file=sys.stderr)
    sys.exit(1)


def stop(proc: subprocess.Popen | None) -> None:
    if proc is None or proc.poll() is not None:
        return
    proc.send_signal(signal.SIGTERM)
    try:
        proc.wait(timeout=4)
    except subprocess.TimeoutExpired:
        proc.kill()


def port_open(host: str, port: int) -> bool:
    s = socket.socket()
    s.settimeout(0.3)
    try:
        s.connect((host, port))
        return True
    except OSError:
        return False
    finally:
        s.close()


def http_json(path: str, timeout: float = 3.0) -> dict:
    req = urllib.request.Request(URL.rstrip("/") + path, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.loads(r.read().decode())
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, OSError):
        return {}


def post(path: str, payload: dict | None = None, timeout: float = 8.0) -> dict:
    data = json.dumps(payload or {}).encode()
    req = urllib.request.Request(
        URL.rstrip("/") + path,
        data=data,
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            raw = r.read().decode()
            return json.loads(raw) if raw else {}
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError, OSError, ValueError):
        return {}


def prepare_workspace() -> None:
    WS.mkdir(parents=True, exist_ok=True)
    for p in WS.iterdir():
        if p.is_file() and p.suffix in {".py", ".txt", ".md"}:
            try:
                p.unlink()
            except OSError:
                pass


def free_port() -> int:
    """Don't steal 8765. Another project may already be serving files there."""
    if not port_open(HOST, PORT):
        return PORT
    for p in range(PORT + 1, PORT + 20):
        if not port_open(HOST, p):
            return p
    print(f"no free port near {PORT}", file=sys.stderr)
    sys.exit(1)


def ensure_fighter() -> subprocess.Popen[bytes] | None:
    global PORT, URL
    PORT = free_port()
    URL = f"http://{HOST}:{PORT}/"
    env = os.environ.copy()
    env["PYTHONPATH"] = str(ROOT) + os.pathsep + env.get("PYTHONPATH", "")
    proc = subprocess.Popen(
        [
            sys.executable,
            "-m",
            "fighter",
            "--name",
            "Arcade Coder",
            "--callsign",
            "ARCADE",
            "--instructions",
            "You are Arcade Coder. Short replies. Write the file, run it with python3 (not python — it is not on PATH), then stop.",
            "--workspace",
            str(WS),
            "--host",
            HOST,
            "--port",
            str(PORT),
            "--no-browser",
        ],
        cwd=str(ROOT),
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    deadline = time.time() + 8
    while time.time() < deadline:
        if port_open(HOST, PORT):
            return proc
        if proc.poll() is not None:
            break
        time.sleep(0.15)
    return proc


def wait_ready(secs: float = 20.0) -> dict:
    deadline = time.time() + secs
    last: dict = {}
    while time.time() < deadline:
        last = http_json("/api/status")
        if last.get("logged_in"):
            return last
        time.sleep(0.3)
    print(f"fighter not logged in: {last}", file=sys.stderr)
    sys.exit(1)


def figure8(t: float, cx: float, cy: float, rx: float, ry: float) -> tuple[float, float]:
    return cx + rx * math.sin(t), cy + ry * math.sin(2 * t) * 0.55


def demo_path(kit: str) -> Path:
    if os.environ.get("DEMO_OUT"):
        return Path(os.environ["DEMO_OUT"])
    return ROOT / "docs" / f"demo-{kit}.mp4"


def parse_kits(argv: list[str]) -> list[str]:
    args = [a for a in argv[1:] if not a.startswith("-")]
    if "--all" in argv or os.environ.get("ARCADE_KITS") == "all":
        return list(KITS)
    if args:
        return args
    kit = os.environ.get("ARCADE_KIT", "aladdin")
    return [kit]


def window_size() -> tuple[int, int]:
    """LÖVE window pixels, not the 640x360 game canvas."""
    try:
        out = subprocess.check_output(
            ["xwininfo", "-name", TITLE],
            stderr=subprocess.DEVNULL,
            text=True,
            timeout=2,
        )
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, FileNotFoundError):
        return 1280, 720
    w = h = 0
    for line in out.splitlines():
        if "Width:" in line:
            w = int(line.split()[-1])
        elif "Height:" in line:
            h = int(line.split()[-1])
    return (w or 1280, h or 720)


def record_kit(kit: str, love: str) -> int:
    out = demo_path(kit)
    out.parent.mkdir(parents=True, exist_ok=True)
    prepare_workspace()
    subprocess.run(
        ["pkill", "-f", f"{love} {LOVE_DIR}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    time.sleep(0.25)
    fighter = ensure_fighter()
    wait_ready()
    post("/api/new")
    time.sleep(0.3)
    env = os.environ.copy()
    env.pop("ARCADE_DEMO", None)
    env["ARCADE_AGENT"] = URL
    env["ARCADE_KIT"] = kit
    proc = subprocess.Popen(
        [love, str(LOVE_DIR)],
        cwd=str(LOVE_DIR),
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    try:
        # Type the first half before ffmpeg opens, so the clip starts mid-sentence.
        half = len(PROMPT) // 2
        gate = threading.Event()
        WindowRecord._capture_gate = gate
        try:
            with WindowRecord(
                TITLE,
                out,
                fps=FPS,
                max_sec=MAX_SEC + 8,
                min_w=640,
                min_h=360,
                hide_cursor=True,
                overlay_pointer=True,
            ) as rec:
                rec.hold(0.8)
                rec.focus()
                ww, wh = window_size()
                # composer is the bottom HUD bar; click it before the first letter
                rec.click(ww * 0.5, wh - 36)
                rec.hold(0.35)
                rec.type_text(PROMPT[:half], delay=0.045)
                rec.hold(0.15)
                gate.set()
                rec.hold(0.35)
                rec.type_text(PROMPT[half:], delay=0.045)
                rec.hold(0.4)
                rec.key("Return")
                rec.hold(0.5)
                t0 = time.monotonic()
                idle = 0.0
                saw_busy = False
                while time.monotonic() - t0 < MAX_SEC:
                    u = (time.monotonic() - t0) * 0.55
                    x, y = figure8(u, 640, 340, 260, 100)
                    rec.move(x, y)
                    st = http_json("/api/status")
                    busy = bool(st.get("busy"))
                    if busy:
                        idle = 0.0
                        saw_busy = True
                    elif saw_busy:
                        idle += 0.12
                        if idle >= 4.0:
                            rec.hold(0.6)
                            break
                    time.sleep(0.12)
                if not saw_busy:
                    print("agent never went busy — keys may have missed the composer", file=sys.stderr)
        finally:
            WindowRecord._capture_gate = None
        if not out.is_file() or out.stat().st_size < 1000:
            print(f"{out} missing or tiny", file=sys.stderr)
            return 1
        print(out, out.stat().st_size)
        return 0
    finally:
        stop(proc)
        if fighter is not None:
            stop(fighter)


def main() -> int:
    kits = parse_kits(sys.argv)
    love = find_love()
    rc = 0
    for kit in kits:
        print(f"recording {kit} -> {demo_path(kit)}", file=sys.stderr)
        n = record_kit(kit, love)
        if n != 0:
            rc = n
    return rc


if __name__ == "__main__":
    raise SystemExit(main())
