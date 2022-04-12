// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response = await client.get(Uri.parse(
      'https://kubsau.ru/api/getNews.php?key=6df2f5d38d4e16b5a923a6d4873e2ee295d0ac90'));
  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class Photo {
  final String? ID;
  final String? ACTIVE_FROM;
  final String? TITLE;
  final String? PREVIEW_TEXT;
  final String? PREVIEW_PICTURE_SRC;
  final String? DETAIL_PAGE_URL;
  final String? DETAIL_TEXT;
  final String? LAST_MODIFIED;

  Photo({
    required this.ID,
    required this.ACTIVE_FROM,
    required this.TITLE,
    required this.PREVIEW_TEXT,
    required this.PREVIEW_PICTURE_SRC,
    required this.DETAIL_PAGE_URL,
    required this.DETAIL_TEXT,
    required this.LAST_MODIFIED,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      ID: json['ID'] as String?,
      ACTIVE_FROM: json['ACTIVE_FROM'] as String?,
      TITLE: json['TITLE'] as String?,
      PREVIEW_TEXT: json['PREVIEW_TEXT'] as String?,
      PREVIEW_PICTURE_SRC: json['PREVIEW_PICTURE_SRC'] as String?,
      DETAIL_PAGE_URL: json['DETAIL_PAGE_URL'] as String?,
      DETAIL_TEXT: json['DETAIL_TEXT'] as String?,
      LAST_MODIFIED: json['LAST_MODIFIED'] as String?,
    );
  }
}

class PhotosList extends StatelessWidget {
  const PhotosList({Key? key, required this.photos}) : super(key: key);

  final List<Photo> photos;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        itemCount: 10, //иначе при скроллинге ошибка RangeError

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          return Card(
              child: Column(
            children: [
              Image.network(photos[index].PREVIEW_PICTURE_SRC!),
              SizedBox(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Bidi.stripHtmlIfNeeded(photos[index].ACTIVE_FROM!),
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      Text(
                        Bidi.stripHtmlIfNeeded(photos[index].TITLE!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(Bidi.stripHtmlIfNeeded(photos[index].PREVIEW_TEXT!)),
                    ],
                  ),
                ),
              )
            ],
          ));
        });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ошибка запроса!'),
            );
          } else if (snapshot.hasData) {
            return PhotosList(photos: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Лента новостей КубГАУ';

    return MaterialApp(
      title: appTitle,
      home: const MyHomePage(title: appTitle),
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
    );
  }
}
