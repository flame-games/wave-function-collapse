class Cell {
  bool collapsed = false;
  List<int> sockets = [];

  Cell.clone(Cell other)
      : collapsed = other.collapsed,
        sockets = other.sockets;

  Cell.fromValue(int value)
      : collapsed = false,
        sockets = List<int>.generate(value, (i) => i);

  Cell.fromList(List<int> value)
      : collapsed = false,
        sockets = value;
}
