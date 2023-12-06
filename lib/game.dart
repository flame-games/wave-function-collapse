import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

const int DIM = 10;

class Cell {
  bool collapsed = false;
  List<int> sockets = [];
}

List<Cell> grid = List.generate(DIM * DIM, (index) => Cell());

class MainGame extends FlameGame with KeyboardEvents {
  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final w = size.x / DIM;
    final h = size.y / DIM;

    for (int j = 0; j < DIM; j++) {
      for (int i = 0; i < DIM; i++) {
        Cell cell = grid[i + j * DIM];
        if (cell.collapsed) {
          // タイル画像を描画（実際の画像描画方法は異なるかもしれません）
          // image(tiles[index].img, i * w, j * h, w, h);
        } else {
          // 矩形を描画
          Rect rect = Rect.fromLTWH(i * w, j * h, w, h);
          canvas.drawRect(rect, Paint()..color = Colors.white);
        }
      }
    }
  }
}
