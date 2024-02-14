import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PreListScreen extends StatefulWidget {
  @override
  _PreListScreenState createState() => _PreListScreenState();
}

class _PreListScreenState extends State<PreListScreen> {
  final TextEditingController _noteController = TextEditingController();
  late String _userEmail;
  late CollectionReference _preListCollection;
  late Map<String, bool> _completedPreListItems;

  @override
  void initState() {
    super.initState();
    _userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    _preListCollection = FirebaseFirestore.instance.collection('prelists');
    _completedPreListItems = {};
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.purple, Colors.blue]
            )
        ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        //backgroundColor: Colors.transparent,
        title: Text('PreLists'),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _preListCollection
            .where('email', isEqualTo: _userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(

              child: Text('Error: ${snapshot.error}',

              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> preListDocs = snapshot.data!.docs;
          if (preListDocs.isEmpty) {
            return Center(
              child: Text('No notes found.'),
            );
          }

          return ListView.builder(
            itemCount: preListDocs.length,
            itemBuilder: (context, index) {
              QueryDocumentSnapshot preListDoc = preListDocs[index];
              String preListId = preListDoc.id;
              String note = preListDoc['note'];
              bool isCompleted = _completedPreListItems.containsKey(preListId)
                  ? _completedPreListItems[preListId]!
                  : false;

              return ListTile(
                title: Text(
                  note,
                  style: TextStyle(
                    decoration:
                    isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      focusColor: Colors.black,
                      value: isCompleted,
                      onChanged: (value) => _toggleCompletion(preListId, value!),
                    ),
                    IconButton(
                      color: Colors.red,
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteNoteDialog(preListId, note),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: Icon(Icons.add),
      ),
    ),
    );
  }

  Future<void> _showAddNoteDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Note'),
          content: TextField(
            controller: _noteController,
            decoration: InputDecoration(hintText: 'Enter a note'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String note = _noteController.text.trim();
                if (note.isNotEmpty) {
                  await _addNoteToPreList(note);
                  _noteController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNoteToPreList(String note) async {
    try {
      await _preListCollection.add({
        'email': _userEmail,
        'note': note,
      });
    } catch (e) {
      print('Error adding note: $e');
    }
  }

  Future<void> _deleteNoteDialog(String preListId, String note) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Note'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteNoteByEmail(preListId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNoteByEmail(String preListId) async {
    try {
      await _preListCollection.doc(preListId).delete();
    } catch (e) {
      print('Error deleting note: $e');
    }
  }

  void _toggleCompletion(String preListId, bool value) {
    setState(() {
      _completedPreListItems[preListId] = value;
    });
  }
}
