import 'package:cinetrackr/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static bool _isTutorialShowing = false;

  static Future<void> checkAndShowTutorial(
    BuildContext context, {
    required String tutorialKey,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isDone = prefs.getBool('tutorial_done_$tutorialKey') ?? false;

    if (isDone) return;
    if (_isTutorialShowing) return;

    // We wachten even tot de UI gerenderd is om zeker te weten dat de keys er zijn
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!TutorialService.mounted(context)) return;

      // Controleer of de targets daadwerkelijk een context hebben
      bool allKeysValid = targets.every((t) {
        final key = t.keyTarget;
        if (key is GlobalKey) {
          final ctx = key.currentContext;
          return ctx != null && ctx.findRenderObject() != null;
        }
        return true;
      });

      if (allKeysValid) {
        _isTutorialShowing = true;
        showTutorial(
          context,
          targets,
          onFinish: () async {
            _isTutorialShowing = false;
            await prefs.setBool('tutorial_done_$tutorialKey', true);
            if (onFinish != null) onFinish();
          },
          onSkip: () async {
            _isTutorialShowing = false;
            await prefs.setBool('tutorial_done_$tutorialKey', true);
            if (onSkip != null) {
              onSkip();
            } else if (onFinish != null) {
              onFinish();
            }
          },
        );
      }
    });
      // Genereer expres een nieuw frame: zonder dit is het scherm volledig inactief en stil, waardoor addPostFrameCallback niets heeft om zich aan te binden tot er weer een animatie is of het beeldscherm wordt aangeraakt.
      WidgetsBinding.instance.scheduleFrame();
  }
  static bool mounted(BuildContext context) {
    try {
      return (context as Element).mounted;
    } catch (_) {
      return false;
    }
  }
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
        if (onSkip != null) {
          onSkip();
        }
        return true;
      },
    ).show(context: context);
  }

  static TargetFocus createTarget({
    required String identify,
    required GlobalKey key,
    required String text,
    ContentAlign align = ContentAlign.bottom,
    ShapeLightFocus shape = ShapeLightFocus.Circle,
    double radius = 0,
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
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/Kevin.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
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
                            fontSize: 14,
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
      shape: shape,
      radius: radius,
      contents: [
        TargetContent(
          align: (identify == 'movie-slider') ? ContentAlign.bottom : align,
          builder: (context, controller) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/Kevin.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                  const SizedBox(width: 4),
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
                            fontSize: 14,
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
