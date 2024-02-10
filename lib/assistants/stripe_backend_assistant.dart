import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mechaniconthego/global/global.dart';
import 'package:mechaniconthego/global/keys.dart';

class CheckoutSessionResponse {
  late Map<String, dynamic> session;

  CheckoutSessionResponse(this.session);
}

class StripeBackendService {
  static String createAccountUrl = '$BACKEND_HOST/stripeCreateConnectedAccount';
  static String checkOutUrl = '$BACKEND_HOST/checkout';
  static Map<String, String> headers = {'Content-Type': 'application/json'};

  static Future createMechanicAccount() async {
    var url = Uri.parse(StripeBackendService.createAccountUrl);
    var reqBody = jsonEncode({'user': currentUserData});
    var response = await http.post(
        url,
        headers: StripeBackendService.headers,
        body: reqBody,
    );
    Map<String, dynamic> body = jsonDecode(response.body);
    return body;
  }


  static Future<CheckoutSessionResponse> payOnline(String accountId, double charges) async {
    var url = "${StripeBackendService.checkOutUrl}?&accountId=$accountId&amount=$charges&currency=PKR";
    Uri parsedUrl = Uri.parse(url);
    var response = await http.get(parsedUrl, headers: StripeBackendService.headers);
    Map<String, dynamic> body = jsonDecode(response.body);
    return CheckoutSessionResponse(body['session']);
  }
}
