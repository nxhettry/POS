import "package:flutter/material.dart";
import "package:pos/services/database_service.dart";
import "package:pos/models/models.dart" as models;

class Tables extends StatefulWidget {
  const Tables({super.key});

  @override
  State<Tables> createState() => _TablesState();
}

class _TablesState extends State<Tables> {
  List<models.Table> currentTables = [];
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    try {
      final tables = await _dbService.getTables();
      setState(() {
        currentTables = tables;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tables: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void onAddNewTable(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Table'),
          content: const Text('Are you sure you want to add a new table?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final newId = currentTables.isEmpty
            ? 1
            : currentTables.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
        
        final tableName = "Table $newId";
        final tableId = await _dbService.addTable(tableName);
        
        setState(() {
          currentTables.add(models.Table(id: tableId, name: tableName));
        });
      } catch (e) {
        print('Error adding table: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding table: $e')),
          );
        }
      }
    }
  }

  void _handleTableSelection(models.Table table) {
    print("Table ${table.name} selected");
  }

  void _deleteTable(models.Table table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Table'),
          content: Text('Are you sure you want to delete ${table.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        if (table.id != null) {
          await _dbService.deleteTable(table.id!);
          setState(() {
            currentTables.remove(table);
          });
        }
      } catch (e) {
        print('Error deleting table: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting table: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[50]),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => onAddNewTable(context),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Table',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.blue[800],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            color: Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 24),
          ),

          // Tables Grid Section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentTables.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_restaurant_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tables available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a new table to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                    itemCount: currentTables.length,
                    itemBuilder: (context, index) {
                      final table = currentTables[index];
                      return GestureDetector(
                        onTap: () => _handleTableSelection(table),
                        onLongPress: () => _deleteTable(table),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.table_restaurant,
                                      color: Colors.blue[600],
                                      size: 28,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      table.name,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _deleteTable(table),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.red[600],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
