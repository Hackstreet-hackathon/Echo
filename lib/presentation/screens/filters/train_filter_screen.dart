import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/user_profile_model.dart';
import '../../../data/models/train_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/providers.dart';
import '../../../services/data/train_service.dart';

class TrainFilterScreen extends ConsumerStatefulWidget {
  const TrainFilterScreen({super.key});

  @override
  ConsumerState<TrainFilterScreen> createState() => _TrainFilterScreenState();
}

class _TrainFilterScreenState extends ConsumerState<TrainFilterScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _controller.text = profile?.preferredTrainNo ?? '';
    // Initialize train service
    ref.read(trainServiceProvider).initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter by Train'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () async {
                final selectedTrain = await showSearch(
                  context: context,
                  delegate: TrainSearchDelegate(ref.read(trainServiceProvider)),
                );
                if (selectedTrain != null) {
                  _controller.text = selectedTrain.number;
                  // Auto-save when selected
                  ref.read(userProfileProvider.notifier).updateProfile(
                        (ref.read(userProfileProvider) ?? const UserProfileModel())
                            .copyWith(preferredTrainNo: selectedTrain.number),
                      );
                }
              },
              child: IgnorePointer(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Train Number / Name',
                    hintText: 'Tap to search trains...',
                    prefixIcon: Icon(Icons.train),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_controller.text.isNotEmpty) ...[
              const Text(
                'Selected Train:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.train, color: Colors.blue),
                  title: Text(_controller.text),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      ref.read(userProfileProvider.notifier).updateProfile(
                            (ref.read(userProfileProvider) ?? const UserProfileModel())
                                .copyWith(preferredTrainNo: null),
                          );
                    },
                  ),
                ),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainSearchDelegate extends SearchDelegate<TrainModel?> {
  final TrainService _trainService;

  TrainSearchDelegate(this._trainService);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _trainService.searchTrains(query);
    return _buildList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _trainService.searchTrains(query);
    return _buildList(results);
  }

  Widget _buildList(List<TrainModel> trains) {
    if (trains.isEmpty) {
      if (query.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.train, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Search by train name or number'),
              SizedBox(height: 8),
              Text('Try "Rajdhani" or "12951"', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }
      return const Center(child: Text('No trains found'));
    }

    return ListView.builder(
      itemCount: trains.length,
      itemBuilder: (context, index) {
        final train = trains[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.train)),
          title: Text('${train.number} - ${train.name}'),
          subtitle: Text('${train.from} ➔ ${train.to}'),
          onTap: () {
            close(context, train);
          },
        );
      },
    );
  }
}
