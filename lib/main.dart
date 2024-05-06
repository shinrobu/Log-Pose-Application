import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:log_pose/util/todoTile.dart';
import 'firebase_options.dart';
import 'package:log_pose/screens/newActivityScreen.dart';
import 'package:log_pose/screens/signInScreen.dart';
import 'package:log_pose/screens/profileScreen.dart';
import 'package:log_pose/util/dialogBox.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Log Pose',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const SignInScreen(),
      routes: {
        "/homepage": (_) => MyHomePage(title: "Log Pose"),
        "/signin": (_) => SignInScreen()
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variables for local storage of tasks, username, and task identifiers
  var taskList = [];
  var taskKeys = [];
  var userName = "";
  var numIncomplete = 0;
  // Load all the tasks from Firebase

  _MyHomePageState() {

    // Get the tasks from the database if there is a user signed in
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        CircularProgressIndicator();
      } else {
        DatabaseReference taskListRef = FirebaseDatabase.instance.ref(
            'users/' + FirebaseAuth.instance.currentUser!.uid + "/tasks");
        taskListRef.onValue.listen((DatabaseEvent event) {
          if (event.snapshot.value != null) {
            final data = event.snapshot.value as Map;
            // In case data gets deleted, update local variables entirely
            taskList.clear();
            taskKeys.clear();
            numIncomplete = 0;
            data.forEach((k, v) {
              if (!taskList.contains(v) && !taskKeys.contains(k)) {
                taskList.add(v);
                taskKeys.add(k);
              }
            });
            print(taskKeys);
            if(mounted) {
              setState(() {
                numberIncomplete();
              });
            }
          }
        });

        // Get the name from the database and update local variable
        DatabaseReference userNameRef = FirebaseDatabase.instance.ref(
            'users/' + FirebaseAuth.instance.currentUser!.uid + "/name");
        userNameRef.onValue.listen((DatabaseEvent event) {
          if (event.snapshot.value != null) {
            userName = "";
            final nameData = event.snapshot.value as String;
            userName = nameData;
            print(nameData);
            // Update list and name view
            if(mounted) {
              setState(() {

              });
            }
          }
        });
      }
    });
  }

  // Checkbox tap, will update the task's "complete" value
  Future<void> checkBoxChanged(bool? value, int index) async {
    DatabaseReference taskRef = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}/tasks/' + taskKeys[index]);
    // Update the "complete" field for the task at the specified index
    await taskRef.update({'complete': !taskList[index]["complete"]});

    // Rerun the build to show the changes on app
    if(mounted) {
      setState(() {

      });
    }
  }

  // Edit tap, will update name of the task
  Future<void> taskNameChange(int index) async {
    DatabaseReference taskRef = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}/tasks/' + taskKeys[index]);
    final nameController = TextEditingController();
    showDialog(
        context: context,
        builder: (context)  {
          return DialogBox(
            controller: nameController,
            onSave: () {
              // Update local taskList
              if(nameController.text.length < 24) {
                taskList[index]["name"] = nameController.text;
                if(mounted) {
                  // Rerun the build to show the changes on app
                  setState(() {
                    numberIncomplete();
                  });
                }
                // Update the "name" field for the task at the specified index
                taskRef.update({'name': taskList[index]["name"]});
                Navigator.of(context).pop();
              }
            },
            onCancel: () => Navigator.of(context).pop(),
            textOfHint: "New task name:"
          );
    });
  }

  // Delete tap, will delete the task
  Future<void> taskDelete(int index) async {
    DatabaseReference taskRef = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}/tasks/' + taskKeys[index]);
    showDialog(
        context: context,
        builder: (context)  {
          return AlertDialog(
            title: const Text("Are you sure you want to delete this task?"),
            content: const Text("This will permanently delete the task."),
            actions: <Widget> [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => {
                  // If one task left, clear the list entirely. Edge-case that needs to be in here or else it doesn't delete properly at 1 task remaining
                  if(taskList.length == 1 && taskKeys.length == 1) {
                    taskList.clear(),
                    taskKeys.clear()
                  }
                  else {
                    taskList.remove(index),
                    taskKeys.remove(index),
                  },
                  // Update the "name" field for the task at the specified index
                  taskRef.remove(),
                  if(mounted) {
                    setState(() {
                      numberIncomplete();
                    })
                  },
                  Navigator.pop(context, 'OK'),
                },
                child: const Text('OK'),
              ),
            ]
          );
        });
  }


  // Function to handle the calculations of the number of incomplete tasks based on local variables
  Future<void> numberIncomplete() async {
    int compCount = 0;
    if(taskList.length <= 0) {
      compCount = 0;
    }
    else {
      for(int i = 0; i < taskList.length; i++) {
        if(taskList[i]['complete'] == false) {
          compCount++;
        }
      }
    }
    // Update the list view
    numIncomplete = compCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(
            child: Text(
            'Log Pose',
            style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            ),
          ),
        ),
      ),
      body: Center(
        child: Row(
          children: <Widget>[
            Expanded(
              child:
              ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  Align(
                  alignment: Alignment.topCenter,
                  child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                                Icons.explore,
                                size: 100,
                                color: Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8C78E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                      "Welcome back!\n" + userName,

                                  ),
                                ],
                              ),
                          ),
                        ]
                      ),
              ),

                  // Row of the views that have total tasks and tasks completed
                  Row(
                    children: <Widget>[
                      const Spacer(),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA6C9B4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Total Tasks\n" + taskList.length.toString(),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 5,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA6C9B4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Incomplete Tasks\n" + numIncomplete.toString(),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  // Stream builder to update the tasks as they get modified within the database in realtime (database updated in app)
                  StreamBuilder(
                    // Every time tasks are updated (the entire list view is called)
                    stream: FirebaseDatabase.instance.ref().child('users/' + FirebaseAuth.instance.currentUser!.uid + "/tasks").onValue,
                    builder: (context, snapshot) {
                      print(taskList);
                      return ListView.builder(
                          primary: false,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: taskList.length,
                          itemBuilder: (context, index) {
                            return ToDoTile(
                              taskName: taskList[index]['name'],
                              taskComplete: taskList[index]['complete'],
                              onChanged: (value) =>
                                  checkBoxChanged(value, index),
                              onPressedEdit: () =>
                                  taskNameChange(index),
                              onPressedDelete: () =>
                                  taskDelete(index)
                            );
                          }
                      );
                    }
                  ),
                ],
                ),
            ),
        ]
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
              const Spacer(),
              InkWell(
                  onTap: () {

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
              InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NewActivityPage(title: "New Activity")));
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