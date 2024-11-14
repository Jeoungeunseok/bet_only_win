import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/game_controller.dart';

class SecretSettingsDialog extends StatefulWidget {
  final GameController gameController;

  const SecretSettingsDialog({
    super.key,
    required this.gameController,
  });

  @override
  State<SecretSettingsDialog> createState() => _SecretSettingsDialogState();
}

class _SecretSettingsDialogState extends State<SecretSettingsDialog> {
  Widget _buildToggleOption(String title, ValueNotifier<bool> valueNotifier) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF3C3C3E),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: valueNotifier,
            builder: (context, value, child) {
              return CupertinoSwitch(
                value: value,
                onChanged: (newValue) {
                  valueNotifier.value = newValue;
                },
                activeColor: const Color(0xFF0A84FF),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF3C3C3E),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '비밀 설정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A84FF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildToggleOption(
              '왼쪽 하단 모서리',
              widget.gameController.leftBottomEnabled,
            ),
            _buildToggleOption(
              '오른쪽 하단 모서리',
              widget.gameController.rightBottomEnabled,
            ),
            _buildToggleOption(
              '오른쪽 상단 모서리',
              widget.gameController.rightTopEnabled,
            ),
            _buildToggleOption(
              '왼쪽 상단 모서리',
              widget.gameController.leftTopEnabled,
            ),
          ],
        ),
      ),
    );
  }
}
