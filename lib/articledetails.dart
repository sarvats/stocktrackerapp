import 'package:flutter/material.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> article; // Retrieves the article

  const ArticleDetailsPage({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['headline'] ?? 'Article Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['image'] != null)
              Image.network(
                article['image'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16.0),
            Text(
              article['headline'] ?? 'No Title',
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  article['summary'] ?? 'No content available.',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
