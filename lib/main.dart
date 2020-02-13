import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JSON',
      home: ElementsList(),
    );
  }
}

// 2- Creamos un método que parsee nuestra response HTTP
List<User> parseUsers(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<User>((json) => User.fromJson(json)).toList();
}

// 3- Creamos el método que se conecta con el servidor
// Llamará al método parseUsers, tendremos una lista
Future<List<User>> fetchUsers(http.Client client) async {
  final response =
      await client.get('https://jsonplaceholder.typicode.com/posts');
  print(response.body);
  return parseUsers(response.body);
}

class ElementsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ElementsListState();
  }
}

// 5- En la clase que tenemos como home, definimos como body el paso 4
class ElementsListState extends State<ElementsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prueba JSON')),
      body: usersListView(),
    );
  }
}

Widget usersListView() {
  return FutureBuilder(
      future: fetchUsers(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasError) print(snapshot.error);

        return snapshot.hasData
            ? UsersList(users: snapshot.data)
            : Center(child: CircularProgressIndicator());
      });
}

// 1- Primero creamos la clase POJO
class User {
  final int userId;
  final int id;
  final String title;
  final String body;

  User({this.userId, this.id, this.title, this.body});

  // Utilizamos este método al que le pasamos nuestro JSON para crear usuarios
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['userId'],
        id: json['id'],
        title: json['title'],
        body: json['body']);
  }

  @override
  String toString() {
    return '$title \n $body';
  }
}

// 4- Creamos la clase que liste finalmente los usuarios
class UsersList extends StatelessWidget {
  final List<User> users;

  UsersList({Key key, this.users}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          if (index.isOdd) {
            return Divider(color: Colors.black);
          }
          return Text(users[index].toString());
        },
        padding: EdgeInsets.all(30.0));
  }
}
