import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutcanvas/features/canvas/domain/models/board_element.dart';
import '../../domain/models/ai_diagram_provider.dart';
import '../../data/services/ai_prompt_templates.dart';
import '../bloc/ai_diagram_cubit.dart';
import '../bloc/ai_diagram_state.dart';

class AiPromptBarDialog extends StatefulWidget {
  final Offset targetOrigin;
  final void Function(List<BoardElement> elements) onInsert;

  const AiPromptBarDialog({
    super.key,
    required this.targetOrigin,
    required this.onInsert,
  });

  @override
  State<AiPromptBarDialog> createState() => _AiPromptBarDialogState();
}

class _AiPromptBarDialogState extends State<AiPromptBarDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _promptController;
  late final TextEditingController _apiKeyController;
  late final FocusNode _promptFocusNode;
  bool _obscureApiKey = true;
  bool _showRawCode = false;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _apiKeyController = TextEditingController();
    _promptFocusNode = FocusNode();

    final cubitState = context.read<AiDiagramCubit>().state;
    _apiKeyController.text = cubitState.apiKey;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _promptFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _apiKeyController.dispose();
    _promptFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    final cubit = context.read<AiDiagramCubit>();
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    final result = await cubit.generate(
      prompt: prompt,
      origin: widget.targetOrigin,
    );

    if (result != null && mounted) {
      widget.onInsert(result.elements);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AiDiagramCubit, AiDiagramState>(
      listener: (context, state) {
        if (_apiKeyController.text != state.apiKey) {
          _apiKeyController.text = state.apiKey;
        }
      },
      builder: (context, state) {
        final cubit = context.read<AiDiagramCubit>();

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xE61E222D)
                          : const Color(0xF2FFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.08),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Header Bar
                        _buildHeader(context, state, cubit, isDark),

                        const Divider(height: 1, thickness: 1),

                        // 2. Settings Drawer (Collapsible)
                        if (state.isSettingsOpen)
                          _buildSettingsDrawer(context, state, cubit, isDark),

                        // 3. Prompt Input Area
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPromptField(context, state, isDark),
                              const SizedBox(height: 12),
                              _buildSuggestionChips(isDark),
                            ],
                          ),
                        ),

                        // 4. Status / Error Message
                        if (state.errorMessage != null)
                          _buildErrorBanner(context, state.errorMessage!, isDark),

                        if (state.isGenerating)
                          _buildLoadingIndicator(state.loadingMessage, isDark),

                        // 5. Raw Code Preview (if generated & requested)
                        if (_showRawCode && state.lastResult != null)
                          _buildCodePreview(state.lastResult!.mermaidCode, isDark),

                        const Divider(height: 1, thickness: 1),

                        // 6. Action Footer
                        _buildFooter(context, state, isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AiDiagramState state,
    AiDiagramCubit cubit,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4C6EF5), Color(0xFF15AABF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Text-to-Diagram',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C6EF5).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Cmd + Shift + A',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4C6EF5),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Describe a system, flowchart, or mind map to inject editable canvas shapes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Provider selector button / Settings toggle
          IconButton(
            tooltip: state.isSettingsOpen ? 'Close Settings' : 'AI Settings & API Key',
            icon: Icon(
              state.isSettingsOpen ? Icons.settings : Icons.settings_outlined,
              size: 20,
              color: state.isSettingsOpen
                  ? const Color(0xFF4C6EF5)
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            onPressed: () => cubit.toggleSettings(),
          ),
          IconButton(
            tooltip: 'Close (Esc)',
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsDrawer(
    BuildContext context,
    AiDiagramState state,
    AiDiagramCubit cubit,
    bool isDark,
  ) {
    return Container(
      color: isDark ? Colors.black26 : const Color(0xFFF8F9FA),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 16, color: Color(0xFF4C6EF5)),
              const SizedBox(width: 8),
              const Text(
                'AI Engine & Provider',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Provider switcher
          Row(
            children: [
              Expanded(
                child: _buildProviderOption(
                  title: 'Google Gemini API',
                  subtitle: 'Cloud AI (Fast & versatile)',
                  isSelected: state.provider == AiDiagramProvider.gemini,
                  isDark: isDark,
                  onTap: () => cubit.setProvider(AiDiagramProvider.gemini),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProviderOption(
                  title: 'Chrome Built-in AI',
                  subtitle: 'window.ai (On-device Gemini Nano)',
                  isSelected: state.provider == AiDiagramProvider.chromeNano,
                  isDark: isDark,
                  onTap: () => cubit.setProvider(AiDiagramProvider.chromeNano),
                ),
              ),
            ],
          ),

          // If Gemini selected: API key input
          if (state.provider == AiDiagramProvider.gemini) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureApiKey,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Google Gemini API Key',
                      hintText: 'AIzaSy...',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.key, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureApiKey
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureApiKey = !_obscureApiKey;
                          });
                        },
                      ),
                    ),
                    onChanged: (val) => cubit.saveApiKey(val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.info_outline, size: 13, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Saved locally on your device. Free API keys available at ai.google.dev',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2F9E44).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF2F9E44), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Zero API key required. Uses Chrome Canary or Chrome 127+ with window.ai (Gemini Nano) built-in.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : const Color(0xFF2B8A3E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProviderOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4C6EF5)
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 1.8 : 1,
          ),
          color: isSelected
              ? const Color(0xFF4C6EF5).withValues(alpha: 0.08)
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: isSelected
                      ? const Color(0xFF4C6EF5)
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptField(
    BuildContext context,
    AiDiagramState state,
    bool isDark,
  ) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter &&
            !HardwareKeyboard.instance.isShiftPressed) {
          _submit();
        }
      },
      child: TextField(
        controller: _promptController,
        focusNode: _promptFocusNode,
        maxLines: 3,
        minLines: 2,
        style: const TextStyle(fontSize: 14, height: 1.4),
        decoration: InputDecoration(
          hintText:
              'e.g. "Create a microservices authentication architecture with API Gateway, Auth Service, Redis Cache, and PostgreSQL"',
          hintStyle: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.02),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF4C6EF5),
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_outline,
                size: 14, color: isDark ? Colors.white54 : Colors.black54),
            const SizedBox(width: 6),
            Text(
              'Suggestions (click to use):',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: AiPromptTemplates.suggestions.map((suggestion) {
            return ActionChip(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              avatar: const Icon(Icons.flash_on, size: 14, color: Color(0xFFF59F00)),
              label: Text(
                suggestion.title,
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () {
                _promptController.text = suggestion.prompt;
                _promptFocusNode.requestFocus();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE03131).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE03131).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE03131), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFE03131),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(String? message, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4C6EF5).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6EF5)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message ?? 'Generating shapes, styles & layout...',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4C6EF5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodePreview(String code, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black45 : const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generated Mermaid Code:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          SelectableText(
            code,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AiDiagramState state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          if (state.lastResult != null)
            TextButton.icon(
              icon: Icon(
                _showRawCode ? Icons.visibility_off : Icons.code,
                size: 16,
              ),
              label: Text(
                _showRawCode ? 'Hide Code' : 'View Code',
                style: const TextStyle(fontSize: 12),
              ),
              onPressed: () {
                setState(() {
                  _showRawCode = !_showRawCode;
                });
              },
            ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4C6EF5),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: state.isGenerating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.auto_awesome, size: 16),
            label: Text(
              state.isGenerating ? 'Generating...' : 'Generate & Insert',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            onPressed: state.isGenerating ? null : _submit,
          ),
        ],
      ),
    );
  }
}
