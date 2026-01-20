import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../constants/app_colors.dart';
import '../services/gemini_service.dart';
import 'resume_preview_screen.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  bool isLoading = false;
  String? selectedFileName;
  String? extractedText;
  String _statusMessage = '';
  bool _useAI = true; // Toggle for AI extraction

  final GeminiService _geminiService = GeminiService();

  Future<void> _pickAndExtractPDF() async {
    try {
      setState(() {
        isLoading = true;
        _statusMessage = 'Selecting file...';
      });

      // Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          selectedFileName = result.files.single.name;
          _statusMessage = 'Reading PDF...';
        });

        // Extract text from PDF
        final bytes = await file.readAsBytes();
        final PdfDocument document = PdfDocument(inputBytes: bytes);

        String text = '';
        setState(() => _statusMessage = 'Extracting text...');

        for (int i = 0; i < document.pages.count; i++) {
          text += PdfTextExtractor(document)
                  .extractText(startPageIndex: i, endPageIndex: i) ??
              '';
          text += '\n';
        }
        document.dispose();

        setState(() => extractedText = text.trim());

        if (extractedText != null && extractedText!.isNotEmpty) {
          Map<String, dynamic> resumeData;

          if (_useAI) {
            // Use AI-powered extraction
            setState(() => _statusMessage = 'AI is analyzing your resume...');
            try {
              resumeData =
                  await _geminiService.extractResumeData(extractedText!);
              resumeData['rawText'] = extractedText;
              resumeData['extractionMethod'] = 'AI (Gemini)';
              resumeData['totalLines'] = extractedText!.split('\n').length;
            } catch (e) {
              // Fallback to local parsing if AI fails
              setState(() =>
                  _statusMessage = 'AI unavailable, using local parser...');
              resumeData = _parseResumeText(extractedText!);
              resumeData['extractionMethod'] = 'Local Parser (AI failed)';
            }
          } else {
            // Use local parsing
            setState(() => _statusMessage = 'Parsing resume locally...');
            resumeData = _parseResumeText(extractedText!);
            resumeData['extractionMethod'] = 'Local Parser';
          }

          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ResumePreviewScreen(resumeData: resumeData),
              ),
            );
          }
        } else {
          _showError('Could not extract text from PDF');
        }
      }
    } catch (e) {
      _showError('Error processing PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          _statusMessage = '';
        });
      }
    }
  }

  Map<String, dynamic> _parseResumeText(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final textLower = text.toLowerCase();

    // Initialize all data fields
    String name = '';
    String email = '';
    String phone = '';
    String location = '';
    String summary = '';
    String linkedin = '';
    String github = '';
    String website = '';
    String portfolio = '';
    String jobTitle = '';
    List<String> skills = [];
    List<Map<String, String>> experience = [];
    List<Map<String, String>> education = [];
    List<Map<String, String>> projects = [];
    List<String> certifications = [];
    List<String> languages = [];
    List<String> awards = [];
    List<String> interests = [];
    List<String> references = [];
    List<String> publications = [];
    List<String> volunteerWork = [];
    Map<String, List<String>> customSections = {};

    // ============ CONTACT INFORMATION ============

    // Extract email (multiple patterns)
    final emailRegex =
        RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final allEmails =
        emailRegex.allMatches(text).map((m) => m.group(0)!).toSet().toList();
    if (allEmails.isNotEmpty) {
      email = allEmails.first;
    }

    // Extract phone numbers (multiple formats)
    final phonePatterns = [
      RegExp(r'\+?1?[-.\s]?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}'),
      RegExp(
          r'\+?[0-9]{1,3}[-.\s]?[0-9]{3,5}[-.\s]?[0-9]{3,5}[-.\s]?[0-9]{3,5}'),
      RegExp(r'\+91[-.\s]?[0-9]{10}'),
      RegExp(r'[0-9]{10,12}'),
    ];
    for (var pattern in phonePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        phone = match.group(0)!.trim();
        break;
      }
    }

    // Extract LinkedIn
    final linkedinPatterns = [
      RegExp(r'linkedin\.com/in/[\w-]+', caseSensitive: false),
      RegExp(r'linkedin:\s*([\w-]+)', caseSensitive: false),
    ];
    for (var pattern in linkedinPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        linkedin = match.group(0)!.contains('linkedin.com')
            ? 'https://${match.group(0)}'
            : 'https://linkedin.com/in/${match.group(1)}';
        break;
      }
    }

    // Extract GitHub
    final githubPatterns = [
      RegExp(r'github\.com/[\w-]+', caseSensitive: false),
      RegExp(r'github:\s*([\w-]+)', caseSensitive: false),
    ];
    for (var pattern in githubPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        github = match.group(0)!.contains('github.com')
            ? 'https://${match.group(0)}'
            : 'https://github.com/${match.group(1)}';
        break;
      }
    }

    // Extract personal website/portfolio
    final websiteRegex = RegExp(
        r'https?://(?!linkedin|github)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[/\w.-]*');
    final websiteMatch = websiteRegex.firstMatch(text);
    if (websiteMatch != null) {
      website = websiteMatch.group(0)!;
    }

    // Extract location (various formats)
    final locationPatterns = [
      RegExp(r'([A-Z][a-zA-Z\s]+,\s*[A-Z]{2}\s*\d{5})'), // City, ST 12345
      RegExp(r'([A-Z][a-zA-Z\s]+,\s*[A-Z]{2})'), // City, ST
      RegExp(
          r'([A-Z][a-zA-Z\s]+,\s*[A-Z][a-zA-Z\s]+,\s*[A-Z][a-zA-Z\s]+)'), // City, State, Country
      RegExp(r'([A-Z][a-zA-Z\s]+,\s*[A-Z][a-zA-Z\s]+)'), // City, Country
      RegExp(r'Location:\s*([^\n]+)', caseSensitive: false),
      RegExp(r'Address:\s*([^\n]+)', caseSensitive: false),
    ];
    for (var pattern in locationPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && !match.group(0)!.contains('@')) {
        location = match.group(1) ?? match.group(0)!;
        location = location.trim();
        break;
      }
    }

    // ============ NAME EXTRACTION ============
    // Try multiple strategies for name
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i];
      // Skip if line contains email, phone, or common header words
      if (line.contains('@') ||
          RegExp(r'[0-9]{3}').hasMatch(line) ||
          line.toLowerCase().contains('resume') ||
          line.toLowerCase().contains('curriculum') ||
          line.toLowerCase().contains('cv') ||
          line.length > 50 ||
          line.contains('http')) {
        continue;
      }
      // Likely a name if it's 2-4 words, all capitalized or title case
      final words = line.split(' ').where((w) => w.isNotEmpty).toList();
      if (words.length >= 1 && words.length <= 5) {
        final allCapOrTitle = words.every((w) =>
            w[0] == w[0].toUpperCase() && !RegExp(r'[0-9@.]').hasMatch(w));
        if (allCapOrTitle) {
          name = line;
          // Check if next line might be job title
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            if (!nextLine.contains('@') &&
                !RegExp(r'[0-9]{3}').hasMatch(nextLine) &&
                nextLine.length < 60 &&
                !nextLine.toLowerCase().contains('summary') &&
                !nextLine.toLowerCase().contains('experience')) {
              final jobTitleKeywords = [
                'engineer',
                'developer',
                'manager',
                'designer',
                'analyst',
                'consultant',
                'specialist',
                'director',
                'lead',
                'senior',
                'junior',
                'intern',
                'architect',
                'administrator',
                'coordinator',
                'executive',
                'officer',
                'scientist',
                'researcher',
                'professor',
                'teacher',
                'student'
              ];
              if (jobTitleKeywords
                  .any((k) => nextLine.toLowerCase().contains(k))) {
                jobTitle = nextLine;
              }
            }
          }
          break;
        }
      }
    }

    // ============ SECTION DETECTION ============
    final sectionHeaders = <String, int>{};
    final sectionKeywordsMap = {
      'summary': [
        'summary',
        'profile',
        'objective',
        'about me',
        'about',
        'professional summary',
        'career objective',
        'personal statement',
        'overview'
      ],
      'experience': [
        'experience',
        'work experience',
        'employment',
        'work history',
        'professional experience',
        'employment history',
        'career history'
      ],
      'education': [
        'education',
        'academic',
        'qualifications',
        'academic background',
        'educational background',
        'academics'
      ],
      'skills': [
        'skills',
        'technical skills',
        'core competencies',
        'competencies',
        'expertise',
        'technologies',
        'tools',
        'proficiencies',
        'technical proficiencies',
        'key skills',
        'areas of expertise'
      ],
      'projects': [
        'projects',
        'personal projects',
        'academic projects',
        'key projects',
        'major projects',
        'project experience'
      ],
      'certifications': [
        'certifications',
        'certificates',
        'licenses',
        'credentials',
        'professional certifications',
        'training'
      ],
      'languages': ['languages', 'language skills', 'linguistic skills'],
      'awards': [
        'awards',
        'honors',
        'achievements',
        'accomplishments',
        'recognition'
      ],
      'interests': ['interests', 'hobbies', 'activities', 'extracurricular'],
      'publications': ['publications', 'papers', 'research', 'articles'],
      'volunteer': [
        'volunteer',
        'volunteering',
        'community service',
        'social work'
      ],
      'references': ['references', 'referees'],
    };

    // Find all section start positions
    for (int i = 0; i < lines.length; i++) {
      final lineLower =
          lines[i].toLowerCase().replaceAll(RegExp(r'[:\-_|]'), '').trim();
      for (var entry in sectionKeywordsMap.entries) {
        if (entry.value.any((keyword) =>
            lineLower == keyword || lineLower.startsWith('$keyword '))) {
          sectionHeaders[entry.key] = i;
          break;
        }
      }
    }

    // Sort sections by position
    final sortedSections = sectionHeaders.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // ============ EXTRACT EACH SECTION ============

    for (int secIdx = 0; secIdx < sortedSections.length; secIdx++) {
      final section = sortedSections[secIdx];
      final startIdx = section.value + 1;
      final endIdx = secIdx + 1 < sortedSections.length
          ? sortedSections[secIdx + 1].value
          : lines.length;

      final sectionLines = lines.sublist(startIdx, endIdx);

      switch (section.key) {
        case 'summary':
          summary = sectionLines.join(' ').trim();
          break;

        case 'skills':
          skills = _extractSkills(sectionLines);
          break;

        case 'experience':
          experience = _extractExperience(sectionLines);
          break;

        case 'education':
          education = _extractEducation(sectionLines);
          break;

        case 'projects':
          projects = _extractProjects(sectionLines);
          break;

        case 'certifications':
          certifications = _extractBulletPoints(sectionLines);
          break;

        case 'languages':
          languages = _extractBulletPoints(sectionLines);
          break;

        case 'awards':
          awards = _extractBulletPoints(sectionLines);
          break;

        case 'interests':
          interests = _extractBulletPoints(sectionLines);
          break;

        case 'publications':
          publications = _extractBulletPoints(sectionLines);
          break;

        case 'volunteer':
          volunteerWork = _extractBulletPoints(sectionLines);
          break;

        case 'references':
          references = _extractBulletPoints(sectionLines);
          break;
      }
    }

    // ============ FALLBACK EXTRACTIONS ============

    // If no skills found, scan entire document for tech keywords
    if (skills.isEmpty) {
      skills = _extractTechKeywords(text);
    }

    // If no summary found, try to extract from beginning
    if (summary.isEmpty && sectionHeaders.isNotEmpty) {
      final firstSectionIdx = sortedSections.first.value;
      if (firstSectionIdx > 3) {
        final potentialSummary =
            lines.sublist(2, firstSectionIdx).join(' ').trim();
        if (potentialSummary.length > 50) {
          summary = potentialSummary;
        }
      }
    }

    // Clean up data
    skills = skills.toSet().toList();
    skills.removeWhere((s) => s.length < 2 || s.length > 50);

    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'jobTitle': jobTitle,
      'linkedin': linkedin,
      'github': github,
      'website': website,
      'summary': summary.isNotEmpty
          ? summary
          : 'Experienced professional seeking new opportunities.',
      'skills': skills,
      'experience': experience,
      'education': education,
      'projects': projects,
      'certifications': certifications,
      'languages': languages,
      'awards': awards,
      'interests': interests,
      'publications': publications,
      'volunteerWork': volunteerWork,
      'references': references,
      'rawText': text,
      'totalLines': lines.length,
      'sectionsFound': sectionHeaders.keys.toList(),
    };
  }

  List<String> _extractSkills(List<String> lines) {
    List<String> skills = [];
    for (var line in lines) {
      // Split by common delimiters
      final parts = line
          .split(RegExp(r'[,•●○◦▪▸►\|;/]'))
          .map((s) => s.replaceAll(RegExp(r'^[\-\*]\s*'), '').trim())
          .where((s) => s.isNotEmpty && s.length > 1 && s.length < 50);
      skills.addAll(parts);
    }
    return skills;
  }

  List<String> _extractTechKeywords(String text) {
    final techKeywords = [
      'JavaScript',
      'Python',
      'Java',
      'C++',
      'C#',
      'C',
      'Ruby',
      'Go',
      'Rust',
      'Swift',
      'Kotlin',
      'TypeScript',
      'PHP',
      'Scala',
      'R',
      'MATLAB',
      'Perl',
      'Dart',
      'Objective-C',
      'React',
      'Angular',
      'Vue',
      'Node.js',
      'Express',
      'Django',
      'Flask',
      'Spring',
      'Laravel',
      'Rails',
      'ASP.NET',
      'Flutter',
      'React Native',
      'Electron',
      'Next.js',
      'Nuxt.js',
      'HTML',
      'CSS',
      'SASS',
      'LESS',
      'Bootstrap',
      'Tailwind',
      'Material UI',
      'jQuery',
      'SQL',
      'MySQL',
      'PostgreSQL',
      'MongoDB',
      'Redis',
      'Firebase',
      'Oracle',
      'SQLite',
      'DynamoDB',
      'Cassandra',
      'Elasticsearch',
      'AWS',
      'Azure',
      'GCP',
      'Docker',
      'Kubernetes',
      'Jenkins',
      'CI/CD',
      'Terraform',
      'Ansible',
      'Linux',
      'Git',
      'GitHub',
      'GitLab',
      'Bitbucket',
      'Machine Learning',
      'Deep Learning',
      'TensorFlow',
      'PyTorch',
      'Keras',
      'NLP',
      'Computer Vision',
      'Data Science',
      'AI',
      'REST API',
      'GraphQL',
      'Microservices',
      'Serverless',
      'WebSocket',
      'Agile',
      'Scrum',
      'Kanban',
      'JIRA',
      'Confluence',
      'Trello',
      'Asana',
      'Figma',
      'Sketch',
      'Adobe XD',
      'Photoshop',
      'Illustrator',
      'InDesign',
      'After Effects',
      'Premiere Pro',
      'Excel',
      'PowerPoint',
      'Word',
      'Power BI',
      'Tableau',
      'SAP',
      'Salesforce',
      'Communication',
      'Leadership',
      'Team Management',
      'Problem Solving',
      'Critical Thinking',
      'Project Management',
      'Time Management',
    ];

    List<String> found = [];
    final textLower = text.toLowerCase();
    for (var keyword in techKeywords) {
      if (textLower.contains(keyword.toLowerCase())) {
        found.add(keyword);
      }
    }
    return found;
  }

  List<Map<String, String>> _extractExperience(List<String> lines) {
    List<Map<String, String>> experiences = [];

    String currentTitle = '';
    String currentCompany = '';
    String currentDuration = '';
    String currentLocation = '';
    List<String> currentDescription = [];

    final datePatterns = [
      RegExp(
          r'(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\s*[,.]?\s*\d{2,4}\s*[-–—to]+\s*(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\s*[,.]?\s*\d{2,4}|Present|Current|Now',
          caseSensitive: false),
      RegExp(
          r'\d{1,2}/\d{2,4}\s*[-–—to]+\s*(\d{1,2}/\d{2,4}|Present|Current|Now)',
          caseSensitive: false),
      RegExp(r'\d{4}\s*[-–—to]+\s*(\d{4}|Present|Current|Now)',
          caseSensitive: false),
    ];

    void saveCurrentExperience() {
      if (currentTitle.isNotEmpty || currentCompany.isNotEmpty) {
        experiences.add({
          'title': currentTitle,
          'company': currentCompany,
          'duration': currentDuration,
          'location': currentLocation,
          'description': currentDescription.join('\n'),
        });
      }
      currentTitle = '';
      currentCompany = '';
      currentDuration = '';
      currentLocation = '';
      currentDescription = [];
    }

    for (var line in lines) {
      if (line.isEmpty) continue;

      // Check for date pattern - usually indicates new entry
      String? foundDate;
      for (var pattern in datePatterns) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          foundDate = match.group(0);
          break;
        }
      }

      if (foundDate != null) {
        // New experience entry
        saveCurrentExperience();
        currentDuration = foundDate;
        final remainingText = line
            .replaceAll(foundDate, '')
            .replaceAll(RegExp(r'[|,]'), '')
            .trim();
        if (remainingText.isNotEmpty) {
          currentTitle = remainingText;
        }
      } else if (line.startsWith('•') ||
          line.startsWith('-') ||
          line.startsWith('*') ||
          line.startsWith('●') ||
          line.startsWith('○')) {
        // Bullet point - description
        currentDescription
            .add(line.replaceAll(RegExp(r'^[•\-*●○]\s*'), '').trim());
      } else if (currentTitle.isEmpty) {
        currentTitle = line;
      } else if (currentCompany.isEmpty) {
        // Check if line contains location indicators
        if (line.contains(',') &&
            (RegExp(r'[A-Z]{2}$').hasMatch(line.trim()) ||
                line.toLowerCase().contains('remote'))) {
          final parts = line.split(',');
          currentCompany = parts.first.trim();
          currentLocation = parts.sublist(1).join(',').trim();
        } else {
          currentCompany = line;
        }
      } else if (currentLocation.isEmpty &&
          (line.contains(',') || line.toLowerCase().contains('remote'))) {
        currentLocation = line;
      } else {
        currentDescription.add(line);
      }
    }

    saveCurrentExperience();
    return experiences;
  }

  List<Map<String, String>> _extractEducation(List<String> lines) {
    List<Map<String, String>> educations = [];

    String currentDegree = '';
    String currentInstitution = '';
    String currentYear = '';
    String currentGpa = '';
    String currentDetails = '';

    final degreeKeywords = [
      'bachelor',
      'master',
      'phd',
      'doctorate',
      'associate',
      'diploma',
      'certificate',
      'b.s.',
      'b.a.',
      'm.s.',
      'm.a.',
      'mba',
      'b.tech',
      'm.tech',
      'b.e.',
      'm.e.',
      'bsc',
      'msc',
      'b.sc',
      'm.sc',
      'bca',
      'mca',
      'bba',
      'llb',
      'md',
      'mbbs',
      'high school',
      'secondary',
      'intermediate'
    ];
    final institutionKeywords = [
      'university',
      'college',
      'institute',
      'school',
      'academy',
      'polytechnic'
    ];

    void saveCurrentEducation() {
      if (currentDegree.isNotEmpty || currentInstitution.isNotEmpty) {
        educations.add({
          'degree': currentDegree,
          'institution': currentInstitution,
          'year': currentYear,
          'gpa': currentGpa,
          'details': currentDetails.trim(),
        });
      }
      currentDegree = '';
      currentInstitution = '';
      currentYear = '';
      currentGpa = '';
      currentDetails = '';
    }

    for (var line in lines) {
      if (line.isEmpty) continue;

      final lineLower = line.toLowerCase();

      // Extract year
      final yearMatch = RegExp(r'\b(19|20)\d{2}\b').firstMatch(line);
      if (yearMatch != null && currentYear.isEmpty) {
        currentYear = yearMatch.group(0)!;
      }

      // Extract GPA
      final gpaMatch = RegExp(
              r'(GPA|CGPA|Grade)[\s:]*(\d+\.?\d*)\s*/?(\d+\.?\d*)?',
              caseSensitive: false)
          .firstMatch(line);
      if (gpaMatch != null) {
        currentGpa = gpaMatch.group(0)!;
      }

      // Check if line contains degree
      if (degreeKeywords.any((k) => lineLower.contains(k))) {
        if (currentDegree.isNotEmpty) {
          saveCurrentEducation();
        }
        currentDegree = line.replaceAll(RegExp(r'\b(19|20)\d{2}\b'), '').trim();
      } else if (institutionKeywords.any((k) => lineLower.contains(k))) {
        currentInstitution =
            line.replaceAll(RegExp(r'\b(19|20)\d{2}\b'), '').trim();
      } else if (currentDegree.isEmpty && currentInstitution.isEmpty) {
        currentDegree = line;
      } else {
        currentDetails += ' $line';
      }
    }

    saveCurrentEducation();
    return educations;
  }

  List<Map<String, String>> _extractProjects(List<String> lines) {
    List<Map<String, String>> projects = [];

    String currentName = '';
    String currentTechnologies = '';
    String currentUrl = '';
    List<String> currentDescription = [];

    void saveCurrentProject() {
      if (currentName.isNotEmpty) {
        projects.add({
          'name': currentName,
          'technologies': currentTechnologies,
          'url': currentUrl,
          'description': currentDescription.join('\n'),
        });
      }
      currentName = '';
      currentTechnologies = '';
      currentUrl = '';
      currentDescription = [];
    }

    for (var line in lines) {
      if (line.isEmpty) continue;

      // Check for URL
      final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(line);
      if (urlMatch != null) {
        currentUrl = urlMatch.group(0)!;
        line = line.replaceAll(urlMatch.group(0)!, '').trim();
      }

      // Check for technologies (usually in parentheses or after colon)
      final techMatch = RegExp(r'\(([^)]+)\)').firstMatch(line);
      if (techMatch != null && techMatch.group(1)!.contains(RegExp(r'[,|]'))) {
        currentTechnologies = techMatch.group(1)!;
        line = line.replaceAll(techMatch.group(0)!, '').trim();
      }

      if (line.startsWith('•') ||
          line.startsWith('-') ||
          line.startsWith('*')) {
        currentDescription
            .add(line.replaceAll(RegExp(r'^[•\-*]\s*'), '').trim());
      } else if (currentName.isEmpty) {
        saveCurrentProject();
        currentName = line;
      } else {
        currentDescription.add(line);
      }
    }

    saveCurrentProject();
    return projects;
  }

  List<String> _extractBulletPoints(List<String> lines) {
    List<String> items = [];
    String currentItem = '';

    for (var line in lines) {
      if (line.isEmpty) continue;

      if (line.startsWith('•') ||
          line.startsWith('-') ||
          line.startsWith('*') ||
          line.startsWith('●')) {
        if (currentItem.isNotEmpty) {
          items.add(currentItem.trim());
        }
        currentItem = line.replaceAll(RegExp(r'^[•\-*●]\s*'), '').trim();
      } else if (RegExp(r'^\d+[.)]').hasMatch(line)) {
        if (currentItem.isNotEmpty) {
          items.add(currentItem.trim());
        }
        currentItem = line.replaceAll(RegExp(r'^\d+[.)]\s*'), '').trim();
      } else if (currentItem.isNotEmpty) {
        currentItem += ' $line';
      } else {
        items.add(line.trim());
      }
    }

    if (currentItem.isNotEmpty) {
      items.add(currentItem.trim());
    }

    return items.where((item) => item.isNotEmpty).toList();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.accentRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Upload Resume',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // AI Toggle
                      // Container(
                      //   padding: const EdgeInsets.all(16),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.surface,
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(color: AppColors.divider),
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Icon(
                      //             Icons.auto_awesome,
                      //             color: _useAI
                      //                 ? AppColors.primaryBlue
                      //                 : AppColors.textSecondary,
                      //             size: 20,
                      //           ),
                      //           const SizedBox(width: 12),
                      //           Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               const Text(
                      //                 'AI-Powered Extraction',
                      //                 style: TextStyle(
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.w600,
                      //                   color: AppColors.textPrimary,
                      //                 ),
                      //               ),
                      //               Text(
                      //                 _useAI
                      //                     ? 'Better accuracy with Gemini AI'
                      //                     : 'Using basic parser',
                      //                 style: const TextStyle(
                      //                   fontSize: 12,
                      //                   color: AppColors.textSecondary,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //       Switch(
                      //         value: _useAI,
                      //         onChanged: (value) =>
                      //             setState(() => _useAI = value),
                      //         activeColor: AppColors.primaryBlue,
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // const SizedBox(height: 24),

                      // Upload Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          size: 50,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title & Subtitle
                      const Text(
                        'Upload Your Resume',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload a PDF resume to automatically\ngenerate your portfolio website',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Upload Area
                      GestureDetector(
                        onTap: isLoading ? null : _pickAndExtractPDF,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 48,
                                color: AppColors.accentRed,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                selectedFileName ?? 'Tap to select PDF',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: selectedFileName != null
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'PDF files only • Max 10MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Status Message
                      if (isLoading && _statusMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _statusMessage,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Upload Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _pickAndExtractPDF,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColors.primaryBlue.withOpacity(0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'SELECT PDF FILE',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const Text(
                'YOUR DATA IS SECURE',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
