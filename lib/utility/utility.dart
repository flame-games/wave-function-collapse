import 'package:flutter/services.dart';
import 'dart:convert';
import '../constants/defines.dart';
import '../components/tile.dart';

Future<dynamic> loadJsonData(String fileName) async {
  String jsonString = await rootBundle.loadString('assets/data/$fileName');
  return jsonDecode(jsonString);
}

Future<void> createTilesFromJson(List<Tile> tiles) async {
  var tileListData = await loadJsonData(jsonFileName);
  for (int i = 0; i < tileListData['tileList'].length; i++) {
    var tileData = tileListData['tileList'][i];
    tiles.add(await Tile.load(tileData['src'],
        List<String>.from(tileData['edges']), tileData['isRotate']));
  }
}
