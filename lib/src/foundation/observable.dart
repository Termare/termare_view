typedef _VoidCallback = void Function();

/// 一个极简的观察者模式的实现
mixin Observable {
  final listeners = <_VoidCallback>{};

  void addListener(_VoidCallback listener) {
    listeners.add(listener);
  }

  void removeListener(_VoidCallback listener) {
    listeners.remove(listener);
  }

  void notifyListeners() {
    // print('notifyListeners');
    for (final _VoidCallback listener in listeners) {
      listener();
    }
  }
}
