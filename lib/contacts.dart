import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:android_p1/stats.dart';

/// Displays the list of contacts from the user's phone book.
/// Allows refreshing the list and tapping on a contact to view/edit stats.
class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  /// Stores the list of contacts fetched from the phone book.
  List<fc.Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    // Load contacts when the page is first opened
    loadContacts();
  }

  /// Fetches all contacts from the device, with details like number, photo, etc.
  /// Updates the state if permission is granted.
  Future<void> loadContacts() async {
    if (await fc.FlutterContacts.requestPermission()) {
      final cList = await fc.FlutterContacts.getContacts(
        withProperties: true, 
        withAccounts: true,
        withPhoto: true,
        withGroups: true,
        withThumbnail: true,
      );
      setState(() {
        contacts = cList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Sets the color of the back button (and all icons) to white
        iconTheme: IconThemeData(color: Colors.white), 
        title: Text(
          "Contacts",
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontWeight: FontWeight.bold,
          )
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      // Pull-to-refresh the contacts list
      body: RefreshIndicator(
        onRefresh: () async {
          await loadContacts();
        },
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, i) {
            final appContact = contacts[i];
            final name = appContact.displayName;
            final number = appContact.phones.isNotEmpty ? appContact.phones.first.number : 'No number';
            return ListTile(
              // Display contact name and number
              title: Text(name),
              subtitle: Text(number),
              // On tap: go to StatsPage for this contact
              onTap: () async {
                if (appContact.phones.isNotEmpty) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatsPage(
                        myContact: appContact,
                      ),
                    ),
                  );
                  // Refresh contacts after returning from StatsPage
                  loadContacts();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
