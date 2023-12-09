import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import './components/cell.dart';
import './components/tile.dart';
import 'dart:math';

const int DIM = 10;

class MainGame extends FlameGame with KeyboardEvents {
  List<Cell> grid = [];
  List<Tile> tiles = [];
  List<Tile> tileImages = [];

  @override
  Future<void> onLoad() async {
    super.onLoad();

    tiles.add(await Tile.load('tiles/blank.png', ["AAA", "AAA", "AAA", "AAA"]));
    tiles.add(await Tile.load('tiles/right.png', ["ABA", "ABA", "ABA", "AAA"]));
    tiles.add(await Tile.load('tiles/down.png', ["AAA", "ABA", "ABA", "ABA"]));
    tiles.add(await Tile.load('tiles/left.png', ["ABA", "AAA", "ABA", "ABA"]));
    tiles.add(await Tile.load('tiles/up.png', ["ABA", "ABA", "AAA", "ABA"]));

    // tiles.add(await Tile.load('circuit/0.png', ["AAA", "AAA", "AAA", "AAA"]));
    // tiles.add(await Tile.load('circuit/1.png', ["BBB", "BBB", "BBB", "BBB"]));
    // tiles.add(await Tile.load('circuit/2.png', ["BBB", "BCB", "BBB", "BBB"]));
    // tiles.add(await Tile.load('circuit/3.png', ["BBB", "BDB", "BBB", "BDB"]));
    // tiles.add(await Tile.load('circuit/4.png', ["ABB", "BCB", "BBA", "AAA"]));
    // tiles.add(await Tile.load('circuit/5.png', ["ABB", "BBB", "BBB", "BBA"]));
    // tiles.add(await Tile.load('circuit/6.png', ["BBB", "BCB", "BBB", "BCB"]));
    // tiles.add(await Tile.load('circuit/7.png', ["BDB", "BCB", "BDB", "BCB"]));
    // tiles.add(await Tile.load('circuit/8.png', ["BDB", "BBB", "BCB", "BBB"]));
    // tiles.add(await Tile.load('circuit/9.png', ["BCB", "BCB", "BBB", "BCB"]));
    // tiles.add(await Tile.load('circuit/10.png', ["BCB", "BCB", "BCB", "BCB"]));
    // tiles.add(await Tile.load('circuit/11.png', ["BCB", "BCB", "BBB", "BBB"]));
    // tiles.add(await Tile.load('circuit/12.png', ["BBB", "BCB", "BBB", "BCB"]));

    // タイルの回転バージョンを生成
    // for (int i = 2; i < 14; i++) {
    //   for (int j = 1; j < 4; j++) {
    //     tiles.add(tiles[i].rotate(j));
    //   }
    // }

    // for (int i = 2; i < 11; i++) {
    //   for (int j = 1; j < 4; j++) {
    //     tiles.add(tiles[i].rotate(j));
    //   }
    // }

    // 隣接規則の生成
    for (var tile in tiles) {
      tile.analyze(tiles);
    }

    grid = List.generate(DIM * DIM, (index) => Cell.fromValue(tiles.length));
  }

  void checkValid(List<int> arr, List<int> valid) {
    for (int i = arr.length - 1; i >= 0; i--) {
      int element = arr[i];
      if (!valid.contains(element)) {
        arr.removeAt(i);
      }
    }
  }

  void startOver() {
    // 初期化ロジック
    print("startOver");
  }

  @override
  void render(Canvas canvas) {
    Random random = Random();

    final w = size.x / DIM;
    final h = size.y / DIM;

    for (int j = 0; j < DIM; j++) {
      for (int i = 0; i < DIM; i++) {
        Cell cell = grid[i + j * DIM];
        if (cell.collapsed) {
          int index = cell.sockets[0];
          // int index = 3;
          Tile tile = tiles[index];

          // SpriteComponentの位置とサイズを設定
          // tile.img.position = Vector2(i * w, j * h);
          tile.img.size = Vector2(w, h);
          // キャンバスの描画位置を調整
          canvas.save();
          canvas.translate(i * w, j * h);
          // SpriteComponentを描画（原点に対する相対位置で描画）
          tile.img.render(canvas);
          // キャンバスの状態を元に戻す
          canvas.restore();
        } else {
          Rect rect = Rect.fromLTWH(i * w, j * h, w, h);
          canvas.drawRect(rect, Paint()..color = Colors.white);
        }
      }
    }

    // Pick cell with least entropy
    List<Cell> gridCopy = List<Cell>.from(grid);
    // List<Cell> gridCopy = grid.map((cell) => Cell.clone(cell)).toList();
    gridCopy = gridCopy.where((a) => !a.collapsed).toList();

    if (gridCopy.isEmpty) {
      return;
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
      print("stopIndex > 0");
      gridCopy.removeRange(stopIndex, gridCopy.length);
    }

    // リストからランダムな要素を選択
    Cell cell = gridCopy[random.nextInt(gridCopy.length)];
    cell.collapsed = true;

    if (cell.sockets.isEmpty) {
      startOver(); // この関数は適切に定義する必要があります
      return;
    }

    // オプションリストからランダムな要素を選択
    var pick = cell.sockets[random.nextInt(cell.sockets.length)];
    cell.sockets = [pick];

    List<Cell?> nextGrid = List.filled(DIM * DIM, null);
    for (int j = 0; j < DIM; j++) {
      for (int i = 0; i < DIM; i++) {
        int index = i + j * DIM;

        if (grid[index].collapsed) {
          nextGrid[index] = grid[index];
        } else {
          List<int> options = List.generate(tiles.length, (i) => i);
          // Look up
          if (j > 0) {
            Cell up = grid[i + (j - 1) * DIM];
            List<int> validOptions = [];
            for (int option in up.sockets) {
              List<int> valid = tiles[option].down;
              validOptions.addAll(valid);
            }
            checkValid(options, validOptions);
          }
          // Look right
          if (i < DIM - 1) {
            Cell right = grid[i + 1 + j * DIM];
            List<int> validOptions = [];
            for (int option in right.sockets) {
              List<int> valid = tiles[option].left;
              validOptions.addAll(valid);
            }
            checkValid(options, validOptions);
          }
          // Look down
          if (j < DIM - 1) {
            Cell down = grid[i + (j + 1) * DIM];
            List<int> validOptions = [];
            for (int option in down.sockets) {
              List<int> valid = tiles[option].up;
              validOptions.addAll(valid);
            }
            checkValid(options, validOptions);
          }
          // Look left
          if (i > 0) {
            Cell left = grid[i - 1 + j * DIM];
            List<int> validOptions = [];
            for (int option in left.sockets) {
              List<int> valid = tiles[option].right;
              validOptions.addAll(valid);
            }
            checkValid(options, validOptions);
          }

          nextGrid[index] = Cell.fromList(options);
        }
      }
    }

    grid = nextGrid.where((cell) => cell != null).cast<Cell>().toList();
  }
}
