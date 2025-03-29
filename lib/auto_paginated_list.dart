import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Signature for a function that builds a widget given a [BuildContext] and an item of type [T].
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);

/// Signature for a function that fetches more items of type [T] given a page number.
typedef FetchMoreItems<T> = Future<List<T>> Function(int page);

/// Manages pagination state for the [AutoPaginatedList] widget.
///
/// This class keeps track of loaded data, handles API calls for fetching more items,
/// and manages loading, error, and page-tracking states.
///
/// It uses [ChangeNotifier] to notify listeners when the pagination state changes.
class PaginationState<T> extends ChangeNotifier {
  /// Internal list to store fetched data.
  List<T> _data = [];

  /// Indicates whether data is currently being loaded.
  bool _isLoading = false;

  /// Tracks the current page number.
  int _currentPage = 1;

  /// The total number of pages available.
  int _totalPages = 1;

  /// Stores any error message encountered while loading data.
  String? _error;

  /// Returns the list of loaded data items.
  List<T> get data => _data;

  /// Returns whether the data is currently being fetched.
  bool get isLoading => _isLoading;

  /// Returns the current page number.
  int get currentPage => _currentPage;

  /// Returns the total number of pages available.
  int get totalPages => _totalPages;

  /// Returns the error message if an error occurred, otherwise null.
  String? get error => _error;

  /// Returns `true` if an error has occurred.
  bool get hasError => _error != null;

  /// Returns `true` if more pages are available to fetch.
  bool get hasMorePages => _currentPage <= _totalPages;

  /// Updates the total number of pages available and notifies listeners.
  void setTotalPages(int pages) {
    _totalPages = pages;
    notifyListeners();
  }

  /// Sets the initial page number for pagination and notifies listeners.
  void setInitialPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  /// Fetches the next page of data using the provided [fetchData] function.
  ///
  /// If a request is already in progress or all pages are loaded, it does nothing.
  Future<void> loadData(FetchMoreItems<T> fetchData) async {
    if (_isLoading || _currentPage > _totalPages) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newData = await fetchData(_currentPage);
      _data.addAll(newData);
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the pagination state, clearing all data and resetting page tracking.
  void reset() {
    _data = [];
    _currentPage = 1;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

/// A widget that displays a paginated list and loads more data as the user scrolls.
///
/// Uses Provider for state management and supports custom UI for loading,
/// error, and empty states.
class AutoPaginatedList<T> extends StatefulWidget {
  /// Function to fetch more items from an API or database.
  final FetchMoreItems<T> fetchData;

  /// Function to build each list item.
  final ItemBuilder<T> itemBuilder;

  /// Number of items per page.
  final int itemsPerPage;

  /// The initial page index for pagination.
  final int initialPage;

  /// The total number of pages available from the API.
  final int totalPagesFromApi;

  /// Widget to show while data is loading.
  final Widget? loadingWidget;

  /// Widget to show when an error occurs.
  final Widget? errorWidget;

  /// Widget to show when no data is available.
  final Widget? emptyWidget;

  /// Padding around the list.
  final EdgeInsets? padding;

  /// Whether the list should shrink to fit its content.
  final bool shrinkWrap;

  /// The scroll physics for the list.
  final ScrollPhysics? physics;

  /// A builder function to create a separator between list items.
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Creates an [AutoPaginatedList].
  ///
  /// Example usage:
  /// ```dart
  /// AutoPaginatedList<MyModel>(
  ///   fetchData: (page) async => fetchItemsFromApi(page),
  ///   itemBuilder: (context, item) => ListTile(title: Text(item.name)),
  ///   itemsPerPage: 10,
  ///   initialPage: 1,
  ///   totalPagesFromApi: 5,
  ///   loadingWidget: CircularProgressIndicator(),
  ///   errorWidget: Text('Error loading data'),
  ///   emptyWidget: Text('No items found'),
  /// )
  /// ```
  const AutoPaginatedList({
    super.key,
    required this.fetchData,
    required this.itemBuilder,
    required this.itemsPerPage,
    required this.initialPage,
    required this.totalPagesFromApi,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.padding,
    this.shrinkWrap = true,
    this.physics,
    this.separatorBuilder,
  });

  @override
  State<AutoPaginatedList<T>> createState() => _AutoPaginatedListState<T>();
}

class _AutoPaginatedListState<T> extends State<AutoPaginatedList<T>> {
  late ScrollController _scrollController;
  late PaginationState<T> _paginationState;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // Initialize state
    _paginationState = PaginationState<T>();
    _paginationState.setInitialPage(widget.initialPage);
    _paginationState.setTotalPages(widget.totalPagesFromApi);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _paginationState.loadData(widget.fetchData);
    });
  }

  @override
  void didUpdateWidget(covariant AutoPaginatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.totalPagesFromApi != oldWidget.totalPagesFromApi) {
      _paginationState.setTotalPages(widget.totalPagesFromApi);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent -
                200 && // Buffer before reaching the end
        _paginationState.hasMorePages &&
        !_paginationState.isLoading) {
      _paginationState.loadData(widget.fetchData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _paginationState,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(0),
        child: Consumer<PaginationState<T>>(
          builder: (context, state, _) {
            return ListView.separated(
              controller: _scrollController,
              shrinkWrap: widget.shrinkWrap,
              physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
              itemCount:
                  state.data.length +
                  1, // Add 1 for loading indicator or empty state
              itemBuilder: (context, index) {
                if (index == state.data.length) {
                  // If loading, show loading indicator
                  if (state.isLoading) {
                    return widget.loadingWidget ??
                        const Center(child: CircularProgressIndicator());
                  } else if (state.data.isEmpty && widget.emptyWidget != null) {
                    return widget.emptyWidget!;
                  } else if (state.hasError && widget.errorWidget != null) {
                    return widget.errorWidget!;
                  } else if (!state.isLoading && !state.hasMorePages) {
                    return const SizedBox.shrink(); // No more pages
                  }
                  return const SizedBox.shrink();
                }

                // Render item
                return widget.itemBuilder(context, state.data[index]);
              },
              separatorBuilder:
                  widget.separatorBuilder ??
                  (context, index) => const SizedBox(), // Default separator
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
