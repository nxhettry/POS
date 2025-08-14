import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/party_service.dart';
import '../../utils/responsive.dart';
import 'party_form_dialog.dart';
import 'party_detail_card.dart';

class PartiesScreen extends StatefulWidget {
  const PartiesScreen({super.key});

  @override
  State<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends State<PartiesScreen> {
  final PartyService _partyService = PartyService();
  final TextEditingController _searchController = TextEditingController();

  List<Party> _allParties = [];
  List<Party> _filteredParties = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedType = 'all';
  String _selectedStatus = 'all';
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadParties();
    _searchController.addListener(_filterParties);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final parties = await _partyService.getAllParties();
      setState(() {
        _allParties = parties;
        _filteredParties = parties;
        _isLoading = false;
      });
      _filterParties();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterParties() {
    List<Party> filtered = List.from(_allParties);

    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where(
            (party) =>
                party.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                party.phone.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                (party.email?.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ) ??
                    false),
          )
          .toList();
    }

    if (_selectedType != 'all') {
      filtered = filtered
          .where((party) => party.type == _selectedType)
          .toList();
    }

    if (_selectedStatus != 'all') {
      bool isActive = _selectedStatus == 'active';
      filtered = filtered.where((party) => party.isActive == isActive).toList();
    }

    filtered.sort((a, b) {
      int result = 0;
      switch (_sortBy) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'balance':
          result = a.balance.compareTo(b.balance);
          break;
        case 'created':
          result = (a.createdAt ?? DateTime.now()).compareTo(
            b.createdAt ?? DateTime.now(),
          );
          break;
      }
      return _sortAscending ? result : -result;
    });

    setState(() {
      _filteredParties = filtered;
    });
  }

  void _showAddPartyDialog() {
    showDialog(
      context: context,
      builder: (context) => PartyFormDialog(
        onSave: (party) async {
          try {
            await _partyService.createParty(party);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Party added successfully!')),
              );
              _loadParties();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error adding party: $e')));
            }
          }
        },
      ),
    );
  }

  void _showEditPartyDialog(Party party) {
    showDialog(
      context: context,
      builder: (context) => PartyFormDialog(
        party: party,
        onSave: (updatedParty) async {
          try {
            await _partyService.updateParty(party.id!, updatedParty);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Party updated successfully!')),
              );
              _loadParties();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating party: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteParty(Party party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Party'),
        content: Text('Are you sure you want to delete "${party.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _partyService.deleteParty(party.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Party deleted successfully!'),
                    ),
                  );
                  _loadParties();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting party: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorWidget()
                : _filteredParties.isEmpty
                ? _buildEmptyWidget()
                : _buildPartiesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPartyDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Party'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: ResponsiveUtils.getPadding(context, base: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.people, size: 32, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parties Management',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                    ),
                    Text(
                      '${_filteredParties.length} ${_filteredParties.length == 1 ? 'party' : 'parties'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: ResponsiveUtils.getFontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSummaryCard(
                'Customers',
                _allParties.where((p) => p.type == 'customer').length,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                'Suppliers',
                _allParties.where((p) => p.type == 'supplier').length,
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, phone, or email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Types')),
                    DropdownMenuItem(
                      value: 'customer',
                      child: Text('Customer'),
                    ),
                    DropdownMenuItem(
                      value: 'supplier',
                      child: Text('Supplier'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                    _filterParties();
                  },
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _filterParties();
                  },
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'Sort by',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'balance', child: Text('Balance')),
                    DropdownMenuItem(
                      value: 'created',
                      child: Text('Created Date'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    _filterParties();
                  },
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                  });
                  _filterParties();
                },
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                tooltip: _sortAscending ? 'Ascending' : 'Descending',
              ),

              IconButton(
                onPressed: _loadParties,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildPartiesList() {
    return ListView.builder(
      padding: ResponsiveUtils.getPadding(context, base: 16),
      itemCount: _filteredParties.length,
      itemBuilder: (context, index) {
        final party = _filteredParties[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PartyDetailCard(
            party: party,
            onEdit: () => _showEditPartyDialog(party),
            onDelete: () => _deleteParty(party),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error Loading Parties',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadParties, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Parties Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty ||
                    _selectedType != 'all' ||
                    _selectedStatus != 'all'
                ? 'Try adjusting your filters'
                : 'Start by adding your first party',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPartyDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Party'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
