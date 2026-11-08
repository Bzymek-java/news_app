import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:news_app/const.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../models/filterc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{
  final Dio dio = Dio();
  List<Article> articles = [];
  bool isLoading = false;
  String selectedCategory = 'business';
//wincyj filtrow albo moze wyszukiwarke
  final List<NewsFilter> filters = const [
    NewsFilter(title: 'Business', category: 'business', description: 'Business and  Finance'),
    NewsFilter(title: 'Entertainment', category: 'entertainment', description: 'Entertainment'),
    NewsFilter(title: 'General', category: 'general', description: 'General'),
    NewsFilter(title: 'Health', category: 'health', description: 'Health'),
    NewsFilter(title: 'Science', category: 'science', description: 'Science'),
    NewsFilter(title: 'Sports', category: 'sports', description: 'Sports'),
    NewsFilter(title: 'Technology', category: 'technology', description: 'Technology'),
  ];


  @override
  void initState(){
    super.initState();
    _getNews();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("News"),
    ),
    body: _buildUI(),
  );
}
//Widget do budowania filtrow sprawdzic konstrukcje
Widget _buildFilterList() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter.category == selectedCategory;
          return ChoiceChip(
            label: Text(filter.title),
            selected: isSelected,
            onSelected: (selected) {
              if (selected && filter.category != selectedCategory) {
                setState(() {
                  selectedCategory = filter.category;
                });
                _getNews();
                }
              },
          );

        },
    ),
    );
}

Widget _buildUI() {
  return Column(
    children: [
      _buildFilterList(), // Dodaje widget do filtrowania na gore
    Expanded(child: isLoading
    ? const Center (child: CircularProgressIndicator())
        : ListView.builder(
    itemCount: articles.length,
    itemBuilder: (context, index) {
  final article = articles[index];
  return ListTile(
  onTap: () {
  _launchUrl(Uri.parse(article.url ?? ""));
  },
  leading: Image.network(
  article.urlToImage ?? PLACEHOLDER_IMAGE_LINK,
  height: 250,
  width: 100,
  fit: BoxFit.cover,
  ),
  title: Text(article.title ?? ""),
  subtitle: Text(article.publishedAt ?? ""),
         );
      },
    ),
  ),
    ],
  );
}

Future<void> _getNews() async {
    setState(() {
      isLoading = true;
    });
   try{
  final response = await dio.get(
    'https://newsapi.org/v2/top-headlines?country=us&category=$selectedCategory&apiKey=$NEWS_API_KEY',
  );
  final articlesJson = response.data["articles"] as List;
  setState(() {
    List<Article> newsArticle =
    articlesJson.map((a) => Article.fromJson(a)).toList();
    newsArticle = newsArticle.where((a) => a.title != "[Removed]").toList();
    articles = newsArticle;
  });
} catch (e) {
     setState(() {
       articles = [];
     });
   } finally {
     setState(() {
       isLoading = false;
   });
     }
}

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
}