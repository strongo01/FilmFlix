import 'dart:async';
import 'dart:math' as Math;

import 'package:cinetrackr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cinetrackr/l10n/l10n.dart';

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
          title: Text(AppLocalizations.of(context)!.admin_title),
          bottom: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context)!.tab_chats),
              Tab(text: AppLocalizations.of(context)!.tab_faqs),
            ],
          ),
        ),
        body: TabBarView(children: [_buildChatsTab(), _buildFaqsTab()]),
      ),
    );
  }

  Future<void> _showPermissionHelp() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.not_logged_in_title),
          content: Text(AppLocalizations.of(ctx)!.not_logged_in_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(ctx)!.close),
            ),
          ],
        ),
      );
      return;
    }

    String roleText = AppLocalizations.of(context)!.no_users_doc;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null && data['role'] != null) {
        roleText = AppLocalizations.of(context)!.users_doc_role(user.uid, data['role'].toString());
      } else {
        roleText = AppLocalizations.of(context)!.users_doc_no_role(user.uid);
      }
    } catch (e) {
      roleText = AppLocalizations.of(context)!.users_doc_read_error(e.toString());
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.check_permissions_title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(ctx)!.possible_causes),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(ctx)!.firestore_rules),
              const SizedBox(height: 6),
              Text(AppLocalizations.of(ctx)!.custom_claims_hint),
              const SizedBox(height: 6),
              Text(AppLocalizations.of(ctx)!.rules_temp_change(user.uid)),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(ctx)!.current_users_doc),
              const SizedBox(height: 6),
              Text(roleText),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(ctx)!.close),
          ),
        ],
      ),
    );
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
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        usersDoc = doc.data();
      }
    } catch (e) {
      usersDoc = {'error': e.toString()};
    }

    debugPrint(
      'AdminScreen debug: uid=$uid claims=$claims usersDoc=$usersDoc idTokenErr=$idTokenErr',
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.debug_info_title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(ctx)!.uid_label(uid)),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(ctx)!.idtoken_claims_label(claims?.toString() ?? '<none>')),
              if (idTokenErr.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(AppLocalizations.of(ctx)!.idtoken_error_label(idTokenErr)),
              ],
              const SizedBox(height: 8),
              Text(AppLocalizations.of(ctx)!.users_doc_label(usersDoc?.toString() ?? '<not found>')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(ctx)!.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _promptAndFetchDoc() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.fetch_doc_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(ctx)!.paste_doc_id),
            const SizedBox(height: 8),
            TextField(controller: ctrl),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: Text(AppLocalizations.of(ctx)!.fetch),
          ),
        ],
      ),
    );
    if (res == null || res.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('customerquestions')
          .doc(res)
          .get();
      if (!doc.exists) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(ctx)!.not_found_title),
            content: Text(AppLocalizations.of(ctx)!.document_not_found(res)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(AppLocalizations.of(ctx)!.ok),
              ),
            ],
          ),
        );
        debugPrint('fetchDoc: not found $res');
        return;
      }
      final data = doc.data();
      debugPrint('fetchDoc ${res}: $data');
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.document_title(res)),
          content: SingleChildScrollView(
            child: Text(data?.toString() ?? AppLocalizations.of(ctx)!.empty),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(ctx)!.ok),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('fetchDoc error for $res: $e');
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.fetch_error_title),
          content: Text(AppLocalizations.of(ctx)!.fetch_error_message(e.toString())),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(ctx)!.ok),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildChatsTab() {
    final col = FirebaseFirestore.instance
        .collection('customerquestions')
        .orderBy('updatedAt', descending: true);
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
                    AppLocalizations.of(ctx)!.cannot_load_chats(snap.error?.toString() ?? ''),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          debugPrint('customerquestions: no docs (uid=$uid)');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.no_questions_found),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _promptAndFetchDoc,
                    child: Text(AppLocalizations.of(context)!.show_debug_info),
                  ),
                ],
              ),
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
              if (m['text'] != null && m['text'].toString().trim().isNotEmpty)
                return m['text'].toString();
              if (m['answer'] != null &&
                  m['answer'].toString().trim().isNotEmpty)
                return m['answer'].toString();
              if (m['message'] != null &&
                  m['message'].toString().trim().isNotEmpty)
                return m['message'].toString();
              final firstString = m.values.firstWhere(
                (v) =>
                    v != null && v is String && v.toString().trim().isNotEmpty,
                orElse: () => null,
              );
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
                timeText =
                    '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }
            } catch (_) {}

            // determine if there are unread user messages for admins
            int _tsToMs(dynamic ts) {
              try {
                if (ts == null) return 0;
                if (ts is Timestamp) return ts.millisecondsSinceEpoch;
                if (ts is DateTime) return ts.millisecondsSinceEpoch;
                if (ts is int) return ts;
                if (ts is String)
                  return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
              } catch (_) {}
              return 0;
            }

            int lastUserMs = _tsToMs(data['createdAt']);
            for (final ur in userReplies) {
              try {
                final ts = ur is Map
                    ? (ur['createdAt'] ?? ur['updatedAt'])
                    : null;
                lastUserMs = Math.max(lastUserMs, _tsToMs(ts));
              } catch (_) {}
            }

            int lastAdminMs = _tsToMs(data['answerAt'] ?? data['updatedAt']);
            if (answer.isNotEmpty)
              lastAdminMs = Math.max(
                lastAdminMs,
                _tsToMs(data['answerAt'] ?? data['updatedAt']),
              );
            // consider admin's last seen timestamp (set when admin opens the chat)
            lastAdminMs = Math.max(lastAdminMs, _tsToMs(data['adminSeenAt']));
            for (final ar in adminReplies) {
              try {
                final ts = ar is Map
                    ? (ar['createdAt'] ?? ar['answerAt'] ?? ar['updatedAt'])
                    : null;
                lastAdminMs = Math.max(lastAdminMs, _tsToMs(ts));
              } catch (_) {}
            }
            final int adminSeenMs = _tsToMs(data['adminSeenAt']);
            final bool noAdminActivity =
                answer.isEmpty && (adminReplies.isEmpty);
            final bool unreadForAdmin =
                (adminSeenMs == 0 && noAdminActivity && lastUserMs > 0) ||
                (lastUserMs > lastAdminMs);

            return Dismissible(
              key: ValueKey(d.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (confirmCtx) => AlertDialog(
                    title: Text(AppLocalizations.of(confirmCtx)!.delete_chat_title),
                    content: Text(AppLocalizations.of(confirmCtx)!.delete_chat_confirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(confirmCtx).pop(false), child: Text(AppLocalizations.of(confirmCtx)!.cancel)),
                      ElevatedButton(onPressed: () => Navigator.of(confirmCtx).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text(AppLocalizations.of(confirmCtx)!.delete)),
                    ],
                  ),
                );
                return confirm == true;
              },
              onDismissed: (direction) async {
                try {
                  await FirebaseFirestore.instance.collection('customerquestions').doc(d.id).delete();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.chat_deleted)));
                } catch (e) {
                  debugPrint('Failed to delete chat ${d.id}: $e');
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.delete_failed)));
                }
              },
              child: ListTile(
                leading: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    if (unreadForAdmin)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: const Center(
                            child: Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (_) {
                        final userName = (data['name'] ?? AppLocalizations.of(context)!.user_label_default).toString();
                        final adminNames = (data['adminNames'] as List?) ?? [];
                        final adminText = adminNames.isNotEmpty
                          ? AppLocalizations.of(context)!.admins_label(adminNames.map((e) => e.toString()).join(', '))
                          : '';
                        return adminText.isNotEmpty
                            ? Text(
                                adminText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                trailing: SizedBox(
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (timeText.isNotEmpty)
                        Text(timeText, style: const TextStyle(fontSize: 11)),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _openAdminChat(d.id),
                        child: Text(AppLocalizations.of(context)!.open),
                      ),
                    ],
                  ),
                ),
                onTap: () => _openAdminChat(d.id),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openAdminChat(String docId) async {
    // fetch latest doc
    final docRef = FirebaseFirestore.instance
        .collection('customerquestions')
        .doc(docId);
    final snap = await docRef.get();
    if (!snap.exists) return;
    // mark chat as seen by this admin
    try {
      await docRef.set({
        'adminSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to set adminSeenAt: $e');
    }
    final data = snap.data()!;
    final questionText = (data['question'] ?? '').toString();
    final answerText = (data['answer'] ?? '').toString();
    final adminReplies = (data['adminReplies'] as List?) ?? [];
    final userReplies = (data['userReplies'] as List?) ?? [];

    final TextEditingController replyCtrl = TextEditingController();
    final ScrollController scrollCtrl = ScrollController();

    // build message list (include sender names)
    final List<Map<String, dynamic>> messages = [];
    final ownerName = (data['name'] ?? AppLocalizations.of(context)!.user_label_default).toString();
    messages.add({
      'text': questionText,
      'isAdmin': false,
      'ts': data['createdAt'],
      'name': ownerName,
    });
    if (answerText.isNotEmpty)
      messages.add({
        'text': answerText,
        'isAdmin': true,
        'ts': data['answerAt'] ?? data['updatedAt'],
        'name': (data['answerAdminName'] ?? AppLocalizations.of(context)!.admin_title).toString(),
      });
    for (final ar in adminReplies) {
      if (ar is Map) {
        final textVal =
            (ar['text'] ?? ar['answer'] ?? ar['message'])?.toString() ??
            ar.toString();
        final adminName = (ar['adminName'] ?? ar['name'] ?? AppLocalizations.of(context)!.admin_title).toString();
        messages.add({
          'text': textVal,
          'isAdmin': true,
          'ts': ar['createdAt'],
          'name': adminName,
        });
      } else {
        messages.add({
          'text': ar?.toString() ?? '',
          'isAdmin': true,
          'ts': null,
          'name': AppLocalizations.of(context)!.admin_title,
        });
      }
    }
    for (final ur in userReplies) {
      if (ur is Map) {
        final textVal =
            (ur['text'] ?? ur['message'])?.toString() ?? ur.toString();
        final uName = (ur['name'] ?? ownerName).toString();
        messages.add({
          'text': textVal,
          'isAdmin': false,
          'ts': ur['createdAt'],
          'name': uName,
        });
      } else {
        messages.add({
          'text': ur?.toString() ?? '',
          'isAdmin': false,
          'ts': null,
          'name': ownerName,
        });
      }
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
    docSub = docRef.snapshots().listen(
      (snap) {
        if (!snap.exists) return;
        try {
          final d = snap.data()!;
          final qText = (d['question'] ?? '').toString();
          final aText = (d['answer'] ?? '').toString();
          final aReplies = (d['adminReplies'] as List?) ?? [];
          final uReplies = (d['userReplies'] as List?) ?? [];
          final ownerName = (d['name'] ?? AppLocalizations.of(context)!.user_label_default).toString();

          final List<Map<String, dynamic>> newMessages = [];
          newMessages.add({
            'text': qText,
            'isAdmin': false,
            'ts': d['createdAt'],
            'name': ownerName,
          });
          if (aText.isNotEmpty)
            newMessages.add({
              'text': aText,
              'isAdmin': true,
              'ts': d['answerAt'] ?? d['updatedAt'],
              'name': (d['answerAdminName'] ?? AppLocalizations.of(context)!.admin_title).toString(),
            });
          for (final ar in aReplies) {
            if (ar is Map) {
              final textVal =
                  (ar['text'] ?? ar['answer'] ?? ar['message'])?.toString() ??
                  ar.toString();
              final adminName = (ar['adminName'] ?? ar['name'] ?? AppLocalizations.of(context)!.admin_title)
                  .toString();
              newMessages.add({
                'text': textVal,
                'isAdmin': true,
                'ts': ar['createdAt'],
                'name': adminName,
              });
            } else {
              newMessages.add({
                'text': ar?.toString() ?? '',
                'isAdmin': true,
                'ts': null,
                'name': AppLocalizations.of(context)!.admin_title,
              });
            }
          }
          for (final ur in uReplies) {
            if (ur is Map) {
              final textVal =
                  (ur['text'] ?? ur['message'])?.toString() ?? ur.toString();
              final uName = (ur['name'] ?? ownerName).toString();
              newMessages.add({
                'text': textVal,
                'isAdmin': false,
                'ts': ur['createdAt'],
                'name': uName,
              });
            } else {
              newMessages.add({
                'text': ur?.toString() ?? '',
                'isAdmin': false,
                'ts': null,
                'name': ownerName,
              });
            }
          }

          int _tsToMs(dynamic ts) {
            try {
              if (ts == null) return 0;
              if (ts is Timestamp) return ts.millisecondsSinceEpoch;
              if (ts is DateTime) return ts.millisecondsSinceEpoch;
              if (ts is int) return ts;
              if (ts is String)
                return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
            } catch (_) {}
            return 0;
          }

          newMessages.sort(
            (a, b) => _tsToMs(a['ts']).compareTo(_tsToMs(b['ts'])),
          );

          setStateDialog?.call(() {
            messages
              ..clear()
              ..addAll(newMessages);
          });
        } catch (e) {
          debugPrint('Realtime admin doc listener error: $e');
        }
      },
      onError: (e) {
        debugPrint('admin doc snapshots listen error: $e');
      },
    );

    // show chat as a fullscreen page while keeping the realtime listener active
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx2) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.chat_page_title_prefix(
                  questionText.length > 40 ? questionText.substring(0, 40) + AppLocalizations.of(context)!.ellipsis : questionText,
                ),
              ),
            ),
            body: SafeArea(
              child: StatefulBuilder(
                builder: (ctx3, setState) {
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
                                final senderName =
                                  (m['name'] ??
                                      (isAdmin ? AppLocalizations.of(context)!.admin_title : AppLocalizations.of(context)!.user_label_default))
                                    .toString();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: isAdmin
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      senderName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isAdmin
                                            ? Colors.white70
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: isAdmin
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.66,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isAdmin
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            txt,
                                            style: TextStyle(
                                              color: isAdmin
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
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
                              child: TextField(
                                controller: replyCtrl,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.reply_hint,
                                ),
                                maxLines: 3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final text = replyCtrl.text.trim();
                                if (text.isEmpty) return;
                                String adminName = AppLocalizations.of(context)!.admin_title;
                                String? adminId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                try {
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  if (adminId != null) {
                                    final udoc = await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(adminId)
                                        .get();
                                    final udata = udoc.data();
                                    adminName =
                                        (udata != null && udata['name'] != null)
                                        ? udata['name'].toString()
                                        : (currentUser?.displayName ?? AppLocalizations.of(context)!.admin_title);
                                  } else {
                                    adminName =
                                        FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.displayName ??
                                        AppLocalizations.of(context)!.admin_title;
                                  }
                                } catch (_) {}

                                final reply = {
                                  'text': text,
                                  'createdAt': Timestamp.now(),
                                  'seenBy': <String>[],
                                  'adminName': adminName,
                                  'adminId': adminId,
                                };
                                try {
                                  await docRef.update({
                                    'adminReplies': FieldValue.arrayUnion([
                                      reply,
                                    ]),
                                    'adminNames': FieldValue.arrayUnion([
                                      adminName,
                                    ]),
                                    'updatedAt': FieldValue.serverTimestamp(),
                                    'userRead': false,
                                  });
                                  setStateDialog?.call(() {
                                    //messages.add({'text': text, 'isAdmin': true, 'ts': Timestamp.now(), 'name': adminName});
                                    replyCtrl.clear();
                                  });
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                  if (scrollCtrl.hasClients)
                                    scrollCtrl.jumpTo(
                                      scrollCtrl.position.maxScrollExtent,
                                    );
                                  // Notify the user of this admin reply via backend
                                  try {
                                    final userId = data['userId']?.toString();
                                    debugPrint('AdminScreen: Attempting to notify user. userId=$userId');
                                    if (userId != null && userId.isNotEmpty) {
                                      final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/notify');
                                      final payload = {
                                        'type': 'adminToUser',
                                        'userId': userId,
                                        'title': AppLocalizations.of(context)!.notify_title,
                                        'body': text,
                                        'data': {'conversationId': docId}
                                      };
                                      debugPrint('AdminScreen: Sending payload: ${json.encode(payload)}');
                                      final resp = await http.post(uri,
                                        headers: {'Content-Type': 'application/json'},
                                        body: json.encode(payload),
                                      );
                                      debugPrint('AdminScreen: Notify response status: ${resp.statusCode}');
                                      debugPrint('AdminScreen: Notify response body: ${resp.body}');
                                    } else {
                                      debugPrint('AdminScreen: Cannot notify user, userId is null or empty in document data.');
                                    }
                                  } catch (e) {
                                    debugPrint('AdminScreen: Failed to notify user: $e');
                                  }
                                  } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(AppLocalizations.of(context)!.send_failed),
                                    ),
                                  );
                                }
                              },
                              child: Text(AppLocalizations.of(context)!.send),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    // stop realtime listener when page is popped
    await docSub?.cancel();
  }

  Widget _buildFaqsTab() {
    final col = FirebaseFirestore.instance
        .collection('faqs')
        .orderBy('createdAt', descending: true);
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: col.snapshots(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty)
                return Center(child: Text(AppLocalizations.of(context)!.no_faq_items));
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(a),
                      ),
                      ButtonBar(
                        children: [
                          TextButton(
                            onPressed: () => _editFaq(d.id, q, a),
                            child: Text(AppLocalizations.of(context)!.edit),
                          ),
                          TextButton(
                            onPressed: () => _deleteFaq(d.id),
                            child: Text(AppLocalizations.of(context)!.remove),
                          ),
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
            label: Text(AppLocalizations.of(context)!.add_new_faq),
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
        title: Text(AppLocalizations.of(ctx)!.new_faq_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.question_label),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: aCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.answer_label),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx)!.add),
          ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.faq_added)));
    } catch (e) {
      debugPrint('Failed to add faq: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.faq_add_failed)));
    }
  }

  Future<void> _editFaq(String id, String currentQ, String currentA) async {
    final qCtrl = TextEditingController(text: currentQ);
    final aCtrl = TextEditingController(text: currentA);
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.edit_faq_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.question_label),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: aCtrl,
              decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.answer_label),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx)!.save),
          ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.faq_updated)));
    } catch (e) {
      debugPrint('Failed to update faq: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.faq_update_failed)));
    }
  }

  Future<void> _deleteFaq(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.delete_faq_title),
        content: Text(AppLocalizations.of(ctx)!.delete_faq_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx)!.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await FirebaseFirestore.instance.collection('faqs').doc(id).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.faq_deleted)));
    } catch (e) {
      debugPrint('Failed to delete faq: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.faq_delete_failed)));
    }
  }
}
