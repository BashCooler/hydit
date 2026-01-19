import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hydrus_api/hydrus.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final _urlController = TextEditingController();
  final _keyController = TextEditingController();

  String? _urlError, _keyError, _urlHint, _keyHint;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(
            context,
            MaterialPageRoute(builder: (_) => Home()),
          ),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SettingsTextField(
            setting: 'URL',
            controller: _urlController,
            errorMessage: _urlError,
            hint: _urlHint,
          ),
          Divider(color: Colors.transparent),
          SettingsTextField(
            setting: 'Hydrus API key',
            controller: _keyController,
            errorMessage: _keyError,
            hint: _keyHint,
          ),
          Divider(color: Colors.transparent),
          OutlinedButton(
            // TODO Implement access request
            onPressed: null,
            child: Text('Get key'),
          ),
          Divider(color: Colors.transparent),
          OutlinedButton(
            onPressed: _isLoading ? null : () async {
              await verifySave();
              setState(() => _isLoading = false);
            },
            child: Text('Verify key and save'),
          ),
        ],
      ),
    );
  }

  //  MARK: VERIFY SAVE

  Future<void> verifySave() async {
    // Set loading state
    setState(() => _isLoading = true);
    _urlError = _keyError = _urlHint = _keyHint = null;
    // Check URL format
    final key = _keyController.text;
    final url = _urlController.text;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      setState(() => _urlError = 'Invalid URL');
      return;
    }
    // Get response from client
    final client = Client(key, uri.host, uri.port);
    String response;
    try {
      response = await client.getVerifyAccessKey();
    } on HydrusUnknownHostException {
      setState(() => _urlError = 'Host is unknown, probably wrong URL');
      return;
    } on HydrusNoServiceException {
      setState(() => _urlError = 'No connection with Hydrus. Is your client running?');
      return;
    } on HydrusTimeoutException {
      setState(() => _urlError = 'No response (timeout). Is this the correct host?');
      return;
    } on HydrusUnknownException {
      setState(() => _urlError = 'Unknown error');
      return;
    }
    // Check if the key is valid
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    if (decoded['error'] != null) {
      switch (decoded['status_code']) {
        case 401:
        case 403:
        case 419:
          setState(() => _keyError = decoded['error']);
        default:
          setState(() => _keyError = 'Unknown error');
      }
    }
    // Save settings
    final prefs = await SharedPreferences.getInstance();
    log('Settings saved!');
    setState(() {
      prefs.setString('URL', _urlController.text);
      prefs.setString('Hydrus API key', _keyController.text);
      _urlError = _keyError = null;
      _urlHint = _keyHint = 'Saved';
    });
  }
}


//ignore: must_be_immutable
class SettingsTextField extends StatefulWidget {
  final String setting;
  final TextEditingController controller;

  String? errorMessage;
  String? hint;

  SettingsTextField({
    super.key,
    required this.setting,
    required this.controller,
    required this.errorMessage,
    required this.hint,
  });

  @override
  State<SettingsTextField> createState() => _SettingsTextFieldState();
}

class _SettingsTextFieldState extends State<SettingsTextField> {
  final _focusNode = FocusNode();

  String _text = '';
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    loadValue();
    _focusNode.addListener(() {  // show actions on editing
      setState(() => _showActions = (_focusNode.hasFocus) ? true : false);
    });
  }

  Future<void> loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _text = prefs.getString(widget.setting) ?? '';
      widget.controller.text = _text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: .fromLTRB(20, 20, 20, 20),
        filled: true,
        errorText: widget.errorMessage,
        labelText: widget.setting,
        helperText: widget.hint,
        suffixIcon: _showActions ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => widget.controller.clear(),
              icon: Icon(Icons.clear),
            ),
            VerticalDivider(),
          ],
        ) : null,
      ),
      onChanged: (value) {
        setState(() {
          widget.hint = null;
          widget.errorMessage = null;
        });
      },
    );
  }
}

