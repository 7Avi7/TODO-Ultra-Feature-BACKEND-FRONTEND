import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_nodejs/config.dart';

class Contact extends StatefulWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  Map<String, dynamic>? authorData;
  List<String> imageUrls = [
    'http://192.168.1.102:3000/avi.png',
    'http://192.168.1.102:3000/avi2.png',
    'http://192.168.1.102:3000/avi3.png',
  ];
  bool _isConnected = true;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchAuthorData();
    initConnectivity();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      for (var result in results) {
        setState(() {
          _isConnected = result != ConnectivityResult.none;
        });
        if (result == ConnectivityResult.none) {
          showNoInternetNotification();
        } else {
          showInternetRestoredNotification();
          if (_isLoading) {
            fetchAuthorData();
          }
        }
      }
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isLoading) {
        fetchAuthorData();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  Future<void> sendMessage() async {
    final String subject = subjectController.text;
    final String message = messageController.text;

    final Uri uri = Uri.parse('http://192.168.1.102:3000/email');

    try {
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'subject': subject,
          'text': message,
        }),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
      } else {
        print('Failed to send message: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> fetchAuthorData() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get(Uri.parse('http://192.168.1.102:3000/avi/author'));
    if (response.statusCode == 200) {
      setState(() {
        authorData = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load author data');
    }
  }

  void showNoInternetNotification() {
    print("No internet connection!");
  }

  void showInternetRestoredNotification() {
    print("Internet connection restored!");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Contact',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('${url}nature4.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading) ...[
                    CircularProgressIndicator(),
                  ] else if (_isConnected && authorData != null) ...[
                    Text(
                      'Name: ${authorData!["data"][0]["author"]["name"]}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Education: ${authorData!["data"][0]["author"]["education"]}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Department: ${authorData!["data"][0]["author"]["department"]}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Mobile: ${authorData!["data"][0]["author"]["mobile"]}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Email: ${authorData!["data"][0]["author"]["email"]}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: 500,
                      width: 300,
                      child: CarouselSlider.builder(
                        itemCount: imageUrls.length,
                        itemBuilder:
                            (BuildContext context, int index, int realIndex) {
                          return Image.network(imageUrls[index]);
                        },
                        options: CarouselOptions(
                          aspectRatio: 1,
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            // Your code here
                          },
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text('No internet connection!'),
                  ],
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _isConnected
            ? FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.green,
                        title: const Text('To: avilashbhowmik7@gmail.com'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: subjectController,
                              decoration:
                                  const InputDecoration(labelText: 'Subject'),
                            ),
                            TextField(
                              controller: messageController,
                              decoration:
                                  const InputDecoration(labelText: 'Message'),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              sendMessage();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Send'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Icon(Icons.message),
              )
            : FloatingActionButton.extended(
                onPressed: () {
                  showNoInternetNotification();
                },
                label: Text('No Internet'),
                icon: Icon(Icons.error),
              ),
      ),
    );
  }
}
