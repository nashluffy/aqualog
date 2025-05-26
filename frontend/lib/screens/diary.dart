import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  const DiaryPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diary')),
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
