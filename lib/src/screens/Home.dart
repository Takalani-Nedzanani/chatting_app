import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _setOnlineStatus(true);

    // Set the user as offline when the app is closed
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _setOnlineStatus(false);
      }
    });
  }

  @override
  void dispose() {
    _setOnlineStatus(false);
    super.dispose();
  }

  void _setOnlineStatus(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'isOnline': isOnline});
    }
  }

  void _logout(BuildContext context) async {
    _setOnlineStatus(false);
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _goToChatScreen(BuildContext context) {
    Navigator.pushNamed(context, '/chat', arguments: 'general');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value.trim().toLowerCase();
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search by email...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = "";
              });
            },
            icon: const Icon(Icons.clear),
            tooltip: 'Clear Search',
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: StreamBuilder(
        stream: (_searchQuery.isEmpty)
            ? FirebaseFirestore.instance.collection('users').snapshots()
            : FirebaseFirestore.instance
                .collection('users')
                .where('email', isGreaterThanOrEqualTo: _searchQuery)
                .where('email', isLessThan: '$_searchQuery\uf8ff')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            itemBuilder: (context, index) {
              final user = users[index];
              final currentUser = FirebaseAuth.instance.currentUser!;
              if (user['email'] == currentUser.email) {
                // Skip the current user from the list
                return const SizedBox.shrink();
              }

              final isOnline = user['isOnline'] ?? false;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  leading: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          user['email'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (isOnline)
                        const CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.green,
                        ),
                    ],
                  ),
                  title: Text(
                    user['email'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(isOnline ? 'Online' : 'Offline'),
                  trailing: const Icon(Icons.chat, color: Colors.blueAccent),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: user.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        // ignore: sort_child_properties_last
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () => _goToChatScreen(context),
        tooltip: 'Go to General Chat',
      ),
    );
  }
}
