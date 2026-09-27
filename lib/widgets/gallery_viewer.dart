import 'package:flutter/material.dart';

import 'package:bugin/theme/app_text.dart';
import 'package:bugin/widgets/app_image.dart';
import 'package:bugin/widgets/buttons.dart';

/// Полноэкранный просмотр фото со свайпом.
class GalleryViewer extends StatefulWidget {
  const GalleryViewer({super.key, required this.photos, this.initialIndex = 0});

  final List<String> photos;
  final int initialIndex;

  static Future<void> open(
    BuildContext context,
    List<String> photos, {
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => GalleryViewer(photos: photos, initialIndex: initialIndex),
      ),
    );
  }

  @override
  State<GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<GalleryViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              maxScale: 3,
              child: SizedBox.expand(
                child: AppImage(widget.photos[i], fit: BoxFit.contain),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const AppBackButton(
                    style: CircleButtonStyle.overlay,
                    icon: Icons.close_rounded,
                    semanticLabel: 'Закрыть',
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      '${_index + 1} / ${widget.photos.length}',
                      style: AppText.label.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
