import 'package:flutter/material.dart';
import 'package:record_app/features/record-detail/presentation/widgets/controls_button_row.dart';

class DetailRecordPage extends StatelessWidget {
  const DetailRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Record'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(flex: 3, child: Text('WaveForm')),
              Expanded(flex: 1, child: ControlsButtonRow()),
            ],
          ),
        ),
      ),
    );
  }
}
