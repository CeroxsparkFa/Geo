import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IconTextFormField extends StatefulWidget {
  const IconTextFormField({super.key, this.onChanged, this.keyboardType, this.controller, this.color, this.focusColor, this.label, this.placeholderString, this.icon, this.validator, this.privateField = false});

  final Function(String)? onChanged;
  final Color? color;
  final Color? focusColor;
  final bool privateField;
  final IconData? icon;
  final String? label;
  final String? placeholderString;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  State<StatefulWidget> createState() {
    return _IconTextFormFieldState();
  }
}

class _IconTextFormFieldState extends State<IconTextFormField> {
  
  bool hidden = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    hidden = widget.privateField;
  }

  @override
  Widget build(BuildContext context) {
    Color color = widget.color?? Theme.of(context).colorScheme.secondary;
    Color focusColor = widget.focusColor?? Theme.of(context).colorScheme.tertiary;
    return TextFormField(
      keyboardType: widget.keyboardType,
      inputFormatters: widget.keyboardType != TextInputType.number ? [] : [
        FilteringTextInputFormatter.digitsOnly
      ],
      onChanged: widget.onChanged,
      obscureText: hidden,
      validator: widget.validator,
      cursorColor: focusColor,
      style: TextStyle(color: color),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: color.withOpacity(0.5)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: color)
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: focusColor,
            width: 2.0
            )
        ),
        iconColor: color,
        labelStyle: TextStyle(color: color),
        floatingLabelStyle: TextStyle(color: focusColor),
        alignLabelWithHint: false,
        suffixIcon: widget.privateField ? IconButton(
          onPressed: () {
            setState(() {
              hidden = !hidden;
            });
          },
          icon: Icon(hidden ? Icons.visibility: Icons.visibility_off, size: 20, color: color)
        ) : null,
        hintText: widget.placeholderString,
        label: Text(widget.label?? ""),
        icon: widget.icon != null ? Icon(widget.icon, size: 20) : null,
      ),
      controller: widget.controller
    );
  }
}