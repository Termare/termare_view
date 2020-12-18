# Supported Terminal Sequences
xterm.js version: 4.4.0

## Table of Contents
- General notes
- C0
- C1
- CSI
- DCS
- ESC
- OSC
## General notes
This document lists xterm.js’ support of terminal sequences. The sequences are grouped by their sequence type:

- C0: single byte command (7bit control codes, byte range \x00 .. \x1F, \x7F)
- C1: single byte command (8bit control codes, byte range \x80 .. \x9F)
- ESC: sequence starting with ESC (\x1B)
- CSI - Control Sequence Introducer: sequence starting with ESC [ (7bit) or CSI (\x9B, 8bit)
- DCS - Device Control String: sequence starting with ESC P (7bit) or DCS (\x90, 8bit)
- OSC - Operating System Command: sequence starting with ESC ] (7bit) or OSC (\x9D, 8bit)
Application Program Command (APC), Privacy Message (PM) and Start of String (SOS) are recognized but not supported, any sequence of these types will be ignored. They are also not hookable by the API.

Note that the list only contains sequences implemented in xterm.js’ core codebase. Missing sequences are either not supported or unstable/experimental. Furthermore addons or integrations can provide additional custom sequences.

To denote the sequences the tables use the same abbreviations as xterm does:

- `Ps`: A single (usually optional) numeric parameter, composed of one or more decimal digits.
- `Pm`: A multiple numeric parameter composed of any number of single numeric parameters, separated by ; character(s), e.g. ` Ps ; Ps ; … `.
- `Pt`: A text parameter composed of printable characters. Note that for most commands with Pt only ASCII printables are specified to work. Additionally the parser will let pass any codepoint greater than C1 as printable.

## C0
| Mnemonic | Name | Sequence | Short Description | Support |
| :----------------------:| :----: | :----: | :----: | :----: |
| NUL | NUL | \0, \x00 | NUL is ignored.	 | ✓ |
| BEL | Bell | \b, \x07 | Ring the bell. | ✓ |
| BS | Backspace | \b, \x08 | Move the cursor one position to the left. | ✓ |
| HT | Horizontal Tabulation | \t, \x09 | Move the cursor to the next character tab stop. | ✓ |
| LF | Line Feed | \n, \x0A | Move the cursor one row down, scrolling if needed. more | ✓ |
| VT | Vertical Tabulation | \v, \x0B | Treated as LF. | ✓ |
| FF | Form Feed | \f, \x0C | Treated as LF. | ✓ |
| CR | Carriage Return | \r, \x0D | Move the cursor to the beginning of the row. | ✓ |
| SO | Shift Out | \x0E | Switch to an alternative character set.	Partial | ✗ |
| SI | Shift In | \x0F | Return to regular character set after Shift Out. | ✗ |
| ESC | Escape | \e, \x1B | Start of a sequence. Cancels any other sequence. | ✓ |

## C1
| Mnemonic | Name | Sequence | Short Description | Support |
| :----------------------:| :----: | :----: | :----: | :----: |
| IND | Index | \x84 | Move the cursor one line down scrolling if needed.	| ✓ |
| NEL | Next Line | \x85 | Move the cursor to the beginning of the next row. | ✓ |
| HTS | Horizontal Tabulation Set | \x88 | Places a tab stop at the current cursor position. | ✓ |
| DCS | Device Control String | \x90 | Start of a DCS sequence. | ✓ |
| CSI | Control Sequence Introducer | \x9B | Start of a CSI sequence. | ✓ |
| ST | String Terminator | \x9C | Terminator used for string type sequences. | ✗ |
| OSC | Operating System Command | \x9D | Start of an OSC sequence. | ✓ |
| PM | Privacy Message | \x9E | Start of a privacy message. | ✗ |
| APC | Application Program Command | \x9F | Start of an APC sequence. | ✗ |

## CSI
| Mnemonic | Name | Sequence | Short Description | Support |
| :----------------------:| :----: | :----: | :----: | :----: |
| CUU | Cursor Up | CSI Ps A | Move cursor `Ps` times up (default=1)	| ✓ |
| CUD | Cursor Down | CSI Ps B | Move cursor `Ps` times down (default=1). | ✓ |
| CUF | Cursor Forward | CSI Ps C | Move cursor `Ps` times forward (default=1). | ✓ |
| CUB | Cursor Backward | CSI Ps D | Move cursor `Ps` times backward (default=1). | ✓ |
| EL | Erase In Line | CSI Ps K | Erase various parts of the active row. | ✓ |
| SGR | Select Graphic Rendition | CSI Pm m | Set/Reset various text attributes. | ✓ |

## DCS
无

## ESC
| Mnemonic | Name | Sequence | Short Description | Support |
| :----------------------:| :----: | :----: | :----: | :----: |
| CSI | Control Sequence Introducer | ESC [ | Start of a CSI sequence.	| ✓ |
| OSC | Operating System Command | ESC ] | Start of an OSC sequence. | ✓ |
## OSC
Note: Other than listed in the table, the parser recognizes both ST (ECMA-48) and BEL (xterm) as OSC sequence finalizer.
| Identifier | Sequence | Short Description | Support |
| :----------------------:| :----: | :----: | :----: |
| 0 | OSC 0 ; Pt BEL | Set window title and icon name. more | Partial	|
| 1 | OSC 1 ; Pt BEL | Set icon name. | ✗	|
| 2 | OSC 2 ; Pt BEL | Set window title. more | ✓	|
