class SafeList<E> {
  SafeList() {
    _items = [];
  }
  List<E> _items = [];

  int get length => _items.length;
  E operator [](int index) {
    if (length < index + 1) {
      _items.length = index + 1;
    }
    // print('取值了  ${_items[index]}');
    if (_items[index] == null) {
      // _items[index] = ;
    }
    return _items[index];
  }

  set length(int newLength) {
    _items.length = newLength;
  }

  void operator []=(int index, E value) {
    if (length < index + 1) {
      _items.length = index + 1;
    }
    _items[index] = value;
  }
}
