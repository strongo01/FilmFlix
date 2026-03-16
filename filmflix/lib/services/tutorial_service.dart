import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class TutorialService {
  static void showTutorial(BuildContext context, List<TargetFocus> targets) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.8,
      paddingFocus: 10,
      textSkip: "OVERSLAAN",
      onClickTarget: (target) {
        debugPrint('Target clicked: ${target.identify}');
      },
      onSkip: () {
        debugPrint("Skip clicked");
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
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/images/Kevin.png'),
                  backgroundColor: Colors.transparent,
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
