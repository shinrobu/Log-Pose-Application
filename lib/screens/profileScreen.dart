import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:log_pose/main.dart';
import 'package:log_pose/util/dialogBox.dart';
import 'package:log_pose/util/todoTile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:log_pose/screens/newActivityScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});
  final String title;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var userName = "";
  _ProfilePageState() {
    // Get the name from database when state is called
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
  // Delete account from firebase database
  Future<void> dbAccountDelete() async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}');
    userRef.remove();
    await FirebaseAuth.instance.signOut();
    }

  Future<void> deleteUserAccount() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      print("Error ${e.toString()}");
      if (e.code == "requires-recent-login") {
        await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
      }
    } catch (e) {
      print("Error ${e.toString()}");
      // Handle general exception
    }
  }

  // Code to ensure that account is deleted properly (reauthentication)
  Future<void> _reauthenticateAndDelete() async {
    try {
      final providerData = FirebaseAuth.instance.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(AppleAuthProvider());
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithProvider(GoogleAuthProvider());
      }
      await FirebaseAuth.instance.currentUser?.delete();
    } catch (e) {
      // Handle exceptions
    }
  }

  Future<void> profileNameChange() async {
    DatabaseReference nameRef = FirebaseDatabase.instance.ref('users/${FirebaseAuth.instance.currentUser!.uid}');
    final _profileNameController = TextEditingController();
    showDialog(
        context: context,
        builder: (context)  {
          return DialogBox(
              controller: _profileNameController,
              onSave: () {
                // Update the "name" field for the profile of the user if its less than 24 chars
                if(_profileNameController.text.length < 24) {
                  nameRef.update({'name': _profileNameController.text});
                  if(mounted) {
                    setState(() {
                      userName = _profileNameController.text;
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              onCancel: () => Navigator.of(context).pop(),
              textOfHint: "Profile name (less than 24 chars):"
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.person,
                  size: 100,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Container(
                width: 250,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8C78E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                        "Name:\n" + userName,
                        style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Button to change name
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    profileNameChange();
                  },
                  child: const Text('Change Name'),
                ),
              ),

              // Button to sign out and return to the sign in page
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, "/signin",  (Route<dynamic> route) => false);
                  },
                  child: const Text('Log Out'),
                ),
              ),

              // Unused delete account code deleted because app store wouldn't approve with this in
              /*SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context)  {
                          return AlertDialog(
                              title: const Text("Are you sure you want to delete your account?"),
                              content: const Text("This will permanently delete your data and account."),
                              actions: <Widget> [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => {
                                    deleteUserAccount(),
                                    dbAccountDelete(),
                                    print("Deleting Account"),
                                    Navigator.pushNamedAndRemoveUntil(context, "/signin",  (Route<dynamic> route) => false)
                                  },
                                  child: const Text('OK'),
                                ),
                              ]
                          );
                        });
                  },
                  child: const Text('Delete Account'),
                ),
              ),
              */
              const Spacer(),
            ]
        )
      ),

      // For the cool orange navigation bar at the bottom
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).colorScheme.inversePrimary,
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            children: <Widget>[
              const Spacer(),
              InkWell(
                  onTap: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.home),
                        Text("Home Page", style: TextStyle(color: Colors.white))
                      ])),
              const Spacer(),
              InkWell(
                  onTap: () {},
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
                  child:
                      const Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_circle),
                    Text("New Activity", style: TextStyle(color: Colors.white))
                  ])),
              const Spacer()
            ],
          ),
        ),
      ),
    );
  }
}

