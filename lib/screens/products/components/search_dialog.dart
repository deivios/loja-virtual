import 'package:flutter/material.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key, this.initialText});

  final String? initialText;

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText?.trim() ?? '';
    if (_controller.text.isNotEmpty) {
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Card(
                elevation: 8,
                child: TextFormField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Buscar produto...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  onFieldSubmitted: (_) => Navigator.of(context).pop(_controller.text.trim()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
