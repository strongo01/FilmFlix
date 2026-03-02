import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Chats'), Tab(text: 'FAQs')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChatsTab(),
            _buildFaqsTab(),
          ],
        ),
      ),
    );
  }

  Future<void> _showPermissionHelp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Niet ingelogd'),
        content: const Text('Log eerst in als admin en probeer het opnieuw.'),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Sluiten'))],
      ));
      return;
    }

    String roleText = 'Geen users-doc gevonden.';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null && data['role'] != null) {
        roleText = 'users/${user.uid} role = ${data['role'].toString()}';
      } else {
        roleText = 'users/${user.uid} bestaat, maar heeft geen role-veld.';
      }
    } catch (e) {
      roleText = 'Fout bij lezen users-doc: $e';
    }

    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Rechten controleren'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mogelijke oorzaken en oplossingen:'),
        const SizedBox(height: 8),
        const Text('- Firestore rules controleren: regels gebruiken custom claims (request.auth.token.role).'),
        const SizedBox(height: 6),
        const Text('- Als je custom claims gebruikt: zet role/admin via Admin SDK (service account) en laat admin opnieuw inloggen.'),
        const SizedBox(height: 6),
        const Text('- Of wijzig tijdelijk de rules om de rol uit /users/{uid} te lezen.'),
        const SizedBox(height: 12),
        const Text('Huidige users-doc:'),
        const SizedBox(height: 6),
        Text(roleText),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Sluiten')),
      ],
    ));
  }

  Future<void> _showDebugInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    String uid = user?.uid ?? '<not logged in>';
    Map<String, dynamic>? claims;
    Map<String, dynamic>? usersDoc;
    String idTokenErr = '';
    try {
      if (user != null) {
        final token = await user.getIdTokenResult(true);
        claims = Map<String, dynamic>.from(token.claims ?? {});
      }
    } catch (e) {
      idTokenErr = e.toString();
    }

    try {
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        usersDoc = doc.data();
      }
    } catch (e) {
      usersDoc = {'error': e.toString()};
    }

    debugPrint('AdminScreen debug: uid=$uid claims=$claims usersDoc=$usersDoc idTokenErr=$idTokenErr');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Debug info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('uid: $uid'),
              const SizedBox(height: 8),
              Text('idToken claims: ${claims ?? '<none>'}'),
              if (idTokenErr.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('idToken error: $idTokenErr'),
              ],
              const SizedBox(height: 8),
              Text('users doc: ${usersDoc ?? '<not found>'}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
      ),
    );
  }

  Future<void> _promptAndFetchDoc() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fetch document by ID'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Plak hier het document ID van customerquestions:'),
          const SizedBox(height: 8),
          TextField(controller: ctrl),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Annuleer')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()), child: const Text('Fetch')),
        ],
      ),
    );
    if (res == null || res.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('customerquestions').doc(res).get();
      if (!doc.exists) {
        await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Niet gevonden'),
          content: Text('Document ${res} bestaat niet of is niet leesbaar.'),
          actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
        ));
        debugPrint('fetchDoc: not found $res');
        return;
      }
      final data = doc.data();
      debugPrint('fetchDoc ${res}: $data');
      await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
        title: Text('Document ${res}'),
        content: SingleChildScrollView(child: Text(data?.toString() ?? '<empty>')),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
      ));
    } catch (e) {
      debugPrint('fetchDoc error for $res: $e');
      await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Fout'),
        content: Text('Fout bij ophalen: $e'),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
      ));
    }
  }

  Widget _buildChatsTab() {
    final col = FirebaseFirestore.instance.collection('customerquestions').orderBy('updatedAt', descending: true);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: col.snapshots(),
      builder: (ctx, snap) {
        if (snap.hasError) {
          debugPrint('customerquestions stream error: ${snap.error}');
          // show a helpful message when Firestore denies permission
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Kan geen chats laden: ${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _showPermissionHelp,
                    child: const Text('Wat nu?'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _promptAndFetchDoc,
                    child: const Text('Toon debug info'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.security),
                    label: const Text('Maak mij Admin (DEV)'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                        'role': 'admin',
                        'updatedAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Je bent nu Admin in Firestore! Refresh de app.')),
                      );
                    },
                  ),
                ],
              ),            ),
          );

        }
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          debugPrint('customerquestions: no docs (uid=$uid)');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Geen vragen gevonden'),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _promptAndFetchDoc, child: const Text('Toon debug info')),
              ]),
            ),
          );
        }
        final docs = snap.data!.docs;
        // debug: print fetched docs
        final uid = FirebaseAuth.instance.currentUser?.uid;
        debugPrint('customerquestions snapshot: count=${docs.length} uid=$uid');
        for (final dd in docs) {
          try {
            debugPrint('customerquestions doc ${dd.id}: ${dd.data()}');
          } catch (e) {
            debugPrint('Failed to print doc ${dd.id}: $e');
          }
        }
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (c, i) {
            final d = docs[i];
            final data = d.data();
            final question = (data['question'] ?? '').toString();
            String preview = question;
            final adminReplies = (data['adminReplies'] as List?) ?? [];
            final userReplies = (data['userReplies'] as List?) ?? [];
            final answer = (data['answer'] ?? '').toString();

            DateTime? _toDt(dynamic ts) {
              try {
                if (ts == null) return null;
                if (ts is Timestamp) return ts.toDate();
                if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
                if (ts is String) return DateTime.tryParse(ts);
              } catch (_) {}
              return null;
            }

            String _extractTextFromMap(Map m) {
              if (m['text'] != null && m['text'].toString().trim().isNotEmpty) return m['text'].toString();
              if (m['answer'] != null && m['answer'].toString().trim().isNotEmpty) return m['answer'].toString();
              if (m['message'] != null && m['message'].toString().trim().isNotEmpty) return m['message'].toString();
              final firstString = m.values.firstWhere((v) => v != null && v is String && v.toString().trim().isNotEmpty, orElse: () => null);
              return firstString?.toString() ?? m.toString();
            }

            DateTime? lastDt = _toDt(data['createdAt']);
            String lastText = preview;

            if (answer.isNotEmpty) {
              final dt = _toDt(data['answerAt'] ?? data['updatedAt']);
              if (dt != null && (lastDt == null || dt.isAfter(lastDt))) {
                lastDt = dt;
                lastText = answer;
              }
            }

            for (final ar in adminReplies) {
              try {
                String text;
                dynamic rawTs;
                if (ar is Map) {
                  text = _extractTextFromMap(ar);
                  rawTs = ar['createdAt'] ?? ar['answerAt'] ?? ar['updatedAt'];
                } else {
                  text = ar?.toString() ?? '';
                  rawTs = null;
                }
                final dt = _toDt(rawTs);
                if (dt != null && (lastDt == null || dt.isAfter(lastDt))) {
                  lastDt = dt;
                  lastText = text;
                }
              } catch (_) {}
            }

            for (final ur in userReplies) {
              try {
                String text;
                dynamic rawTs;
                if (ur is Map) {
                  text = _extractTextFromMap(ur);
                  rawTs = ur['createdAt'] ?? ur['updatedAt'];
                } else {
                  text = ur?.toString() ?? '';
                  rawTs = null;
                }
                final dt = _toDt(rawTs);
                if (dt != null && (lastDt == null || dt.isAfter(lastDt))) {
                  lastDt = dt;
                  lastText = text;
                }
              } catch (_) {}
            }

            preview = lastText;
            String timeText = '';
            try {
              if (lastDt != null) {
                final dt = lastDt.toLocal();
                timeText = '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }
            } catch (_) {}

            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(question, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timeText.isNotEmpty) Text(timeText, style: const TextStyle(fontSize: 11)),
                  TextButton(
                    onPressed: () => _openAdminChat(d.id),
                    child: const Text('Open'),
                  ),
                ],
              ),
              onTap: () => _openAdminChat(d.id),
            );
          },
        );
      },
    );
  }

  Future<void> _openAdminChat(String docId) async {
    // fetch latest doc
    final docRef = FirebaseFirestore.instance.collection('customerquestions').doc(docId);
    final snap = await docRef.get();
    if (!snap.exists) return;
    final data = snap.data()!;
    final questionText = (data['question'] ?? '').toString();
    final answerText = (data['answer'] ?? '').toString();
    final adminReplies = (data['adminReplies'] as List?) ?? [];
    final userReplies = (data['userReplies'] as List?) ?? [];

    final TextEditingController replyCtrl = TextEditingController();
    final ScrollController scrollCtrl = ScrollController();

    // build message list
    final List<Map<String, dynamic>> messages = [];
    messages.add({'text': questionText, 'isAdmin': false, 'ts': data['createdAt']});
    if (answerText.isNotEmpty) messages.add({'text': answerText, 'isAdmin': true, 'ts': data['answerAt'] ?? data['updatedAt']});
    for (final ar in adminReplies) {
      if (ar is Map && ar['text'] != null) messages.add({'text': ar['text'].toString(), 'isAdmin': true, 'ts': ar['createdAt']});
      else messages.add({'text': ar?.toString() ?? '', 'isAdmin': true, 'ts': null});
    }
    for (final ur in userReplies) {
      if (ur is Map && ur['text'] != null) messages.add({'text': ur['text'].toString(), 'isAdmin': false, 'ts': ur['createdAt']});
      else messages.add({'text': ur?.toString() ?? '', 'isAdmin': false, 'ts': null});
    }

    // sort messages by timestamp (oldest -> newest). support Timestamp, DateTime, int, String
    int _tsToMs(dynamic ts) {
      try {
        if (ts == null) return 0;
        if (ts is Timestamp) return ts.millisecondsSinceEpoch;
        if (ts is DateTime) return ts.millisecondsSinceEpoch;
        if (ts is int) return ts;
        if (ts is String) {
          final dt = DateTime.tryParse(ts);
          return dt?.millisecondsSinceEpoch ?? 0;
        }
      } catch (_) {}
      return 0;
    }

    messages.sort((a, b) => _tsToMs(a['ts']).compareTo(_tsToMs(b['ts'])));

    // subscribe to realtime updates for this doc while dialog is open
    //final docRef = FirebaseFirestore.instance.collection('customerquestions').doc(docId);
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? docSub;
    void Function(void Function())? setStateDialog;
    docSub = docRef.snapshots().listen((snap) {
      if (!snap.exists) return;
      try {
        final d = snap.data()!;
        final qText = (d['question'] ?? '').toString();
        final aText = (d['answer'] ?? '').toString();
        final aReplies = (d['adminReplies'] as List?) ?? [];
        final uReplies = (d['userReplies'] as List?) ?? [];

        final List<Map<String, dynamic>> newMessages = [];
        newMessages.add({'text': qText, 'isAdmin': false, 'ts': d['createdAt']});
        if (aText.isNotEmpty) newMessages.add({'text': aText, 'isAdmin': true, 'ts': d['answerAt'] ?? d['updatedAt']});
        for (final ar in aReplies) {
          if (ar is Map) newMessages.add({'text': ar['text']?.toString() ?? ar.toString(), 'isAdmin': true, 'ts': ar['createdAt']});
          else newMessages.add({'text': ar?.toString() ?? '', 'isAdmin': true, 'ts': null});
        }
        for (final ur in uReplies) {
          if (ur is Map) newMessages.add({'text': ur['text']?.toString() ?? ur.toString(), 'isAdmin': false, 'ts': ur['createdAt']});
          else newMessages.add({'text': ur?.toString() ?? '', 'isAdmin': false, 'ts': null});
        }

        int _tsToMs(dynamic ts) {
          try {
            if (ts == null) return 0;
            if (ts is Timestamp) return ts.millisecondsSinceEpoch;
            if (ts is DateTime) return ts.millisecondsSinceEpoch;
            if (ts is int) return ts;
            if (ts is String) return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
          } catch (_) {}
          return 0;
        }

        newMessages.sort((a, b) => _tsToMs(a['ts']).compareTo(_tsToMs(b['ts'])));

        setStateDialog?.call(() {
          messages
            ..clear()
            ..addAll(newMessages);
        });
      } catch (e) {
        debugPrint('Realtime admin doc listener error: $e');
      }
    }, onError: (e) {
      debugPrint('admin doc snapshots listen error: $e');
    });

    // show chat as a fullscreen page while keeping the realtime listener active
    await Navigator.of(context).push(MaterialPageRoute(builder: (ctx2) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat: ${questionText.length > 40 ? questionText.substring(0, 40) + '...' : questionText}'),
        ),
        body: SafeArea(
          child: StatefulBuilder(builder: (ctx3, setState) {
            setStateDialog = setState;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollCtrl,
                      itemCount: messages.length,
                      itemBuilder: (c, i) {
                        final m = messages[i];
                        final isAdmin = m['isAdmin'] == true;
                        final txt = (m['text'] ?? '').toString();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.66),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isAdmin ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(txt, style: TextStyle(color: isAdmin ? Colors.white : Colors.black87)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(controller: replyCtrl, decoration: const InputDecoration(hintText: 'Typ een antwoord...'), maxLines: 3),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final text = replyCtrl.text.trim();
                          if (text.isEmpty) return;
                          final reply = {
                            'text': text,
                            'createdAt': Timestamp.now(),
                            'seenBy': <String>[],
                          };
                          try {
                            await docRef.update({
                              'adminReplies': FieldValue.arrayUnion([reply]),
                              'updatedAt': FieldValue.serverTimestamp(),
                              'userRead': false,
                            });
                            setStateDialog?.call(() {
                              messages.add({'text': text, 'isAdmin': true, 'ts': Timestamp.now()});
                              replyCtrl.clear();
                            });
                            await Future.delayed(const Duration(milliseconds: 100));
                            if (scrollCtrl.hasClients) scrollCtrl.jumpTo(scrollCtrl.position.maxScrollExtent);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Versturen mislukt')));
                          }
                        },
                        child: const Text('Verstuur'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      );
    }));

    // stop realtime listener when page is popped
    await docSub?.cancel();
  }

  Widget _buildFaqsTab() {
    final col = FirebaseFirestore.instance.collection('faqs').orderBy('createdAt', descending: true);
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: col.snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) return const Center(child: Text('Nog geen FAQ items'));
              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (c, i) {
                  final d = docs[i];
                  final data = d.data();
                  final q = (data['question'] ?? '').toString();
                  final a = (data['answer'] ?? '').toString();
                  return ExpansionTile(
                    title: Text(q),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(a),
                      ),
                      ButtonBar(
                        children: [
                          TextButton(onPressed: () => _editFaq(d.id, q, a), child: const Text('Bewerk')),
                          TextButton(onPressed: () => _deleteFaq(d.id), child: const Text('Verwijder')),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Nieuwe FAQ toevoegen'),
            onPressed: _addFaq,
          ),
        ),
      ],
    );
  }

  Future<void> _addFaq() async {
    final qCtrl = TextEditingController();
    final aCtrl = TextEditingController();
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nieuwe FAQ'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: qCtrl, decoration: const InputDecoration(labelText: 'Question')),
          const SizedBox(height: 8),
          TextField(controller: aCtrl, decoration: const InputDecoration(labelText: 'Answer'), maxLines: 4),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuleren')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Voeg toe')),
        ],
      ),
    );
    if (res != true) return;
    final q = qCtrl.text.trim();
    final a = aCtrl.text.trim();
    if (q.isEmpty || a.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('faqs').add({
        'question': q,
        'answer': a,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('FAQ toegevoegd')));
    } catch (e) {
      debugPrint('Failed to add faq: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toevoegen mislukt')));
    }
  }

  Future<void> _editFaq(String id, String currentQ, String currentA) async {
    final qCtrl = TextEditingController(text: currentQ);
    final aCtrl = TextEditingController(text: currentA);
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bewerk FAQ'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: qCtrl, decoration: const InputDecoration(labelText: 'Question')),
          const SizedBox(height: 8),
          TextField(controller: aCtrl, decoration: const InputDecoration(labelText: 'Answer'), maxLines: 4),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuleren')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Opslaan')),
        ],
      ),
    );
    if (res != true) return;
    final q = qCtrl.text.trim();
    final a = aCtrl.text.trim();
    if (q.isEmpty || a.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('faqs').doc(id).update({
        'question': q,
        'answer': a,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('FAQ bijgewerkt')));
    } catch (e) {
      debugPrint('Failed to update faq: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opslaan mislukt')));
    }
  }

  Future<void> _deleteFaq(String id) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Verwijder FAQ'),
      content: const Text('Weet je zeker dat je deze FAQ wilt verwijderen?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuleren')),
        ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Verwijder')),
      ],
    ));
    if (ok != true) return;
    try {
      await FirebaseFirestore.instance.collection('faqs').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('FAQ verwijderd')));
    } catch (e) {
      debugPrint('Failed to delete faq: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verwijderen mislukt')));
    }
  }
}
