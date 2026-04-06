import 'package:cinetrackr/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class TutorialService {
  static void showTutorial(
    BuildContext context,
    List<TargetFocus> targets, {
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) {
    final l10n = L10n.of(context);
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.8,
      paddingFocus: 10,
      textSkip: l10n!.tutorialSkip,
      onClickTarget: (target) {
        debugPrint('Target clicked: ${target.identify}');
      },
      onFinish: () {
        debugPrint("Tutorial finished");
        if (onFinish != null) onFinish();
      },
      onSkip: () {
        debugPrint("Skip clicked");
        if (onSkip != null) onSkip();
        return true;
      },
    ).show(context: context);
  }

  static TargetFocus createTarget({
    required String identify,
    required GlobalKey key,
    required String text,
    ContentAlign align = ContentAlign.bottom,
  }) {
    if (identify == 'nav-bar') {
      return TargetFocus(
        identify: identify,
        keyTarget: key,
        alignSkip: Alignment.topRight,
        // rounded-rectangle for nav bar
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: align,
            builder: (context, controller) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/Kevin.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        BubbleSpecialThree(
                          text: text,
                          color: const Color(0xFFD4AF37),
                          tail: true,
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          isSender: false,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );
    }

    return TargetFocus(
      identify: identify,
      keyTarget: key,
      alignSkip: Alignment.topRight,
      contents: [
        TargetContent(
          align: align,
          builder: (context, controller) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/Kevin.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BubbleSpecialThree(
                        text: text,
                        color: const Color(0xFFD4AF37),
                        tail: true,
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        isSender: false,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
