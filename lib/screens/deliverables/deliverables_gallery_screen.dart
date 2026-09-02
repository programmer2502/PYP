import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/network_image_view.dart';
import '../../models/deliverable_file_model.dart';
import '../../providers/chat_provider.dart';
import '../photographer/portfolio_viewer_screen.dart';

class DeliverablesGalleryScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const DeliverablesGalleryScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<DeliverablesGalleryScreen> createState() =>
      _DeliverablesGalleryScreenState();
}

class _DeliverablesGalleryScreenState
    extends ConsumerState<DeliverablesGalleryScreen> {
  final Map<String, bool> _downloadingMap = {};

  Future<void> _downloadFile(DeliverableFileModel file) async {
    setState(() => _downloadingMap[file.id] = true);

    try {
      final response = await http.get(Uri.parse(file.fileUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final localFile = File('${directory.path}/${file.fileName}');
        await localFile.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Downloaded "${file.fileName}" to device storage.'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingMap[file.id] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliverablesAsync =
        ref.watch(deliverablesStreamProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorderLight),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimaryLight),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        title: const Text(
          'Deliverables Gallery',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: deliverablesAsync.when(
          data: (files) {
            if (files.isEmpty) {
              return const EmptyStateView(
                icon: Icons.hourglass_top_rounded,
                title: 'Editing in Progress',
                message:
                    'Your creator is currently editing and curating your photos & videos. Files will appear here the moment they are uploaded.',
              );
            }

            final imageFiles = files
                .where((f) => f.fileType == 'image')
                .map((f) => f.fileUrl)
                .toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.badgeGreenBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.cloud_done_rounded,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${files.length} Assets Delivered',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'High-resolution originals ready for download',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final file = files[index];
                        final isDownloading =
                            _downloadingMap[file.id] ?? false;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorderLight),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (file.fileType == 'image') {
                                          final imgIdx =
                                              imageFiles.indexOf(file.fileUrl);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PortfolioViewerScreen(
                                                images: imageFiles,
                                                initialIndex:
                                                    imgIdx != -1 ? imgIdx : 0,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: NetworkImageView(
                                        imageUrl: file.thumbnailUrl ?? file.fileUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.75),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          file.fileType.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file.fileName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimaryLight,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            file.formattedSize,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isDownloading)
                                      const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.primary),
                                        ),
                                      )
                                    else
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.badgeGreenBg,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                              Icons.download_rounded,
                                              color: AppColors.primary,
                                              size: 18),
                                          onPressed: () => _downloadFile(file),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: files.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
          loading: () => const Center(
            child: LoadingIndicator(message: 'Loading deliverables...'),
          ),
          error: (e, _) => ErrorView(message: e.toString()),
        ),
      ),
    );
  }
}
