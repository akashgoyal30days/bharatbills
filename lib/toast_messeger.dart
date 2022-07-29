import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

showPrintedMessage(
    BuildContext context,
    String title,
    String msg,
    Color iconcolor,
    Color backcolor,
    IconData icon,
    bool autodismiss,
    String position) {
  if (autodismiss == true) {
    showSimpleNotification(Text(title),
        context: context,
        subtitle: Text(msg),
        background: backcolor,
        leading: Icon(
          icon,
          color: iconcolor,
        ),
        elevation: 0,
        autoDismiss: autodismiss,
        position: position == 'top'
            ? NotificationPosition.top
            : NotificationPosition.bottom);
  }
  if (autodismiss == false) {
    showSimpleNotification(Text(title),
        context: context,
        subtitle: Text(msg),
        background: backcolor,
        leading: Icon(
          icon,
          color: iconcolor,
        ),
        elevation: 0,
        autoDismiss: autodismiss,
        slideDismissDirection: DismissDirection.up,
        position: position == 'top'
            ? NotificationPosition.top
            : NotificationPosition.bottom);
  }
}
