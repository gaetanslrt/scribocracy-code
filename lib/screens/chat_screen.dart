import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart' hide ChatSession;
import 'package:scribocracy_new/models/chat.dart';
import 'package:scribocracy_new/providers.dart';
import 'package:scribocracy_new/services/ai_service.dart';
import 'package:scribocracy_new/services/database.dart';
import 'package:scribocracy_new/theme.dart';
import 'package:scribocracy_new/widgets/glass_container.dart';
import 'package:scribocracy_new/widgets/background_scaffold.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final ChatSession? session;
  final String? initialInput;
  final String? systemContext;

  const ChatScreen({
    super.key, 
    this.session, 
    this.initialInput, 
    this.systemContext
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late List<ChatMessage> _messages; 
  bool _isLoading = false; 
  ChatSession? _currentSession; 

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
    _messages = widget.session?.messages.toList() ?? [];
    
    if (widget.initialInput != null) {
      _inputController.text = widget.initialInput!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messages.isNotEmpty) _scrollToBottom(animated: false);
    });
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          if (animated) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: "user", content: text, timestamp: DateTime.now()));
      _isLoading = true;
      _inputController.clear();
    });
    _scrollToBottom();
    
    await _saveLocalSession();

    try {
      StringBuffer contextBuffer = StringBuffer();
      
      if (widget.systemContext != null && widget.systemContext!.isNotEmpty) {
        contextBuffer.writeln("--- DÉBUT DU CONTENU DE LA PAGE WEB ---");
        contextBuffer.writeln(widget.systemContext);
        contextBuffer.writeln("--- FIN DU CONTENU DE LA PAGE WEB ---");
        contextBuffer.writeln("\nINSTRUCTION : Utilise le contenu ci-dessus pour répondre à la demande suivante.");
      }

      String promptToSend = """
${contextBuffer.toString()}

DEMANDE UTILISATEUR :
$text
""";

      List<Content> history = [];
      final historyMessages = _messages.length > 10 
          ? _messages.sublist(_messages.length - 10, _messages.length - 1) 
          : _messages.sublist(0, _messages.length - 1);

      for (var msg in historyMessages) {
        if (msg.role == 'user') {
          history.add(Content.text(msg.content ?? ""));
        } else {
          history.add(Content.model([TextPart(msg.content ?? "")]));
        }
      }

      final response = await ref.read(aiServiceProvider).chatWithHistory(history, promptToSend);
      
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: "ai", content: response, timestamp: DateTime.now()));
        });
        await _saveLocalSession();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(role: "ai", content: "Erreur de connexion avec l'IA."));
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  Future<void> _saveLocalSession() async {
    final db = ref.read(databaseProvider);
    if (_currentSession == null) {
      final title = _messages.first.content!.length > 25 
          ? "${_messages.first.content!.substring(0, 25)}..." 
          : _messages.first.content!;
          
      final newS = ChatSession(
        lastModified: DateTime.now(), 
        title: title, 
        messages: _messages
      );
      await db.saveChat(newS);
      setState(() => _currentSession = newS);
    } else {
      _currentSession!.messages = _messages;
      _currentSession!.lastModified = DateTime.now();
      await db.saveChat(_currentSession!);
    }
    ref.refresh(chatsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: Text("Assistant Web", style: Theme.of(context).textTheme.headlineSmall),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Column(
        children: [
          // INDICATEUR DE CONTEXTE
          if (widget.systemContext != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: GlassContainer(
                opacity: 0.5,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Correction couleur : AppTheme.greyText
                    const Icon(Icons.link, size: 14, color: AppTheme.greyText),
                    const SizedBox(width: 8),
                    const Text("Analyse de page active", style: TextStyle(color: AppTheme.greyText, fontSize: 11)),
                  ],
                ),
              ),
            ),

          // ZONE DE MESSAGES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: GlassContainer(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    // Thème Clair : On fonce un peu le fond des bulles pour le contraste
                    opacity: isUser ? 0.8 : 0.5,
                    // Bordure grise légère
                    borderColor: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      child: Text(
                        msg.content ?? "",
                        // Correction couleur : AppTheme.darkText (Noir)
                        style: const TextStyle(
                          color: AppTheme.darkText,
                          height: 1.5,
                          fontSize: 15
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: LinearProgressIndicator(
                // Correction couleur : AppTheme.greyText
                color: AppTheme.greyText,
                backgroundColor: Colors.transparent,
                minHeight: 2,
              ),
            ),

          // INPUT ZONE
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: GlassContainer(
              opacity: 0.8,
              borderRadius: BorderRadius.circular(30),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      // Correction couleur : AppTheme.darkText (Noir)
                      style: const TextStyle(color: AppTheme.darkText),
                      decoration: const InputDecoration(
                        hintText: "Posez une question...",
                        hintStyle: TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  IconButton(
                    // Correction couleur : AppTheme.darkText
                    icon: const Icon(Icons.arrow_upward_rounded, color: AppTheme.darkText),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}