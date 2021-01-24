import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quiver/iterables.dart';
import 'dart:io';
import 'package:paginator/country.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Paginator',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Paginator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<String> saved = {};

  Future<List<Country>> _getUsers() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = await http.get("https://api.first.org/data/v1/countries");

        var jsonData = json.decode(data.body);

        var users = jsonData['data'];
        List<Country> cu = [];
        List countries = users.values.toList();

        List keys = users.keys.toList();

        for (var u in zip([countries, keys])) {
          Country user = Country(u[1], u[0]['country'], u[0]['region']);
          cu.add(user);
        }

        ;
        return cu;
      }
    } on SocketException catch (_) {
      print("Please check your network Connectivity");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: new AppBar(
            title: Text("Tatsam Paginator App"),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Home'),
                Tab(icon: Icon(Icons.favorite), text: "Favorite"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(
                child: FutureBuilder(
                  future: _getUsers(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    print(snapshot.data);
                    if (snapshot.data == null) {
                      return Container(
                        child: Center(
                          child: Text("loading!"),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                snapshot.data[index].id,
                              ),
                            ),
                            title: Text(
                              snapshot.data[index].country,
                            ),
                            subtitle: Text(
                              snapshot.data[index].region,
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.favorite,
                              ),
                              color:
                                  saved.contains(snapshot.data[index].country)
                                      ? Colors.red
                                      : Colors.grey,
                              onPressed: () {
                                setState(
                                  () {
                                    if (saved.contains(
                                        snapshot.data[index].country)) {
                                      saved
                                          .remove(snapshot.data[index].country);
                                    } else
                                      saved.add(snapshot.data[index].country);
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              //Favorite VIEW Container
              Container(
                child: FutureBuilder(
                  future: _getUsers(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Container(
                        child: Center(
                          child: Text("Loading!"),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: saved.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                snapshot.data[index].id,
                              ),
                            ),
                            title: Text(
                              snapshot.data[index].country,
                            ),
                            subtitle: Text(
                              snapshot.data[index].region,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
