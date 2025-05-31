import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: const Text('Digital Notice Board'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEventPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Announcements'), Tab(text: 'Events')],
          labelColor: Colors.black,
          indicatorColor: Colors.black,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAnnouncementsTab(), _buildEventsTab()],
      ),
    );
  }

  Widget _buildAnnouncementsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('announcements')
              .orderBy('date', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        /*if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildDefaultAnnouncements();
        }*/

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildAnnouncement(
              title: data['title'] ?? '',
              date: _formatTimestamp(data['date']),
              content: data['content'] ?? '',
              hasImage: data['hasImage'] ?? false,
              imageUrl: data['imageUrl'],
            );
          },
        );
      },
    );
  }

  /* Widget _buildDefaultAnnouncements() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAnnouncement(
          title: 'Parking Rules Reminder',
          date: 'May 5, 2023',
          content:
              'Please be reminded that each resident is allowed only one parking space. Visitors must use the designated visitor parking areas.',
        ),
        _buildAnnouncement(
          title: 'Monthly Maintenance Fee',
          date: 'May 3, 2023',
          content:
              'The monthly maintenance fee for May is due on the 10th. Please make sure to pay on time to avoid late payment charges.',
          hasImage: true,
          imageUrl: 'assets/images/maintenance_notice.jpg',
        ),
        _buildAnnouncement(
          title: 'Building Inspection Notice',
          date: 'May 1, 2023',
          content:
              'The annual building inspection will be conducted on May 20th. Please ensure your units are accessible between 9:00 AM and 5:00 PM.',
        ),
        _buildAnnouncement(
          title: 'Holiday Hours',
          date: 'April 28, 2023',
          content:
              'The management office will have reduced hours during the upcoming holiday. We will be open from 9:00 AM to 12:00 PM on May 15th.',
        ),
      ],
    );
  }
  */
  Widget _buildAnnouncement({
    required String title,
    required String date,
    required String content,
    bool hasImage = false,
    String? imageUrl,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.announcement, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted on: $date',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 12),
                Text(content),
              ],
            ),
          ),
          if (hasImage && imageUrl != null)
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.white,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('events')
              .orderBy('date', descending: false)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No events found. Add some events!'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            final event = Event.fromFirestore(doc.id, data);
            return _buildEventCard(event);
          },
        );
      },
    );
  }

  Widget _buildEventCard(Event event) {
    final dateFormatter = DateFormat('EEEE, MMM d, yyyy');
    final formattedDate = dateFormatter.format(event.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4.0),
            ),
            child:
                event.imageUrl.isNotEmpty
                    ? Image.network(
                      event.imageUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                    : Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.event,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(formattedDate),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16),
                    const SizedBox(width: 8),
                    Text(event.location),
                  ],
                ),
                const SizedBox(height: 12),
                Text(event.description),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // View details logic
                        _showEventDetails(event);
                      },
                      child: const Text('View Details'),
                    ),
                    IconButton(
                      icon: Icon(
                        event.isInterested ? Icons.star : Icons.star_border,
                        color: event.isInterested ? Colors.amber : null,
                      ),
                      onPressed: () {
                        _toggleInterest(event);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(event.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${DateFormat('EEEE, MMM d, yyyy').format(event.date)}',
                ),
                const SizedBox(height: 8),
                Text('Location: ${event.location}'),
                const SizedBox(height: 8),
                Text('Description: ${event.description}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _toggleInterest(Event event) async {
    try {
      await _firestore.collection('events').doc(event.id).update({
        'isInterested': !event.isInterested,
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating interest: $e')));
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    if (timestamp is Timestamp) {
      return DateFormat('MMM d, yyyy').format(timestamp.toDate());
    } else if (timestamp is String) {
      return timestamp;
    }

    return '';
  }
}

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String description;
  final String imageUrl;
  final bool isInterested;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.isInterested,
  });

  factory Event.fromFirestore(String id, Map<String, dynamic> data) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isInterested: data['isInterested'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'isInterested': isInterested,
      'createdAt': Timestamp.now(),
    };
  }
}
