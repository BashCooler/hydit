import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hydrus_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hydrus_api/hydrus.dart';
import 'hydrus_api/hydrus_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// TODO !IMPORTANT check input in settings
// wrong input creates fuckton of trouble

class _SettingsPageState extends State<SettingsPage> {

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
          ),
          Divider(color: Colors.transparent),
          SettingsTextField(
            setting: 'Hydrus API key',
          ),
          Divider(color: Colors.transparent),
          OutlinedButton(
            // TODO Implement access request
            onPressed: null,
            child: Text('Get key'),
          ),
          Divider(color: Colors.transparent),
          VerifyKeyButton(),
        ],
      ),
    );
  }
}

class VerifyKeyButton extends StatelessWidget {
  const VerifyKeyButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        Client client = await createClientWithSettings();
        String response = await client.getVerifyAccessKey();
        // TODO parse message before showing
        // error: {"error": "Did not find an entry for that access key!", "exception_type": "InsufficientCredentialsException", "status_code": 403, "version": 81, "hydrus_version": 645}
        // success: {"name": "My app", "permits_everything": true, "basic_permissions": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "human_description": "API Permissions (My app): can do anything", "version": 81, "hydrus_version": 645}
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response, style: TextStyle(color: Colors.black)),
              duration: const Duration(milliseconds: 5000),
              behavior: .fixed,  // floating is better but animation is ass
              backgroundColor: Theme.of(context).colorScheme.outline,
            ),
          );
        }
      },
      child: Text('Verify key'),
    );
  }
}


class SettingsTextField extends StatefulWidget {
  final String setting;
  final String? hint;

  const SettingsTextField({
    super.key,
    required this.setting,
    this.hint,
  });

  @override
  State<SettingsTextField> createState() => _SettingsTextFieldState();
}

// TODO 'Saved' and 'Error' messages

class _SettingsTextFieldState extends State<SettingsTextField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String _text = '';
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    loadValue();
    _focusNode.addListener(() {
      setState(() => _showActions = (_focusNode.hasFocus) ? true : false);
    });
  }

  Future<void> loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _text = prefs.getString(widget.setting) ?? '';
      _controller.text = _text;
    });
  }

  Future<void> writeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString(widget.setting, _controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(24),
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        onSubmitted: (String s) => writeValue(),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: .fromLTRB(20, 20, 20, 20),
          filled: true,
          labelText: widget.setting,
          helperText: null,
          suffixIcon: _showActions ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _controller.clear(),
                icon: Icon(Icons.clear),
              ),
              VerticalDivider(),
              IconButton(
                onPressed: () {
                  writeValue();
                  FocusScope.of(context).unfocus();
                },
                icon: Icon(Icons.check),
              ),
              VerticalDivider(),
            ],
          ) : null,
        ),
      ),
    );
  }
}

