import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diary')),
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Next'),
        ),
      ),
    );
  }
}
