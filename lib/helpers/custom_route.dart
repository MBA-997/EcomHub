import 'package:flutter/material.dart';

class CustomRoute extends MaterialPageRoute {
  CustomRoute({WidgetBuilder? builder, RouteSettings? settings})
      : super(builder: builder!, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // TODO: implement buildTransitions
    return super
        .buildTransitions(context, animation, secondaryAnimation, child);
  }
}
