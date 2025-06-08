import 'package:flutter/material.dart';
import 'package:android_p1/contacts.dart';
import 'package:android_p1/service.dart';
import 'package:android_p1/localsave.dart';
import 'package:android_p1/notifications.dart';
import 'package:android_p1/settings.dart';

/// The main home page of the application.
/// Shows navigation buttons to different features/pages.
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title at the top of the app
        title: Text('Android P1',
            style: TextStyle(
                color: Colors.white,fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // Tüm düğmeleri içeri biraz çek
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tek tek butonlar...
            _homeButton(
              context,
              label: 'Contacts & Stats',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactListPage())),
            ),
            const SizedBox(height: 18),
            _homeButton(
              context,
              label: 'Service',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserListPage())),
            ),
            const SizedBox(height: 18),
            _homeButton(
              context,
              label: 'Local Save',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalSavePage())),
            ),
            const SizedBox(height: 18),
            _homeButton(
              context,
              label: 'Notification',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage())),
            ),
            const SizedBox(height: 18),
            _homeButton(
              context,
              label: 'Settings',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage())),
            ),
          ],
        ),
      ),
    );
  }
}
Widget _homeButton(BuildContext context, {required String label, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16), // Daha az kavis için: 8-16 arası güzel olur
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ]
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    ),
  );
}
