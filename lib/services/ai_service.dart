// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
//
// class AiService extends ChangeNotifier {
//
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//
//   Future<String> generatePortfolioCode(String resumeText) async {
//     _isLoading = true;
//     notifyListeners();
//
//     // Debug logs
//     print("🔑 Using API Key: $_apiKey");
//     print("📄 Resume Text Length: ${resumeText.length}");
//     print("📤 Sending prompt to Gemini...");
//
//     try {
//       final model = GenerativeModel(
//         model: 'gemini-pro',
//         apiKey: _apiKey,
//       );
//
//
//       final prompt = '''
//       You are an expert portfolio website generator AI.
//
//       Based ONLY on this resume text, generate a complete, modern, responsive
//       Personal Portfolio Website using **raw HTML + internal CSS**.
//
//       Requirements:
//       - MUST return only pure HTML (NO markdown, NO ``` code blocks)
//       - Internal `<style>` CSS only (no external files)
//       - Modern UI with good spacing & typography
//       - Responsive for Mobile, Tablet, and Desktop
//       - Sections to include:
//           * Hero (name, role)
//           * About Me
//           * Skills
//           * Projects
//           * Experience
//           * Education
//           * Contact
//       - Use colors that look professional.
//
//       Resume Content:
//       $resumeText
//       ''';
//
//       final response = await model.generateContent([
//         Content.text(prompt),
//       ]);
//
//       _isLoading = false;
//       notifyListeners();
//
//       print("✅ AI Response Received!");
//
//       return response.text ?? "Error: No response text.";
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//       print("❌ AI Error: $e");
//       return "Error: $e";
//     }
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
//
// class AiService extends ChangeNotifier {
//   final String _apiKey = 'AIzaSyBV3ze021VSDFsHFR7XFaM7WK4JLaA5Ie8';
//
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//
//   Future<String> generatePortfolioCode(String resumeText) async {
//     _isLoading = true;
//     notifyListeners();
//
//     // Debug logs
//     print("🔑 Using API Key: $_apiKey");
//     print("📄 Resume Text Length: ${resumeText.length}");
//     print("📤 Sending prompt to Gemini...");
//
//     try {
//       final model = GenerativeModel(
//         model: 'gemini-pro',
//         apiKey: _apiKey,
//       );
//
//
//       final prompt = '''
//       You are an expert portfolio website generator AI.
//
//       Based ONLY on this resume text, generate a complete, modern, responsive
//       Personal Portfolio Website using **raw HTML + internal CSS**.
//
//       Requirements:
//       - MUST return only pure HTML (NO markdown, NO ``` code blocks)
//       - Internal `<style>` CSS only (no external files)
//       - Modern UI with good spacing & typography
//       - Responsive for Mobile, Tablet, and Desktop
//       - Sections to include:
//           * Hero (name, role)
//           * About Me
//           * Skills
//           * Projects
//           * Experience
//           * Education
//           * Contact
//       - Use colors that look professional.
//
//       Resume Content:
//       $resumeText
//       ''';
//
//       final response = await model.generateContent([
//         Content.text(prompt),
//       ]);
//
//       _isLoading = false;
//       notifyListeners();
//
//       print("✅ AI Response Received!");
//
//       return response.text ?? "Error: No response text.";
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//       print("❌ AI Error: $e");
//       return "Error: $e";
//     }
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiService extends ChangeNotifier {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String> generatePortfolioCode(String resumeText) async {
    _isLoading = true;
    notifyListeners();

    print("🔑 Using Groq API Key: $_apiKey");
    print("📄 Resume length: ${resumeText.length}");
    print("📤 Sending request to Groq...");

    final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $_apiKey",
    };

    final body = jsonEncode({
      "model": "llama-3.1-8b-instant",
      "messages": [
        {
          "role": "system",
          "content":
              "You are a highly skilled website-generator AI. Create clean, responsive HTML + internal CSS only.",
        },
        {
          "role": "user",
          "content":
              """
Generate a complete personal portfolio website using RAW HTML + internal CSS.

IMPORTANT:
- DO NOT use markdown
- DO NOT wrap with ``` code blocks
- ONLY return pure HTML
- Must include hero, about, skills, experience, education, projects, contact sections
- Clean design, responsive layout

Resume content:
$resumeText
""",
        },
      ],
      "temperature": 0.4,
    });

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(Duration(seconds: 40));

      print("📥 Status Code: ${response.statusCode}");

      final previewLength = response.body.length < 300
          ? response.body.length
          : 300;
      print(
        "📥 Raw Body Preview: ${response.body.substring(0, previewLength)}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final html = data["choices"][0]["message"]["content"];

        print("✅ Groq Response Received (HTML Length: ${html.length})");

        _isLoading = false;
        notifyListeners();
        return html;
      } else {
        print("❌ Error: ${response.body}");
        return "Error: ${response.body}";
      }
    } catch (e) {
      print("❌ Exception: $e");
      return "Error: $e";
    }
  }
}
