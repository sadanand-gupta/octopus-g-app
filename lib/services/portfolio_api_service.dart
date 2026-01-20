import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;

class PortfolioApiService {
  // Your Firebase Cloud Function URL
  static const String _functionUrl =
      'https://us-central1-resume2webai.cloudfunctions.net/extractResumeData';

  /// Send resume text to Firebase Cloud Function and get generated HTML
  Future<PortfolioResponse> generatePortfolio(
    String resumeText, {
    String primaryColor = '#1F5EFF',
    String accentColor = '#3B82F6',
    String darkColor = '#0F172A',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'resumeText': resumeText,
          'primaryColor': primaryColor,
          'accentColor': accentColor,
          'darkColor': darkColor,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['html'] != null && data['html'].toString().isNotEmpty) {
          return PortfolioResponse(
            success: true,
            htmlCode: data['html'],
            error: null,
          );
        } else {
          return PortfolioResponse(
            success: false,
            htmlCode: '',
            error: data['error'] ?? 'No HTML returned',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        return PortfolioResponse(
          success: false,
          htmlCode: '',
          error: errorData['error'] ?? 'API Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return PortfolioResponse(
        success: false,
        htmlCode: '',
        error: 'Failed to generate portfolio: $e',
      );
    }
  }
}

class PortfolioResponse {
  final bool success;
  final String htmlCode;
  final String? error;

  PortfolioResponse({
    required this.success,
    required this.htmlCode,
    this.error,
  });
}

// Color theme model
class ColorTheme {
  final String name;
  final String primary;
  final String accent;
  final String dark;
  final List<Color> colors;

  ColorTheme({
    required this.name,
    required this.primary,
    required this.accent,
    required this.dark,
    required this.colors,
  });
}
