import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/contractor_provider.dart';
import '../../model/user.dart';
import '../../utils/constants.dart';
import 'contractor_detail_screen.dart';

class ContractorListScreen extends StatefulWidget {
  const ContractorListScreen({super.key});

  @override
  State<ContractorListScreen> createState() => _ContractorListScreenState();
}

class _ContractorListScreenState extends State<ContractorListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ContractorProvider>(context, listen: false);
      provider.fetchContractors().catchError((error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error loading contractors: ${provider.lastError ?? error.toString()}',
              ),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => provider.fetchContractors(),
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contractors'), elevation: 0),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            child: Column(
              children: [
                // Search Bar
                Consumer<ContractorProvider>(
                  builder: (context, provider, _) {
                    return TextField(
                      decoration: InputDecoration(
                        hintText: 'Search contractors...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: provider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => provider.setSearchQuery(''),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: provider.setSearchQuery,
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Filter Row
                Consumer<ContractorProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        // Sort Dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: provider.sortBy,
                            decoration: const InputDecoration(
                              labelText: 'Sort by',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: SortOptions.rating,
                                child: Text('Rating'),
                              ),
                              DropdownMenuItem(
                                value: SortOptions.name,
                                child: Text('Name'),
                              ),
                              DropdownMenuItem(
                                value: SortOptions.totalReviews,
                                child: Text('Most Reviewed'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) provider.setSortBy(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Rating Filter
                        Expanded(
                          child: DropdownButtonFormField<double?>(
                            value: provider.minRating,
                            decoration: const InputDecoration(
                              labelText: 'Min Rating',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Any'),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.maxRating - 1,
                                child: Text(
                                  '${AppConstants.maxRating - 1}+ Stars',
                                ),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.maxRating - 2,
                                child: Text(
                                  '${AppConstants.maxRating - 2}+ Stars',
                                ),
                              ),
                              DropdownMenuItem(
                                value: AppConstants.maxRating - 3,
                                child: Text(
                                  '${AppConstants.maxRating - 3}+ Stars',
                                ),
                              ),
                            ],
                            onChanged: provider.setMinRating,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Contractors List
          Expanded(
            child: Consumer<ContractorProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.contractors.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error state if there's an error and no cached data
                if (provider.lastError != null &&
                    provider.contractors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error Loading Contractors',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            provider.lastError!,
                            style: TextStyle(color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => provider.fetchContractors(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.contractors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.engineering_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No contractors found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.clearFilters(),
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchContractors(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.contractors.length,
                    itemBuilder: (context, index) {
                      final contractor = provider.contractors[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildContractorCard(context, contractor),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractorCard(BuildContext context, UserModel contractor) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ContractorDetailScreen(contractorId: contractor.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.engineering,
                      size: 30,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contractor.legalName ??
                              AppConstants.unknownContractorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contractor.email,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (contractor.averageRating != null) ...[
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index <
                                            (contractor.averageRating ?? 0)
                                                .round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${contractor.averageRating?.toStringAsFixed(1) ?? '0.0'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ] else ...[
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    Icons.star_border,
                                    color: Colors.grey.shade400,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'No ratings yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (contractor.totalReviews != null)
                              Text(
                                '(${contractor.totalReviews} reviews)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
