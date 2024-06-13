import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
 
import '../models/place.dart';
 
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 65.01236,
      longitude: 25.46816,
      address: '',
    ),
    this.isSelecting = true,
  });
 
  final PlaceLocation location;
  final bool isSelecting;
 
  @override
  ConsumerState<MapScreen> createState() {
    return _MapScreenState();
  }
}
 
class _MapScreenState extends ConsumerState<MapScreen> {
  LatLng? _pickedLocation;
 
  void _selectLocation(dynamic tapPosn, LatLng posn) {
    setState(() {
      _pickedLocation = posn;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
          actions: [
            if (widget.isSelecting)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  Navigator.of(context).pop(_pickedLocation);
                },
              ),
          ]),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(widget.location.latitude, widget.location.longitude),
          zoom: 15.0,
          onTap: widget.isSelecting ? _selectLocation : null,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
            additionalOptions: const {'hl': 'en'},
            subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
          ),
          if (_pickedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _pickedLocation ??
                      LatLng(
                          widget.location.latitude,
                          widget.location.longitude,
                      ),
                  builder: (context) => const Icon(
                    Icons.location_on,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}