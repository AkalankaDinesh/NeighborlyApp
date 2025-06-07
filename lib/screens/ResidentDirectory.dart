import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResidentDirectoryPage extends StatefulWidget {
  const ResidentDirectoryPage({Key? key}) : super(key: key);

  @override
  _ResidentDirectoryPageState createState() => _ResidentDirectoryPageState();
}

class _ResidentDirectoryPageState extends State<ResidentDirectoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Resident> _residents = [];
  List<Resident> _filteredResidents = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadResidentsFromFirestore();
  }

  Future<void> _loadResidentsFromFirestore() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final QuerySnapshot snapshot = await _firestore
          .collection('residentDirectory')
          .get();

      final List<Resident> loadedResidents = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Resident.fromFirestore(doc.id, data);
      }).toList();

      // Sort by name locally to avoid indexing requirements
      loadedResidents.sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _residents = loadedResidents;
        _filteredResidents = loadedResidents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load residents: $e';
      });
      print('Error loading residents: $e');
    }
  }

  Future<void> _createDummyData() async {
    try {
      final batch = _firestore.batch();
      
      final List<Map<String, dynamic>> dummyResidents = [
        {
          'name': 'John Smith',
          'apartment': '101',
          'phone': '+1 (555) 123-4567',
          'email': 'john.smith@example.com',
          'isVisible': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Sarah Johnson',
          'apartment': '205',
          'phone': '+1 (555) 234-5678',
          'email': 'sarah.johnson@example.com',
          'isVisible': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Michael Brown',
          'apartment': '310',
          'phone': '+1 (555) 345-6789',
          'email': 'michael.brown@example.com',
          'isVisible': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Emily Davis',
          'apartment': '402',
          'phone': '+1 (555) 456-7890',
          'email': 'emily.davis@example.com',
          'isVisible': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'David Wilson',
          'apartment': '507',
          'phone': '+1 (555) 567-8901',
          'email': 'david.wilson@example.com',
          'isVisible': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Jessica Miller',
          'apartment': '612',
          'phone': '+1 (555) 678-9012',
          'email': 'jessica.miller@example.com',
          'isVisible': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Robert Taylor',
          'apartment': '701',
          'phone': '+1 (555) 789-0123',
          'email': 'robert.taylor@example.com',
          'isVisible': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Amanda Martinez',
          'apartment': '805',
          'phone': '+1 (555) 890-1234',
          'email': 'amanda.martinez@example.com',
          'isVisible': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (int i = 0; i < dummyResidents.length; i++) {
        final docRef = _firestore.collection('residentDirectory').doc();
        batch.set(docRef, dummyResidents[i]);
      }

      await batch.commit();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dummy data created successfully!')),
      );
      
      // Reload data after creating dummy data
      _loadResidentsFromFirestore();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create dummy data: $e')),
      );
      print('Error creating dummy data: $e');
    }
  }

  void _filterResidents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredResidents = _residents;
      } else {
        _filteredResidents = _residents
            .where(
              (resident) =>
                  resident.name.toLowerCase().contains(query.toLowerCase()) ||
                  resident.apartment.toLowerCase().contains(query.toLowerCase()) ||
                  resident.phone.toLowerCase().contains(query.toLowerCase()) ||
                  resident.email.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Resident Directory'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResidentsFromFirestore,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'create_dummy') {
                _createDummyData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create_dummy',
                child: Text('Create Dummy Data'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, apartment, phone, or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterResidents,
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadResidentsFromFirestore,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredResidents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No residents found'
                  : 'No residents match your search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_residents.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createDummyData,
                child: const Text('Create Sample Data'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResidentsFromFirestore,
      child: ListView.builder(
        itemCount: _filteredResidents.length,
        itemBuilder: (context, index) {
          final resident = _filteredResidents[index];
          return ResidentListItem(resident: resident);
        },
      ),
    );
  }
}

class ResidentListItem extends StatelessWidget {
  final Resident resident;

  const ResidentListItem({Key? key, required this.resident}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            resident.name.isNotEmpty ? resident.name.substring(0, 1) : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blueGrey,
        ),
        title: Text(
          resident.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apartment ${resident.apartment}'),
            if (resident.phone.isNotEmpty)
              Text(
                resident.phone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            if (!resident.isVisible)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Private',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (resident.phone.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.phone),
                color: Colors.green,
                onPressed: () {
                  // TODO: Implement phone call functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Calling ${resident.phone}')),
                  );
                },
                tooltip: 'Call',
              ),
            if (resident.email.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.mail),
                color: Colors.blue,
                onPressed: () {
                  // TODO: Implement email functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Emailing ${resident.email}')),
                  );
                },
                tooltip: 'Email',
              ),
          ],
        ),
        isThreeLine: resident.phone.isNotEmpty || !resident.isVisible,
      ),
    );
  }
}

class Resident {
  final String id;
  final String name;
  final String apartment;
  final String phone;
  final String email;
  final bool isVisible;
  final DateTime? createdAt;

  Resident({
    required this.id,
    required this.name,
    required this.apartment,
    required this.phone,
    required this.email,
    required this.isVisible,
    this.createdAt,
  });

  factory Resident.fromFirestore(String id, Map<String, dynamic> data) {
    return Resident(
      id: id,
      name: data['name'] ?? '',
      apartment: data['apartment'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      isVisible: data['isVisible'] ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'apartment': apartment,
      'phone': phone,
      'email': email,
      'isVisible': isVisible,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
    };
  }
}