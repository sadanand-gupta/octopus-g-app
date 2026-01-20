import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiService extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 🔥 Firebase Cloud Function URL
  static const String _functionUrl =
      "https://us-central1-resume2webai.cloudfunctions.net/extractResumeData";

  Future<String> generatePortfolioCode(String resumeText) async {
    _isLoading = true;
    notifyListeners();

    // ✅ SAFE DEBUG LOG (URL only, no secrets)
    debugPrint("🔥 Calling Firebase Cloud Function:");
    debugPrint(_functionUrl);
    debugPrint("📄 Resume length: ${resumeText.length}");

    try {
      final response = await http
          .post(
            Uri.parse(_functionUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"resumeText": resumeText}),
          )
          .timeout(const Duration(seconds: 60));

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📥 Gupta ponse: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("📥 Gupta response: ${response.body}");

        // ❌ Backend error handling
        if (data["error"] != null) {
          throw Exception(data["error"]);
        }

        final html = data["html"];

        if (html == null || html.isEmpty) {
          throw Exception("Empty HTML received from server");
        }

        debugPrint("✅ HTML received (length: ${html.length})");
        return html;
      } else {
        throw Exception("Server error: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ AI ERROR: $e");

      // Return safe HTML so WebView doesn't crash
      return """
<!DOCTYPE html>
<html>
<body style="font-family: Arial; padding: 20px;">
  <h2>Error generating website</h2>
  <p>$e</p>
</body>
</html>
""";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
