# termare_view

Language: 中文简体 | [English](README-EN.md)

[![Last Commits](https://img.shields.io/github/last-commit/termare/termare_view?logo=git&logoColor=white)](https://github.com/termare/termare_view/commits/master)
[![Code size](https://img.shields.io/github/languages/code-size/termare/termare_view?logo=github&logoColor=white)](https://github.com/termare/termare_view)
[![License](https://img.shields.io/github/license/termare/termare_view?logo=open-source-initiative&logoColor=green)](https://github.com/termare/termare_view/blob/master/LICENSE)

支持全平台的终端模拟器，使用 Flutter 开发，是一个通过 canvas 渲染的上层组件，不依赖任何平台代码。

[终端序列支持文档](Support_Sequences.md)

这个 view 就类似于 [xterm.js](https://github.com/xtermjs/xterm.js) 一样，仅仅是一个上层 UI 显示组件，你可以使用来自操作系统底层的终端流，亦或者是连接 ssh 服务器的终端流，只需要给这个组件输入，就能自动的解析终端序列渲染终端。

## 开始使用

### 引入项目

这是一个纯 flutter package，所以只需要在 yaml 配置文件的 dependencies 下引入:

```dart
termare_view:
  git: https://github.com/termare/termare_view
```

### 创建终端控制器

```dart
TermareController controller = TermareController();
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

## 为什么没有使用 xterm.dart

最初开发这个组件的原因是因为个人的一个项目需要在 Flutter 中集成一个终端模拟器，至今这也很好的实现了我想要的需求。
本仓库与 xterm.dart 的开始时间基本上是差不多的，我尝试将本仓库的内容合并到 xterm.dart，但最后由于代码风格
太不统一，还是决定像 termux-view 那样，单独维护一个更适应安卓端场景的终端。

但 xterm.dart 目前的很多功能是比 termare 多的，架构上的设计也更优一些。

## 更详细的例子

- [termare_pty](https://github.com/termare/termare_pty)
- [termare_ssh](https://github.com/termare/termare_ssh)

## 为何要用Flutter重写而不是...？

- 一次编写，到处运行。
- Flutter 当前作为非常优秀的跨平台框架，我想也能用它来编写一个全平台终端模拟器，从安卓前几代终端模拟器来看，
这可能是一个比较漫长的过程，而我的时间并不太多，但我会尽量尝试重写。
- 我喜欢尝试。

## 相关文章

- [Flutter 终端模拟器探索篇（一）| 简易终端模拟器](https://juejin.cn/post/6844904065889992712)
- [Flutter 终端模拟器探索篇（二）| 完整终端模拟器](https://juejin.cn/post/6844904082155503629)
- [Flutter 终端模拟器探索篇（三）| 原理解析与集成](https://juejin.cn/post/6844904194525102087)
- [Flutter 终端模拟器组件 - 开源篇](https://juejin.cn/post/6906039308424052743)
- [Flutter 终端模拟器 - 写一个 Termux，开源篇](https://juejin.cn/post/6958756311890657310)

## 是否存在未适配的序列？

按照 xterm.js 的 序列文档 适配了其中 90% 的序列，但个别序列实现比较复杂，例如 CSI ps;ps r，目前能正常解析，但在序列的行为表现上还有问题，还有个别序列没获取到具体的行为，例如ESC \。
一些命令如 vim，htop，nano，在运行的时候使用到了较多的序列，主要表现在 vim 编写文本时，内容超过终端高度时涉及到的序列。而 htop 输出的终端序列实在太多，不好定位是哪个序列的问题导致表现上的差异。

## 帮助开发？

测试序列可以通过输入指定的序列对比 xterm.js 或者操作系统中本地终端的显示。
发现可优化的地方你可以提交 issue 或 pr。

pr 请尽量保证与当前项目代码风格一致喔。

## 开发者

[终端序列支持文档](Support_Sequences.md)
## 以下来自 termux 仓库的终端资源
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
