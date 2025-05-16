import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todolist/main.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/empty_state.svg",
          width: 200,
        ),
        const SizedBox(
          height: 16,
        ),
        Text("Your task list is empty",
            style: Theme.of(context).textTheme.headlineSmall?.apply(
                  fontSizeFactor: 0.6,
                )),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}


class MyCheckBox extends StatelessWidget {
  final bool value;
  final Function() onTap;
  const MyCheckBox({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: !value ? Border.all(color: secondaryTextColor) : null,
            color: value ? primaryColor : null,
          ),
          child: value
              ? Icon(
                  size: 16,
                  CupertinoIcons.check_mark,
                  color: themeData.colorScheme.onPrimary)
              : null),
    );
  }
}
