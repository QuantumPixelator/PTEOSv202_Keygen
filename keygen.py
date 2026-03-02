#!/usr/bin/env python3
"""
Planets: TEOS v2.02 - Registration Key Generator
Reverse-engineered from PLANCFG.EXE (Turbo Pascal 7.0 16-bit DOS)
Keygen by Quantum Pixelator, 2026
"""

def compute_key(sysop_name: str, bbs_name: str) -> int:
    sysop = sysop_name.upper()
    bbs   = bbs_name.upper()
    seed = 4
    for i, ch in enumerate(sysop, start=1):
        c = ord(ch)
        seed += c
        if i % 2 == 0:
            seed += c // i
    for i, ch in enumerate(bbs, start=1):
        c = ord(ch)
        seed += c
        if i % 2 == 1:
            seed += i
            seed += seed // i
    if seed < 1000: seed *= 17
    if seed < 3000: seed *= 11
    if seed < 7000: seed *= 4
    return seed & 0xFFFFFFFF


def main():
    print("=" * 55)
    print("  Planets: TEOS v2.02 - Registration Key Generator")
    print("       Reverse-engineered by Quantum Pixelator    ")
    print("=" * 55)
    print()
    sysop_name = input("Sysop Real Name : ").strip()
    bbs_name   = input("BBS Name        : ").strip()
    if not sysop_name or not bbs_name:
        print("\nERROR: Both names are required.")
        return
    key = compute_key(sysop_name, bbs_name)
    print()
    print("-" * 55)
    print(f"  Registration # : {key}")
    print("-" * 55)
    print()


if __name__ == "__main__":
    main()
