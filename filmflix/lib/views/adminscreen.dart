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
  // AdminScreen is een StatefulWidget omdat we realtime updates van Firestore willen ontvangen en de UI willen bijwerken op basis van die updates.
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState(); // Deze methode maakt de mutable state voor deze widget, wat betekent dat we een _AdminScreenState klasse hebben die de daadwerkelijke logica en UI bevat.
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    // De build methode is waar we de UI van deze screen definiëren. We gebruiken een DefaultTabController om tabbladen te maken voor "Chats" en "FAQs", zodat admins gemakkelijk kunnen navigeren tussen deze twee secties.
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.admin_title),
          bottom: TabBar(
            // De TabBar definieert de tabbladen die we willen tonen. In dit geval hebben we twee tabbladen: één voor chats en één voor FAQs. We gebruiken AppLocalizations om de tekst van de tabbladen te vertalen op basis van de huidige taalinstellingen van de app.
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
    final user = FirebaseAuth
        .instance
        .currentUser; //dit is de huidige ingelogde gebruiker
    if (user == null) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          //alertdialog is een pop-up venster dat we gebruiken om de gebruiker te informeren dat ze niet zijn ingelogd, wat een mogelijke reden kan zijn waarom ze geen toegang hebben tot bepaalde functies in de admin screen.
          title: Text(AppLocalizations.of(ctx)!.not_logged_in_title),
          content: Text(AppLocalizations.of(ctx)!.not_logged_in_message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(
                ctx,
              ).pop(), //pop betekent dat we het dialog venster sluiten wanneer de gebruiker op de "Close" knop klikt.
              child: Text(AppLocalizations.of(ctx)!.close),
            ),
          ],
        ),
      );
      return;
    }

    String roleText = AppLocalizations.of(context)!.no_users_doc;
    try {
      final doc = await FirebaseFirestore
          .instance // we proberen het document van de huidige gebruiker op te halen uit de "users" collectie in Firestore. Dit document zou informatie moeten bevatten over de rol van de gebruiker (bijvoorbeeld admin, moderator, etc.), wat can helpen bij het diagnosticeren van problemen met toegangsrechten.
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null && data['role'] != null) {
        // Als het document bestaat en er een "role" veld is, tonen we die rol in de dialog. Dit kan admins helpen begrijpen welke permissies ze hebben en waarom ze mogelijk geen toegang hebben tot bepaalde functies.
        roleText = AppLocalizations.of(
          context,
        )!.users_doc_role(user.uid, data['role'].toString());
      } else {
        roleText = AppLocalizations.of(context)!.users_doc_no_role(user.uid);
      }
    } catch (e) {
      roleText = AppLocalizations.of(
        context,
      )!.users_doc_read_error(e.toString());
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.check_permissions_title),
        content: SingleChildScrollView(
          // SingleChildScrollView zorgt ervoor dat de inhoud van de dialog scrollbaar is als deze te lang is om in het venster te passen, wat handig kan zijn als er veel informatie wordt weergegeven over mogelijke oorzaken van toegangsproblemen en de huidige gebruikersdocumentstatus.
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

  Future<void> _promptAndFetchDoc() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String?>(
      ///res omdat we de ID van het document willen terugkrijgen dat de admin wil opzoeken. We gebruiken een TextEditingController om de invoer van de gebruiker te beheren in het TextField van de dialog, zodat we later kunnen ophalen welke document ID ze hebben ingevoerd.
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
    if (res == null || res.isEmpty)
      return; // Als de admin geen ID invoert of de actie annuleert, doen we niets. Anders proberen we het document op te halen uit de "customerquestions" collectie in Firestore met de opgegeven ID en tonen we de inhoud ervan in een nieuwe dialog. Dit kan admins helpen bij het debuggen van problemen met specifieke chats of vragen die gebruikers hebben ingediend.

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
      final data = doc
          .data(); // data bevat de inhoud van het opgehaalde document, wat we vervolgens in een dialog tonen. We gebruiken AppLocalizations om de tekst in de dialog te vertalen, en we zorgen ervoor dat als er geen data is, we een bericht tonen dat aangeeft dat het document leeg is.
      debugPrint('fetchDoc ${res}: $data');
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.document_title(res)),
          content: SingleChildScrollView(
            // SingleChildScrollView zorgt ervoor dat de inhoud van de dialog scrollbaar is als deze te lang is om in het venster te passen, wat handig kan zijn als het document veel gegevens bevat.
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
          content: Text(
            AppLocalizations.of(ctx)!.fetch_error_message(e.toString()),
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
  }

  Widget _buildChatsTab() {
    // Bouwt de UI voor het "Chats" tabblad met realtime Firestore data
    final col = FirebaseFirestore.instance
        // Haalt de 'customerquestions' collectie op
        .collection('customerquestions')
        // Sorteert op 'updatedAt' in aflopende volgorde (nieuwste eerst)
        .orderBy('updatedAt', descending: true);
    // Retourneert een StreamBuilder die luistert naar realtime updates
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      // Luistert naar snapshots van de gesorteerde query
      stream: col.snapshots(),
      // Builder functie die aangeroepen wordt bij elke snapshot update
      builder: (ctx, snap) {
        // Controleert of er een fout is opgetreden bij het ophalen van gegevens
        if (snap.hasError) {
          // Print de fout voor debugging
          debugPrint('customerquestions stream error: ${snap.error}');
          // Toont een error UI met lock icoon en foutbericht
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toont een lock icoon
                  const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  // Toont het foutbericht
                  Text(
                    AppLocalizations.of(
                      ctx,
                    )!.cannot_load_chats(snap.error?.toString() ?? ''),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        // Controleert of de gegevens nog worden geladen
        if (snap.connectionState == ConnectionState.waiting)
          // Toont een laadspinner
          return const Center(child: CircularProgressIndicator());
        // Controleert of er geen gegevens beschikbaar zijn
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          // Haalt de huidige gebruiker ID op voor debugging
          final uid = FirebaseAuth.instance.currentUser?.uid;
          // Print debugging info
          debugPrint('customerquestions: no docs (uid=$uid)');
          // Toont een UI als er geen vragen zijn
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toont bericht dat geen vragen gevonden zijn
                  Text(AppLocalizations.of(context)!.no_questions_found),
                  const SizedBox(height: 8),
                  // Knop om debug info te tonen
                  ElevatedButton(
                    onPressed: _promptAndFetchDoc,
                    child: Text(AppLocalizations.of(context)!.show_debug_info),
                  ),
                ],
              ),
            ),
          );
        }
        // Haalt alle documenten uit de snapshot
        final docs = snap.data!.docs;
        // Haalt het huidige gebruiker ID op voor debugging
        final uid = FirebaseAuth.instance.currentUser?.uid;
        // Print hoeveel documenten opgehaald zijn
        debugPrint('customerquestions snapshot: count=${docs.length} uid=$uid');
        // Loopt door alle documenten en print hun data
        for (final dd in docs) {
          try {
            debugPrint('customerquestions doc ${dd.id}: ${dd.data()}');
          } catch (e) {
            debugPrint('Failed to print doc ${dd.id}: $e');
          }
        }
        // Retourneert een ListView met alle gesprekken
        return ListView.separated(
          // Aantal items in de lijst
          itemCount: docs.length,
          // Scheidt items met een divider lijn
          separatorBuilder: (_, __) => const Divider(height: 1),
          // Bouwt elk ListTile item
          itemBuilder: (c, i) {
            // Haalt het huidige document op
            final d = docs[i];
            // Haalt de data uit het document
            final data = d.data();
            // Haalt de initiële vraag tekst op
            final question = (data['question'] ?? '').toString();
            // Zet de preview tekst gelijk aan de vraag
            String preview = question;
            // Haalt alle admin replies op
            final adminReplies = (data['adminReplies'] as List?) ?? [];
            // Haalt alle user replies op
            final userReplies = (data['userReplies'] as List?) ?? [];
            // Haalt het antwoord tekst op
            final answer = (data['answer'] ?? '').toString();

            // Helper functie die verschillende timestamp formaten naar DateTime converteert
            DateTime? _toDt(dynamic ts) {
              try {
                if (ts == null) return null;
                if (ts is Timestamp) return ts.toDate();
                if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
                if (ts is String) return DateTime.tryParse(ts);
              } catch (_) {}
              return null;
            }

            // Helper functie die tekst uit een Map haalt met fallback opties
            String _extractTextFromMap(Map m) {
              // Controleert eerst op 'text' veld
              if (m['text'] != null && m['text'].toString().trim().isNotEmpty)
                return m['text'].toString();
              // Fallback op 'answer' veld
              if (m['answer'] != null &&
                  m['answer'].toString().trim().isNotEmpty)
                return m['answer'].toString();
              // Fallback op 'message' veld
              if (m['message'] != null &&
                  m['message'].toString().trim().isNotEmpty)
                return m['message'].toString();
              // Pakt de eerste string waarde uit de Map
              final firstString = m.values.firstWhere(
                (v) =>
                    v != null && v is String && v.toString().trim().isNotEmpty,
                orElse: () => null,
              );
              // Retourneert de gevonden string of de hele Map als string
              return firstString?.toString() ?? m.toString();
            }

            // Zet de initiële laatste timestamp op createdAt
            DateTime? lastDt = _toDt(data['createdAt']);
            // Zet de initiële laatste tekst op de preview
            String lastText = preview;

            // Controleert of er een antwoord is
            if (answer.isNotEmpty) {
              // Haalt de answerAt of updatedAt timestamp op
              final dt = _toDt(data['answerAt'] ?? data['updatedAt']);
              // Controleert of deze timestamp recenter is dan de huidge lastDt
              if (dt != null && (lastDt == null || dt.isAfter(lastDt))) {
                // Updatet lastDt naar het antwoord timestamp
                lastDt = dt;
                // Updatet lastText naar het antwoord
                lastText = answer;
              }
            }

            // Loopt door alle admin replies
            for (final ar in adminReplies) {
              try {
                // Declareert variabelen voor tekst en timestamp
                String text;
                dynamic rawTs;
                // Controleert of ar een Map is
                if (ar is Map) {
                  // Haalt tekst uit de Map
                  text = _extractTextFromMap(ar);
                  // Haalt de timestamp op
                  rawTs = ar['createdAt'] ?? ar['answerAt'] ?? ar['updatedAt'];
                } else {
                  // Converteert ar naar string als het geen Map is
                  text = ar?.toString() ?? '';
                  // Zet rawTs op null
                  rawTs = null;
                }
                // Converteert rawTs naar DateTime
                final dt = _toDt(rawTs);
                // Controleert of deze timestamp recenter is
                if (dt != null && (lastDt == null || dt.isAfter(lastDt))) {
                  // Updatet lastDt
                  lastDt = dt;
                  // Updatet lastText
                  lastText = text;
                }
              } catch (_) {}
            }

            // Loopt door alle user replies
            for (final ur in userReplies) {
              try {
                // Declareert variabelen voor tekst en timestamp
                String text;
                dynamic rawTs;
                // Controleert of ur een Map is
                if (ur is Map) {
                  // Haalt tekst uit de Map
                  text = _extractTextFromMap(ur);
                  // Haalt de timestamp op
                  rawTs = ur['createdAt'] ?? ur['updatedAt'];
                } else {
                  // Converteert ur naar string als het geen Map is
                  text = ur?.toString() ?? '';
                  // Zet rawTs op null
                  rawTs = null;
                }
                // Converteert rawTs naar DateTime
                final dt = _toDt(rawTs);
                // Controleert of deze timestamp recenter is
                if (dt != null && (lastDt == null || dt.isAfter(lastDt))) {
                  // Updatet lastDt
                  lastDt = dt;
                  // Updatet lastText
                  lastText = text;
                }
              } catch (_) {}
            }

            // Zet preview op de laatst gevonden tekst
            preview = lastText;
            // Initialiseert timeText als lege string
            String timeText = '';
            try {
              // Controleert of lastDt niet null is
              if (lastDt != null) {
                // Converteert naar locale timezone
                final dt = lastDt.toLocal();
                // Format timestamp als dag/maand uur:minuut
                timeText =
                    '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              }
            } catch (_) {}

            // Helper functie die verschillende timestamp formaten naar milliseconden converteert
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

            // Haalt de createdAt timestamp van de vraag in milliseconden
            int lastUserMs = _tsToMs(data['createdAt']);
            // Loopt door alle user replies
            for (final ur in userReplies) {
              try {
                // Haalt het timestamp uit de user reply
                final ts = ur is Map
                    ? (ur['createdAt'] ?? ur['updatedAt'])
                    : null;
                // Zet lastUserMs op de maximale waarde
                lastUserMs = Math.max(lastUserMs, _tsToMs(ts));
              } catch (_) {}
            }

            // Zet lastAdminMs op answerAt of updatedAt timestamp
            int lastAdminMs = _tsToMs(data['answerAt'] ?? data['updatedAt']);
            // Controleert of er een antwoord is
            if (answer.isNotEmpty)
              // Zet lastAdminMs op de maximale waarde
              lastAdminMs = Math.max(
                lastAdminMs,
                _tsToMs(data['answerAt'] ?? data['updatedAt']),
              );
            // Updatet lastAdminMs met adminSeenAt timestamp
            lastAdminMs = Math.max(lastAdminMs, _tsToMs(data['adminSeenAt']));
            // Loopt door alle admin replies
            for (final ar in adminReplies) {
              try {
                // Haalt het timestamp uit de admin reply
                final ts = ar is Map
                    ? (ar['createdAt'] ?? ar['answerAt'] ?? ar['updatedAt'])
                    : null;
                // Zet lastAdminMs op de maximale waarde
                lastAdminMs = Math.max(lastAdminMs, _tsToMs(ts));
              } catch (_) {}
            }
            // Haalt de adminSeenAt timestamp in milliseconden
            final int adminSeenMs = _tsToMs(data['adminSeenAt']);
            // Controleert of er geen admin activiteit is geweest
            final bool noAdminActivity =
                answer.isEmpty && (adminReplies.isEmpty);
            // Haalt de adminRead flag op, default op true als niet aanwezig
            final bool adminReadFlag = data['adminRead'] is bool
                ? data['adminRead'] as bool
                : true;
            // Controleert of de chat ongelezen is voor admin
            final bool unreadForAdmin =
                (!adminReadFlag && lastUserMs > 0) ||
                (lastUserMs > lastAdminMs);

            // Retourneert een Dismissible widget zodat items kunnen worden geswiped
            return Dismissible(
              // Unieke key voor het widget
              key: ValueKey(d.id),
              // Staat swipen toe in beide richtingen
              direction: DismissDirection.horizontal,
              // Swipe naar rechts: markeer als ongelezen
              background: Container(
                // Blauwe achtergrond
                color: Colors.blueAccent,
                // Align icoon naar links
                alignment: Alignment.centerLeft,
                // Padding rond het icoon
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // Toont markunread icoon
                child: const Icon(Icons.markunread, color: Colors.white),
              ),
              // Swipe naar links: verwijder
              secondaryBackground: Container(
                // Rode achtergrond
                color: Colors.red,
                // Align icoon naar rechts
                alignment: Alignment.centerRight,
                // Padding rond het icoon
                padding: const EdgeInsets.symmetric(horizontal: 16),
                // Toont delete icoon
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              // Bevestigt of het item wil worden verwijderd
              confirmDismiss: (direction) async {
                // Haalt de document reference op
                final docRef = FirebaseFirestore.instance
                    .collection('customerquestions')
                    .doc(d.id);
                // Controleert of naar rechts is geswiped
                if (direction == DismissDirection.startToEnd) {
                  // Markeer als ongelezen
                  try {
                    // Update het adminRead veld naar false
                    await docRef.update({'adminRead': false});
                    // Controleert of de widget nog mounted is
                    if (mounted)
                      // Toont een snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.marked_unread,
                          ),
                        ),
                      );
                  } catch (e) {
                    // Print de fout
                    debugPrint('Failed to mark chat ${d.id} as unread: $e');
                    // Controleert of de widget nog mounted is
                    if (mounted)
                      // Toont error snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "AppLocalizations.of(context)!.action_failed",
                          ),
                        ),
                      );
                  }
                  // Retourneert false zodat het item niet wordt verwijderd
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  // Toont een bevestigingsdialog voor verwijdering
                  final confirm = await showDialog<bool>(
                    context: ctx,
                    builder: (confirmCtx) => AlertDialog(
                      // Dialog titel
                      title: Text(
                        AppLocalizations.of(confirmCtx)!.delete_chat_title,
                      ),
                      // Dialog inhoud
                      content: Text(
                        AppLocalizations.of(confirmCtx)!.delete_chat_confirm,
                      ),
                      // Dialog knoppen
                      actions: [
                        // Cancel knop
                        TextButton(
                          onPressed: () => Navigator.of(confirmCtx).pop(false),
                          child: Text(AppLocalizations.of(confirmCtx)!.cancel),
                        ),
                        // Delete knop met rode achtergrond
                        ElevatedButton(
                          onPressed: () => Navigator.of(confirmCtx).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(AppLocalizations.of(confirmCtx)!.delete),
                        ),
                      ],
                    ),
                  );
                  // Retourneert true als gebruiker bevestigd heeft
                  return confirm == true;
                }
                // Retourneert false als geen actie nodig is
                return false;
              },
              // Wordt aangeroepen nadat het item is gedismissed
              onDismissed: (direction) async {
                // Controleert of naar links is geswiped (delete)
                if (direction == DismissDirection.endToStart) {
                  try {
                    // Verwijdert het document uit Firestore
                    await FirebaseFirestore.instance
                        .collection('customerquestions')
                        .doc(d.id)
                        .delete();
                    // Controleert of de widget nog mounted is
                    if (mounted)
                      // Toont success snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.chat_deleted,
                          ),
                        ),
                      );
                  } catch (e) {
                    // Print de fout
                    debugPrint('Failed to delete chat ${d.id}: $e');
                    // Controleert of de widget nog mounted is
                    if (mounted)
                      // Toont error snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.delete_failed,
                          ),
                        ),
                      );
                  }
                }
              },
              // Het child widget dat wordt getoond
              child: ListTile(
                // Avatar aan de linkerkant
                leading: Stack(
                  // Clipt alle content niet
                  clipBehavior: Clip.none,
                  children: [
                    // Toont een persoon icoon
                    const CircleAvatar(child: Icon(Icons.person)),
                    // Controleert of de chat ongelezen is
                    if (unreadForAdmin)
                      // Toont een rode notificatie badge
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
                // Titel van de ListTile (de vraag)
                title: Text(
                  question,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Subtitel met preview en admin info
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Toont preview van het laatst bericht
                    Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    // Builder voor admin namen
                    Builder(
                      builder: (_) {
                        // Haalt de gebruiker naam op
                        final userName =
                            (data['name'] ??
                                    AppLocalizations.of(
                                      context,
                                    )!.user_label_default)
                                .toString();
                        // Haalt de admin namen op
                        final adminNames = (data['adminNames'] as List?) ?? [];
                        // Bouwt admin tekst
                        final adminText = adminNames.isNotEmpty
                            ? AppLocalizations.of(context)!.admins_label(
                                adminNames.map((e) => e.toString()).join(', '),
                              )
                            : '';
                        // Retourneert admin tekst of leeg widget
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
                // Trailing widget aan de rechterkant
                trailing: SizedBox(
                  height: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Toont de tijd als deze aanwezig is
                      if (timeText.isNotEmpty)
                        Text(timeText, style: const TextStyle(fontSize: 11)),
                      // Open knop
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
                // Wordt aangeroepen wanneer op het item wordt getikt
                onTap: () => _openAdminChat(d.id),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openAdminChat(String docId) async {
    // Haalt de document reference op voor de geselecteerde chat
    final docRef = FirebaseFirestore.instance
        .collection('customerquestions')
        .doc(docId);
    // Haalt het huidige document op uit Firestore
    final snap = await docRef.get();
    // Stopt de functie als het document niet bestaat
    if (!snap.exists) return;
    // Markeert de chat als gelezen door deze admin met server timestamp
    try {
      await docRef.set({
        'adminSeenAt': FieldValue.serverTimestamp(),
        'adminRead': true,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to set adminSeenAt: $e');
    }
    // Haalt alle gegevens uit het document op
    final data = snap.data()!;
    // Extraheert de vraag tekst uit het document
    final questionText = (data['question'] ?? '').toString();
    // Extraheert het antwoord tekst uit het document
    final answerText = (data['answer'] ?? '').toString();
    // Haalt alle admin replies op als een lijst (leeg als niet aanwezig)
    final adminReplies = (data['adminReplies'] as List?) ?? [];
    // Haalt alle user replies op als een lijst (leeg als niet aanwezig)
    final userReplies = (data['userReplies'] as List?) ?? [];

    // Maakt een controller voor het reply input veld
    final TextEditingController replyCtrl = TextEditingController();
    // Maakt een controller voor het scroll gedrag van de chat
    final ScrollController scrollCtrl = ScrollController();

    // Initialiseert een lege lijst voor alle berichten
    final List<Map<String, dynamic>> messages = [];
    // Haalt de naam van de vraagsteller op (of default tekst)
    final ownerName =
        (data['name'] ?? AppLocalizations.of(context)!.user_label_default)
            .toString();
    // Voegt de oorspronkelijke vraag toe aan de berichtenlijst
    messages.add({
      'text': questionText,
      'isAdmin': false,
      'ts': data['createdAt'],
      'name': ownerName,
    });
    // Voegt het antwoord toe aan de berichtenlijst als het niet leeg is
    if (answerText.isNotEmpty)
      messages.add({
        'text': answerText,
        'isAdmin': true,
        'ts': data['answerAt'] ?? data['updatedAt'],
        'name':
            (data['answerAdminName'] ??
                    AppLocalizations.of(context)!.admin_title)
                .toString(),
      });
    // Loopt door alle admin replies
    for (final ar in adminReplies) {
      // Controleert of de admin reply een Map object is
      if (ar is Map) {
        // Extraheert de tekst uit de admin reply met fallbacks
        final textVal =
            (ar['text'] ?? ar['answer'] ?? ar['message'])?.toString() ??
            ar.toString();
        // Haalt de naam van de admin op
        final adminName =
            (ar['adminName'] ??
                    ar['name'] ??
                    AppLocalizations.of(context)!.admin_title)
                .toString();
        // Voegt de admin reply toe aan de berichtenlijst
        messages.add({
          'text': textVal,
          'isAdmin': true,
          'ts': ar['createdAt'],
          'name': adminName,
        });
      } else {
        // Voegt de admin reply toe als string als het geen Map is
        messages.add({
          'text': ar?.toString() ?? '',
          'isAdmin': true,
          'ts': null,
          'name': AppLocalizations.of(context)!.admin_title,
        });
      }
    }
    // Loopt door alle user replies
    for (final ur in userReplies) {
      // Controleert of de user reply een Map object is
      if (ur is Map) {
        // Extraheert de tekst uit de user reply met fallbacks
        final textVal =
            (ur['text'] ?? ur['message'])?.toString() ?? ur.toString();
        // Haalt de naam van de user op (of de vraagsteller naam)
        final uName = (ur['name'] ?? ownerName).toString();
        // Voegt de user reply toe aan de berichtenlijst
        messages.add({
          'text': textVal,
          'isAdmin': false,
          'ts': ur['createdAt'],
          'name': uName,
        });
      } else {
        // Voegt de user reply toe als string als het geen Map is
        messages.add({
          'text': ur?.toString() ?? '',
          'isAdmin': false,
          'ts': null,
          'name': ownerName,
        });
      }
    }

    // Definieert een helper functie die timestamp naar milliseconden converteert
    int _tsToMs(dynamic ts) {
      try {
        // Controleert als timestamp null is
        if (ts == null) return 0;
        // Converteert Firestore Timestamp naar milliseconden
        if (ts is Timestamp) return ts.millisecondsSinceEpoch;
        // Converteert DateTime naar milliseconden
        if (ts is DateTime) return ts.millisecondsSinceEpoch;
        // Retourneert direct als het al een int is
        if (ts is int) return ts;
        // Parsed een string timestamp naar milliseconden
        if (ts is String) {
          final dt = DateTime.tryParse(ts);
          return dt?.millisecondsSinceEpoch ?? 0;
        }
      } catch (_) {}
      // Retourneert 0 als conversie mislukt
      return 0;
    }

    // Sorteert alle berichten op timestamp van oud naar nieuw
    messages.sort((a, b) => _tsToMs(a['ts']).compareTo(_tsToMs(b['ts'])));

    // Initialiseert variabele voor de document listener
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? docSub;
    // Initialiseert variabele voor setState callback van de dialog
    void Function(void Function())? setStateDialog;
    // Luistert naar realtime updates van het document
    docSub = docRef.snapshots().listen(
      (snap) {
        // Stopt de verwerking als het document niet meer bestaat
        if (!snap.exists) return;
        try {
          // Haalt alle gegevens uit het bijgewerkte document op
          final d = snap.data()!;
          // Extraheert de vraag tekst
          final qText = (d['question'] ?? '').toString();
          // Extraheert het antwoord tekst
          final aText = (d['answer'] ?? '').toString();
          // Haalt alle admin replies op
          final aReplies = (d['adminReplies'] as List?) ?? [];
          // Haalt alle user replies op
          final uReplies = (d['userReplies'] as List?) ?? [];
          // Haalt de naam van de vraagsteller op
          final ownerName =
              (d['name'] ?? AppLocalizations.of(context)!.user_label_default)
                  .toString();

          // Initialiseert een nieuwe berichtenlijst met bijgewerkte gegevens
          final List<Map<String, dynamic>> newMessages = [];
          // Voegt de oorspronkelijke vraag toe aan de berichtenlijst
          newMessages.add({
            'text': qText,
            'isAdmin': false,
            'ts': d['createdAt'],
            'name': ownerName,
          });
          // Voegt het antwoord toe als het niet leeg is
          if (aText.isNotEmpty)
            newMessages.add({
              'text': aText,
              'isAdmin': true,
              'ts': d['answerAt'] ?? d['updatedAt'],
              'name':
                  (d['answerAdminName'] ??
                          AppLocalizations.of(context)!.admin_title)
                      .toString(),
            });
          // Loopt door alle bijgewerkte admin replies
          for (final ar in aReplies) {
            // Controleert of de admin reply een Map is
            if (ar is Map) {
              // Extraheert de tekst uit de admin reply
              final textVal =
                  (ar['text'] ?? ar['answer'] ?? ar['message'])?.toString() ??
                  ar.toString();
              // Haalt de naam van de admin op
              final adminName =
                  (ar['adminName'] ??
                          ar['name'] ??
                          AppLocalizations.of(context)!.admin_title)
                      .toString();
              // Voegt de admin reply toe aan de berichtenlijst
              newMessages.add({
                'text': textVal,
                'isAdmin': true,
                'ts': ar['createdAt'],
                'name': adminName,
              });
            } else {
              // Voegt de admin reply toe als string
              newMessages.add({
                'text': ar?.toString() ?? '',
                'isAdmin': true,
                'ts': null,
                'name': AppLocalizations.of(context)!.admin_title,
              });
            }
          }
          // Loopt door alle bijgewerkte user replies
          for (final ur in uReplies) {
            // Controleert of de user reply een Map is
            if (ur is Map) {
              // Extraheert de tekst uit de user reply
              final textVal =
                  (ur['text'] ?? ur['message'])?.toString() ?? ur.toString();
              // Haalt de naam van de user op
              final uName = (ur['name'] ?? ownerName).toString();
              // Voegt de user reply toe aan de berichtenlijst
              newMessages.add({
                'text': textVal,
                'isAdmin': false,
                'ts': ur['createdAt'],
                'name': uName,
              });
            } else {
              // Voegt de user reply toe als string
              newMessages.add({
                'text': ur?.toString() ?? '',
                'isAdmin': false,
                'ts': null,
                'name': ownerName,
              });
            }
          }

          // Definieert een helper functie voor timestamp conversie
          int _tsToMs(dynamic ts) {
            try {
              // Retourneert 0 als timestamp null is
              if (ts == null) return 0;
              // Converteert Firestore Timestamp naar milliseconden
              if (ts is Timestamp) return ts.millisecondsSinceEpoch;
              // Converteert DateTime naar milliseconden
              if (ts is DateTime) return ts.millisecondsSinceEpoch;
              // Retourneert direct als het al een int is
              if (ts is int) return ts;
              // Parsed een string timestamp naar milliseconden
              if (ts is String)
                return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
            } catch (_) {}
            // Retourneert 0 als conversie mislukt
            return 0;
          }

          // Sorteert alle berichten op timestamp van oud naar nieuw
          newMessages.sort(
            (a, b) => _tsToMs(a['ts']).compareTo(_tsToMs(b['ts'])),
          );

          // Werkt de UI bij met de nieuwe berichtenlijst
          setStateDialog?.call(() {
            messages
              ..clear()
              ..addAll(newMessages);
          });
        } catch (e) {
          // Print fout bij realtime luisteren
          debugPrint('Realtime admin doc listener error: $e');
        }
      },
      // Behandelt fouten bij het luisteren naar snapshots
      onError: (e) {
        debugPrint('admin doc snapshots listen error: $e');
      },
    );

    // Opent de chatpagina als vollschermpagina terwijl realtime listener actief blijft
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx2) {
          return Scaffold(
            // Appbar met titel van de chat
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)!.chat_page_title_prefix(
                  questionText.length > 40
                      ? questionText.substring(0, 40) +
                            AppLocalizations.of(context)!.ellipsis
                      : questionText,
                ),
              ),
            ),
            // Body met veilige gebied en stateful builder
            body: SafeArea(
              child: StatefulBuilder(
                builder: (ctx3, setState) {
                  // Wijs setState callback toe voor realtime updates
                  setStateDialog = setState;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Expandible container voor berichtenoverzicht
                        Expanded(
                          child: ListView.builder(
                            controller: scrollCtrl,
                            itemCount: messages.length,
                            itemBuilder: (c, i) {
                              // Haalt het huidige bericht op
                              final m = messages[i];
                              // Controleert of bericht van admin is
                              final isAdmin = m['isAdmin'] == true;
                              // Haalt de berichtekst op
                              final txt = (m['text'] ?? '').toString();
                              // Haalt de naam van de afzender op
                              final senderName =
                                  (m['name'] ??
                                          (isAdmin
                                              ? AppLocalizations.of(
                                                  context,
                                                )!.admin_title
                                              : AppLocalizations.of(
                                                  context,
                                                )!.user_label_default))
                                      .toString();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 8,
                                ),
                                child: Column(
                                  // Align berichten links voor user, rechts voor admin
                                  crossAxisAlignment: isAdmin
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    // Toont de naam van de afzender
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
                                    // Voegt ruimte toe tussen naam en bericht
                                    const SizedBox(height: 4),
                                    // Rij met het berichtbubbel
                                    Row(
                                      // Align berichten links voor user, rechts voor admin
                                      mainAxisAlignment: isAdmin
                                          ? MainAxisAlignment.end
                                          : MainAxisAlignment.start,
                                      children: [
                                        // Berichtbubbel container
                                        Container(
                                          // Beperk breedte van bericht tot 66% van scherm
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.66,
                                          ),
                                          // Binnenruimte van het bubbel
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 12,
                                          ),
                                          // Styling van het berichtbubbel
                                          decoration: BoxDecoration(
                                            // Blauw voor admin, grijs voor user
                                            color: isAdmin
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Colors.grey.shade200,
                                            // Afgeronde hoeken
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          // Berichtekst
                                          child: Text(
                                            txt,
                                            style: TextStyle(
                                              // Wit voor admin, zwart voor user
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
                        // Voegt ruimte toe boven het input veld
                        const SizedBox(height: 8),
                        // Rij met input veld en verzendknop
                        Row(
                          children: [
                            // Expandible input veld voor reply
                            Expanded(
                              child: TextField(
                                controller: replyCtrl,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.reply_hint,
                                ),
                                maxLines: 3,
                              ),
                            ),
                            // Voegt ruimte toe tussen input en knop
                            const SizedBox(width: 8),
                            // Verzendknop
                            ElevatedButton(
                              onPressed: () async {
                                // Haalt de ingevoerde tekst op
                                final text = replyCtrl.text.trim();
                                // Stopt als input leeg is
                                if (text.isEmpty) return;
                                // Initialiseert admin naam
                                String adminName = AppLocalizations.of(
                                  context,
                                )!.admin_title;
                                // Haalt de ID van de huidige admin op
                                String? adminId =
                                    FirebaseAuth.instance.currentUser?.uid;
                                try {
                                  // Haalt de huidige gebruiker op
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  // Controleert als admin ID aanwezig is
                                  if (adminId != null) {
                                    // Haalt het user document van de admin op
                                    final udoc = await FirebaseFirestore
                                        .instance
                                        .collection('users')
                                        .doc(adminId)
                                        .get();
                                    // Haalt data uit het user document
                                    final udata = udoc.data();
                                    // Zet admin naam uit document of fallback
                                    adminName =
                                        (udata != null && udata['name'] != null)
                                        ? udata['name'].toString()
                                        : (currentUser?.displayName ??
                                              AppLocalizations.of(
                                                context,
                                              )!.admin_title);
                                  } else {
                                    // Zet admin naam uit displayName of fallback
                                    adminName =
                                        FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.displayName ??
                                        AppLocalizations.of(
                                          context,
                                        )!.admin_title;
                                  }
                                } catch (_) {}

                                // Bouwt het reply object
                                final reply = {
                                  'text': text,
                                  'createdAt': Timestamp.now(),
                                  'seenBy': <String>[],
                                  'adminName': adminName,
                                  'adminId': adminId,
                                };
                                try {
                                  // Update het document met de nieuwe reply
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
                                  // Werkt UI bij en wist input veld
                                  setStateDialog?.call(() {
                                    replyCtrl.clear();
                                  });
                                  // Wacht even voordat we scrollen
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                  // Scroll naar beneden als scroll controller beschikbaar is
                                  if (scrollCtrl.hasClients)
                                    scrollCtrl.jumpTo(
                                      scrollCtrl.position.maxScrollExtent,
                                    );
                                  // Stuur notificatie naar gebruiker via backend
                                  try {
                                    // Haalt de user ID op uit document data
                                    final userId = data['userId']?.toString();
                                    // Print debug info
                                    debugPrint(
                                      'AdminScreen: Attempting to notify user. userId=$userId',
                                    );
                                    // Controleert als userId geldig is
                                    if (userId != null && userId.isNotEmpty) {
                                      // Bouwt de URI voor de notification endpoint
                                      final uri = Uri.parse(
                                        'https://film-flix-olive.vercel.app/apiv2/notify',
                                      );
                                      // Bouwt de notification payload
                                      final payload = {
                                        'type': 'adminToUser',
                                        'userId': userId,
                                        'title': AppLocalizations.of(
                                          context,
                                        )!.notify_title,
                                        'body': text,
                                        'data': {'conversationId': docId},
                                      };
                                      // Print de payload voor debugging
                                      debugPrint(
                                        'AdminScreen: Sending payload: ${json.encode(payload)}',
                                      );
                                      // Stuurt HTTP POST request naar backend
                                      final resp = await http.post(
                                        uri,
                                        headers: {
                                          'Content-Type': 'application/json',
                                        },
                                        body: json.encode(payload),
                                      );
                                      // Print response status
                                      debugPrint(
                                        'AdminScreen: Notify response status: ${resp.statusCode}',
                                      );
                                      // Print response body
                                      debugPrint(
                                        'AdminScreen: Notify response body: ${resp.body}',
                                      );
                                    } else {
                                      // Print error als userId niet beschikbaar is
                                      debugPrint(
                                        'AdminScreen: Cannot notify user, userId is null or empty in document data.',
                                      );
                                    }
                                  } catch (e) {
                                    // Print error bij notificatie
                                    debugPrint(
                                      'AdminScreen: Failed to notify user: $e',
                                    );
                                  }
                                } catch (e) {
                                  // Toont error snackbar als verzenden mislukt
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.send_failed,
                                      ),
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

    // Stopt de realtime listener wanneer de pagina wordt gesloten
    await docSub?.cancel();
  }

  Widget _buildFaqsTab() {
    // Haalt de FAQs collectie op en sorteert op createdAt (nieuwste eerst)
    final col = FirebaseFirestore.instance
        .collection('faqs')
        .orderBy('createdAt', descending: true);
    // Retourneert een Column met de FAQ lijst en een add knop
    return Column(
      children: [
        // Maakt de FAQ lijst expandable zodat deze groeit met content
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // Luistert naar realtime updates van de FAQs
            stream: col.snapshots(),
            builder: (ctx, snap) {
              // Toont loading spinner terwijl data wordt opgehaald
              if (snap.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              // Haalt de FAQ documenten op of geeft lege lijst als niet beschikbaar
              final docs = snap.data?.docs ?? [];
              // Toont bericht als er geen FAQs zijn
              if (docs.isEmpty)
                return Center(
                  child: Text(AppLocalizations.of(context)!.no_faq_items),
                );
              // Bouwt een ListView met alle FAQs gescheiden door dividers
              return ListView.separated(
                // Aantal items in de lijst
                itemCount: docs.length,
                // Voegt een lijn toe tussen items
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (c, i) {
                  // Haalt het huidige FAQ document op
                  final d = docs[i];
                  // Extraheert de data uit het document
                  final data = d.data();
                  // Haalt de vraag tekst op (lege string als niet aanwezig)
                  final q = (data['question'] ?? '').toString();
                  // Haalt het antwoord tekst op (lege string als niet aanwezig)
                  final a = (data['answer'] ?? '').toString();
                  // Retourneert een expandable tile met vraag, antwoord en knoppen
                  return ExpansionTile(
                    // Toont de vraag als titel
                    title: Text(q),
                    // Toont inhoud wanneer expanded
                    children: [
                      // Padding rond het antwoord
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        // Toont het antwoord tekst
                        child: Text(a),
                      ),
                      // Rij met edit en delete knoppen
                      ButtonBar(
                        children: [
                          // Knop om FAQ te bewerken
                          TextButton(
                            onPressed: () => _editFaq(d.id, q, a),
                            child: Text(AppLocalizations.of(context)!.edit),
                          ),
                          // Knop om FAQ te verwijderen
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
        // Padding rond de add knop
        Padding(
          padding: const EdgeInsets.all(12.0),
          // Knop om nieuwe FAQ toe te voegen met plus icoon
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
    // Controller voor de vraag input
    final qCtrl = TextEditingController();
    // Controller voor het antwoord input
    final aCtrl = TextEditingController();
    // Toont dialog en wacht op resultaat (true als voegt toe, false als annuleert)
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        // Titel van het dialog venster
        title: Text(AppLocalizations.of(ctx)!.new_faq_title),
        content: Column(
          // Geeft column minimale grootte
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tekstveld voor vraag input
            TextField(
              controller: qCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(ctx)!.question_label,
              ),
            ),
            // Voegt ruimte toe tussen velden
            const SizedBox(height: 8),
            // Tekstveld voor antwoord input (multi-line)
            TextField(
              controller: aCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(ctx)!.answer_label,
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          // Knop om dialog te annuleren
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          // Knop om FAQ toe te voegen en dialog te sluiten
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx)!.add),
          ),
        ],
      ),
    );
    // Stopt als gebruiker annuleert
    if (res != true) return;
    // Haalt ingevoerde vraag op en verwijdert spaties
    final q = qCtrl.text.trim();
    // Haalt ingevoerd antwoord op en verwijdert spaties
    final a = aCtrl.text.trim();
    // Stopt als vraag of antwoord leeg is
    if (q.isEmpty || a.isEmpty) return;
    try {
      // Voegt nieuw FAQ document toe aan Firestore
      await FirebaseFirestore.instance.collection('faqs').add({
        'question': q,
        'answer': a,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Toont succes melding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.faq_added)),
      );
    } catch (e) {
      // Print fout bij toevoegen
      debugPrint('Failed to add faq: $e');
      // Toont error melding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.faq_add_failed)),
      );
    }
  }

  Future<void> _editFaq(String id, String currentQ, String currentA) async {
    // Controller met huidge vraag voorgevuld
    final qCtrl = TextEditingController(text: currentQ);
    // Controller met huidig antwoord voorgevuld
    final aCtrl = TextEditingController(text: currentA);
    // Toont dialog en wacht op resultaat (true als opslaan, false als annuleert)
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        // Titel van het edit dialog
        title: Text(AppLocalizations.of(ctx)!.edit_faq_title),
        content: Column(
          // Geeft column minimale grootte
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tekstveld voor vraag met huidge waarde
            TextField(
              controller: qCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(ctx)!.question_label,
              ),
            ),
            // Voegt ruimte toe tussen velden
            const SizedBox(height: 8),
            // Tekstveld voor antwoord met huidge waarde (multi-line)
            TextField(
              controller: aCtrl,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(ctx)!.answer_label,
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          // Knop om dialog te annuleren
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          // Knop om wijzigingen op te slaan en dialog te sluiten
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx)!.save),
          ),
        ],
      ),
    );
    // Stopt als gebruiker annuleert
    if (res != true) return;
    // Haalt bewerkte vraag op en verwijdert spaties
    final q = qCtrl.text.trim();
    // Haalt bewerkt antwoord op en verwijdert spaties
    final a = aCtrl.text.trim();
    // Stopt als vraag of antwoord leeg is
    if (q.isEmpty || a.isEmpty) return;
    try {
      // Update het FAQ document met nieuwe vraag en antwoord
      await FirebaseFirestore.instance.collection('faqs').doc(id).update({
        'question': q,
        'answer': a,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Toont succes melding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.faq_updated)),
      );
    } catch (e) {
      // Print fout bij updaten
      debugPrint('Failed to update faq: $e');
      // Toont error melding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.faq_update_failed),
        ),
      );
    }
  }

  Future<void> _deleteFaq(String id) async {
    // Toont bevestigingsdialog en wacht op resultaat (true als verwijdert, false als annuleert)
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        // Titel van het delete dialog
        title: Text(AppLocalizations.of(ctx)!.delete_faq_title),
        // Inhoud met bevestigingsbericht
        content: Text(AppLocalizations.of(ctx)!.delete_faq_confirm),
        actions: [
          // Knop om dialog te annuleren
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          // Knop om FAQ te verwijderen en dialog te sluiten
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx)!.delete),
          ),
        ],
      ),
    );
    // Stopt als gebruiker annuleert
    if (ok != true) return;
    try {
      // Verwijdert het FAQ document uit Firestore
      await FirebaseFirestore.instance.collection('faqs').doc(id).delete();
      // Toont succes melding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.faq_deleted)),
      );
    } catch (e) {
      // Print fout bij verwijderen
      debugPrint('Failed to delete faq: $e');
      // Toont error melding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.faq_delete_failed),
        ),
      );
    }
  }
}
