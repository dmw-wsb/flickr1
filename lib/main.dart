import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flickr Photo Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PhotoSearchScreen(),
    );
  }
}

class PhotoSearchScreen extends StatefulWidget {
  @override
  _PhotoSearchScreenState createState() => _PhotoSearchScreenState();
}

class _PhotoSearchScreenState extends State<PhotoSearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _photoUrls = [];

  void _searchPhotos() async {
    String tags = _searchController.text;
    String apiUrl =
        'https://api.flickr.com/services/feeds/photos_public.gne?tags=$tags&format=json&nojsoncallback=1';

    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<String> photoUrls = [];

      for (var item in jsonData['items']) {
        String photoUrl = item['media']['m'];
        photoUrl = photoUrl.replaceFirst('_m.', '_b.');
        photoUrls.add(photoUrl);
      }

      setState(() {
        _photoUrls = photoUrls;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flickr Photo Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search photos by tags',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _searchPhotos,
            child: Text('Search'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _photoUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenPhotoScreen(photoUrl: _photoUrls[index]),
                      ),
                    );
                  },
                  child: Image.network(_photoUrls[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenPhotoScreen extends StatelessWidget {
  final String photoUrl;

  FullScreenPhotoScreen({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(photoUrl),
      ),
    );
  }
}
