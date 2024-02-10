import 'package:dailyal_support/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void launchURLWithConfirmation(
  String url, {
  required BuildContext context,
}) async {
  var result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'Just a second...',
      ),
      content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This link will take you to'),
            Text(url),
            const Text('Continue?'),
          ]),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: url));
            Navigator.of(context, rootNavigator: true).pop(false);
          },
          child: const Text('Copy'),
        ),
        ..._yesOrNoButtons(context)
      ],
    ),
  );
  if (result ?? false) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.host.isNotEmpty) {
      launchURL(url);
    }
  }
}

List<Widget> _yesOrNoButtons(BuildContext context) {
  return [
    TextButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(false); // dismisses only the dialog and returns false
      },
      child: const Text('No'),
    ),
    ElevatedButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop(true); // dismisses only the dialog and returns true
      },
      child: const Text('Yes'),
    ),
  ];
}

void launchURL(String url) async {
  try {
    await launchUrl(Uri.parse(url));
  } catch (e) {
    showToast("Couldn't Launch $url!");
  }
}

showToast(String message) {
  showSnackBar(
    Text(message),
  );
}

void showSnackBar(Widget content, [Duration? duration]) async {
  messenger.currentState!.showSnackBar(
    SnackBar(
      content: content,
      duration: duration ?? const Duration(seconds: 4),
    ),
  );
}

Future<void> openFutureAndNavigate<T>({
  required String text,
  required Future<T> future,
  required Widget? Function(T) onData,
  required BuildContext context,
  String? customError,
}) async {
  showModalBottomSheet(
    context: context,
    builder: (_) => loadingBelowText(text: text),
  );

  try {
    final result = await future;
    if (result == null) throw Error();
    final newPage = onData(result);
    Navigator.pop(context);
    if (newPage != null) {
      showDialog(context: context, builder: (_) => newPage);
    }
  } catch (e) {
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    showToast(customError ?? 'Couldnt connect network');
  }
}

Widget loadingBelowText({
  String? text,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
}) {
  text ??= 'Loading_Content';
  return Column(
    mainAxisAlignment: mainAxisAlignment,
    children: [
      loadingCenter(),
      const SizedBox(height: 20),
      Padding(
        padding: padding,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    ],
  );
}

Widget loadingCenter({
  double? width,
  double containerSide = 20,
}) {
  return Center(
    child: SizedBox(
      width: containerSide,
      height: containerSide,
      child: CircularProgressIndicator(
        strokeWidth: width ?? 2,
      ),
    ),
  );
}
