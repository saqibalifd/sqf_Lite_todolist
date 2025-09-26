import 'dart:math'; // used to generate random colors
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // custom fonts
import 'package:iconsax/iconsax.dart'; // icon pack
import 'package:todolist/add_note_screen.dart'; // screen for adding/editing notes
import 'package:todolist/db_helper.dart'; // our SQLite database helper

/// HomeScreen: Displays all notes from the database.
/// Supports viewing, adding, editing, and deleting notes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Step 1: Future holding our notes list from the database.
  Future<List<Map<String, dynamic>>>? notes;

  @override
  void initState() {
    super.initState();
    // Step 2: Load all notes when screen initializes.
    refreshNotes();
  }

  // Step 3: Helper method to refresh notes from DB.
  // This reassigns `notes` with a fresh query and rebuilds UI.
  void refreshNotes() {
    setState(() {
      notes = DatabaseHelper.instance.queryAll();
    });
  }

  // Step 4: Generate a soft random color (light shades between 180–230).
  // Used for card backgrounds.
  Color getRandomDimColor() {
    final Random random = Random();
    return Color.fromRGBO(
      180 + random.nextInt(51),
      180 + random.nextInt(51),
      180 + random.nextInt(51),
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Step 5: AppBar with custom font title.
      appBar: AppBar(
        title: Text("Todo List", style: GoogleFonts.dmSerifDisplay()),
        centerTitle: true,
      ),

      // --- Step 6: Body displays notes using a FutureBuilder.
      // Handles 3 states: loading, empty, or data list.
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Loading state
          if (!snapshot.hasData)
            return const Center(child: Text('Todo List is Empty'));

          // Empty state
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text("No notes yet"));
          }

          // Data state
          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final note = data[index];

              // --- Step 7: Dismissible widget allows swipe-to-delete.
              return Dismissible(
                key: ValueKey(note['id']), // unique key for each note
                direction: DismissDirection.endToStart, // swipe right-to-left
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                // Step 7.1: When swiped, delete the note and refresh.
                onDismissed: (_) async {
                  await DatabaseHelper.instance.delete(note['id']);
                  refreshNotes();
                },

                // --- Step 8: Card displaying each note.
                child: Card(
                  color: getRandomDimColor(),
                  child: ListTile(
                    // Step 8.1: Tapping a note opens AddNoteScreen in edit mode.
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddNoteScreen(
                            id: note['id'],
                            title: note['title'],
                            description: note['description'],
                          ),
                        ),
                      );
                      // If a note was updated, refresh the list.
                      if (updated == true) refreshNotes();
                    },

                    // Step 8.2: Show note title in bold.
                    title: Text(
                      note['title'],
                      style: GoogleFonts.dmSerifDisplay(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Step 8.3: Show note description in smaller font.
                    subtitle: Text(
                      note['description'],
                      style: GoogleFonts.dmSerifDisplay(fontSize: 13),
                    ),

                    // Step 8.4: Show note date (splitting off time).
                    trailing: Text(
                      note['time'].toString().split("T").first,
                      style: GoogleFonts.dmSerifDisplay(fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),

      // --- Step 9: FloatingActionButton for adding new notes.
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddNoteScreen in add mode.
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddNoteScreen()),
          );
          // If a note was added, refresh the list.
          if (added == true) refreshNotes();
        },
        backgroundColor: Colors.cyan,
        shape: const CircleBorder(),
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }
}
