<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

AutoPaginatedList simplifies infinite scrolling in Flutter with Provider, auto-loading data with customizable states.

## Features

- ✅ **Auto Pagination** – Loads more data as you scroll.
- ✅ **Preloads Next Page** – Loads the next page before reaching the bottom for a smooth experience.
- ✅ **Provider-Based State** – Optimized with `ChangeNotifier`.
- ✅ **Customizable UI** – Supports loading, error, and empty states.
- ✅ **Smooth Scrolling** – Efficient handling with `ScrollController`.
- ✅ **Flexible Config** – Customize page size, separators, and physics.
- ✅ **Easy to Use** – Just provide a fetch function and item builder!

## Usage

To use this package, simply integrate it into your Flutter project and provide a function to fetch paginated data. The package handles infinite scrolling, loading indicators, error handling, and empty states out of the box.

You can customize the appearance using optional widgets for loading, error, and empty states. Additionally, separators can be added between list items.

check the /example folder in the repository.

```dart
class PaginatedListScreen extends StatelessWidget {
  const PaginatedListScreen({super.key});

  // Simulating an API call
  Future<List<String>> fetchItems(int page) async {
    // page will be automatically incremented.
    await Future.delayed(const Duration(seconds: 2));
    return List.generate(10, (index) => 'Item ${(page - 1) * 10 + index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paginated ListView')),
      body: PaginatedListView<String>(
        fetchData: fetchItems,
        itemBuilder: (context, item) => ListTile(title: Text(item)),
        itemsPerPage: 10, //  Page size per page
        initialPage: 1, // Initial page
        totalPagesFromApi: 5, // Total pages
        loadingWidget: const Center(child: CircularProgressIndicator()),
        emptyWidget: const Center(child: Text('No items found')),
        errorWidget: const Center(child: Text('Error loading data')),
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
```

## Contributing 🤝

Contributions are welcome! If you'd like to improve this package, feel free to reach out or submit a pull request.

## Reporting Issues 🐛

If you find a bug or have a feature request, please open an issue on the GitHub Issues page. When reporting an issue, include:
- A clear description of the problem
- Steps to reproduce (if applicable)
- Expected vs. actual behavior
- Logs or screenshots (if relevant)  

