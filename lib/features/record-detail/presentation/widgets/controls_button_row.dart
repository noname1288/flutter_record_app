import 'package:flutter/material.dart';

class ControlsButtonRow extends StatefulWidget {
  const ControlsButtonRow({super.key});

  @override
  State<ControlsButtonRow> createState() => _ControlsButtonRowState();
}

class _ControlsButtonRowState extends State<ControlsButtonRow> {
  bool isRecording = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: isRecording ? _buildPauseStopButton() : _buildPlayButton(),
    );
  }

  Widget _buildPauseStopButton() {
    return Row(
      children: [
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 1,
          child: RecordControlButton(
            icon: Icons.pause,
            label: 'Pause',
            onPressed: () {
              setState(() {
                isRecording = false;
              });
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: RecordControlButton(
            icon: Icons.stop,
            label: 'Stop',
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Row(
      children: [
        const Expanded(flex: 1, child: SizedBox.shrink()),
        Expanded(
          flex: 1,
          child: RecordControlButton(
            icon: Icons.play_arrow,
            label: 'Play',
            onPressed: () {
              setState(() {
                isRecording = true;
              });
            },
          ),
        ),
        const Expanded(flex: 1, child: SizedBox.shrink()),
      ],
    );
  }
}

class RecordControlButton extends StatelessWidget {
  const RecordControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 48,
        ),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
