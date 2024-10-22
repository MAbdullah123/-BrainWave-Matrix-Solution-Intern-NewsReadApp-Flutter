import 'package:flutter/material.dart';
import 'package:flutter_application_task2_newsreaderapp/news_view.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';

class NewsPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  const NewsPage({super.key, required this.toggleTheme});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<Article>> future;
  String? searchTerm;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<String> categoryItems = [
    "General",
    "Entertainment",
    "Business",
    "Health",
    "Science",
    "Sports",
    "Technology",
  ];
  late String selectedCategory;

  @override
  void initState() {
    selectedCategory = categoryItems[0]; // Default to first category
    future = getNewsData();
    super.initState();
  }

  Future<List<Article>> getNewsData() async {
    NewsAPI newsAPI = NewsAPI(apiKey: "3f5071f3f40a402baa21c63ed87abefb");
    return await newsAPI.getTopHeadlines(
      country: "us",
      query: searchTerm,
      category: selectedCategory,
      pageSize: 50, // API expects lowercase category
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isSearching ? searchAppBar() : appBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildCategories(),
            Expanded(
              child: FutureBuilder<List<Article>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error loading the news"),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return _buildNewsListView(snapshot.data!);
                  } else {
                    return const Center(
                      child: Text("No news available"),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  searchAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(179, 48, 24, 24),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            isSearching = false;
            searchTerm = null;
            searchController.text = "";
            future = getNewsData();
          });
        },
      ),
      title: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {
              setState(() {
                searchTerm = searchController.text;
                future = getNewsData();
              });
            },
            icon: const Icon(Icons.search)),
      ],
    );
  }

  appBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(179, 48, 24, 24),
      title: const Text("World Wide News"),
      actions: [
        IconButton(
            onPressed: () {
              setState(() {
                isSearching = true;
              });
            },
            icon: const Icon(Icons.search)),
        IconButton(
          icon: const Icon(Icons.brightness_6), // Theme toggle icon
          onPressed:
              widget.toggleTheme, // Call the toggle function when pressed
        ),
      ],
    );
  }

  Widget _buildNewsListView(List<Article> articleList) {
    return ListView.builder(
      itemCount: articleList.length,
      itemBuilder: (context, index) {
        Article article = articleList[index];
        return _buildNewsItem(article);
      },
    );
  }

  Widget _buildNewsItem(Article article) {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsView(url: article.url!),
            ),
          );
        },
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: Image.network(
                    article.urlToImage ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, StackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title!,
                      maxLines: 3,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      article.source.name!,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ))
              ],
            ),
          ),
        ));
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory =
                      categoryItems[index]; // Update the selected category
                  future =
                      getNewsData(); // Refresh news data based on the new category
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryItems[index] == selectedCategory
                    ? const Color.fromARGB(179, 208, 203, 203)
                    : const Color.fromARGB(179, 200, 195, 195),
              ),
              child: Text(categoryItems[index]),
            ),
          );
        },
        itemCount: categoryItems.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
