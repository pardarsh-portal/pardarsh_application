import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/project_provider.dart';
import '../../model/user.dart';
import '../../widgets/custom_button.dart';

class ContractorAssignmentScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ContractorAssignmentScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ContractorAssignmentScreen> createState() =>
      _ContractorAssignmentScreenState();
}

class _ContractorAssignmentScreenState
    extends State<ContractorAssignmentScreen> {
  UserModel? selectedContractor;
  bool isLoading = false;
  bool isAssigning = false;

  @override
  void initState() {
    super.initState();
    _loadContractors();
  }

  Future<void> _loadContractors() async {
    setState(() => isLoading = true);
    try {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      await provider.fetchContractors();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading contractors: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _assignContractor() async {
    if (selectedContractor == null) return;

    setState(() => isAssigning = true);
    try {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      await provider.assignContractor(widget.projectId, selectedContractor!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully assigned ${selectedContractor!.legalName} to project',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      ); // Return true to indicate successful assignment
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error assigning contractor: $e')));
    } finally {
      setState(() => isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Contractor')),
      body: Column(
        children: [
          // Project info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.projectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Contractors list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.contractors.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No contractors available',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.contractors.length,
                    itemBuilder: (context, index) {
                      final contractor = provider.contractors[index];
                      final isSelected =
                          selectedContractor?.id == contractor.id;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            child: Icon(
                              Icons.person,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                          title: Text(
                            contractor.legalName ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contractor.email),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  contractor.role.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              selectedContractor = isSelected
                                  ? null
                                  : contractor;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: isAssigning ? 'Assigning...' : 'Assign Contractor',
                    onPressed: selectedContractor == null || isAssigning
                        ? null
                        : _assignContractor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
