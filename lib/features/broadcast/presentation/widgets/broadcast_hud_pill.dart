import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/broadcast/presentation/bloc/broadcast_cubit.dart';

/// Top bar / HUD indicator for active local network live broadcast.
class BroadcastHudPill extends StatefulWidget {
  final VoidCallback onTap;

  const BroadcastHudPill({
    super.key,
    required this.onTap,
  });

  @override
  State<BroadcastHudPill> createState() => _BroadcastHudPillState();
}

class _BroadcastHudPillState extends State<BroadcastHudPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BroadcastCubit>().state;
    if (!state.isBroadcasting) {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
      }
      return const SizedBox.shrink();
    }

    if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }

    final scheme = Theme.of(context).colorScheme;
    final viewers = state.viewersCount;

    return Tooltip(
      message: 'LAN Live Broadcast Active (${state.serverUrl})\nClick to view QR & Audience Link',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, _) => Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF10B981)
                          .withValues(alpha: _pulseAnimation.value),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981),
                          blurRadius: 6 * _pulseAnimation.value,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  viewers > 0 ? 'Live ($viewers)' : 'Live',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
