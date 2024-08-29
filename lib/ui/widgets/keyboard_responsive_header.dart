
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class KeyboardResponsiveHeader extends StatefulWidget {
  const KeyboardResponsiveHeader({super.key, this.child, this.backgroundColor, this.initialSize, this.padding = EdgeInsets.zero, this.margin = EdgeInsets.zero, this.alignment = Alignment.topLeft});

  final EdgeInsets padding;
  final EdgeInsets margin;
  final Alignment alignment;
  final Color? backgroundColor;
  final Widget? child;
  final double? initialSize;

  @override
  State<StatefulWidget> createState() {
    return _KeyboardResponsiveHeaderState();
  }
}

class _KeyboardResponsiveHeaderState extends State<KeyboardResponsiveHeader> with TickerProviderStateMixin {
  
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
    reverseDuration: const Duration(milliseconds: 200),
    value: widget.initialSize
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
    reverseCurve: Curves.fastOutSlowIn,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = widget.backgroundColor ?? Theme.of(context).colorScheme.secondary;
    final double initialSize = widget.initialSize ?? MediaQuery.sizeOf(context).height * 2/5;

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        if (isKeyboardVisible) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
        return SizeTransition(
          sizeFactor: _animation,
          axis: Axis.vertical,
          child: Container(
            height: initialSize,
            padding: EdgeInsets.only(left: widget.padding.left, right: widget.padding.right, bottom: widget.padding.bottom, top: widget.padding.top + MediaQuery.of(context).padding.top),
            alignment: widget.alignment,
            color: backgroundColor,
            child: widget.child
          )
        );
      }
    );
  }
}