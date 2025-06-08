import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data model for a notification item, including message, time, location, and city/district info.
class NotificationItem {
  final String message;
  final String dateTime;
  final String location;
  final String cityDistrict;

  NotificationItem({
    required this.message,
    required this.dateTime,
    required this.location,
    required this.cityDistrict,
  });

  /// Converts this notification item to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
    'message': message,
    'dateTime': dateTime,
    'location': location,
    'cityDistrict': cityDistrict,
  };

  /// Creates a NotificationItem from a JSON map.
  factory NotificationItem.fromJson(Map<String, dynamic> map) => NotificationItem(
    message: map['message'],
    dateTime: map['dateTime'],
    location: map['location'],
    cityDistrict: map['cityDistrict'] ?? '',
  );
}

/// The page that displays a list of all notifications.
/// Allows the user to clear all notifications with a single button.
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  /// List of all notification items loaded from local storage.
  List<NotificationItem> notifs = [];

  @override
  void initState() {
    super.initState();
    // Load the notifications list when the page is first opened.
    loadData();
  }

  /// Loads notification data from SharedPreferences.
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final notifListString = prefs.getString('notification_list');
    if (notifListString != null) {
      setState(() {
        notifs = (jsonDecode(notifListString) as List)
            .map((e) => NotificationItem.fromJson(e))
            .toList();
      });
    }
  }

  /// Clears all notifications from local storage and updates the UI.
  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_list');
    setState(() {
      notifs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar with white icons and title, and a "Clear All" button.
        iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.titleTextStyle?.color),
        title: Text('Notifications', style: TextStyle(
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          // Button to clear all notifications.
          IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).appBarTheme.titleTextStyle?.color),
            onPressed: () async {
              await clearNotifications();
            },
            tooltip: "Clear All Notifications",
          ),
        ],
      ),
      body: notifs.isEmpty
          // Show message if there are no notifications.
          ? const Center(child: Text("There are no notifications yet"))
          // Show list of notifications if any exist.
          : ListView.builder(
              itemCount: notifs.length,
              itemBuilder: (context, i) {
                final n = notifs[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ListTile(
                    // Main notification message
                    title: Text(n.message),
                    // Additional metadata: date/time, location, city/district
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date/Time: ${n.dateTime}"),
                        Text("Location: ${n.location}"),
                        if (n.cityDistrict.isNotEmpty)
                          Text("City/District: ${n.cityDistrict}"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
