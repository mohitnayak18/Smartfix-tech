import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';


class GetLocationController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  var selectedAddress = ''.obs;
  var addresses = <QueryDocumentSnapshot>[].obs;

  String get uid => _auth.currentUser!.uid;

  @override
  void onInit() {
    fetchAddresses();
    super.onInit();
  }

  void fetchAddresses() {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          addresses.value = snapshot.docs;
        });
  }

  Future<void> saveAddress({
    required String address,
    required String label,
    required String phone,
  }) async {
    await _firestore.collection('users').doc(uid).collection('addresses').add({
      "address": address,
      "label": label,
      "phone": phone,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAddress(String docId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .doc(docId)
        .delete();
  }

  void selectAddress(String address) {
    selectedAddress.value = address;
  }
}
