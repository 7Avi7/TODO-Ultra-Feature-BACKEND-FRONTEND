import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_nodejs/contact.dart';

import 'config.dart';
import 'login_page.dart';

class DashBoard extends StatefulWidget {
  final String token;

  const DashBoard({required this.token, Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  late String userId;
  List? items;
  TextEditingController _todoTitle = TextEditingController();
  TextEditingController _todoDesc = TextEditingController();
  Map<String, dynamic>? userInfo;

  bool _isLoading = false;
  bool _isConnected = true;
  bool _isDataFetchedCompletely = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _isConnected = (result != ConnectivityResult.none);
        if (_isConnected) {
          getTodoList(userId);
        }
      });
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isConnected && !_isDataFetchedCompletely) {
        getTodoList(userId);
      } else {
        timer
            .cancel(); // Stop the timer when data is fetched completely or when disconnected
      }
    });

    Map<String, dynamic>? jwtDecodedToken = JwtDecoder.decode(widget.token);
    if (jwtDecodedToken != null) {
      userId = jwtDecodedToken['_id'];
    } else {
      userId = "Unknown";
    }
    getTodoList(userId);
    if (userInfo == null) {
      getUserInfo().then((info) {
        setState(() {
          userInfo = info;
        });
      }).catchError((error) {
        print('Error fetching user info: $error');
      });
    }
  }

  void addTodo() async {
    if (_todoTitle.text.isNotEmpty && _todoDesc.text.isNotEmpty) {
      var regBody = {
        "userId": userId,
        "title": _todoTitle.text,
        "desc": _todoDesc.text
      };

      var response = await http.post(Uri.parse(urladdTodo),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);

      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        _todoDesc.clear();
        _todoTitle.clear();
        // Navigator.pop(context);
        getTodoList(userId);
      } else {
        print("SomeThing Went Wrong");
      }
    }
  }

  void getTodoList(userId) async {
    if (_isConnected) {
      var regBody = {"userId": userId};

      var response = await http.post(Uri.parse(urlGetTodoList),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);
      items = jsonResponse['success'];
      if (items != null && items!.isNotEmpty) {
        _isDataFetchedCompletely = true;
      }

      setState(() {});
    }
  }

  void deleteItem(id) async {
    var regBody = {"id": id};

    var response = await http.post(Uri.parse(urldeleteTodo),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody));

    var jsonResponse = jsonDecode(response.body);
    if (jsonResponse['status']) {
      getTodoList(userId);
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    var response = await http.get(Uri.parse('${url}user/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load user information');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow,
          title: const Text("ADD To-Do"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _todoTitle,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: _todoDesc,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                addTodo();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Center(child: const Text("Add")),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog() async {
    if (userInfo != null) {
      TextEditingController nameController =
          TextEditingController(text: userInfo!['name']);
      TextEditingController mobileController =
          TextEditingController(text: userInfo!['mobile']);
      TextEditingController addressController =
          TextEditingController(text: userInfo!['address']);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit Profile"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: mobileController,
                    decoration: InputDecoration(labelText: 'Mobile'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Address'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        // Call API to update user info
                        var regBody = {
                          'name': nameController.text,
                          'mobile': mobileController.text,
                          'address': addressController.text,
                        };

                        setState(() {
                          _isLoading = true; // Show loading indicator
                        });

                        var response = await http.put(
                          Uri.parse('${url}user/$userId'),
                          headers: {
                            "Content-Type": "application/json",
                            "Authorization": "Bearer ${widget.token}"
                          },
                          body: jsonEncode(regBody),
                        );

                        if (response.statusCode == 200) {
                          await Future.delayed(Duration(seconds: 3));
                          setState(() {
                            _isLoading = false; // Hide loading indicator
                          });
                          Navigator.pop(context); // Close the dialog
                          // Refresh the entire page
                          setState(() {});
                        } else {
                          print(
                              'Failed to update user info: ${response.statusCode}');
                        }
                      } catch (error) {
                        print('Error updating user info: $error');
                      }
                    },
                    child: Text('Update'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Handle case where user info is not available
      print('User information not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : _isConnected
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  leading: Icon(
                    Icons.sunny,
                    color: Colors.yellow,
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Contact()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors
                                .green, // Change color according to your design
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Contact',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _showEditProfileDialog,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _logout,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                body: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('$urlBackgroundImage1'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Flexible(
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: getUserInfo(),
                            builder: (context, snapshot) {
                              var userInfo = snapshot.data;

                              return Column(
                                children: [
                                  SizedBox(height: 8),
                                  Text("Dashboard",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  userInfo?['photo'] != null
                                      ? CircleAvatar(
                                          radius: 100,
                                          backgroundImage: NetworkImage(
                                              '$urlGetImage/${userInfo?['photo']}'),
                                        )
                                      : Placeholder(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "ID: ${userInfo?['_id']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Email: ${userInfo?['email']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Name: ${userInfo?['name']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Mobile: ${userInfo?['mobile']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Address: ${userInfo?['address']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: items?.length ?? 0,
                            itemBuilder: (context, index) {
                              return Slidable(
                                key: ValueKey(index),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (BuildContext context) {
                                        print(
                                            '${items![index]['_id']} is Deleted');
                                        deleteItem('${items![index]['_id']}');
                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: Card(
                                  color: Colors.yellow,
                                  child: ListTile(
                                    title: Text(items![index]['title']),
                                    subtitle: Text(items![index]['desc']),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: _showAddTodoDialog,
                  backgroundColor: Colors.yellow,
                  tooltip: 'Add Todo',
                  child: Icon(Icons.add),
                ),
              )
            : Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _todoTitle.dispose();
    _todoDesc.dispose();
    super.dispose();
  }
}
