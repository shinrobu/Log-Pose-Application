import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:log_pose/screens/profileScreen.dart';
import 'package:log_pose/main.dart';
import 'package:log_pose/util/dialogBox.dart';
import 'package:log_pose/util/todoTile.dart';
import 'package:firebase_database/firebase_database.dart';

class NewActivityPage extends StatefulWidget {
  const NewActivityPage({super.key, required this.title});
  final String title;

  @override
  State<NewActivityPage> createState() => _NewActivityPageState();
}

class _NewActivityPageState extends State<NewActivityPage> {

  final _controller = TextEditingController();

  // Create a new task
  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
              controller: _controller,
              onSave: () {
                // Text length must be less than 24 characters so it fits inside its container
                if(_controller.text.length < 24) {

                    // Unique task IDs generated based on time of creation
                    var timestamp = DateTime.now().millisecondsSinceEpoch;
                    FirebaseDatabase.instance.ref().child(
                        'users/' + FirebaseAuth.instance.currentUser!.uid + "/tasks/task" + timestamp.toString()).set(
                        {
                          "name": _controller.text ?? "",
                          "complete": false
                        }
                    ).then((value) {
                      print("Successfully added a task!");

                    }).catchError((error) {
                      print("Failed to add." + error.toString());
                    });
                    Navigator.of(context).pop();
                  }
              },
              onCancel: () => Navigator.of(context).pop(),
              textOfHint: "Add a new activity:",
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('New Activity'),
      ),
      body: Center(
        // Button to create a task
        child: ElevatedButton(
          onPressed: () {
            createNewTask();
          },
          child: const Text('Add a New Activity'),
        ),
      ),

      // For the cool orange navigation bar at the bottom
      bottomNavigationBar: BottomAppBar(
        color: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        child: IconTheme(
          data: IconThemeData(color: Theme
              .of(context)
              .colorScheme
              .onPrimary),
          child: Row(
            children: <Widget>[
              // Home page button
              const Spacer(),
              InkWell(
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        Icon(Icons.home),
                        Text("Home Page", style: TextStyle(color: Colors.white))
                      ]
                  )
              ),
              const Spacer(),

              // Profile page button
              InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage(title: "Profile")));
                  },
                  child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_circle),
                        Text("Profile", style: TextStyle(color: Colors.white))
                      ])),
              const Spacer(),

              // New Activity page button
              InkWell(
                  onTap: () {
                  },
                  child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        Icon(Icons.add_circle),
                        Text("New Activity", style: TextStyle(color: Colors.white))
                      ]
                  )
              ),
              const Spacer()
            ],
          ),
        ),
      ),
    );
  }
}