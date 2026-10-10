import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 55,
              child: Icon(
                Icons.person,
                size: 60,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'PetCare User',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),

          const SizedBox(height: 24),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Name'),
                  subtitle: Text('Daniil'),
                ),
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Email'),
                  subtitle: Text('user@petcare.md'),
                ),
                ListTile(
                  leading: Icon(Icons.pets),
                  title: Text('Pets'),
                  subtitle: Text('6 registered pets'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}