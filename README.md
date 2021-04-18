# termare_view

Language: 中文简体 | [English](README-EN.md)

支持全平台的终端模拟器，使用 Flutter 开发，是一个通过 canvas 渲染的上层组件，不依赖任何平台代码。

[终端序列支持文档](Support_Sequences.md)

这个 view 就类似于 [xterm.js](https://github.com/xtermjs/xterm.js) 一样，仅仅是一个上层 UI 显示组件，你可以使用来自操作系统底层的终端流，亦或者是连接 ssh 服务器的终端流，只需要给这个组件输入，就能自动的解析终端序列渲染终端。

对于这个组件有问题的

## 开始使用

### 引入项目

这是一个纯 flutter package，所以只需要在 yaml 配置文件的 dependencies 下引入:

```dart
termare_view:
  git: https://github.com/termare/termare_view
```

### 创建终端控制器

```dart
TermareController controller = TermareController(
  showBackgroundLine: true,
);
```
### 使用组件

TermareView 是一个 Widget，通常情况下，只需要给一个 TermareController 作为终端组件的控制器即可。

```dart
TermareView(
  controller: controller,
),
```

### 让终端显示一些东西

```dart
controller.write('hello termare_view');
```

代码在 example 中。
## 更详细的例子

- [termare_pty](https://github.com/termare/termare_pty)
- [termare_ssh](https://github.com/termare/termare_ssh)

## 为何要用Flutter重写而不是安卓原生？

- 一次编写，到处运行。
- Flutter 当前作为非常优秀的跨平台框架，我想也能用它来编写一个全平台终端模拟器，从安卓前几代终端模拟器来看，
这可能是一个比较漫长的过程，而我的时间并不太多，但我会尽量尝试重写。
- 我喜欢尝试。

更多原因请移步个人文章

- [Flutter 终端模拟器探索篇（一）| 简易终端模拟器](https://juejin.cn/post/6844904065889992712)
- [Flutter 终端模拟器探索篇（二）| 完整终端模拟器](https://juejin.cn/post/6844904082155503629)
- [Flutter 终端模拟器探索篇（三）| 原理解析与集成](https://juejin.cn/post/6844904194525102087)
- [Flutter 终端模拟器组件 - 开源篇](https://juejin.cn/post/6906039308424052743)

## 是否存在未适配的序列？

我已经参考 xterm.js 中支持的序列，大部分序列均已适配，但仍有极个别较难的序列存在问题。

## 帮助开发？

测试序列可以通过输入指定的序列对比 xterm.js 或者操作系统中本地终端的显示。

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
