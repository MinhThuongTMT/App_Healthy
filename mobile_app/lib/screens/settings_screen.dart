import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  final TextEditingController _sensorNameController = TextEditingController();
  final TextEditingController _sensorPurposeController =
      TextEditingController();
  File? _selectedImage;

  // Method to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _addSensor() {
    // Logic for adding a new sensor
    final String name = _sensorNameController.text;
    final String purpose = _sensorPurposeController.text;
    if (name.isNotEmpty && purpose.isNotEmpty && _selectedImage != null) {
      // Add sensor to the list (this is a placeholder for actual functionality)
      print('New Sensor Added: $name, $purpose');
      // Clear fields after adding
      _sensorNameController.clear();
      _sensorPurposeController.clear();
      setState(() {
        _selectedImage = null;
      });
    } else {
      // Show error if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please fill in all fields and select an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configure Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            Divider(height: 40),
            Text(
              'Add New Sensor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _sensorNameController,
              decoration: InputDecoration(labelText: 'Sensor Name'),
            ),
            TextField(
              controller: _sensorPurposeController,
              decoration: InputDecoration(labelText: 'Purpose'),
            ),
            SizedBox(height: 10),
            _selectedImage == null
                ? Text('No image selected.')
                : Image.file(_selectedImage!, height: 100),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text('Choose Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSensor,
              child: Text('Add Sensor'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
