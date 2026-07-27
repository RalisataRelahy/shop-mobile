import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantMapPage extends StatelessWidget {
  const RestaurantMapPage({super.key});
  // Coordonnées du restaurant
  static const LatLng restaurantLocation =
  LatLng(-18.93820175723935, 47.52182435230497,);
  Future<void> openItinerary() async {
    final url = Uri.parse(
      "https://www.openstreetmap.org/directions?to="
          "-18.93820175723935%47.52182435230497",
    );
    if(await canLaunchUrl(url)){
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notre restaurant'),),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: restaurantLocation,
          initialZoom: 16,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName:"com.shopgood.app",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point:restaurantLocation,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.red,
                  size: 45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}