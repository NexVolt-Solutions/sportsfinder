import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sport_finding/feature/viewModel/user_view_model.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Users")),
      body: Builder(
        builder: (_) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error.isNotEmpty) {
            return Center(child: Text(vm.error));
          }

          return ListView.builder(
            itemCount: vm.users.length,
            itemBuilder: (context, index) {
              final user = vm.users[index];

              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.fetchUsers,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
