import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:record_app/core/router/app_router.dart';

class ListRecordPage extends StatelessWidget {
  const ListRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Recordings'),
        centerTitle: false,
        actions: [IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.add_circled))],
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            context.push(AppRouter.recordDetailPath);
          },
          child: Text("Detail Record"),
        ),
      ),
    );
  }
}
