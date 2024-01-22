import 'package:auto_size_text/auto_size_text.dart';
import 'package:dailyanimelist/constant.dart';
import 'package:flutter/material.dart';

class AutoSizeCopyText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  const AutoSizeCopyText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
  });

  @override
  State<AutoSizeCopyText> createState() => _AutoSizeCopyTextState();
}

class _AutoSizeCopyTextState extends State<AutoSizeCopyText> {
  bool _textSelected = false;

  @override
  Widget build(BuildContext context) {
    final length = widget.text.length;
    return GestureDetector(
      onTap: () async {
        if (_textSelected) return;
        _textSelected = true;
        if (mounted) setState(() {});
        await Future.delayed(const Duration(seconds: 15));
        _textSelected = false;
        if (mounted) setState(() {});
      },
      child: conditional(
        on: _textSelected,
        parent: (_) => SelectableText(
          widget.text,
          style: TextStyle(
            fontSize:
                length < 15 ? 24 : (length < 30 ? 16 : (length < 50 ? 14 : 12)),
          ),
          textAlign: widget.textAlign,
        ),
        child: AutoSizeText(
          widget.text,
          style: widget.style,
          overflow: widget.overflow,
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}
