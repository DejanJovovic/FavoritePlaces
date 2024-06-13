import 'package:favorite_places/providers/user_places.dart';
import 'package:favorite_places/screens/add_place.dart';
import 'package:favorite_places/widgets/places_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PlacesScreenState();
  }

}

class _PlacesScreenState extends ConsumerState<PlacesScreen>{

  late Future<void> _placesFuture; // late will be set before its needed


  @override
  void initState() {
    super.initState();
    // this will load places from database and update the state of the provider
    _placesFuture = ref.read(userPlacesProvider.notifier).loadPlaces();
  }

  @override
  Widget build(BuildContext context) {

    final userPlaces = ref.watch(userPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your places'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddPlaceScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _placesFuture,
          // if its waiting for the database to get the data and show on the screen display the progress indicator, else show the placesList
          builder: (context, snapshot) => snapshot.connectionState == 
          ConnectionState.waiting ? const Center(
            child: CircularProgressIndicator()) : PlacesList(
              places: userPlaces,),
        ),
      ),
    );
  }
}
