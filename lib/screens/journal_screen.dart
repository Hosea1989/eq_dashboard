import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class JournalScreen extends StatefulWidget {
  final List<JournalEntry> journalEntries;

  const JournalScreen({super.key, required this.journalEntries});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTagFilter;
  Mood? _selectedMoodFilter;
  String? _expandedEntryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<JournalEntry> get _filteredEntries {
    var entries = widget.journalEntries.where((entry) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!entry.content.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      // Tag filter
      if (_selectedTagFilter != null) {
        if (!entry.tags.contains(_selectedTagFilter)) {
          return false;
        }
      }
      
      // Mood filter
      if (_selectedMoodFilter != null) {
        if (entry.mood != _selectedMoodFilter) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Set<String> get _allTags {
    final tags = <String>{};
    for (final entry in widget.journalEntries) {
      tags.addAll(entry.tags);
    }
    return tags;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedTagFilter = null;
      _selectedMoodFilter = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF673AB7); // Deep Purple
    final backgroundColor = primaryColor.withOpacity(0.05);
    
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Stack(
        children: [
          Column(
            children: [
              // Search and Filter Section
              Container(
                color: CupertinoColors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Search your journal...',
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Clear Filters Button
                    if (_searchQuery.isNotEmpty || _selectedTagFilter != null || _selectedMoodFilter != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          onPressed: _clearFilters,
                          child: const Text('Clear Filters'),
                        ),
                      ),
                    
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Tag Filters
                          ..._allTags.map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              color: _selectedTagFilter == tag ? primaryColor.withOpacity(0.3) : CupertinoColors.systemGrey6,
                              onPressed: () {
                                setState(() {
                                  _selectedTagFilter = _selectedTagFilter == tag ? null : tag;
                                });
                              },
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  color: _selectedTagFilter == tag ? CupertinoColors.white : CupertinoColors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )),
                          
                          // Mood Filters
                          ...Mood.values.map((mood) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              color: _selectedMoodFilter == mood ? primaryColor.withOpacity(0.3) : CupertinoColors.systemGrey6,
                              onPressed: () {
                                setState(() {
                                  _selectedMoodFilter = _selectedMoodFilter == mood ? null : mood;
                                });
                              },
                              child: Text(
                                _getMoodEmoji(mood),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Journal Entries List
              Expanded(
                child: _filteredEntries.isEmpty
                    ? _buildEmptyState(primaryColor)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _filteredEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _filteredEntries[index];
                          return JournalEntryCard(
                            entry: entry,
                            isExpanded: _expandedEntryId == entry.id,
                            onTap: () {
                              setState(() {
                                _expandedEntryId = _expandedEntryId == entry.id ? null : entry.id;
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 16,
            child: CupertinoButton.filled(
              onPressed: () => _showNewEntryDialog(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.add, color: CupertinoColors.white),
                  SizedBox(width: 8),
                  Text('New Entry', style: TextStyle(color: CupertinoColors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(Mood mood) {
    switch (mood) {
      case Mood.sad:
        return '😞';
      case Mood.neutral:
        return '😐';
      case Mood.happy:
        return '🙂';
      case Mood.excited:
        return '😄';
    }
  }

  Widget _buildEmptyState(Color primaryColor) {
    if (widget.journalEntries.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.book,
                size: 64,
                color: primaryColor.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              const Text(
                'Start Your Journal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capture your thoughts, feelings, and reflections',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No entries found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showNewEntryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewJournalEntryForm(
        onSave: (entry) {
          setState(() {
            widget.journalEntries.insert(0, entry);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journal entry saved! ✨'),
              backgroundColor: Color(0xFF673AB7),
            ),
          );
        },
        existingTags: _allTags.toList(),
      ),
    );
  }
}

// Journal Entry Card Widget
class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;
  final bool isExpanded;
  final VoidCallback onTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF673AB7);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Date
                  Expanded(
                    child: Text(
                      entry.formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  // Mood
                  if (entry.mood != null) ...[
                    Text(
                      entry.moodEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Expand/Collapse Icon
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Content
              Text(
                isExpanded ? entry.content : entry.preview,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              
              // Tags
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// New Journal Entry Form
class NewJournalEntryForm extends StatefulWidget {
  final Function(JournalEntry) onSave;
  final List<String> existingTags;

  const NewJournalEntryForm({
    super.key,
    required this.onSave,
    required this.existingTags,
  });

  @override
  State<NewJournalEntryForm> createState() => _NewJournalEntryFormState();
}

class _NewJournalEntryFormState extends State<NewJournalEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  
  Mood? _selectedMood;
  final List<String> _selectedTags = [];
  
  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !_selectedTags.contains(trimmedTag)) {
      setState(() {
        _selectedTags.add(trimmedTag);
      });
    }
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final entry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: _contentController.text.trim(),
        date: DateTime.now(),
        tags: List.from(_selectedTags),
        mood: _selectedMood,
      );
      
      widget.onSave(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF673AB7);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'New Journal Entry',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatCurrentDateTime(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood Selector
                    const Text(
                      'How are you feeling?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: Mood.values.map((mood) {
                        final isSelected = _selectedMood == mood;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = isSelected ? null : mood;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? primaryColor.withOpacity(0.1) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? primaryColor 
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _getMoodEmoji(mood),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Content Input
                    const Text(
                      'What\'s on your mind?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Write your thoughts here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please write something';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tags Section
                    const Text(
                      'Tags (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tag Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: InputDecoration(
                              hintText: 'Add a tag...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            onSubmitted: _addTag,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _addTag(_tagController.text),
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Existing Tags Suggestions
                    if (widget.existingTags.isNotEmpty) ...[
                      const Text(
                        'Suggested tags:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.existingTags
                            .where((tag) => !_selectedTags.contains(tag))
                            .take(10)
                            .map((tag) => GestureDetector(
                              onTap: () => _addTag(tag),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Selected Tags
                    if (_selectedTags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _selectedTags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _removeTag(tag),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
            
            // Save Button
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(Mood mood) {
    switch (mood) {
      case Mood.sad:
        return '😞';
      case Mood.neutral:
        return '😐';
      case Mood.happy:
        return '🙂';
      case Mood.excited:
        return '😄';
    }
  }

  String _formatCurrentDateTime() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    
    return '$weekday, $month ${now.day} • $hour:$minute';
  }
} 