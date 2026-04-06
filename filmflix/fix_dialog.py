with open('lib/views/settingscreen.dart', 'r') as f:
    text = f.read()

text = text.replace('''                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cardColor,
                          title: Text(
                            l10n?.resetTutorial ?? 'Start tutorial opnieuw',
                            style: TextStyle(color: textColor),
                          ),
                          content: Column(''','''                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cardColor,
                          title: Text(
                            l10n?.resetTutorial ?? 'Start tutorial opnieuw',
                            style: TextStyle(color: textColor),
                          ),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: SingleChildScrollView(
                              child: Column(''')

text = text.replace('''                                  Navigator.pop(ctx);
                                  _triggerMainTutorial();
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(''','''                                  Navigator.pop(ctx);
                                  _triggerMainTutorial();
                                },
                              ),
                            ],
                          ),
                          ),
                          ),
                          actions: [
                            TextButton(''')

with open('lib/views/settingscreen.dart', 'w') as f:
    f.write(text)
