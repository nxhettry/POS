import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';

class PartyDetailCard extends StatelessWidget {
  final Party party;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PartyDetailCard({
    super.key,
    required this.party,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showPartyDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                party.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            _buildStatusChip(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _capitalizeFirst(party.type),
                          style: TextStyle(
                            color: _getTypeColor(),
                            fontSize: ResponsiveUtils.getFontSize(context, 12),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Party',
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Party',
                        iconSize: 20,
                        visualDensity: VisualDensity.compact,
                        color: Colors.red[600],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: party.phone,
                    ),
                  ),
                  if (party.email != null && party.email!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: party.email!,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),

              _buildInfoItem(
                icon: Icons.location_on,
                label: 'Address',
                value: party.address,
              ),

              if (party.balance != 0) ...[
                const SizedBox(height: 8),

                _buildBalanceItem(),
              ],

              if (party.createdAt != null) ...[
                const SizedBox(height: 8),

                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Created',
                  value: _formatDate(party.createdAt!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: party.isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: party.isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Text(
        party.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: party.isActive ? Colors.green[700] : Colors.red[700],
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceItem() {
    final isPositive = party.balance >= 0;
    return Row(
      children: [
        Icon(Icons.account_balance_wallet, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          'Balance: ',
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
        Text(
          '\$${party.balance.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: isPositive ? Colors.green[700] : Colors.red[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (!isPositive)
          Text(
            ' (Due)',
            style: TextStyle(color: Colors.red[700], fontSize: 12),
          ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (party.type) {
      case 'customer':
        return Colors.blue;
      case 'supplier':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (party.type) {
      case 'customer':
        return Icons.person;
      case 'supplier':
        return Icons.business;
      default:
        return Icons.people;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPartyDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          party.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _capitalizeFirst(party.type),
                              style: TextStyle(
                                color: _getTypeColor(),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildStatusChip(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildDetailRow('Phone:', party.phone),
              if (party.email != null && party.email!.isNotEmpty)
                _buildDetailRow('Email:', party.email!),
              _buildDetailRow('Address:', party.address),
              if (party.balance != 0)
                _buildDetailRow(
                  'Balance:',
                  '\$${party.balance.toStringAsFixed(2)} ${party.balance < 0 ? '(Due)' : ''}',
                ),
              if (party.createdAt != null)
                _buildDetailRow('Created:', _formatDate(party.createdAt!)),
              if (party.updatedAt != null)
                _buildDetailRow('Updated:', _formatDate(party.updatedAt!)),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onEdit();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
