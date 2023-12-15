import 'package:flame/game.dart';
import 'package:flame/input.dart';
import './components/cell.dart';
import './components/tile.dart';
import './constants/defines.dart';
import './utility/utility.dart';
import './core/wfc.dart';

class MainGame extends FlameGame with KeyboardEvents {
  List<Cell> grid = [];
  List<Tile> tiles = [];

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(Vector2(gameWidth.toDouble(), gameHeight.toDouble()));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    await initTiles();
    generatingAdjacencyRules();
    initGrid();
  }

  Future<void> initTiles() async {
    await createTilesFromJson(tiles);
    createRotateTiles(tiles.length);
  }

  void initGrid() {
    grid = List.generate(DIM * DIM, (index) => Cell.fromValue(tiles.length));
  }

  // void checkValid(List<int> arr, List<int> valid) {
  //   for (int i = arr.length - 1; i >= 0; i--) {
  //     int element = arr[i];
  //     if (!valid.contains(element)) {
  //       arr.removeAt(i);
  //     }
  //   }
  // }

  void draw() {
    final w = size.x / DIM;
    final h = size.y / DIM;

    for (int j = 0; j < DIM; j++) {
      for (int i = 0; i < DIM; i++) {
        Cell cell = grid[i + j * DIM];
        if (cell.collapsed) {
          int index = cell.sockets[0];
          Tile tile = tiles[index];
          add(tile.createSpriteComponent(Vector2(w, h), Vector2(i * w, j * h)));
        }
      }
    }
  }

  void generatingAdjacencyRules() {
    for (var tile in tiles) {
      tile.analyze(tiles);
    }
  }

  void createRotateTiles(int tileLength) {
    for (int i = 0; i < tileLength; i++) {
      if (tiles[i].isRotate) {
        for (int j = 1; j < 4; j++) {
          tiles.add(tiles[i].rotate(j));
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    draw();
    mainLoop();
  }

  void mainLoop() {
    List<Cell> lowEntropyGrid = pickCellWithLeastEntropy(grid);
    if (lowEntropyGrid.isEmpty) {
      return;
    }
    if (!randomSelectionOfSockets(lowEntropyGrid)) {
      initGrid();
      return;
    }
    waveCollapse(grid, tiles);
  }

  // List<Cell> pickCellWithLeastEntropy() {
  //   List<Cell> gridCopy = List<Cell>.from(grid);
  //   gridCopy = gridCopy.where((a) => !a.collapsed).toList();
  //
  //   if (gridCopy.isEmpty) {
  //     return [];
  //   }
  //   gridCopy.sort((a, b) => a.sockets.length - b.sockets.length);
  //
  //   int len = gridCopy[0].sockets.length;
  //   int stopIndex = 0;
  //   for (int i = 1; i < gridCopy.length; i++) {
  //     if (gridCopy[i].sockets.length > len) {
  //       stopIndex = i;
  //       break;
  //     }
  //   }
  //
  //   if (stopIndex > 0) {
  //     gridCopy.removeRange(stopIndex, gridCopy.length);
  //   }
  //
  //   return gridCopy;
  // }

  // bool randomSelectionOfSockets(List<Cell> gridTarget) {
  //   Random random = Random();
  //
  //   Cell cell = gridTarget[random.nextInt(gridTarget.length)];
  //   cell.collapsed = true;
  //
  //   if (cell.sockets.isEmpty) {
  //     return false;
  //   }
  //
  //   var pick = cell.sockets[random.nextInt(cell.sockets.length)];
  //   cell.sockets = [pick];
  //   return true;
  // }

//   void waveCollapse() {
//     List<Cell?> nextGrid = List.filled(DIM * DIM, null);
//
//     for (int j = 0; j < DIM; j++) {
//       for (int i = 0; i < DIM; i++) {
//         int index = i + j * DIM;
//
//         if (grid[index].collapsed) {
//           nextGrid[index] = grid[index];
//         } else {
//           List<int> sockets = List.generate(tiles.length, (i) => i);
//           // Look up
//           if (j > 0) {
//             cellCollapse(grid[i + (j - 1) * DIM], "down", sockets);
//           }
//           // Look right
//           if (i < DIM - 1) {
//             cellCollapse(grid[i + 1 + j * DIM], "left", sockets);
//           }
//           // Look down
//           if (j < DIM - 1) {
//             cellCollapse(grid[i + (j + 1) * DIM], "up", sockets);
//           }
//           // Look left
//           if (i > 0) {
//             cellCollapse(grid[i - 1 + j * DIM], "right", sockets);
//           }
//           nextGrid[index] = Cell.fromList(sockets);
//         }
//       }
//     }
//
//     grid = nextGrid.where((cell) => cell != null).cast<Cell>().toList();
//   }
//
//   void cellCollapse(Cell cell, String direction, sockets) {
//     List<int> validSockets = getValidSockets(cell, direction);
//     checkValid(sockets, validSockets);
//   }
//
//   List<int> getValidSockets(Cell cell, String direction) {
//     List<int> validSockets = [];
//     for (int socket in cell.sockets) {
//       List<int> valid = tiles[socket].valid(direction);
//       validSockets.addAll(valid);
//     }
//     return validSockets;
//   }
}
