import 'dart:math';
import '../components/cell.dart';
import '../components/tile.dart';
import '../constants/defines.dart';

List<Cell> pickCellWithLeastEntropy(List<Cell> grid) {
  List<Cell> gridCopy = List<Cell>.from(grid);
  gridCopy = gridCopy.where((a) => !a.collapsed).toList();

  if (gridCopy.isEmpty) {
    return [];
  }
  gridCopy.sort((a, b) => a.sockets.length - b.sockets.length);

  int len = gridCopy[0].sockets.length;
  int stopIndex = 0;
  for (int i = 1; i < gridCopy.length; i++) {
    if (gridCopy[i].sockets.length > len) {
      stopIndex = i;
      break;
    }
  }

  if (stopIndex > 0) {
    gridCopy.removeRange(stopIndex, gridCopy.length);
  }

  return gridCopy;
}

bool randomSelectionOfSockets(List<Cell> gridTarget) {
  Random random = Random();

  Cell cell = gridTarget[random.nextInt(gridTarget.length)];
  cell.collapsed = true;

  if (cell.sockets.isEmpty) {
    return false;
  }

  var pick = cell.sockets[random.nextInt(cell.sockets.length)];
  cell.sockets = [pick];
  return true;
}

void waveCollapse(List<Cell> grid, List<Tile> tiles) {
  List<Cell?> nextGrid = List.filled(DIM * DIM, null);

  for (int j = 0; j < DIM; j++) {
    for (int i = 0; i < DIM; i++) {
      int index = i + j * DIM;

      if (grid[index].collapsed) {
        nextGrid[index] = grid[index];
      } else {
        List<int> sockets = List.generate(tiles.length, (i) => i);
        // Look up
        if (j > 0) {
          cellCollapse(grid[i + (j - 1) * DIM], "down", sockets, tiles);
        }
        // Look right
        if (i < DIM - 1) {
          cellCollapse(grid[i + 1 + j * DIM], "left", sockets, tiles);
        }
        // Look down
        if (j < DIM - 1) {
          cellCollapse(grid[i + (j + 1) * DIM], "up", sockets, tiles);
        }
        // Look left
        if (i > 0) {
          cellCollapse(grid[i - 1 + j * DIM], "right", sockets, tiles);
        }
        nextGrid[index] = Cell.fromList(sockets);
      }
    }
  }
  grid = nextGrid.where((cell) => cell != null).cast<Cell>().toList();
}

void checkValid(List<int> sockets, List<int> validSockets) {
  for (int i = sockets.length - 1; i >= 0; i--) {
    int element = sockets[i];
    if (!validSockets.contains(element)) {
      sockets.removeAt(i);
    }
  }
}

void cellCollapse(
    Cell cell, String direction, List<int> sockets, List<Tile> tiles) {
  List<int> validSockets = getValidSockets(cell, direction, tiles);
  checkValid(sockets, validSockets);
}

List<int> getValidSockets(Cell cell, String direction, List<Tile> tiles) {
  List<int> validSockets = [];
  for (int socket in cell.sockets) {
    List<int> valid = tiles[socket].valid(direction);
    validSockets.addAll(valid);
  }
  return validSockets;
}
