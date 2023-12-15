import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import './components/cell.dart';
import './components/tile.dart';
import './constants/defines.dart';
import './utility/utility.dart';
import './core/wfc.dart';

class MainGame extends FlameGame with KeyboardEvents, TapCallbacks {
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
    grid = waveCollapse(grid, tiles);
  }

  @override
  void onTapDown(tapDownEvent) {
    initGrid();
  }

  @override
  void render(Canvas canvas) {
    final w = size.x / DIM;
    final h = size.y / DIM;

    for (int j = 0; j < DIM; j++) {
      for (int i = 0; i < DIM; i++) {
        Cell cell = grid[i + j * DIM];
        if (cell.collapsed) {
          int index = cell.sockets[0];
          Tile tile = tiles[index];
          tile.img.size = Vector2(w, h);
          canvas.save();

          double dx = i * w + w / 2;
          double dy = j * h + h / 2;
          canvas.translate(dx, dy);
          canvas.rotate(tile.angle);
          canvas.translate(-tile.img.size.x / 2, -tile.img.size.y / 2);
          tile.img.render(canvas);
          canvas.restore();
        } else {
          Rect rect = Rect.fromLTWH(i * w, j * h, w, h);
          canvas.drawRect(rect, Paint()..color = Colors.white);
        }
      }
    }
  }
}
