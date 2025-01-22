import 'package:flutter/material.dart';

class NameListPage extends StatefulWidget {
  const NameListPage({super.key});

  @override
  NameListPageState createState() => NameListPageState();
}

class NameListPageState extends State<NameListPage> {
  final List<String> names = ["John", "Jane", "Paul", "Anna"];

  void _showAddNameDialog() {
    String newName = "";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add New Friend"),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: "Enter name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (newName.isNotEmpty) {
                  // setState(() {
                  //   // names.add(newName);
                  // });
                }
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Name List"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: names.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(names[index]),
                  onTap: () {
                    // Route to another page when a ListTile is tapped
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         NameDetailPage(name: names[index]),
                    //   ),
                    // );
                  },
                );
              },
            ),
          ),
          // Button to add a new name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _showAddNameDialog,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Add Name"),
            ),
          ),
        ],
      ),
    );
  }
}

// class NameDetailPage extends StatelessWidget {
//   final String name;

//   const NameDetailPage({super.key, required this.name});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(name),
//       ),
//       body: Center(
//         child: Text("Details for $name"),
//       ),
//     );
//   }
// }
