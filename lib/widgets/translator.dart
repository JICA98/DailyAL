import 'package:dailyanimelist/constant.dart';
import 'package:dailyanimelist/generated/l10n.dart';
import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:dailyanimelist/widgets/customfuture.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';

class TranslaterWidget extends StatefulWidget {
  final String? content;
  static final translator = GoogleTranslator();
  final Widget? loading;
  final Widget Function(String?)? done;
  final void Function(Object?)? onError;
  final Future<Translation>? future;
  final bool autoTranslate;
  final String? preButtonText;
  final String? postButtonText;
  final EdgeInsetsGeometry buttonPadding;
  final bool reversed;
  const TranslaterWidget({
    Key? key,
    this.content,
    this.loading,
    this.done,
    this.onError,
    this.future,
    this.autoTranslate = false,
    this.preButtonText,
    this.postButtonText,
    this.reversed = false,
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 15),
  }) : super(key: key);

  @override
  State<TranslaterWidget> createState() => _TranslaterWidgetState();
}

class _TranslaterWidgetState extends State<TranslaterWidget> {
  bool translate = false;
  bool get showTranslateButton => Intl.defaultLocale != 'en_US' && !translate;
  bool get shouldTranslate => Intl.defaultLocale != 'en_US' && translate;

  Future<Translation>? transFuture;

  @override
  void initState() {
    super.initState();
    transFuture = widget.future;
    translate = widget.autoTranslate;
  }

  getFuture() {
    return TranslaterWidget.translator.translate(
      widget.content ?? '',
      from: "en",
      to: Intl.shortLocale(Intl.defaultLocale!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.reversed ? reverseWidgets : orderedWidgets,
    );
  }

  List<Widget> get orderedWidgets => [
        _textWidget,
        _translateBtn,
        SB.h5,
      ];

  List<Widget> get reverseWidgets => [
        _translateBtn,
        SB.h5,
        _textWidget,
        SB.h5,
      ];

  Widget get _textWidget {
    if (!shouldTranslate)
      return widget.done!(widget.content);
    else
      return StateFullFutureWidget<Translation>(
        done: (sp) => (sp?.data?.text != null && sp.data!.text.isNotEmpty)
            ? widget.done!(sp.data!.text)
            : widget.done!(widget.content),
        loadingChild: widget.loading ?? loadingCenterColored,
        onError: widget.onError,
        future: () => transFuture ?? getFuture(),
      );
  }

  Widget get _translateBtn {
    if (showTranslateButton)
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: _textButton(widget.preButtonText ??
            (widget.reversed
                ? S.current.Translate_Below_Text
                : S.current.Translate_Above_Text)),
      );
    else if (shouldTranslate)
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: _textButton(widget.postButtonText ?? S.current.Show_Original),
      );
    else
      return SB.z;
  }

  Widget _textButton(String message) {
    return Padding(
      padding: widget.buttonPadding,
      child: ToolTipButton(
        message: message,
        child: title(message),
        onTap: () {
          if (mounted)
            setState(() {
              translate = !translate;
            });
        },
      ),
    );
  }
}
