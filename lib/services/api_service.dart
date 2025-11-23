import 'dart:convert';
import 'package:http/http.dart' as http;
class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});
  Future<Map<String, dynamic>> createOrder({required int amountInPaise, required String currency, required String userId}) async {
    final r = await http.post(Uri.parse('$baseUrl/create-order'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'amount': amountInPaise, 'currency': currency, 'userId': userId}));
    if (r.statusCode != 200) throw Exception(r.body);
    return jsonDecode(r.body);
  }
  Future<Map<String, dynamic>> verifyPayment({required String razorpayPaymentId, required String razorpayOrderId, required String razorpaySignature}) async {
    final r = await http.post(Uri.parse('$baseUrl/verify-payment'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'razorpay_payment_id': razorpayPaymentId, 'razorpay_order_id': razorpayOrderId, 'razorpay_signature': razorpaySignature}));
    if (r.statusCode != 200) throw Exception(r.body);
    return jsonDecode(r.body);
  }
}