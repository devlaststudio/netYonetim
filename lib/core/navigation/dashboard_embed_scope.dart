import 'package:flutter/widgets.dart';

class DashboardEmbedScope extends InheritedWidget {
  final bool hideAppBarBack;

  const DashboardEmbedScope({
    super.key,
    required this.hideAppBarBack,
    required super.child,
  });

  static bool hideBackButton(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<DashboardEmbedScope>();
    return scope?.hideAppBarBack ?? false;
  }

  @override
  bool updateShouldNotify(covariant DashboardEmbedScope oldWidget) {
    return hideAppBarBack != oldWidget.hideAppBarBack;
  }
}
