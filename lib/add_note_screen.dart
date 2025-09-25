import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // custom fonts
import 'package:iconsax/iconsax.dart'; // icons
import 'package:todolist/db_helper.dart'; // database helper
import 'package:todolist/widgets/custom_button_widget.dart'; // reusable custom button

/// AddNoteScreen:
/// - Used for both adding and editing notes.
/// - If `id` is null -> create new note.
/// - If `id` is not null -> edit existing note.
class AddNoteScreen extends StatefulWidget {
  final int? id; // note id (null when creating a new note)
  final String? title; // initial title (for editing)
  final String? description; // initial description (for editing)

  const AddNoteScreen({super.key, this.id, this.title, this.description});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  // --- Step 1: Controllers for text fields.
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // --- Step 2: If editing, pre-fill fields with existing data.
    titleController.text = widget.title ?? '';
    descriptionController.text = widget.description ?? '';
  }

  // --- Step 3: Save or update note in the database.
  Future<void> _saveNote() async {
    // Step 3.1: Validation (title & description required).
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title & description required")),
      );
      return;
    }

    // Step 3.2: Create a note map to insert/update.
    final note = {
      'title': titleController.text,
      'description': descriptionController.text,
      'time': DateTime.now().toIso8601String(), // store current time
    };

    if (widget.id == null) {
      // Step 3.3: If id is null → Insert new note.
      await DatabaseHelper.instance.insert(note);
    } else {
      // Step 3.4: If id exists → Update existing note.
      await DatabaseHelper.instance.update({'id': widget.id, ...note});
    }

    // Step 3.5: Go back to HomeScreen, returning true (to refresh notes).
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Step 4: AppBar with title depending on mode (Add/Edit).
      appBar: AppBar(
        title: Text(
          widget.id == null ? 'Add Note' : 'Edit Note',
          style: GoogleFonts.dmSerifDisplay(),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context), // go back
          icon: const Icon(Iconsax.arrow_circle_left),
        ),
        centerTitle: true,
        forceMaterialTransparency: true, // make AppBar background transparent
      ),

      // --- Step 5: Body with form fields.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 5.1: Title input field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: GoogleFonts.dmSerifDisplay(color: Colors.grey),
              ),
              style: GoogleFonts.dmSerifDisplay(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(color: Colors.cyanAccent),

            // Step 5.2: Description input field (multiline)
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: GoogleFonts.dmSerifDisplay(color: Colors.grey),
              ),
              style: GoogleFonts.dmSerifDisplay(fontSize: 16),
            ),
          ],
        ),
      ),

      // --- Step 6: Bottom button for saving/updating note.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomButtonWidget(
          title: widget.id == null ? 'Add Note' : 'Update Note',
          onTap: _saveNote,
        ),
      ),
    );
  }
}
