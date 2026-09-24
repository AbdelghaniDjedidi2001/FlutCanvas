import 'package:flutter/material.dart';
import '../../models/board_element.dart';

class PresentationOverlay extends StatelessWidget {
  const PresentationOverlay({
    super.key,
    required this.frames,
    required this.currentSlideIndex,
    required this.onNextSlide,
    required this.onPrevSlide,
    required this.onExit,
  });

  final List<BoardElement> frames;
  final int currentSlideIndex;
  final VoidCallback onNextSlide;
  final VoidCallback onPrevSlide;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    if (frames.isEmpty) return const SizedBox.shrink();

    final currentFrame = frames[currentSlideIndex.clamp(0, frames.length - 1)];
    final slideTitle = currentFrame.frameTitle ?? 'Slide ${currentSlideIndex + 1}';

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: const Color(0xEE1E212B),
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.slideshow_rounded, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Text(
                  slideTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${currentSlideIndex + 1} / ${frames.length})',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(width: 16),
                IconButton(
                  tooltip: 'Previous Slide (Left Arrow)',
                  iconSize: 20,
                  color: Colors.white,
                  onPressed: currentSlideIndex > 0 ? onPrevSlide : null,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                IconButton(
                  tooltip: 'Next Slide (Right Arrow)',
                  iconSize: 20,
                  color: Colors.white,
                  onPressed: currentSlideIndex < frames.length - 1 ? onNextSlide : null,
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                ),
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.white24,
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  onPressed: onExit,
                  icon: const Icon(Icons.close_fullscreen, size: 16),
                  label: const Text('Exit (Esc)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
