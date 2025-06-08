import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'dart:async';

/// A page that allows viewing and editing the "stat" values of a contact.
/// The stats are determined by the last 5 digits of the contact's phone number.
/// Changing the stats updates the contact's phone number in the device directory after a short delay.
class StatsPage extends StatefulWidget {
  final fc.Contact myContact;

  const StatsPage({super.key, required this.myContact});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // Individual stat values
  int strength = 0;
  int dexterity = 0;
  int intelligence = 0;
  int faith = 0;
  int arcane = 0;

  /// The sum of all stat values.
  int get totalStats => strength + dexterity + intelligence + faith + arcane;

  /// Image to show at the bottom, determined by the total stats.
  late String bottomImage;

  /// The current contact being displayed/edited.
  late fc.Contact currentContact;

  /// Name and number of the selected contact.
  late String selectedName;
  late String selectedNumber;

  /// Used to debounce stat changes before updating the phone number.
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    currentContact = widget.myContact;
    selectedName = currentContact.displayName;
    selectedNumber = currentContact.phones.isNotEmpty
      ? currentContact.phones.first.number
      : '';

    // Assign stat values from the last 5 digits of the phone number (if available).
    final digits = selectedNumber.replaceAll(RegExp(r'\D'), '').split('');
    if (digits.length >= 5) {
      strength = int.parse(digits[digits.length - 5]);
      dexterity = int.parse(digits[digits.length - 4]);
      intelligence = int.parse(digits[digits.length - 3]);
      faith = int.parse(digits[digits.length - 2]);
      arcane = int.parse(digits[digits.length - 1]);
    }
  }

  /// Updates the image at the bottom according to the total stats.
  void updateBottomImage() {
    if (totalStats <= 10) {
      bottomImage = 'assets/img/wolf.png';
    } else if (totalStats <= 20) {
      bottomImage = 'assets/img/tiger.png';
    } else if (totalStats <= 30) {
      bottomImage = 'assets/img/demon.png';
    } else if (totalStats <= 40) {
      bottomImage = 'assets/img/dragon.png';
    } else {
      bottomImage = 'assets/img/god.png';
    }
  }

  /// Called whenever any stat is changed.
  /// Debounces changes and updates the phone number in the device contact after a short delay.
  void onStatsChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () async {
      String newNumber = updatePhoneWithStats(selectedNumber);

      setState(() {
        selectedNumber = newNumber;
      });

      // IMPORTANT: Update the contact's number in the device directory!
      if (currentContact.phones.isNotEmpty) {
        currentContact.phones[0] = fc.Phone(newNumber);
        await currentContact.update();
      }
      print('Number updated in the directory: $newNumber');
    });
  }

  /// Increases a stat by 1 (up to max 9) and triggers number update.
  void increaseStat(String stat) {
    setState(() {
      switch (stat) {
        case 'Strength':
          if (strength < 9) strength++;
          break;
        case 'Dexterity':
          if (dexterity < 9) dexterity++;
          break;
        case 'Intelligence':
          if (intelligence < 9) intelligence++;
          break;
        case 'Faith':
          if (faith < 9) faith++;
          break;
        case 'Arcane':
          if (arcane < 9) arcane++;
          break;
      }
    });
    onStatsChanged();
  }

  /// Decreases a stat by 1 (down to min 0) and triggers number update.
  void decreaseStat(String stat) {
    setState(() {
      switch (stat) {
        case 'Strength':
          if (strength > 0) strength--;
          break;
        case 'Dexterity':
          if (dexterity > 0) dexterity--;
          break;
        case 'Intelligence':
          if (intelligence > 0) intelligence--;
          break;
        case 'Faith':
          if (faith > 0) faith--;
          break;
        case 'Arcane':
          if (arcane > 0) arcane--;
          break;
      }
    });
    onStatsChanged();
  }

  /// Updates the last 5 digits of the phone number based on the current stats.
  String updatePhoneWithStats(String number) {
    String justDigits = number.replaceAll(RegExp(r'\D'), '');
    if (justDigits.length < 5) return number;
    String prefix = justDigits.substring(0, justDigits.length - 5);
    String newSuffix = '$strength$dexterity$intelligence$faith$arcane';
    String newNumber = prefix + newSuffix;
    return formatPhoneNumber(newNumber, number);
  }

  /// Formats the phone number in Turkish style: 3-3-2-2
  String formatPhoneNumber(String newNumber, String oldFormatted) {
    if (newNumber.length != 10) return newNumber;
    return "${newNumber.substring(0, 3)} ${newNumber.substring(3, 6)} ${newNumber.substring(6, 8)} ${newNumber.substring(8, 10)}";
  }

  /// Returns the image asset path for a stat value.
  String getStatImage(String value) {
    if (int.parse(value) <= 2) {
      return 'assets/img/lvlD.png';
    } else if (int.parse(value) <= 4) {
      return 'assets/img/lvlC.png';
    } else if (int.parse(value) <= 6) {
      return 'assets/img/lvlB.png';
    } else if (int.parse(value) <= 8) {
      return 'assets/img/lvlA.png';
    } else {
      return 'assets/img/lvlS.png';
    }
  }

  /// Widget to display and edit a single stat row.
  Widget statRow(String label, String value, String statName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: darken(Theme.of(context).primaryColor, 0.4), fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: darken(Theme.of(context).primaryColor, 0.4))),
          const Spacer(),
          Image.asset(getStatImage(value), height: 40, colorBlendMode: BlendMode.multiply),
          const SizedBox(width: 8),
          // Button to increase the stat.
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: darken(Theme.of(context).primaryColor, 0.4),
              foregroundColor: lighten(Theme.of(context).primaryColor, 0.4),
              minimumSize: const Size(36, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () => increaseStat(statName),
            child: const Text('+', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          // Button to decrease the stat.
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: darken(Theme.of(context).primaryColor, 0.4),
              foregroundColor: lighten(Theme.of(context).primaryColor, 0.4),
              minimumSize: const Size(36, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () => decreaseStat(statName),
            child: const Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Returns a darker shade of the given color.
  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Returns a lighter shade of the given color.
  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  @override
  Widget build(BuildContext context) {
    // Update bottom image based on the current stats before building UI.
    updateBottomImage();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('$selectedName Stats', style: TextStyle(
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          fontWeight: FontWeight.bold,
        )),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show the name and current phone number of the contact.
            Text("Name: $selectedName", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
            Text("Phone: $selectedNumber", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: 10),
            // Editable stat rows for each stat type.
            statRow('STR', '$strength', 'Strength'),
            statRow('DEX', '$dexterity', 'Dexterity'),
            statRow('INT', '$intelligence', 'Intelligence'),
            statRow('FTH', '$faith', 'Faith'),
            statRow('ARC', '$arcane', 'Arcane'),
            const SizedBox(height: 10),
            // Visualizes the user's total stats as a themed image.
            Image.asset(
              bottomImage,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
