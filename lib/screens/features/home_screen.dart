import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import '../../models/mood.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedMood = useState<String?>(null);
    final noteController = useTextEditingController();
    final moods = ['😊', '😭', '😐', '😔', '😡'];
    final isLoading = useState<bool>(false);

    Future<void> submitMood() async {
      FocusManager.instance.primaryFocus?.unfocus();

      if (selectedMood.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a mood first!'),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      isLoading.value = true;

      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final user = authService.user;

      if (user == null) {
        if (context.mounted) {
          isLoading.value = false;
        }
        return;
      }

      final newEntry = Mood(
        userId: user.id,
        mood: selectedMood.value!,
        note: noteController.text.trim().isNotEmpty
            ? noteController.text.trim()
            : null,
        createdAt: DateTime.now(),
      );

      try {
        await supabaseService.addMood(newEntry);

        if (!context.mounted) return;

        selectedMood.value = null;
        noteController.clear();

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Mood saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to save mood: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Choose Today's Mood:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: moods.map((mood) {
                final isSelected = selectedMood.value == mood;
                return GestureDetector(
                  onTap: () => selectedMood.value = mood,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                    ),
                    child: Text(mood, style: const TextStyle(fontSize: 40)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Add a note (optional)',
                labelStyle: const TextStyle(color: Colors.black54),
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            isLoading.value
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue.shade700,
                    ),
                  )
                : ElevatedButton(
                    onPressed: submitMood,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'SAVE MOOD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}