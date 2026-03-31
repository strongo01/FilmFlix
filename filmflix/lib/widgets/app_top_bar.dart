import 'package:flutter/material.dart';
import 'package:cinetrackr/l10n/app_localizations.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? rightWidgets;
  final Color? backgroundColor;
  final Color? textColor;

  const AppTopBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.rightWidgets,
    this.backgroundColor,
    this.textColor,
  })  : assert(title != null || titleWidget != null),
        super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color bgCandidate = backgroundColor ?? theme.appBarTheme.backgroundColor ?? Colors.transparent;

    // If the app is in dark mode but a light background (e.g. Colors.white) was supplied,
    // prefer a dark app bar background so the bar isn't white in dark mode.
    if (theme.brightness == Brightness.dark && ThemeData.estimateBrightnessForColor(bgCandidate) == Brightness.light) {
      bgCandidate = theme.appBarTheme.backgroundColor ?? const Color.fromRGBO(28, 40, 46, 1);
    }

    final bg = bgCandidate;
    final bool isBgTransparent = bg == Colors.transparent;
    final isDarkBg = isBgTransparent
      ? theme.brightness == Brightness.dark
      : ThemeData.estimateBrightnessForColor(bg) == Brightness.dark;
    final defaultText = textColor ?? (isDarkBg ? Colors.white : Colors.black87);

    return Container(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Left: back button when possible
                Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(builder: (ctx) {
                    if (Navigator.of(ctx).canPop()) {
                      return IconButton(
                        icon: Icon(Icons.arrow_back, color: defaultText),
                        onPressed: () => Navigator.of(ctx).maybePop(),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ),

                // Center title
                Align(
                  alignment: Alignment.center,
                  child: titleWidget ?? Text(
                    title ?? AppLocalizations.of(context)!.appTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: defaultText),
                  ),
                ),

                // Right widgets
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: rightWidgets ?? [],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
