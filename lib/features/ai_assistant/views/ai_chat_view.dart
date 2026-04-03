import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../viewmodels/ai_chat_viewmodel.dart';

import '../widgets/diagnosis_card.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:flutter_chat_core/flutter_chat_core.dart' as chat_core;
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:image_picker/image_picker.dart';

/// AI Mekanik Asistan chat ekranı
class AiChatView extends StatefulWidget {
  const AiChatView({super.key});

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView> {
  final _viewModel = AiChatViewModel();
  late final chat_core.InMemoryChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = chat_core.InMemoryChatController();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    _chatController.setMessages(_getChatMessages());
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _chatController.dispose();
    super.dispose();
  }

  List<chat_core.Message> _getChatMessages() {
    final mappedMessages = <chat_core.Message>[];

    // flutter_chat_ui expects messages in reversed chronological order (newest first).
    for (int i = 0; i < _viewModel.messages.length; i++) {
      final msg = _viewModel.messages[i];
      final authorId = msg.isUser ? '1' : '2';
      final id = 'msg_$i';

      if (msg.diagnosis != null || msg.imageUrl != null) {
        mappedMessages.add(
          chat_core.Message.custom(
            id: id,
            authorId: authorId,
            createdAt: msg.timestamp,
            metadata: {
              'text': msg.content,
              'diagnosis': msg.diagnosis,
              'imageUrl': msg.imageUrl,
            },
          ),
        );
      } else {
        mappedMessages.add(
          chat_core.Message.text(
            id: id,
            authorId: authorId,
            createdAt: msg.timestamp,
            text: msg.content,
          ),
        );
      }
    }

    // Optional typing indicator message insertion can be manually handled or skipped
    // since flutter_chat_ui v2 handles typing users list differently. We will rely on custom builders or skip it.
    return mappedMessages;
  }

  Future<chat_core.User> _resolveUser(String id) async {
    if (id == '1') return const chat_core.User(id: '1', name: 'Siz');
    return const chat_core.User(id: '2', name: 'AutoAssist AI');
  }

  void _onAttachmentPressed() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (image != null) {
      _viewModel.sendMessage('', imagePath: image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Builder(
                builder: (context) => Row(
                  children: [
                    IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const iconoir.Menu(
                        width: 24,
                        height: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const iconoir.MagicWand(
                        width: 18,
                        height: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.aiAssistant,
                        style: AppTypography.h2,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _viewModel.createNewChat();
                      },
                      icon: const iconoir.Refresh(
                        width: 22,
                        height: 22,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: 'Sohbeti Temizle',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoadingSessions) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return chat_ui.Chat(
                    currentUserId: '1',
                    chatController: _chatController,
                    resolveUser: _resolveUser,
                    theme: chat_core.ChatTheme(
                      colors: chat_core.ChatColors(
                        primary: AppColors.accentBlue,
                        onPrimary: Colors.white,
                        surface: AppColors.surfaceLight,
                        onSurface: AppColors.textPrimary,
                        surfaceContainer: AppColors.surfaceCard,
                        surfaceContainerLow: AppColors.surfaceLight,
                        surfaceContainerHigh: AppColors.surfaceDivider,
                      ),
                      typography: chat_core.ChatTypography.standard(),
                      shape: const BorderRadius.all(Radius.circular(16)),
                    ),
                    onMessageSend: (text) {
                      _viewModel.sendMessage(text);
                    },
                    onAttachmentTap: _onAttachmentPressed,
                    builders: chat_core.Builders(
                      customMessageBuilder:
                          (
                            context,
                            message,
                            index, {
                            required bool isSentByMe,
                            chat_core.MessageGroupStatus? groupStatus,
                          }) {
                            final txt =
                                (message.metadata?['text'] ?? '') as String;
                            final dia = message.metadata?['diagnosis'];
                            final imageUrl =
                                message.metadata?['imageUrl'] as String?;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: isSentByMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (imageUrl != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          imageUrl,
                                          width: 240,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, _, __) =>
                                              const SizedBox(),
                                        ),
                                      ),
                                    ),
                                  if (txt.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSentByMe
                                            ? AppColors.accentBlue
                                            : AppColors.surfaceCard,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        txt,
                                        style: TextStyle(
                                          color: isSentByMe
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  if (dia != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: DiagnosisCard(diagnosis: dia),
                                    ),
                                ],
                              ),
                            );
                          },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surfaceLight,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  _viewModel.createNewChat();
                  Navigator.pop(context);
                },
                icon: const iconoir.Plus(width: 20, height: 20),
                label: const Text('Yeni Sohbet'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceDivider),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.sessions.isEmpty) {
                    return const Center(child: Text('Geçmiş bulunamadı'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _viewModel.sessions.length,
                    itemBuilder: (context, index) {
                      final session = _viewModel.sessions[index];
                      final isSelected =
                          session.id == _viewModel.currentSession?.id;

                      return ListTile(
                        leading: const iconoir.ChatBubble(
                          width: 20,
                          height: 20,
                          color: AppColors.textTertiary,
                        ),
                        title: Text(
                          session.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.accentBlue
                                : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.surfaceLight,
                        onTap: () {
                          _viewModel.selectChat(session.id);
                          Navigator.pop(context);
                        },
                        trailing: IconButton(
                          icon: const iconoir.Trash(
                            width: 20,
                            height: 20,
                            color: AppColors.textTertiary,
                          ),
                          onPressed: () {
                            _viewModel.deleteChat(session.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
