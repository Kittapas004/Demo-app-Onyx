import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== ARTWORKS ====================
  
  // Create artwork
  Future<String> createArtwork(Map<String, dynamic> artworkData) async {
    try {
      artworkData['createdAt'] = FieldValue.serverTimestamp();
      artworkData['updatedAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore.collection('artworks').add(artworkData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create artwork: $e');
    }
  }

  // Get artworks
  Stream<QuerySnapshot> getArtworks({String? category, int limit = 20}) {
    Query query = _firestore.collection('artworks').orderBy('createdAt', descending: true);
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.limit(limit).snapshots();
  }

  // Get artwork by ID
  Future<DocumentSnapshot> getArtwork(String artworkId) async {
    return await _firestore.collection('artworks').doc(artworkId).get();
  }

  // Update artwork
  Future<void> updateArtwork(String artworkId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('artworks').doc(artworkId).update(data);
    } catch (e) {
      throw Exception('Failed to update artwork: $e');
    }
  }

  // Delete artwork
  Future<void> deleteArtwork(String artworkId) async {
    try {
      await _firestore.collection('artworks').doc(artworkId).delete();
    } catch (e) {
      throw Exception('Failed to delete artwork: $e');
    }
  }

  // ==================== AUCTIONS ====================
  
  // Create auction
  Future<String> createAuction(Map<String, dynamic> auctionData) async {
    try {
      auctionData['createdAt'] = FieldValue.serverTimestamp();
      auctionData['updatedAt'] = FieldValue.serverTimestamp();
      auctionData['status'] = 'active';
      
      DocumentReference docRef = await _firestore.collection('auctions').add(auctionData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create auction: $e');
    }
  }

  // Get active auctions
  Stream<QuerySnapshot> getActiveAuctions({int limit = 20}) {
    return _firestore
        .collection('auctions')
        .where('status', isEqualTo: 'active')
        .orderBy('endTime', descending: false)
        .limit(limit)
        .snapshots();
  }

  // Get auction by ID
  Future<DocumentSnapshot> getAuction(String auctionId) async {
    return await _firestore.collection('auctions').doc(auctionId).get();
  }

  // Update auction
  Future<void> updateAuction(String auctionId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('auctions').doc(auctionId).update(data);
    } catch (e) {
      throw Exception('Failed to update auction: $e');
    }
  }

  // ==================== BIDS ====================
  
  // Place bid
  Future<String> placeBid(Map<String, dynamic> bidData) async {
    try {
      bidData['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore.collection('bids').add(bidData);
      
      // Update artwork with current highest bid
      await _firestore.collection('artworks').doc(bidData['artworkId']).update({
        'currentBid': bidData['bidAmount'],
        'highestBidderId': bidData['bidderId'],
        'bidCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to place bid: $e');
    }
  }

  // Get bids for auction
  Stream<QuerySnapshot> getBidsForAuction(String auctionId) {
    return _firestore
        .collection('bids')
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('bidAmount', descending: true)
        .snapshots();
  }

  // Get user's participated auctions (where user has placed bids)
  Stream<QuerySnapshot> getUserParticipatedAuctions(String userId) {
    return _firestore
        .collection('bids')
        .where('bidderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ==================== NOTIFICATIONS ====================
  
  // Create notification
  Future<void> createNotification(Map<String, dynamic> notificationData) async {
    try {
      notificationData['createdAt'] = FieldValue.serverTimestamp();
      notificationData['isRead'] = false;
      
      await _firestore.collection('notifications').add(notificationData);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Get user notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // ==================== STORAGE ====================
  
  // Upload image from File
  Future<String> uploadImage(File file, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload image from Uint8List (for web)
  Future<String> uploadImageBytes(Uint8List bytes, String path) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // ==================== TRANSACTIONS ====================
  
  // Create transaction
  Future<String> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      transactionData['createdAt'] = FieldValue.serverTimestamp();
      transactionData['status'] = 'pending';
      
      DocumentReference docRef = await _firestore.collection('transactions').add(transactionData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  // Get user transactions
  Stream<QuerySnapshot> getUserTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update transaction status
  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }
}
