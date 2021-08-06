# termare_view
The full-platform terminal emulator, developed with Flutter, is an upper-layer component rendered by canvas and does not depend on any platform code.

Language: English | [简体中文](README.md)

[Terminal Sequence Support Document](Support_Sequences.md)

This view is similar to the [xterm. Js] (https://github.com/xtermjs/xterm.js), is just an upper UI display component, you can use the terminal flow from the underlying operating system, or is connected to the SSH server terminal flow, only need to input to the components, can automatically parse rendering terminal terminal sequence.

## Start using

### introduce the project

This is a pure Flutter Package, so only needs to be introduced under YAML configuration file dependencies:

```yaml
termare_view:
  git: https://github.com/termare/termare_view
```

### Create the terminal controller

```dart
TermareController controller = TermareController(
  showBackgroundLine: true,
);
```
### Use Widget

```dart
TermareView(
  controller: controller,
),
```

### let the terminal display something
```dart
controller.write('hello termare_view');
```

The code is in Example.

## A more detailed example



## Why rewrite with Flutter instead of Android?

- Write once, run everywhere.

- Flutter is currently a very good cross-platform framework, and I think I can also use it to write a full-platform terminal emulator. From the previous generations of Android terminal emulators,
It may be a long process, and I don't have much time, but I'll try to rewrite it.
- i like to try.
> For more reasons go to my personal article ->

## Why does it not behave like an operating system native terminal emulator

It can only parse a portion of the terminal escape sequence so far, and the parsing time is limited by my code capability.

## Help with development?

### Terminal resources

- [XTerm control sequences](http://invisible-island.net/xterm/ctlseqs/ctlseqs.html)
- [vt100.net](http://vt100.net/)
- [Terminal codes (ANSI and terminfo equivalents)](http://wiki.bash-hackers.org/scripting/terminalcodes)

### Terminal emulators

- VTE (libvte): Terminal emulator widget for GTK+, mainly used in gnome-terminal.
  [Source](https://github.com/GNOME/vte), [Open Issues](https://bugzilla.gnome.org/buglist.cgi?quicksearch=product%3A%22vte%22+),
  and [All (including closed) issues](https://bugzilla.gnome.org/buglist.cgi?bug_status=RESOLVED&bug_status=VERIFIED&chfield=resolution&chfieldfrom=-2000d&chfieldvalue=FIXED&product=vte&resolution=FIXED).

- iTerm 2: OS X terminal application. [Source](https://github.com/gnachman/iTerm2),
  [Issues](https://gitlab.com/gnachman/iterm2/issues) and [Documentation](http://www.iterm2.com/documentation.html)
  (which includes [iTerm2 proprietary escape codes](http://www.iterm2.com/documentation-escape-codes.html)).

- Konsole: KDE terminal application. [Source](https://projects.kde.org/projects/kde/applications/konsole/repository),
  in particular [tests](https://projects.kde.org/projects/kde/applications/konsole/repository/revisions/master/show/tests),
  [Bugs](https://bugs.kde.org/buglist.cgi?bug_severity=critical&bug_severity=grave&bug_severity=major&bug_severity=crash&bug_severity=normal&bug_severity=minor&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&product=konsole)
  and [Wishes](https://bugs.kde.org/buglist.cgi?bug_severity=wishlist&bug_status=UNCONFIRMED&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED&product=konsole).

- hterm: JavaScript terminal implementation from Chromium. [Source](https://github.com/chromium/hterm),
  including [tests](https://github.com/chromium/hterm/blob/master/js/hterm_vt_tests.js),
  and [Google group](https://groups.google.com/a/chromium.org/forum/#!forum/chromium-hterm).

- xterm: The grandfather of terminal emulators.
  [Source](http://invisible-island.net/datafiles/release/xterm.tar.gz).

- Connectbot: Android SSH client. [Source](https://github.com/connectbot/connectbot)

- Android Terminal Emulator: Android terminal app which Termux terminal handling
  is based on. Inactive. [Source](https://github.com/jackpal/Android-Terminal-Emulator).

- termux: Android terminal and Linux environment - app repository.
 [Source](https://github.com/termux/termux-app).
