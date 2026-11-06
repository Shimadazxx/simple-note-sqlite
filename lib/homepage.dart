
import 'package:flutter/material.dart';
import 'database_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Menampung data catatan
  List<Map<String, Object?>> myData = [];

  bool _isLoading = true;

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  // Fungsi refresh data
  Future<void> _refreshData() async {
    final data = await DatabaseHelper.getItems();

    if (!mounted) return;

    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Membersihkan controller
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Form tambah dan edit data
  void showMyForm(int? id) async {
    if (id != null) {
      final existingData =
          myData.firstWhere((element) => element['id'] == id);

      _titleController.text =
          existingData['title']?.toString() ?? '';

      _descriptionController.text =
          existingData['description']?.toString() ?? '';
    } else {
      _titleController.text = '';
      _descriptionController.text = '';
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await addItem();
                } else {
                  await updateItem(id);
                }

                _titleController.clear();
                _descriptionController.clear();

                if (!mounted) return;

                Navigator.of(context).pop();
              },
              child: Text(
                id == null ? 'Create New' : 'Update',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create - Tambah catatan
  Future<void> addItem() async {
    await DatabaseHelper.createItem(
      _titleController.text,
      _descriptionController.text,
    );

    await _refreshData();
  }

  // Update - Edit catatan
  Future<void> updateItem(int id) async {
    await DatabaseHelper.updateItem(
      id,
      _titleController.text,
      _descriptionController.text,
    );

    await _refreshData();
  }

  // Delete - Hapus catatan
  Future<void> deleteItem(int id) async {
    await DatabaseHelper.deleteItem(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully deleted!'),
        backgroundColor: Colors.green,
      ),
    );

    await _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Note with SQLite'),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : myData.isEmpty
              ? const Center(
                  child: Text("Tidak ada data!"),
                )
              : ListView.builder(
                  itemCount: myData.length,
                  itemBuilder: (context, index) => Card(
                    color: index % 2 == 0
                        ? Colors.green
                        : Colors.green[200],
                    margin: const EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(
                        myData[index]['title']?.toString() ?? '',
                      ),
                      subtitle: Text(
                        myData[index]['description']?.toString() ?? '',
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => showMyForm(
                                myData[index]['id'] as int,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteItem(
                                myData[index]['id'] as int,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }
}
