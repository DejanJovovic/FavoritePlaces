import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

// creating the database and returning it, only accessible in this user_places.dart
Future<Database> _getDatabase() async {
  // sqflite database setup
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      // image is text because only the path of the image is stored, REAL IS a number with decimal values
      return db.execute(
          'CREATE TABLE user_places(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    },
    version: 1,
  );
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  // get places from database
  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    // query gets the data from the database table
    final data = await db.query('user_places');

    // converting the data
    final places = data
        .map(
          (row) => Place(
            id: row['id'] as String,
            image: File(row['image'] as String),
            title: row['title'] as String,
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            ),
          ),
        )
        .toList(); //convert this iterable in to a list

    // the state is here set to this places list
    state = places;
  }

  void addPlace(String title, File image, PlaceLocation placeLocation) async {
    //storing data in sqldatabase
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path); // gets the fileName of the path
    final copiedImage = await image.copy('${appDir.path}/$fileName');

    final newPlace =
        Place(title: title, image: copiedImage, location: placeLocation);

    final db = await _getDatabase();

    //storing the data in the database
    db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      },
    );

    state = [newPlace, ...state];
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
