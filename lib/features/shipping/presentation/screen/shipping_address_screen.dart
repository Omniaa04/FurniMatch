import 'package:flutter/material.dart';


import '../../../location/presentation/screen/select_location_screen.dart'; 
import 'save_address_screen.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {

  List<Map<String, dynamic>> addresses = [
    {
      'name': 'Home',
      'address': '1901, Cambridge Street, US 81123',
      'isSelected': true,
      'buildingName': 'Apartment 1', 'street': 'Cambridge Street', 'floor': '5', 'phone': '123456789', 'locationName': 'US 81123', 'latitude': 31.25, 'longitude': 30.01,
      'displayAddress': 'Cambridge Street, Apartment 1, US 81123'
    },
    {
      'name': 'Office',
      'address': '4517, Washington Ave, Manchester, Kentucky 39495',
      'isSelected': false,
      'buildingName': 'Tower 2', 'street': 'Washington Ave', 'floor': '10', 'phone': '987654321', 'locationName': 'Kentucky 39495', 'latitude': 31.2, 'longitude': 30.02,
      'displayAddress': 'Washington Ave, Tower 2, Kentucky 39495'
    },
    {
      'name': "Parent's House",
      'address': '8502 Preston Rd. Inglewood, Maine 98380',
      'isSelected': false,
      'buildingName': 'House', 'street': 'Preston Rd', 'floor': '1', 'phone': '111222333', 'locationName': 'Maine 98380', 'latitude': 31.22, 'longitude': 30.03,
      'displayAddress': 'Preston Rd, House, Maine 98380'
    },
    {
      'name': "Friend's House",
      'address': '2464 Royal Ln. Mesa, New Jersey 45463',
      'isSelected': false,
      'buildingName': 'Unit B', 'street': 'Royal Ln', 'floor': '2', 'phone': '444555666', 'locationName': 'New Jersey 45463', 'latitude': 31.28, 'longitude': 30.04,
      'displayAddress': 'Royal Ln, Unit B, New Jersey 45463'
    },
  ];

  void _addNewAddress() async {
   
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectLocationScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
     
        for (var addr in addresses) {
          addr['isSelected'] = false;
        }
       
        addresses.add(result); 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New address saved successfully!')),
      );
    }
  }
 
  void _editAddress(int index) async {
    final oldAddress = addresses[index];

  
    final updatedAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaveAddressScreen(
          locationName: oldAddress['locationName'], 
          latitude: oldAddress['latitude'],
          longitude: oldAddress['longitude'],
          existingAddress: oldAddress, 
        ),
      ),
    );

    if (updatedAddress != null && updatedAddress is Map<String, dynamic>) {
      setState(() {
       
        addresses[index] = updatedAddress;
        
       
        for (var addr in addresses) {
            addr['isSelected'] = false;
        }
        addresses[index]['isSelected'] = true;
      });
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address updated successfully!')),
      );
    }
  }


  void _deleteAddress(int index) {
    setState(() {
      final wasSelected = addresses[index]['isSelected'] ?? false;
      addresses.removeAt(index);
      
      
      if (wasSelected && addresses.isNotEmpty) {
        addresses.first['isSelected'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address deleted successfully!')),
    );
  }


  void _showEditOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF8B5A3C)),
                title: const Text('Edit Address'),
                onTap: () {
                  Navigator.pop(context); 
                  _editAddress(index); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Address'),
                onTap: () {
                  Navigator.pop(context); 
                  _deleteAddress(index); 
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5A3C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shipping Address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return InkWell(
                 
                  onTap: () => _showEditOptions(index), 
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: address['isSelected'] 
                            ? const Color(0xFF8B5A3C) 
                            : Colors.grey.shade200,
                        width: address['isSelected'] ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey.shade600, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(address['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(address['address'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Radio<bool>(
                          value: true,
                          groupValue: address['isSelected'],
                          onChanged: (value) {
                            setState(() {
                              for (var addr in addresses) {
                                addr['isSelected'] = false;
                              }
                              address['isSelected'] = true;
                            });
                          },
                          activeColor: const Color(0xFF8B5A3C),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _addNewAddress, 
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF8B5A3C)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Color(0xFF8B5A3C)),
                        SizedBox(width: 8),
                        Text(
                          'Add New Shipping Address',
                          style: TextStyle(
                            color: Color(0xFF8B5A3C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5A3C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}