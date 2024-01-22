import 'package:dailyanimelist/widgets/custombutton.dart';
import 'package:flutter/material.dart';

import 'package:dailyanimelist/generated/l10n.dart';
import '../../constant.dart';
import '../../main.dart';

class NextPreviousRow extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  const NextPreviousRow({Key? key, this.onNext, this.onPrevious})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onPrevious != null)
                    Container(
                      width: 90,
                      child: ShadowButton(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: onNext == null
                                ? BorderRadius.circular(12)
                                : BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12))),
                        onPressed: onPrevious,
                        child: title(S.current.Previous),
                      ),
                    ),
                  const SizedBox(
                    width: 10,
                  ),
                  if (onNext != null)
                    Container(
                      width: 90,
                      child: ShadowButton(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: onPrevious == null
                                ? BorderRadius.circular(12)
                                : BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12))),
                        onPressed: onNext,
                        child: title(S.current.Next),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ));
  }
}
