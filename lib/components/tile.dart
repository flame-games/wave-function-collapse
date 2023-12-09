import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

String reverseString(String s) {
  return s.split('').reversed.join('');
}

bool compareEdge(String a, String b) {
  // print("compareEdge");
  // print("a: $a, b : $b = ${a == reverseString(b)}");

  // return a == b;
  return a == reverseString(b);
}

class Tile {
  SpriteComponent img;
  List<String> edges;
  List<int> up = [];
  List<int> right = [];
  List<int> down = [];
  List<int> left = [];

  Tile(this.img, this.edges);

  static Future<Tile> load(String imagePath, List<String> edges) async {
    Image image = await Flame.images.load(imagePath);
    SpriteComponent spriteComponent = SpriteComponent.fromImage(image);
    return Tile(spriteComponent, edges);
  }

  void analyze(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; i++) {
      Tile tile = tiles[i];
      // UP
      if (compareEdge(tile.edges[2], edges[0])) {
        up.add(i);
      }
      // RIGHT
      if (compareEdge(tile.edges[3], edges[1])) {
        right.add(i);
      }
      // DOWN
      if (compareEdge(tile.edges[0], edges[2])) {
        down.add(i);
      }
      // LEFT
      if (compareEdge(tile.edges[1], edges[3])) {
        left.add(i);
      }
    }
  }

  Tile rotate(int num) {
    // 回転角度をラジアンで計算（num回90度回転）
    double rotation = num * (math.pi / 2); // 90度 = π/2 ラジアン

    // 新しいSpriteComponentを作成して回転を適用
    SpriteComponent newImg = SpriteComponent(
      sprite: img.sprite,
      angle: rotation,
      anchor: Anchor.center,
    );

    // エッジを回転させる
    final newEdges = List<String>.generate(edges.length, (i) {
      return edges[(i - num + edges.length) % edges.length];
    });

    return Tile(newImg, newEdges);
  }
}
