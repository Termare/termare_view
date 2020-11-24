typedef _VoidCallback = void Function();

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
