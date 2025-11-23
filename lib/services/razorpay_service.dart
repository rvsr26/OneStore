import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final ApiService api;
  final Function(String) onSuccess, onFailure;

  RazorpayService({required this.api, required this.onSuccess, required this.onFailure}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse r) async {
      try { await api.verifyPayment(razorpayPaymentId: r.paymentId!, razorpayOrderId: r.orderId!, razorpaySignature: r.signature!); onSuccess(r.paymentId!); } 
      catch (e) { onFailure("Verify Error: $e"); }
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse r) => onFailure("${r.code}: ${r.message}"));
  }
  Future<void> startPayment(int amount) async {
    final user = FirebaseAuth.instance.currentUser;
    final order = await api.createOrder(amountInPaise: amount, currency: 'INR', userId: user!.uid);
    _razorpay.open({'key': order['key_id'], 'amount': amount, 'name': 'Shop', 'order_id': order['id'], 'prefill': {'email': user.email}});
  }
  void dispose() => _razorpay.clear();
}