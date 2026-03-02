# Planets: TEOS v2.02 — Registration Keygen

A registration key generator for **Planets: TEOS v2.02**, a 1994 DOS BBS door game by Seth Able Robinson.

## Usage

Run **`keygen.exe`** — no installation required.

1. Enter the **Sysop Real Name** exactly as you will type it in `PLANCFG.EXE`
2. Enter the **BBS Name** exactly as you will type it in `PLANCFG.EXE`
3. Click **Generate Key**
4. Enter the resulting number as the **Registration #** in `PLANCFG.EXE`

Names are case-insensitive — the game uppercases them before checking.

---

## How the algorithm works

The key is computed entirely from the two names.  
No server, no random seed, no date — the same names always produce the same key.

The algorithm was reverse-engineered from function `148D:0000` inside `PLANCFG.EXE`
(a Turbo Pascal 7.0 16-bit DOS executable).

### Step 1 — Uppercase both names

The game converts both names to uppercase before doing any math, so
`"sysop"` and `"SYSOP"` produce identical keys.

### Step 2 — Walk the Sysop name

Start with `seed = 4`.  
For each character (1-indexed):

- Always add the character's ASCII value to `seed`
- If the index is **even**, also add `ascii_value ÷ index` (integer division)

```
seed += ord(ch)
if index % 2 == 0:
    seed += ord(ch) // index
```

### Step 3 — Walk the BBS name

For each character (1-indexed):

- Always add the character's ASCII value to `seed`
- If the index is **odd**, add the index, then add `seed ÷ index` (using the already-updated seed)

```
seed += ord(ch)
if index % 2 == 1:
    seed += index
    seed += seed // index
```

### Step 4 — Scale up small values

After both loops, the seed is multiplied up if it hasn't grown large enough:

| Condition   | Action      |
|-------------|-------------|
| seed < 1000 | multiply × 17 |
| seed < 3000 | multiply × 11 |
| seed < 7000 | multiply × 4  |

The checks are applied in order on the running value, so a very small seed
can be multiplied by more than one factor.

### Step 5 — The result is the registration code

The final 32-bit value is the number you enter in `PLANCFG.EXE`.

---

## Files

| File | Description |
|------|-------------|
| `keygen.exe` | Win64 GUI keygen — just run it |
| `keygen.pas` | Free Pascal source (FPC 3.2.2, Win32 API) |
| `keygen.py` | Python command-line version |

## Building from source

Requires [Free Pascal Compiler](https://www.freepascal.org/) (tested with 3.2.2):

```bat
fpc keygen.pas -WG -O2 -Xs
```

## Why I did this

I ordered valid keys from GamePort and have not received any response or keys. In case there are others who want VALID KEYS with their own information (bbs name/sysop/valid key), I'm posting this on Github. 

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for the full text.
