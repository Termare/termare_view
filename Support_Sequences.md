Supported Terminal Sequences
xterm.js version: 4.4.0

Table of Contents
General notes
C0
C1
CSI
DCS
ESC
OSC
General notes
This document lists xterm.js’ support of terminal sequences. The sequences are grouped by their sequence type:

C0: single byte command (7bit control codes, byte range \x00 .. \x1F, \x7F)
C1: single byte command (8bit control codes, byte range \x80 .. \x9F)
ESC: sequence starting with ESC (\x1B)
CSI - Control Sequence Introducer: sequence starting with ESC [ (7bit) or CSI (\x9B, 8bit)
DCS - Device Control String: sequence starting with ESC P (7bit) or DCS (\x90, 8bit)
OSC - Operating System Command: sequence starting with ESC ] (7bit) or OSC (\x9D, 8bit)
Application Program Command (APC), Privacy Message (PM) and Start of String (SOS) are recognized but not supported, any sequence of these types will be ignored. They are also not hookable by the API.

Note that the list only contains sequences implemented in xterm.js’ core codebase. Missing sequences are either not supported or unstable/experimental. Furthermore addons or integrations can provide additional custom sequences.

To denote the sequences the tables use the same abbreviations as xterm does:

Ps: A single (usually optional) numeric parameter, composed of one or more decimal digits.
Pm: A multiple numeric parameter composed of any number of single numeric parameters, separated by ; character(s), e.g. ` Ps ; Ps ; … `.
Pt: A text parameter composed of printable characters. Note that for most commands with Pt only ASCII printables are specified to work. Additionally the parser will let pass any codepoint greater than C1 as printable.
C0
Mnemonic	Name	Sequence	Short Description	Support
NUL	Null	\0, \x00	NUL is ignored.	✓
BEL	Bell	\a, \x07	Ring the bell. more	✓
BS	Backspace	\b, \x08	Move the cursor one position to the left.	✓
HT	Horizontal Tabulation	\t, \x09	Move the cursor to the next character tab stop.	✓
LF	Line Feed	\n, \x0A	Move the cursor one row down, scrolling if needed. more	✓
VT	Vertical Tabulation	\v, \x0B	Treated as LF.	✓
FF	Form Feed	\f, \x0C	Treated as LF.	✓
CR	Carriage Return	\r, \x0D	Move the cursor to the beginning of the row.	✓
SO	Shift Out	\x0E	Switch to an alternative character set.	Partial
SI	Shift In	\x0F	Return to regular character set after Shift Out.	✓
ESC	Escape	\e, \x1B	Start of a sequence. Cancels any other sequence.	✓
C1
Mnemonic	Name	Sequence	Short Description	Support
IND	Index	\x84	Move the cursor one line down scrolling if needed.	✓
NEL	Next Line	\x85	Move the cursor to the beginning of the next row.	✓
HTS	Horizontal Tabulation Set	\x88	Places a tab stop at the current cursor position.	✓
DCS	Device Control String	\x90	Start of a DCS sequence.	✓
CSI	Control Sequence Introducer	\x9B	Start of a CSI sequence.	✓
ST	String Terminator	\x9C	Terminator used for string type sequences.	✓
OSC	Operating System Command	\x9D	Start of an OSC sequence.	✓
PM	Privacy Message	\x9E	Start of a privacy message.	✓
APC	Application Program Command	\x9F	Start of an APC sequence.	✓
CSI
Mnemonic	Name	Sequence	Short Description	Support
ICH	Insert Characters	CSI Ps @	Insert Ps (blank) characters (default = 1). more	✓
SL	Scroll Left	CSI Ps SP @	Scroll viewport Ps times to the left. more	✓
CUU	Cursor Up	CSI Ps A	Move cursor Ps times up (default=1). more	✓
SR	Scroll Right	CSI Ps SP A	Scroll viewport Ps times to the right. more	✓
CUD	Cursor Down	CSI Ps B	Move cursor Ps times down (default=1). more	✓
CUF	Cursor Forward	CSI Ps C	Move cursor Ps times forward (default=1).	✓
CUB	Cursor Backward	CSI Ps D	Move cursor Ps times backward (default=1).	✓
CNL	Cursor Next Line	CSI Ps E	Move cursor Ps times down (default=1) and to the first column. more	✓
CPL	Cursor Backward	CSI Ps F	Move cursor Ps times up (default=1) and to the first column. more	✓
CHA	Cursor Horizontal Absolute	CSI Ps G	Move cursor to Ps-th column of the active row (default=1).	✓
CUP	Cursor Position	CSI Ps ; Ps H	Set cursor to position [Ps, Ps] (default = [1, 1]). more	✓
CHT	Cursor Horizontal Tabulation	CSI Ps I	Move cursor Ps times tabs forward (default=1).	✓
DECSED	Selective Erase In Display	CSI ? Ps J	Currently the same as ED.	Partial
ED	Erase In Display	CSI Ps J	Erase various parts of the viewport. more	✓
DECSEL	Selective Erase In Line	CSI ? Ps K	Currently the same as EL.	Partial
EL	Erase In Line	CSI Ps K	Erase various parts of the active row. less	✓
Supported param values:

Ps	Effect
0	Erase from the cursor through the end of the row.
1	Erase from the beginning of the line through the cursor.
2	Erase complete line.
IL	Insert Line	CSI Ps L	Insert Ps blank lines at active row (default=1). more	✓
DL	Delete Line	CSI Ps M	Delete Ps lines at active row (default=1). more	✓
DCH	Delete Character	CSI Ps P	Delete Ps characters (default=1). more	✓
SU	Scroll Up	CSI Ps S	Scroll Ps lines up (default=1).	✓
SD	Scroll Down	CSI Ps T	Scroll Ps lines down (default=1).	✓
ECH	Erase Character	CSI Ps X	Erase Ps characters from current cursor position to the right (default=1). more	✓
CBT	Cursor Backward Tabulation	CSI Ps Z	Move cursor Ps tabs backward (default=1).	✓
HPA	Horizontal Position Absolute	CSI Ps `	Same as CHA.	✓
HPR	Horizontal Position Relative	CSI Ps a	Same as CUF.	✓
REP	Repeat Preceding Character	CSI Ps b	Repeat preceding character Ps times (default=1). less	✓
REP repeats the previous character Ps times advancing the cursor, also wrapping if DECAWM is set. REP has no effect if the sequence does not follow a printable ASCII character (NOOP for any other sequence in between or NON ASCII characters).

DA1	Primary Device Attributes	CSI c	Send primary device attributes.	✓
DA2	Secondary Device Attributes	CSI > c	Send primary device attributes.	✓
VPA	Vertical Position Absolute	CSI Ps d	Move cursor to Ps-th row (default=1).	✓
VPR	Vertical Position Relative	CSI Ps e	Move cursor Ps times down (default=1).	✓
HVP	Horizontal and Vertical Position	CSI Ps ; Ps f	Same as CUP.	✓
TBC	Tab Clear	CSI Ps g	Clear tab stops at current position (0) or all (3) (default=0). more	✓
SM	Set Mode	CSI Pm h	Set various terminal modes. more	Partial
DECSET	DEC Private Set Mode	CSI ? Pm h	Set various terminal attributes. more	Partial
RM	Reset Mode	CSI Pm l	Set various terminal attributes. more	Partial
DECRST	DEC Private Reset Mode	CSI ? Pm l	Reset various terminal attributes. less	Partial
Supported param values by DECRST:

param	Action	Support
1	Normal Cursor Keys (DECCKM).	✓
2	Designate VT52 mode (DECANM).	✗
3	80 Column Mode (DECCOLM).	Broken
6	Normal Cursor Mode (DECOM).	✓
7	No Wraparound Mode (DECAWM).	✓
8	No Auto-repeat Keys (DECARM).	✗
9	Don’t send Mouse X & Y on button press.	✓
12	Stop Blinking Cursor.	✓
25	Hide Cursor (DECTCEM).	✓
47	Use Normal Screen Buffer.	✓
66	Numeric keypad (DECNKM).	✓
1000	Don’t send Mouse reports.	✓
1002	Don’t use Cell Motion Mouse Tracking.	✓
1003	Don’t use All Motion Mouse Tracking.	✓
1004	Don’t send FocusIn/FocusOut events.	✓
1005	Disable UTF-8 Mouse Mode.	✗
1006	Disable SGR Mouse Mode.	✓
1015	Disable urxvt Mouse Mode.	✗
1047	Use Normal Screen Buffer (clearing screen if in alt).	✓
1048	Restore cursor as in DECRC.	✓
1049	Use Normal Screen Buffer and restore cursor.	✓
2004	Reset bracketed paste mode.	✓
SGR	Select Graphic Rendition	CSI Pm m	Set/Reset various text attributes. more	Partial
DSR	Device Status Report	CSI Ps n	Request cursor position (CPR) with Ps = 6.	✓
DECDSR	DEC Device Status Report	CSI ? Ps n	Only CPR is supported (same as DSR).	Partial
DECSTR	Soft Terminal Reset	CSI ! p	Reset several terminal attributes to initial state. more	✓
DECSCUSR	Set Cursor Style	CSI Ps SP q	Set cursor style. more	✓
DECSTBM	Set Top and Bottom Margin	CSI Ps ; Ps r	Set top and bottom margins of the viewport [top;bottom] (default = viewport size).	✓
SCOSC	Save Cursor	CSI s	Save cursor position, charmap and text attributes.	Partial
SCORC	Restore Cursor	CSI u	Restore cursor position, charmap and text attributes.	Partial
DECIC	Insert Columns	CSI Ps ' }	Insert Ps columns at cursor position. more	✓
DECDC	Delete Columns	CSI Ps ' ~	Delete Ps columns at cursor position. more	✓
DCS
Mnemonic	Name	Sequence	Short Description	Support
DECRQSS	Request Selection or Setting	DCS $ q Pt ST	Request several terminal settings. more	Partial
DECUDK	User Defined Keys	DCS Ps ; Ps | Pt ST	Definitions for user-defined keys.	✗
SIXEL	SIXEL Graphics	DCS Ps ; Ps ; Ps ; q Pt ST	Draw SIXEL image starting at cursor position.	✗
XTGETTCAP	Request Terminfo String	DCS + q Pt ST	Request Terminfo String.	✗
XTSETTCAP	Set Terminfo Data	DCS + p Pt ST	Set Terminfo Data.	✗
ESC
Mnemonic	Name	Sequence	Short Description	Support
SC	Save Cursor	ESC 7	Save cursor position, charmap and text attributes.	✓
DECALN	Screen Alignment Pattern	ESC # 8	Fill viewport with a test pattern (E).	✓
RC	Restore Cursor	ESC 8	Restore cursor position, charmap and text attributes.	✓
IND	Index	ESC D	Move the cursor one line down scrolling if needed.	✓
NEL	Next Line	ESC E	Move the cursor to the beginning of the next row.	✓
HTS	Horizontal Tabulation Set	ESC H	Places a tab stop at the current cursor position.	✓
IR	Reverse Index	ESC M	Move the cursor one line up scrolling if needed.	✓
DCS	Device Control String	ESC P	Start of a DCS sequence.	✓
CSI	Control Sequence Introducer	ESC [	Start of a CSI sequence.	✓
ST	String Terminator	ESC \	Terminator used for string type sequences.	✓
OSC	Operating System Command	ESC ]	Start of an OSC sequence.	✓
PM	Privacy Message	ESC ^	Start of a privacy message.	✓
APC	Application Program Command	ESC _	Start of an APC sequence.	✓
OSC
Note: Other than listed in the table, the parser recognizes both ST (ECMA-48) and BEL (xterm) as OSC sequence finalizer.

Identifier	Sequence	Short Description	Support
0	OSC 0 ; Pt BEL	Set window title and icon name. more	Partial
1	OSC 1 ; Pt BEL	Set icon name.	✗
2	OSC 2 ; Pt BEL	Set window title. more	✓