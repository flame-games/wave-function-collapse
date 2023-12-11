import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

String reverseString(String s) {
  return s.split('').reversed.join('');
}

bool compareEdge(String a, String b) {
  return a == reverseString(b);
}

class Tile {
  double angle = 0.0;
  SpriteComponent img;
  bool isRotate = false;
  List<String> edges;
  List<int> up = [];
  List<int> right = [];
  List<int> down = [];
  List<int> left = [];

  Tile(this.img, this.edges, this.angle, this.isRotate);

  static Future<Tile> load(
      String imagePath, List<String> edges, bool isRotate) async {
    Image image = await Flame.images.load(imagePath);
    SpriteComponent spriteComponent = SpriteComponent.fromImage(image);
    return Tile(spriteComponent, edges, 0.0, isRotate);
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
    double rotation = num * (math.pi / 2);

    // エッジを回転させる
    final newEdges = List<String>.generate(edges.length, (i) {
      return edges[(i - num + edges.length) % edges.length];
    });

    return Tile(
        SpriteComponent(
          sprite: img.sprite,
        ),
        newEdges,
        rotation,
        false);
  }

  SpriteComponent createSpriteComponent(Vector2 size, Vector2 position) {
    return SpriteComponent(
      sprite: img.sprite,
      size: size,
      position: position,
      anchor: Anchor.center,
      angle: angle,
    );
  }
}
