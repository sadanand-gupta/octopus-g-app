import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';
import 'generated_site_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _extractedText;
  String? _fileName;
  bool _isReadingPdf = false;

  // Pick PDF and Extract Text
  Future<void> _pickAndExtractPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _isReadingPdf = true;
        _fileName = result.files.single.name;
      });

      try {
        String text = await ReadPdfText.getPDFtext(result.files.single.path!);
        setState(() {
          _extractedText = text;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error reading PDF: $e')));
      } finally {
        setState(() => _isReadingPdf = false);
      }
    }
  }

  void _showExtractedData() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            controller: controller,
            children: [
              const Text("Extracted Resume Content", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Text(_extractedText ?? "No content found.", style: const TextStyle(fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _generatePortfolio() async {
    if (_extractedText == null) return;

    final aiService = Provider.of<AiService>(context, listen: false);
    String code = await aiService.generatePortfolioCode(_extractedText!);

    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => GeneratedSiteScreen(htmlCode: code)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final aiService = Provider.of<AiService>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Portfolio.AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () => _showProfileDialog(context, authService),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Build your dream portfolio\nin seconds.",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),

              // Main Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Upload Section
                      _buildActionCard(
                        icon: Icons.upload_file,
                        title: _fileName ?? "Upload Resume (PDF)",
                        subtitle: "We extract details to build your site.",
                        onTap: _pickAndExtractPdf,
                        isLoading: _isReadingPdf,
                      ),

                      const SizedBox(height: 20),

                      // Actions (Visible only after upload)
                      if (_extractedText != null) ...[
                        Skeletonizer(
                          enabled: aiService.isLoading,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildActionCard(
                                  icon: Icons.remove_red_eye,
                                  title: "View Data",
                                  subtitle: "Check extracted info",
                                  onTap: _showExtractedData,
                                  isSmall: true,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildActionCard(
                                  icon: Icons.sync,
                                  title: "Sync & Gen",
                                  subtitle: "Create Website",
                                  onTap: _generatePortfolio,
                                  isSmall: true,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Spacer(),
                      if (aiService.isLoading)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("AI is crafting your website...")
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isSmall = false,
    Color color = const Color(0xFF6A11CB),
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: isSmall ? 20 : 30,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: isSmall ? 20 : 30),
            ),
            const SizedBox(height: 15),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmall ? 16 : 18), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (!isSmall) ...[
              const SizedBox(height: 5),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (ctx) => FutureBuilder<Map<String, dynamic>?>(
          future: auth.getUserData(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Center(child: Text("Profile")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150'), // Default Avatar
                  ),
                  const SizedBox(height: 20),
                  Text(data?['username'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(auth.currentUser?.email ?? "", style: const TextStyle(color: Colors.grey)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    auth.signOut();
                  },
                  child: const Text("Log Out", style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Close"),
                ),
              ],
            );
          }
      ),
    );
  }
}