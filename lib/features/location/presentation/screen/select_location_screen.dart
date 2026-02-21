import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:flutter_application_1/features/shipping/presentation/screen/save_address_screen.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  
 
  LatLng _currentPosition = LatLng(31.2653, 29.9926); 
  String _selectedAddress = 'SIDI BISHR\nسيدي بشر';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

 

  Future<void> _getCurrentLocation() async {

     setState(() => _isLoading = true);

     try {
         Position position = await Geolocator.getCurrentPosition(
             desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10));

         if (mounted) {
             final newPosition = LatLng(position.latitude, position.longitude);
             setState(() {
                 _currentPosition = newPosition;
                 _isLoading = false;
             });
             _mapController.move(_currentPosition, 15);
             _getAddressFromLatLng(_currentPosition);
         }
     } catch (e) {
         if (mounted) {
             setState(() => _isLoading = false);
             ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Could not get current location. Using default.')),
             );
         }
     }
  }
  
  Future<void> _searchLocation(String query) async {
   
     if (query.isEmpty) return;
     setState(() => _isLoading = true);
     try {
         List<Location> locations = await locationFromAddress(query);
         if (locations.isNotEmpty && mounted) {
             final location = locations.first;
             final newPosition = LatLng(location.latitude, location.longitude);
             setState(() {
                 _currentPosition = newPosition;
                 _isLoading = false;
             });
             _mapController.move(newPosition, 15);
             _getAddressFromLatLng(newPosition);
         } else if (mounted) {
             setState(() => _isLoading = false);
         }
     } catch (e) {
         if (mounted) setState(() => _isLoading = false);
     }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
   
     try {
         List<Placemark> placemarks = await placemarkFromCoordinates(
             position.latitude, position.longitude);

         if (placemarks.isNotEmpty && mounted) {
             final place = placemarks.first;
             setState(() {
                 _selectedAddress = [
                     place.street, place.subLocality, place.locality,
                 ].where((s) => s != null && s.isNotEmpty).join(', ');
             });
         }
     } catch (e) {
         if (mounted) setState(() { _selectedAddress = 'Address not available'; });
     }
  }
  
  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    if (_isLoading) return; 
    setState(() {
      _currentPosition = latlng;
    });
    _getAddressFromLatLng(latlng);
  }

  void _confirmLocation() async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveAddressScreen(
          locationName: _selectedAddress,
          latitude: _currentPosition.latitude,
          longitude: _currentPosition.longitude,
        ),
      ),
    );


    if (result != null && mounted) {
      
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      
         children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_application_1',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      size: 50,
                      color: Color(0xFF8B5A3C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8B5A3C),
                ),
              ),
            ),
            
          // Search bar and AppBar 
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8B5A3C),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Select location',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search location...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _searchLocation,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.grey.shade600),
                    onPressed: () => _searchLocation(_searchController.text),
                  ),
                ],
              ),
            ),
          ),

          // Current Location Button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _getCurrentLocation,
              child: const Icon(Icons.my_location, color: Color(0xFF8B5A3C)),
            ),
          ),
          
          // Display Selected Address
          Positioned(
            bottom: 100,
            left: 16,
            right: 80,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF8B5A3C), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Confirm Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _confirmLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5A3C),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}