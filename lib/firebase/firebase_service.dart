import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Events Collection Methods
  static CollectionReference get eventsCollection =>
      _firestore.collection('events');

  static CollectionReference get announcementsCollection =>
      _firestore.collection('announcements');

  // Get all events stream
  static Stream<QuerySnapshot> getEventsStream() {
    return eventsCollection.orderBy('date', descending: false).snapshots();
  }

  // Get all announcements stream
  static Stream<QuerySnapshot> getAnnouncementsStream() {
    return announcementsCollection
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Add a new event
  static Future<DocumentReference> addEvent(Map<String, dynamic> eventData) {
    eventData['createdAt'] = Timestamp.now();
    return eventsCollection.add(eventData);
  }

  // Add a new announcement
  static Future<DocumentReference> addAnnouncement(
    Map<String, dynamic> announcementData,
  ) {
    announcementData['createdAt'] = Timestamp.now();
    return announcementsCollection.add(announcementData);
  }

  // Update event interest status
  static Future<void> updateEventInterest(String eventId, bool isInterested) {
    return eventsCollection.doc(eventId).update({
      'isInterested': isInterested,
      'updatedAt': Timestamp.now(),
    });
  }

  // Delete an event
  static Future<void> deleteEvent(String eventId) {
    return eventsCollection.doc(eventId).delete();
  }

  // Delete an announcement
  static Future<void> deleteAnnouncement(String announcementId) {
    return announcementsCollection.doc(announcementId).delete();
  }

  // Storage Methods
  static Reference getStorageRef(String path) {
    return _storage.ref().child(path);
  }

  // Upload file to Firebase Storage
  static Future<String> uploadFile(String filePath, String storagePath) async {
    final Reference ref = _storage.ref().child(storagePath);
    final UploadTask task = ref.putFile(File(filePath));
    final TaskSnapshot snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  // Delete file from Firebase Storage
  static Future<void> deleteFile(String downloadUrl) async {
    final Reference ref = _storage.refFromURL(downloadUrl);
    await ref.delete();
  }

  // Get events by date range
  static Stream<QuerySnapshot> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return eventsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date')
        .snapshots();
  }

  // Search events by title
  static Stream<QuerySnapshot> searchEvents(String searchTerm) {
    return eventsCollection
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThan: searchTerm + 'z')
        .snapshots();
  }

  // Get interested events
  static Stream<QuerySnapshot> getInterestedEvents() {
    return eventsCollection
        .where('isInterested', isEqualTo: true)
        .orderBy('date')
        .snapshots();
  }
}
