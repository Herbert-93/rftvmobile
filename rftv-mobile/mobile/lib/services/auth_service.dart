import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around FirebaseAuth + GoogleSignIn + the user's Firestore
/// profile doc. Screens should talk to this class rather than those
/// packages directly, so every sign-in method (email, Google, phone) ends
/// up in Firestore the same way.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> get idToken async => _auth.currentUser?.getIdToken();

  // ---------------- Email + password ----------------

  Future<UserCredential> signIn(
      {required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await cred.user?.updateDisplayName(name);
    await _syncProfile(
        uid: cred.user!.uid, name: name, email: email, phone: phone);
    return cred;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  // ---------------- Google ----------------

  /// Returns null if the user cancelled the Google account picker.
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await _auth.signInWithCredential(credential);
    await _syncProfile(
      uid: userCred.user!.uid,
      name: userCred.user!.displayName ?? '',
      email: userCred.user!.email ?? '',
      phone: userCred.user!.phoneNumber ?? '',
    );
    return userCred;
  }

  // ---------------- Phone / OTP ----------------

  /// Kicks off phone verification. [onCodeSent] fires once Firebase has sent
  /// the SMS (with a verificationId you pass to [confirmPhoneCode] later).
  /// [onAutoVerified] fires on the rare Android devices that auto-detect the
  /// SMS and finish sign-in without the user ever typing a code.
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String message) onError,
    required void Function() onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCred = await _auth.signInWithCredential(credential);
        await _syncProfile(
          uid: userCred.user!.uid,
          name: userCred.user!.displayName ?? '',
          email: userCred.user!.email ?? '',
          phone: phoneNumber,
        );
        onAutoVerified();
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Could not verify this number');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<UserCredential> confirmPhoneCode({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    final userCred = await _auth.signInWithCredential(credential);
    await _syncProfile(
      uid: userCred.user!.uid,
      name: userCred.user!.displayName ?? '',
      email: userCred.user!.email ?? '',
      phone: phoneNumber,
    );
    return userCred;
  }

  // ---------------- Shared ----------------

  /// Creates or updates `users/{uid}` in Firestore. Deliberately never
  /// overwrites `isAdmin` on an existing doc — only sets it (to false) the
  /// very first time the doc is created — so signing in again never
  /// accidentally strips admin access someone was granted via the backend's
  /// set-admin script.
  Future<void> _syncProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    final snap = await ref.get();

    final data = <String, dynamic>{
      'uid': uid,
      if (name.isNotEmpty) 'name': name,
      if (email.isNotEmpty) 'email': email,
      if (phone.isNotEmpty) 'phone': phone,
    };

    if (!snap.exists) {
      data['isAdmin'] = false;
      data['createdAt'] = DateTime.now().toIso8601String();
    }

    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
