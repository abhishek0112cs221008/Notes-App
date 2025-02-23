import 'package:flutter/material.dart';
import 'package:sqllite_flutter/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> notes = [];
  final DBHelper dbRef = DBHelper.getInstance;

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  void getNotes() async {
    notes = await dbRef.getAllNotes();
    setState(() {});
  }

  void showNoteDialog({int? sNo, String title = '', String desc = ''}) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController descController = TextEditingController(text: desc);
    bool isUpdate = sNo != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUpdate ? 'Update Note' : 'Add Note',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                      bool success;
                      if (isUpdate) {
                        success = await dbRef.updateNote(
                          sNo: sNo,
                          title: titleController.text,
                          desc: descController.text,
                        );
                      } else {
                        success = await dbRef.addNote(
                          title: titleController.text,
                          desc: descController.text,
                        );
                      }

                      if (success) {
                        getNotes();
                        Navigator.pop(context);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text(isUpdate ? 'Update Note' : 'Add Note'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: notes.isNotEmpty
          ? ListView.separated(
              itemCount: notes.length,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final note = notes[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Text(
                        (index + 1).toString(), // UI index starts from 1
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      note[DBHelper.COL_NOTE_TITLE],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      note[DBHelper.COL_NOTE_DESC],
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    trailing: Wrap(
                      spacing: 5,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => showNoteDialog(
                            sNo: note[DBHelper.COL_NOTE_SNO],
                            title: note[DBHelper.COL_NOTE_TITLE],
                            desc: note[DBHelper.COL_NOTE_DESC],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            bool success = await dbRef.deleteNote(
                              sNo: note[DBHelper.COL_NOTE_SNO],
                            );
                            if (success) getNotes();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                'No notes found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteDialog(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),

     
     
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }
}
