import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'persons.dart' as mypersons;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; 
import 'notifications.dart';

/// Global notification instance, shared with main.dart
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// Shows a local notification with the given message.
Future<void> showLocalNotification(String msg) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', 'Channel Name',
    importance: Importance.max, priority: Priority.high
  );
  const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(0, 'Android P1', msg, notificationDetails);
}

/// Shows notification and saves metadata (date, time, location, city/district) for each change.
Future<void> notifyAndSaveMeta(String message) async {
  await showLocalNotification(message);
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now().toString();

  // Request location permissions
  await Geolocator.requestPermission();
  String locationText = 'Location could not be obtained';
  String cityDistrict = '';
  try {
    final pos = await Geolocator.getCurrentPosition();
    locationText = '${pos.latitude}, ${pos.longitude}';

    // Retrieve address info (city/district)
    final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isNotEmpty) {
      final first = placemarks.first;
      cityDistrict = '${first.administrativeArea ?? ''}, ${first.subAdministrativeArea ?? ''}';
    }
  } catch (e) {}

  // Retrieve all old notifications
  List<NotificationItem> allNotifs = [];
  final notifListString = prefs.getString('notification_list');
  if (notifListString != null) {
    allNotifs = (jsonDecode(notifListString) as List)
        .map((e) => NotificationItem.fromJson(e)).toList();
  }

  // Insert the newest notification at the top of the list
  allNotifs.insert(0, NotificationItem(
    message: message,
    dateTime: now,
    location: locationText,
    cityDistrict: cityDistrict,
  ));

  // Save the updated notification list to SharedPreferences
  await prefs.setString('notification_list',
      jsonEncode(allNotifs.map((e) => e.toJson()).toList()));
}

/// The page for viewing, adding, editing, and deleting locally stored persons.
/// All changes are persisted with SharedPreferences and trigger notifications.
class LocalSavePage extends StatefulWidget {
  const LocalSavePage({super.key});

  @override
  State<LocalSavePage> createState() => _LocalSavePageState();
}

class _LocalSavePageState extends State<LocalSavePage> {
  /// List of locally stored persons.
  List<mypersons.Person> persons = [];

  @override
  void initState() {
    super.initState();
    // Load the list of persons when the page is first opened.
    loadPersons();
  }

  /// Loads persons list from local storage, or creates sample data on first launch.
  Future<void> loadPersons() async {
    final prefs = await SharedPreferences.getInstance();
    final listString = prefs.getString('persons');
    if (listString == null) {
      // Create sample data if running for the first time.
      persons = [
        mypersons.Person(name: "Ali", phone: "05001234567"),
        mypersons.Person(name: "Veli", phone: "05331234567"),
        mypersons.Person(name: "Ayşe", phone: "05441234567"),
      ];
      await savePersons();
    } else {
      final List decoded = jsonDecode(listString);
      persons = decoded.map((e) => mypersons.Person.fromJson(e)).toList().cast<mypersons.Person>();
    }
    setState(() {});
  }

  /// Saves the current list of persons to local storage.
  Future<void> savePersons() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = persons.map((e) => e.toJson()).toList();
    await prefs.setString('persons', jsonEncode(jsonList));
  }

  /// Deletes a person by index and triggers notification.
  void deletePerson(int index) async {
    persons.removeAt(index);
    await savePersons();
    setState(() {});
    await notifyAndSaveMeta("1 data changed (Person deleted)");
  }

  /// Opens a dialog to add a new person.
  void addPersonDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Person"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          // Button to add the person, if fields are not empty.
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                persons.add(mypersons.Person(name: name, phone: phone));
                await savePersons();
                setState(() {});
                await notifyAndSaveMeta("1 data changed (Person added)");
              }
              Navigator.pop(context); 
            },
            child: const Text("Add"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  /// Opens a dialog to edit a person's information.
  void editPersonDialog(int index) {
    final nameController = TextEditingController(text: persons[index].name);
    final phoneController = TextEditingController(text: persons[index].phone);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Person Information"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
          ],
        ),
        actions: [
          // Button to save changes if fields are not empty.
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                persons[index].name = name;
                persons[index].phone = phone;
                await savePersons();
                setState(() {});
                await notifyAndSaveMeta("1 data changed (Person edited)");
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Set AppBar icons and title color to white
        iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.titleTextStyle?.color),
        title: Text('Data', style: TextStyle(
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: persons.length,
        itemBuilder: (context, i) {
          final p = persons[i];
          return ListTile(
            // Display person name and phone number.
            title: Text(p.name),
            subtitle: Text(p.phone),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button opens edit dialog for this person.
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => editPersonDialog(i),
                ),
                // Delete button deletes the person.
                IconButton(
                  icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
                  onPressed: () => deletePerson(i),
                  tooltip: "Delete",
                ),
              ],
            ),
            // Tapping the item also opens the edit dialog.
            onTap: () => editPersonDialog(i),
          );
        },
      ),
      // Button to open the add person dialog.
      floatingActionButton: FloatingActionButton(
        onPressed: addPersonDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
