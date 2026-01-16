/// SharedPreferences depends on ui component not supported while
/// running in console.
///
/// Running [hydrus.dart] as a console app allows you to test the
/// functionality without the need to use any UI which is dope.

library;

import 'package:shared_preferences/shared_preferences.dart';
import 'hydrus.dart';

Future<Client> createClientWithSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final url = prefs.getString('URL') ?? '';
  final key = prefs.getString('Hydrus API key') ?? '';
  final urlPort = parseUrl(url);
  return Client(key, urlPort[0], urlPort[1]);
}