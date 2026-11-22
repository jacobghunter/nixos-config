#!/usr/bin/env python3
"""Package app/ into a webOS .ipk (stdlib + `ar` only, no ares-cli needed).

Usage: ./build.py [output-dir]   (default: this directory)
Install: scp the .ipk to the TV, then over `ssh -t tv`:
  luna-send -i luna://com.webos.appInstallService/dev/install \
    '{"id":"com.ares.defaultName","ipkUrl":"/tmp/<file>.ipk","subscribe":true}'
"""
import io
import json
import struct
import subprocess
import sys
import tarfile
import tempfile
import zlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
APP = HERE / "app"


def png(size):
    """Dark rounded tile with a 3x3 dot grid (middle row lit)."""
    ss = 4  # supersampling for smooth edges
    big = size * ss
    radius = big * 0.22
    dot = big * 0.075
    centers = [big * f for f in (0.28, 0.5, 0.72)]
    rows = []
    for y in range(size):
        row = bytearray([0])
        for x in range(size):
            acc = [0, 0, 0, 0]
            for sy in range(ss):
                for sx in range(ss):
                    px, py = x * ss + sx + 0.5, y * ss + sy + 0.5
                    # rounded-rect mask
                    cx = min(max(px, radius), big - radius)
                    cy = min(max(py, radius), big - radius)
                    if (px - cx) ** 2 + (py - cy) ** 2 > radius**2:
                        continue
                    color = (20, 20, 20)
                    for j, gy in enumerate(centers):
                        for gx in centers:
                            if (px - gx) ** 2 + (py - gy) ** 2 <= dot**2:
                                color = (240, 240, 240) if j == 1 else (110, 110, 110)
                    acc[0] += color[0]
                    acc[1] += color[1]
                    acc[2] += color[2]
                    acc[3] += 255
            n = ss * ss
            alpha = acc[3] // n
            cov = max(acc[3] // 255, 1)
            row += bytes([acc[0] // cov, acc[1] // cov, acc[2] // cov, alpha])
        rows.append(bytes(row))

    def chunk(kind, data):
        body = kind + data
        return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body))

    header = struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(b"".join(rows), 9))
        + chunk(b"IEND", b"")
    )


def targz(entries):
    """entries: list of (archive name, bytes, mode)."""
    buf = io.BytesIO()
    with tarfile.open(fileobj=buf, mode="w:gz", format=tarfile.GNU_FORMAT) as tar:
        dirs = set()
        for name, _, _ in entries:
            parts = name.split("/")[:-1]
            for i in range(1, len(parts) + 1):
                dirs.add("/".join(parts[:i]))
        for d in sorted(dirs):
            info = tarfile.TarInfo(d)
            info.type, info.mode = tarfile.DIRTYPE, 0o755
            tar.addfile(info)
        for name, data, mode in entries:
            info = tarfile.TarInfo(name)
            info.size, info.mode = len(data), mode
            tar.addfile(info, io.BytesIO(data))
    return buf.getvalue()


def main():
    out_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else HERE
    info = json.loads((APP / "appinfo.json").read_text())
    app_id, version = info["id"], info["version"]

    for name, size in (("icon.png", 80), ("largeIcon.png", 130)):
        if not (APP / name).exists():
            (APP / name).write_bytes(png(size))

    prefix = f"./usr/palm/applications/{app_id}"
    files = sorted(p for p in APP.rglob("*") if p.is_file())
    data = targz([(f"{prefix}/{p.relative_to(APP)}", p.read_bytes(), 0o644) for p in files])
    control = targz([(
        "./control",
        (
            f"Package: {app_id}\nVersion: {version}\nSection: misc\nPriority: optional\n"
            f"Architecture: all\nInstalled-Size: {sum(p.stat().st_size for p in files) // 1024 + 1}\n"
            f"Maintainer: {info['vendor']}\nDescription: {info['title']}\nwebOS-Package-Format-Version: 2\n"
            "webOS-Packager-Version: x.y.x\n"
        ).encode(),
        0o644,
    )])

    ipk = out_dir / f"{app_id}_{version}_all.ipk"
    ipk.unlink(missing_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        (tmp / "debian-binary").write_text("2.0\n")
        (tmp / "control.tar.gz").write_bytes(control)
        (tmp / "data.tar.gz").write_bytes(data)
        subprocess.run(
            ["ar", "rc", str(ipk), "debian-binary", "control.tar.gz", "data.tar.gz"],
            cwd=tmp,
            check=True,
        )
    print(ipk)


if __name__ == "__main__":
    main()
