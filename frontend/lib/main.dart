import 'package:aqualog/screens/diary.dart';
import 'package:aqualog/screens/search.dart';
import 'package:flutter/material.dart';
import 'services/grpc_client.dart'; // Import the gRPC client

void main() {
  runApp(const AqualogApp());
}

class AqualogApp extends StatelessWidget {
  const AqualogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter gRPC Client',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DefaultTabController(length: 3, child: AqualogHomePage()),
    );
  }
}

class AqualogHomePage extends StatefulWidget {
  const AqualogHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<AqualogHomePage> {
  final GrpcClient grpcClient = GrpcClient();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    grpcClient.shutdown(); // Clean up the gRPC client
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('aqualog'),
        bottom: const TabBar(
          tabs: [Tab(icon: Icon(Icons.search)), Tab(icon: Icon(Icons.book))],
        ),
      ),
      body: TabBarView(
        children: [SearchPage(grpcClient: grpcClient), const DiaryPage()],
      ),
    );
  }
}
