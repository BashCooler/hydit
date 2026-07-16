import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niku/namespace.dart' as n;
import 'package:flutter_hooks/flutter_hooks.dart';


class SettingsTextField extends HookWidget {
  final String label;
  final void Function(String) onChanged;
  final bool enabled;
  final String? initial;

  const SettingsTextField({
    super.key,
    required this.label,
    required this.onChanged,
    required this.enabled,
    this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final text = useTextEditingController(text: initial);

    final focus = useState(false);
    final node = useFocusNode();
    node.addListener(() => focus.value = node.hasFocus);

    return Padding(
      padding: const .symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 4,
        children: [
          n.Text(label)..fontSize = 16.5,
          TextField(
            enabled: enabled,
            onChanged: onChanged,
            onTapOutside: (_) => node.unfocus(),
            controller: text,
            focusNode: node,
            textAlignVertical: .center,
            decoration: InputDecoration(
              contentPadding: const .symmetric(horizontal: 8),
              border: OutlineInputBorder(
                borderSide: .none,
                borderRadius: .circular(8.0),
              ),
              floatingLabelBehavior: .always,
              filled: true,
              suffixIcon: !focus.value
                  ? const SizedBox.shrink()
                  : Actions(text: text, onChanged: onChanged),
            ),
          )
        ],
      ),
    );
  }
}


class Actions extends StatelessWidget {
  final TextEditingController text;
  final void Function(String) onChanged;

  const Actions({
    super.key,
    required this.text,
    required this.onChanged,
  });

  void paste(TextEditingController controller) async {

    final text = await Clipboard
        .getData(Clipboard.kTextPlain)
        .then((data) => data?.text);

    if (text != null) {
      controller.text = text;
      onChanged(text);
    }
  }

  void clear() {
    text.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      mainAxisSize: .min,
      children: [
        IconButton(
          icon: const Icon(Icons.paste),
          onPressed: () => paste(text),
        ),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: clear,
        ),
      ],
    );
  }
}
