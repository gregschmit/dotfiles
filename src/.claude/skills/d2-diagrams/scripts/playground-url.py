#!/usr/bin/env python3
"""Generate a D2 playground URL from a .d2 file.

Usage: python3 playground-url.py <file.d2>

Encodes the D2 source using deflate + base64url (matching the playground's
urlenc package) and prints the playground URL.
"""
import sys
import zlib
import base64


def encode(script: str) -> str:
    """Encode D2 script the same way play.d2lang.com does: deflate + base64url."""
    # Compress with raw deflate (wbits=-15 = no zlib/gzip header)
    # Using max compression to match flate.BestCompression
    compressed = zlib.compress(script.encode("utf-8"), level=9)
    # zlib.compress adds a 2-byte header and 4-byte checksum; strip them
    # to get raw deflate like Go's compress/flate
    raw_deflate = compressed[2:-4]
    return base64.urlsafe_b64encode(raw_deflate).decode("ascii")


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <file.d2>", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    with open(path, "r") as f:
        script = f.read()

    encoded = encode(script)
    print(f"https://play.d2lang.com/?script={encoded}")


if __name__ == "__main__":
    main()
