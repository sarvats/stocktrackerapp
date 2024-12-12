import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsfeedPage extends StatefulWidget {
  @override
  _NewsfeedPageState createState() => _NewsfeedPageState();
}

class _NewsfeedPageState extends State<NewsfeedPage> {
  List<dynamic> newsArticles = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    const String apiKey = 'ctdlb1hr01qng9get1lgctdlb1hr01qng9get1m0';
    final Uri url = Uri.parse('https://finnhub.io/api/v1/news?category=general&token=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          newsArticles = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch news. Try again later.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  void _bookmarkArticle(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bookmarked: ${newsArticles[index]['headline']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Newsfeed'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : newsArticles.isEmpty
                  ? Center(
                      child: Text(
                        'No news available.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: newsArticles.length,
                      itemBuilder: (context, index) {
                        final article = newsArticles[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(article['headline'] ?? 'No Title'),
                            subtitle: Text('${article['source']}'),
                            trailing: IconButton(
                              icon: Icon(Icons.bookmark_border),
                              onPressed: () => _bookmarkArticle(index),
                            ),
                            onTap: () => _openArticle(article['url']),
                          ),
                        );
                      },
                    ),
    );
  }

  void _openArticle(String url) {
    // Placeholder for URL navigation (use url_launcher package)
    print('Opening article: $url');
  }
}
