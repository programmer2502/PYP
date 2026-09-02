import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/avatar_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/network_image_view.dart';
import '../../models/chat_message_model.dart';
import '../../models/conversation_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/conversation_service.dart';
import '../../services/storage_service.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const ChatRoomScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingMedia = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProfileProvider).value;
      if (user != null) {
        ref.read(conversationServiceProvider).markAsRead(widget.bookingId, user.id);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage({
    String? text,
    String? mediaUrl,
    String mediaType = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final msgText = text ?? _messageController.text.trim();
    if (msgText.isEmpty && mediaUrl == null && metadata == null) return;

    final user = ref.read(userProfileProvider).value;
    if (user == null) return;

    if (text == null) {
      _messageController.clear();
    }

    final message = ChatMessageModel(
      id: '',
      bookingId: widget.bookingId,
      senderId: user.id,
      senderName: user.name,
      senderAvatar: user.avatarUrl,
      text: msgText,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    // Stream through Realtime Layer & Trigger Notifications Layer
    await ref.read(conversationServiceProvider).sendMessage(
      bookingId: widget.bookingId,
      message: message,
      receiverId: 'creator_id', // Target receiver
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      setState(() {
        _isUploadingMedia = true;
        _uploadProgress = 0.0;
      });

      final storageService = ref.read(storageServiceProvider);
      final mediaUrl = await storageService.uploadChatAttachment(
        bookingId: widget.bookingId,
        file: File(pickedFile.path),
        fileType: 'image',
        onProgress: (p) => setState(() => _uploadProgress = p),
      );

      await _sendMessage(mediaUrl: mediaUrl, mediaType: 'image', text: '📷 Photo Attachment');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.accentRose),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingMedia = false);
    }
  }

  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Share with Creator',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: AppColors.badgeCoralIcon,
                      bgColor: AppColors.badgeCoralBg,
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndSendImage(ImageSource.camera);
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Moodboard',
                      color: AppColors.badgeSkyIcon,
                      bgColor: AppColors.badgeSkyBg,
                      onTap: () {
                        Navigator.pop(context);
                        _pickAndSendImage(ImageSource.gallery);
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.location_on_rounded,
                      label: 'Venue Pin',
                      color: AppColors.badgeGreenIcon,
                      bgColor: AppColors.badgeGreenBg,
                      onTap: () {
                        Navigator.pop(context);
                        _sendMessage(
                          text: '📍 Shared shoot location: Bandra West, Mumbai',
                          mediaType: 'location',
                          metadata: {'lat': 19.0596, 'lon': 72.8295, 'label': 'Bandra West, Mumbai'},
                        );
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.schedule_rounded,
                      label: 'Timeline',
                      color: AppColors.badgePurpleIcon,
                      bgColor: AppColors.badgePurpleBg,
                      onTap: () {
                        Navigator.pop(context);
                        _sendMessage(
                          text: '⏰ Proposed Shoot Timeline: 10:00 AM - 12:00 PM (2 Hours)',
                          mediaType: 'timeline',
                          metadata: {'duration': '2 Hours', 'slot': '10:00 AM'},
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).value;
    final messagesAsync = ref.watch(realtimeMessagesStreamProvider(widget.bookingId));
    final conversationContextAsync = ref.watch(realtimeConversationContextProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildChatHeader(conversationContextAsync.value),
      body: Column(
        children: [
          // 1. Interactive Booking Context Header Banner
          _buildBookingContextBanner(conversationContextAsync.value),

          // 2. Quick Action Response Shortcuts
          _buildQuickActionsBar(),

          // 3. Messages Stream (Realtime Layer)
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyChatPlaceholder(conversationContextAsync.value);
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == user?.id;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (err, _) => Center(child: Text('Error loading chat: $err')),
            ),
          ),

          // 4. Progress bar during media upload
          if (_isUploadingMedia)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              color: AppColors.badgeGreenBg,
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Uploading attachment (${(_uploadProgress * 100).toInt()}%)...',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

          // 5. Message Input Bar
          _buildInputBar(),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // HEADER
  // --------------------------------------------------------------------------
  PreferredSizeWidget _buildChatHeader(ConversationModel? convo) {
    final creatorName = convo?.creatorName ?? 'Arjun Mehta';
    final isOnline = convo?.isCreatorOnline ?? true;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimaryLight, size: 20),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              AvatarView(
                imageUrl: convo?.creatorAvatar,
                name: creatorName,
                radius: 20,
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        creatorName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: AppColors.primary, size: 15),
                  ],
                ),
                Text(
                  isOnline ? 'Active now • Verified PRO' : 'Last active recently',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondaryLight),
          onPressed: () => context.push('/booking-detail/${widget.bookingId}'),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.cardBorderLight, height: 1),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // BOOKING CONTEXT BANNER (Architecture Component)
  // --------------------------------------------------------------------------
  Widget _buildBookingContextBanner(ConversationModel? convo) {
    final bookingNumber = convo?.bookingNumber ?? '#BK-9021';
    final service = convo?.serviceName ?? 'Editorial Portrait Standard';
    final venue = convo?.venue ?? 'Bandra West, Mumbai';

    return GestureDetector(
      onTap: () => context.push('/booking-detail/${widget.bookingId}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkHeader,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        bookingNumber,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('CONFIRMED', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  Text(
                    '$service • $venue',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // QUICK ACTIONS BAR
  // --------------------------------------------------------------------------
  Widget _buildQuickActionsBar() {
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          _buildQuickChip('📍 Share Location', () {
            _sendMessage(
              text: '📍 Here is my preferred shoot location in Bandra West',
              mediaType: 'location',
            );
          }),
          const SizedBox(width: 8),
          _buildQuickChip('🎨 Share Moodboard', () => _pickAndSendImage(ImageSource.gallery)),
          const SizedBox(width: 8),
          _buildQuickChip('⏰ Confirm 10 AM Slot', () {
            _sendMessage(text: 'Looking forward to our session at 10:00 AM!');
          }),
          const SizedBox(width: 8),
          _buildQuickChip('🛡️ Escrow Guarantee', () {
            _sendMessage(text: 'Payment is securely held in PYP Escrow until deliverables are reviewed.');
          }),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.cardBorderLight),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // MESSAGE BUBBLES
  // --------------------------------------------------------------------------
  Widget _buildMessageBubble(ChatMessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Media Image Preview if any
            if (message.mediaUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetworkImageView(
                    imageUrl: message.mediaUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Message Text
            Text(
              message.text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isMe ? Colors.white : AppColors.textPrimaryLight,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),

            // Timestamp and Read Receipts
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatter.formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isMe ? Colors.white70 : AppColors.textMutedLight,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all_rounded : Icons.check_rounded,
                    size: 13,
                    color: message.isRead ? Colors.white : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatPlaceholder(ConversationModel? convo) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.badgeGreenBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 14),
          const Text(
            'Direct Connection with Creator',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Coordinate shoot day location, outfits, moodboards, and timeline in real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // INPUT BAR
  // --------------------------------------------------------------------------
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 8, 14, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorderLight)),
      ),
      child: Row(
        children: [
          // Attachment Button (+)
          GestureDetector(
            onTap: _showAttachmentPicker,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorderLight),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.textPrimaryLight, size: 22),
            ),
          ),
          const SizedBox(width: 8),

          // Text Field Pill
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.cardBorderLight),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryLight),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textMutedLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send Button Pill
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D00A86B),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
