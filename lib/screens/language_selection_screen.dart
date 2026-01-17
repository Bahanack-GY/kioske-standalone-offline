import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:kioske/providers/locale_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We can't use AppLocalizations here quite yet if we haven't set the locale,
    // but assuming standard material app setup, it should default to system or en.
    // For safety, hardcode or use simple strings, but we want it to be dynamic.

    // Actually, this screen IS the one setting the locale.
    return Scaffold(
      body: Center(
        child: Card(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language, size: 48, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  "Select Language / Choisir la langue",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                ListTile(
                  leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
                  title: const Text("English"),
                  onTap: () {
                    _setLanguageAndNavigate(context, const Locale('en'));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: Colors.grey.shade100,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Text("🇫🇷", style: TextStyle(fontSize: 24)),
                  title: const Text("Français"),
                  onTap: () {
                    _setLanguageAndNavigate(context, const Locale('fr'));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: Colors.grey.shade100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setLanguageAndNavigate(BuildContext context, Locale locale) {
    Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);

    // No explicit navigation needed.
    // Setting the locale will rebuild MaterialApp in main.dart,
    // causing 'home' to switch from LanguageSelectionScreen to LoginScreen.
  }
}
