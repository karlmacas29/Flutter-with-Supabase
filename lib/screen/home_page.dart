import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  void initState() {
    super.initState();
    _initNoteStream();
  }

  void _initNoteStream() {
    final supabase = Supabase.instance.client;
    noteStream = supabase.from('notes_table').stream(primaryKey: ['id']);
  }

  Future<void> _refreshNoteStream() async {
    setState(() {
      _initNoteStream();
    });
  }

  // final userId = Supabase.instance.client.auth.currentUser?.id;
  final supabase = Supabase.instance.client;
  late Stream noteStream;

  //signout
  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Logout Success'),
      backgroundColor: Colors.green,
    ));
  }

  //INSERT INTO notes_table (note_body) VALUES (note)
  Future<void> _createNote(String note) async {
    //call table name then insert
    await supabase.from('notes_table').insert({
      'note_body': note,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        'Note Created',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Color.fromARGB(221, 41, 41, 41),
    ));
  }

  //UPDATE notes_table SET note_body = noteUpdate WHERE id = noteId
  Future<void> _updateNote(String noteUpdate, String noteId) async {
    await supabase.from('notes_table').update({
      'note_body': noteUpdate,
    }).eq('id', noteId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        'Note Updated',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Color.fromARGB(221, 41, 41, 41),
    ));
  }

  //DELETE FROM notes_table WHERE id = noteId
  Future<void> _deleteNote(String noteId) async {
    await supabase.from('notes_table').delete().eq('id', noteId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
        'Note Deleted',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      backgroundColor: Color.fromARGB(221, 41, 41, 41),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Simple Note'),
        actions: [
          IconButton(
            onPressed: () => _signOut(),
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNoteStream,
        child: StreamBuilder(
            stream: noteStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final notes = snapshot.data!;

              return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final noteId = note['id'].toString();

                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        color: Colors.red,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          // Action for swipe right (delete)
                          _deleteNote(noteId);
                          // Call delete function or navigate
                        } else if (direction == DismissDirection.endToStart) {
                          // Action for swipe left (edit)
                          _deleteNote(noteId);
                          // Call edit function or navigate
                        }
                      },
                      child: ListTile(
                        title: Text(
                          note['note_body'],
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                      title: const Text('Add a Note'),
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(10),
                                          child: TextFormField(
                                            initialValue: note['note_body'],
                                            onFieldSubmitted: (value) async {
                                              await _updateNote(value, noteId);
                                              if (mounted)
                                                Navigator.pop(context);
                                            },
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Type Something...',
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.edit)),
                      ),
                    );
                  });
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Text('Add a Note'),
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: TextFormField(
                        onFieldSubmitted: (value) {
                          _createNote(value);
                          if (mounted) Navigator.pop(context);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Type Something...',
                        ),
                      ),
                    )
                  ],
                );
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
