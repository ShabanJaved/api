import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PostsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Api code',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const PostsListScreen(),
    );
  }
}

class PostsProvider extends ChangeNotifier {
  List<dynamic> _posts = [];
  List<dynamic> _filteredPosts = [];
  final TextEditingController searchController = TextEditingController();

  PostsProvider() {
    searchController.addListener(_onSearchChanged);
    fetchPosts();
  }

  List<dynamic> get filteredPosts => _filteredPosts;

  Future<void> fetchPosts() async {
    final apiService = ApiService();
    _posts = await apiService.fetchPosts();
    _filteredPosts = _posts;
    notifyListeners();
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    _filteredPosts = _posts
        .where((post) => post['title'].toLowerCase().contains(query))
        .toList();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}

class PostsListScreen extends StatelessWidget {
  const PostsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Posts")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBox(),
          ),
          Expanded(child: PostsList()),
        ],
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    return TextField(
      controller: postsProvider.searchController,
      decoration: const InputDecoration(
        labelText: "Search",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  const PostsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        if (postsProvider.filteredPosts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: postsProvider.filteredPosts.length,
          itemBuilder: (context, index) {
            final post = postsProvider.filteredPosts[index];
            return ListTile(
              title: Text(post['title']),
              subtitle: Text(post['body']),
            );
          },
        );
      },
    );
  }
}
