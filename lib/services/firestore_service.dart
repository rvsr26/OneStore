import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/review.dart';
import '../models/address.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================== ORDER MANAGEMENT ==================

  // Save a new order to Firestore
  Future<void> saveOrder({
    required String userId,
    required double total,
    required List<CartItem> items,
    required String paymentId,
    required String shippingAddress,
  }) async {
    try {
      await _db.collection('orders').add({
        'userId': userId,
        'total': total,
        'paymentId': paymentId,
        'shippingAddress': shippingAddress,
        'status': 'Paid', // Default status
        'createdAt': FieldValue.serverTimestamp(),
        // Convert List<CartItem> to List<Map> for storage
        'items': items.map((i) => {
          'productId': i.product.id,
          'title': i.product.title,
          'price': i.product.price,
          'quantity': i.quantity,
          'variant': i.selectedVariant,
          'imageUrl': i.product.imageUrl
        }).toList(),
      });
    } catch (e) {
      print("Error saving order: $e");
      throw e; // Rethrow to let UI handle it
    }
  }

  // Fetch User Orders (Real-time Stream)
  Stream<QuerySnapshot> getUserOrders(String uid) {
    return _db.collection('orders')
        .where('userId', isEqualTo: uid)
        // Note: .orderBy('createdAt') requires a composite index in Firestore.
        // If you see an error, check the debug console for a link to create it.
        // We sort locally in the UI to avoid index errors during development.
        .snapshots();
  }

  // ================== REVIEW MANAGEMENT ==================

  // Add a Review to a specific product
  Future<void> addReview(String pid, Review r) async {
    if (pid.isEmpty) return;
    try {
      await _db
          .collection('products')
          .doc(pid)
          .collection('reviews')
          .add(r.toMap());
    } catch (e) {
      print("Error adding review: $e");
    }
  }

  // Get Reviews for a specific product (Real-time Stream)
  Stream<List<Review>> getReviews(String pid) {
    return _db
        .collection('products')
        .doc(pid)
        .collection('reviews')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Pass both ID and Data to the Model to handle document ID mapping
            return Review.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ================== ADDRESS MANAGEMENT ==================

  // Add a new Address
  Future<void> addAddress(String userId, Address address) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add(address.toMap());
    } catch (e) {
      print("Error adding address: $e");
      throw e;
    }
  }

  // Delete an Address
  Future<void> deleteAddress(String userId, String addressId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .doc(addressId)
          .delete();
    } catch (e) {
      print("Error deleting address: $e");
    }
  }

  // Get User Addresses (Real-time Stream)
  Stream<List<Address>> getUserAddresses(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Address.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ================== WISHLIST MANAGEMENT ==================

  // 1. Add or Remove Item from Wishlist
  Future<void> toggleWishlist(String userId, String productId, bool isLiked) async {
    final userRef = _db.collection('users').doc(userId);
    
    try {
      if (isLiked) {
        // Add ID to the 'wishlist' array in the user's document
        // arrayUnion ensures no duplicates
        await userRef.set({
          'wishlist': FieldValue.arrayUnion([productId])
        }, SetOptions(merge: true));
      } else {
        // Remove ID from the array
        await userRef.update({
          'wishlist': FieldValue.arrayRemove([productId])
        });
      }
    } catch (e) {
      print("Error updating wishlist: $e");
    }
  }

  // 2. Get List of Favorite Product IDs
  Future<List<String>> fetchWishlist(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('wishlist')) {
        // Convert dynamic list to List<String> safely
        return List<String>.from(doc.data()!['wishlist']);
      }
    } catch (e) {
      print("Error fetching wishlist: $e");
    }
    return [];
  }
}