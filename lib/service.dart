import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Page that fetches and displays a list of users from a remote API.
/// Users can expand each list item to view more details (address and phone).
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  /// List of users fetched from the API.
  List<dynamic> users = [];

  /// Indicates whether data is currently being loaded from the service.
  bool isLoading = true;

  /// Stores the index of the currently expanded user in the list.
  int? expandedIndex;

  /// Fetches users from the remote API and updates the state.
  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    print('API response code: ${response.statusCode}');
    print('API response body: ${response.body}');
    if (response.statusCode == 200) {
      // Parse the JSON response into a list.
      users = jsonDecode(response.body);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch users as soon as the page is loaded.
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // White icons and bold white title for the app bar.
        iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.titleTextStyle?.color),
        title: Text('User List', style: TextStyle(
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: isLoading
        // Show a progress indicator while loading.
        ? const Center(child: CircularProgressIndicator())
        : users.isEmpty
          // Show a message if there is no data or no users.
          ? Center(child: Text("No data or no users.", style: TextStyle(color: Theme.of(context).primaryColor)))
          // Show the list of users.
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                // Check if this item is currently expanded.
                final isExpanded = expandedIndex == index;

                return Column(
                  children: [
                    // Main list tile for the user.
                    ListTile(
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                      // Toggle the expanded/collapsed state when tapped.
                      onTap: () {
                        setState(() {
                          expandedIndex = isExpanded ? null : index;
                        });
                      },
                    ),
                    // If expanded, show additional info.
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Address: ${user['address']['street']}, ${user['address']['city']}"),
                            Text("Phone: ${user['phone']}"),
                            const Divider(),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
