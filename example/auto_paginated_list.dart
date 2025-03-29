import 'package:auto_paginated_list/auto_paginated_list.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paginated ListView Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PaginatedListScreen(),
    );
  }
}

class PaginatedListScreen extends StatelessWidget {
  const PaginatedListScreen({super.key});

  Future<List<String>> fetchItems(int page) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating API delay
    return List.generate(10, (index) => 'Item ${(page - 1) * 10 + index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paginated ListView Example')),
      body: AutoPaginatedList<String>(
        fetchData: fetchItems,
        itemBuilder: (context, item) => ListTile(title: Text(item)),
        itemsPerPage: 10,
        initialPage: 1,
        totalPagesFromApi: 5,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        errorWidget: const Center(child: Text('Error loading data')),
        emptyWidget: const Center(child: Text('No items found')),
      ),
    );
  }
}
