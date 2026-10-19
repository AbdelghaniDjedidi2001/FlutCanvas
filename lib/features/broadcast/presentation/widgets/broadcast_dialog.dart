import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutcanvas/features/broadcast/presentation/bloc/broadcast_cubit.dart';
import 'package:flutcanvas/features/broadcast/presentation/bloc/broadcast_state.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/boards_cubit.dart';
import 'package:flutcanvas/features/canvas/presentation/bloc/canvas_bloc.dart';
import 'package:flutcanvas/features/canvas/presentation/controllers/canvas_viewport_controller.dart';

/// Modal dialog providing LAN Live Broadcast controls, URL sharing, and QR Code.
class BroadcastDialog extends StatefulWidget {
  final CanvasViewportController viewport;

  const BroadcastDialog({
    super.key,
    required this.viewport,
  });

  static Future<void> show(
    BuildContext context, {
    required CanvasViewportController viewport,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BroadcastDialog(viewport: viewport),
    );
  }

  @override
  State<BroadcastDialog> createState() => _BroadcastDialogState();
}

class _BroadcastDialogState extends State<BroadcastDialog> {
  final TextEditingController _portController =
      TextEditingController(text: '4040');

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final broadcastState = context.watch<BroadcastCubit>().state;
    final isLive = broadcastState.isBroadcasting;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF161B26) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isLive
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : scheme.outlineVariant.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isLive
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isLive
                            ? const Color(0xFF10B981).withValues(alpha: 0.4)
                            : scheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.wifi_tethering_rounded,
                      size: 24,
                      color: isLive ? const Color(0xFF10B981) : scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LAN Live Broadcast',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stream presentation to local devices via Wi-Fi',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Body: Active Live State vs Inactive Setup
              if (isLive) ...[
                _buildActiveBroadcastView(context, broadcastState, isDark)
              ] else ...[
                _buildInactiveSetupView(context, broadcastState, isDark)
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBroadcastView(
    BuildContext context,
    BroadcastState state,
    bool isDark,
  ) {
    final serverUrl = state.serverUrl ?? 'http://127.0.0.1:4040';
    final viewers = state.viewersCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live Status Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF10B981),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'BROADCASTING LIVE ON LAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group_rounded,
                        size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      '$viewers viewer${viewers == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // QR Code Card
        Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: QrImageView(
              data: serverUrl,
              version: QrVersions.auto,
              size: 170.0,
              gapless: false,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF0F172A),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Audience can scan with phone camera to join',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 18),

        // Copyable URL Bar
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  serverUrl,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                tooltip: 'Copy Link',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: serverUrl));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Broadcast link copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Stop Broadcast Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            await context.read<BroadcastCubit>().stopBroadcast();
          },
          icon: const Icon(Icons.stop_circle_outlined, size: 20),
          label: const Text(
            'Stop Broadcast',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildInactiveSetupView(
    BuildContext context,
    BroadcastState state,
    bool isDark,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Features preview
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.035)
                : Colors.black.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureBullet(
                icon: Icons.sync_rounded,
                title: 'Real-time Camera & Pan Sync',
                subtitle: 'Audience view automatically tracks your pan & zoom',
              ),
              const SizedBox(height: 10),
              _buildFeatureBullet(
                icon: Icons.flare_rounded,
                title: 'Laser Pointer Streaming',
                subtitle: 'Audience sees your live glowing laser trails (K)',
              ),
              const SizedBox(height: 10),
              _buildFeatureBullet(
                icon: Icons.slideshow_rounded,
                title: 'Slide Frame Transition Sync',
                subtitle: 'Follows presentation deck frame jumps (F5)',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Port Configuration
        Row(
          children: [
            Text(
              'Port:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              height: 38,
              child: TextField(
                controller: _portController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Zero-Cloud • Local Wi-Fi',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),

        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        const SizedBox(height: 22),

        // Start Broadcast Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          onPressed: state.isStarting
              ? null
              : () async {
                  final port = int.tryParse(_portController.text) ?? 4040;
                  final elements = context.read<CanvasBloc>().state.elements;
                  final boardName = context.read<BoardsCubit>().state.currentBoard.title;

                  await context.read<BroadcastCubit>().startBroadcast(
                        port: port,
                        initialElements: elements,
                        isDark: isDark,
                        boardName: boardName,
                        pan: widget.viewport.pan,
                        zoom: widget.viewport.zoom,
                      );
                },
          icon: state.isStarting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Icon(Icons.wifi_tethering_rounded, size: 20),
          label: Text(
            state.isStarting ? 'Starting Server...' : 'Start Live Broadcast',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBullet({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
