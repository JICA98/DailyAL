import 'package:flutter/material.dart';

class WillPopWidget extends StatefulWidget {
  const WillPopWidget({
    super.key,
    required this.child,
    required this.onWillPop,
  });

  final Widget child;

  final Future<bool> Function()? onWillPop;

  @override
  State<WillPopWidget> createState() => _WillPopWidgetState();
}

class _WillPopWidgetState extends State<WillPopWidget> {
  @override
  Widget build(BuildContext context) {
    final onWillPopCallback = widget.onWillPop;

    if (onWillPopCallback == null) {
      return PopScope(
        canPop: true,
        child: widget.child,
      );
    }

    return WillPopScope(
      onWillPop: onWillPopCallback,
      child: widget.child,
    );
  }
}
