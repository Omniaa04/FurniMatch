import 'package:flutter/material.dart';

class SaveAddressScreen extends StatefulWidget {
  final String locationName;
  final double latitude;
  final double longitude;
 
  final Map<String, dynamic>? existingAddress; 

  const SaveAddressScreen({
    super.key,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.existingAddress, 
  });

  @override
  State<SaveAddressScreen> createState() => _SaveAddressScreenState();
}

class _SaveAddressScreenState extends State<SaveAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late bool isEditing; 

  @override
  void initState() {
    super.initState();
    isEditing = widget.existingAddress != null;


    if (isEditing) {
      _buildingController.text = widget.existingAddress!['buildingName'] ?? '';
      _streetController.text = widget.existingAddress!['street'] ?? '';
      _floorController.text = widget.existingAddress!['floor'] ?? '';
      _phoneController.text = widget.existingAddress!['phone'] ?? ''; 
    }
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _streetController.dispose();
    _floorController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveOrUpdateAddress() {
    if (_formKey.currentState!.validate()) {
    
      final String currentBuildingName = _buildingController.text;
      final String currentStreet = _streetController.text;
      final String currentLocationName = widget.locationName;
      final String currentPhone = _phoneController.text;

      final Map<String, dynamic> finalAddress = {
       
        'buildingName': currentBuildingName,
        'street': currentStreet,
        'floor': _floorController.text,
        'phone': currentPhone, 
        'phoneNumber': currentPhone, 
        
       
        'locationName': currentLocationName, 
        'latitude': widget.latitude,
        'longitude': widget.longitude,
       
        'displayAddress': '$currentStreet, $currentBuildingName, $currentLocationName', 
        'address': '$currentStreet, $currentBuildingName, $currentLocationName', 
        
        
        'name': isEditing 
            ? widget.existingAddress!['name'] 
            : (currentBuildingName.isNotEmpty ? currentBuildingName : 'New Address'),
            

        'isSelected': true, 
      };

     
      Navigator.pop(context, finalAddress); 
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      
        title: Text(isEditing ? 'Edit Address' : 'Save Address'),
        backgroundColor: const Color(0xFF8B5A3C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildLocationDisplay(),

              const SizedBox(height: 30),

              // Building Name field
              TextFormField(
                controller: _buildingController,
                decoration: const InputDecoration(
                  labelText: 'Building Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the building name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  // Street field
                  Expanded(
                    child: TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.signpost),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the street name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Floor field
                  Expanded(
                    child: TextFormField(
                      controller: _floorController,
                      decoration: const InputDecoration(
                        labelText: 'Floor',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.layers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the floor number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Phone Number field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5A3C), 
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveOrUpdateAddress,
                child: Text(
                  isEditing ? 'Update Address' : 'Save Address',
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildLocationDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.location_on, size: 40, color: Color(0xFF8B5A3C)),
            const SizedBox(height: 10),
            Text(
              widget.locationName.split(',').join('\n'), 
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}