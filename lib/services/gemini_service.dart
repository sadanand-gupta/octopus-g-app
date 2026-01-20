import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Replace with your Gemini API key
  static const String _apiKey = 'YOUR_GEMINI_API_KEY';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<Map<String, dynamic>> extractResumeData(String resumeText) async {
    try {
      final prompt = '''
You are a resume parser. Extract ALL information from the following resume text and return it as a valid JSON object.

Extract these fields:
- name: Full name
- jobTitle: Current or target job title
- email: Email address
- phone: Phone number
- location: City, State/Country
- linkedin: LinkedIn URL
- github: GitHub URL
- website: Personal website URL
- summary: Professional summary or objective (full text)
- skills: Array of all skills mentioned
- experience: Array of objects with {title, company, duration, location, description}
- education: Array of objects with {degree, institution, year, gpa}
- projects: Array of objects with {name, technologies, url, description}
- certifications: Array of certification names
- languages: Array of languages
- awards: Array of awards/achievements
- interests: Array of interests/hobbies
- publications: Array of publications

If a field is not found, use empty string "" or empty array [].
Return ONLY valid JSON, no markdown, no explanation.

Resume Text:
$resumeText
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 8192,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];

        // Clean the response (remove markdown code blocks if present)
        String cleanJson = text.trim();
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.substring(7);
        }
        if (cleanJson.startsWith('```')) {
          cleanJson = cleanJson.substring(3);
        }
        if (cleanJson.endsWith('```')) {
          cleanJson = cleanJson.substring(0, cleanJson.length - 3);
        }
        cleanJson = cleanJson.trim();

        return jsonDecode(cleanJson);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to parse resume: $e');
    }
  }
}
