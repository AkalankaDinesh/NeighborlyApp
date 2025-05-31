import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user_model.dart';

class FireStoreS {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> registerUser(UserModel userModel) async {
    await _fireStore
        .collection('users')
        .doc(userModel.email)
        .set(userModel.toFirestore());
  }

  // Methods to add a data to Firestore
  // Future<void> addUser(UserModel user) async {
  //   await _fireStore.collection('users').doc(user.id).set(user.toFirestore());
  // }
}
