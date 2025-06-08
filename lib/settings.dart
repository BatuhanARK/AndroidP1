import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final List<Color> themeColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
  ];

  final List<String> fontFamilies = [
    'Roboto',
    'Montserrat',
    'Courier New',
    'Georgia',
    'Times New Roman',
  ];

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Theme Color",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1,
                  crossAxisSpacing: 14,
                ),
                itemCount: themeColors.length,
                itemBuilder: (context, i) {
                  final color = themeColors[i];
                  return GestureDetector(
                    onTap: () {
                      themeNotifier.setTheme(color);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: themeNotifier.themeData.primaryColor == color
                              ? Colors.black
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.all(4),
                      child: themeNotifier.themeData.primaryColor == color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Font Family",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: themeNotifier.fontFamily,
              items: fontFamilies
                  .map((font) => DropdownMenuItem(
                        value: font,
                        child: Text(
                          font,
                          style: TextStyle(fontFamily: font),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  themeNotifier.setFontFamily(value);
                }
              },
            ),
            const Spacer(),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeNotifier.themeData.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Preview: Hello, World!',
                  style: TextStyle(
                    fontFamily: themeNotifier.fontFamily,
                    fontSize: 20,
                    color: themeNotifier.themeData.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Default Theme", style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Varsayılan renk ve fontu ayarla (ör: Kırmızı ve Roboto)
                final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
                themeNotifier.setTheme(Colors.red);
                themeNotifier.setFontFamily('Roboto');
              },
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
