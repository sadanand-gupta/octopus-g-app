import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/portfolio_api_service.dart';
import 'portfolio_preview_screen.dart';

class ResumePreviewScreen extends StatefulWidget {
  final Map<String, dynamic> resumeData;

  const ResumePreviewScreen({super.key, required this.resumeData});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  final PortfolioApiService _portfolioService = PortfolioApiService();
  bool _isGenerating = false;
  String _loadingMessage = '';

  // Selected color theme
  int _selectedThemeIndex = 0;

  // Color theme options
  final List<ColorTheme> _colorThemes = [
    ColorTheme(
      name: 'Ocean Blue',
      primary: '#1F5EFF',
      accent: '#3B82F6',
      dark: '#0F172A',
      colors: [Color(0xFF1F5EFF), Color(0xFF3B82F6), Color(0xFF0F172A)],
    ),
    ColorTheme(
      name: 'Emerald Green',
      primary: '#10B981',
      accent: '#34D399',
      dark: '#064E3B',
      colors: [Color(0xFF10B981), Color(0xFF34D399), Color(0xFF064E3B)],
    ),
    ColorTheme(
      name: 'Royal Purple',
      primary: '#8B5CF6',
      accent: '#A78BFA',
      dark: '#1E1B4B',
      colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFF1E1B4B)],
    ),
    ColorTheme(
      name: 'Sunset Orange',
      primary: '#F97316',
      accent: '#FB923C',
      dark: '#431407',
      colors: [Color(0xFFF97316), Color(0xFFFB923C), Color(0xFF431407)],
    ),
    ColorTheme(
      name: 'Rose Pink',
      primary: '#EC4899',
      accent: '#F472B6',
      dark: '#500724',
      colors: [Color(0xFFEC4899), Color(0xFFF472B6), Color(0xFF500724)],
    ),
    ColorTheme(
      name: 'Slate Gray',
      primary: '#64748B',
      accent: '#94A3B8',
      dark: '#0F172A',
      colors: [Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFF0F172A)],
    ),
  ];

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(18)), // was 24
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8), // was 12
              width: 32, // was 40
              height: 3, // was 4
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.all(14), // was 20
              child: Text(
                'Choose Color Theme',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Theme grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12), // was 20
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8, // was 12
                  mainAxisSpacing: 8, // was 12
                  childAspectRatio: 1,
                ),
                itemCount: _colorThemes.length,
                itemBuilder: (context, index) {
                  final theme = _colorThemes[index];
                  final isSelected = _selectedThemeIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedThemeIndex = index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6), // was 8
                        border: Border.all(
                          color:
                              isSelected ? theme.colors[0] : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Color circles
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: theme.colors
                                .map((color) => Container(
                                      width: 14, // was 20
                                      height: 14, // was 20
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1), // was 2
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 4), // was 8
                          // Theme name
                          Text(
                            theme.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colors[0]
                                  : AppColors.textSecondary,
                              fontSize: 12, // smaller font
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Selected indicator
                          if (isSelected) ...[
                            const SizedBox(height: 2), // was 4
                            Icon(Icons.check_circle,
                                color: theme.colors[0], size: 14), // was 16
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14), // was 24

            // Generate button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14), // was 20,24
              child: SizedBox(
                width: double.infinity,
                height: 44, // was 54
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _generatePortfolio();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _colorThemes[_selectedThemeIndex].colors[0],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // was 14
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 18), // was 20
                      SizedBox(width: 6), // was 10
                      Text(
                        'GENERATE WITH THIS THEME',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          fontSize: 13, // smaller font
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePortfolio() async {
    setState(() {
      _isGenerating = true;
      _loadingMessage = 'Preparing your data...';
    });

    try {
      final resumeText = widget.resumeData['rawText'] ?? '';

      if (resumeText.isEmpty || resumeText.length < 100) {
        throw Exception(
            'Resume text is too short. Please upload a valid resume.');
      }

      setState(() => _loadingMessage = 'AI is building your Vue.js portfolio...');

      // Pass selected theme and framework to API
      final selectedTheme = _colorThemes[_selectedThemeIndex];
      // --- MODIFICATION: Added 'framework' parameter ---
      final response = await _portfolioService.generatePortfolio(
        resumeText,
        primaryColor: selectedTheme.primary,
        accentColor: selectedTheme.accent,
        darkColor: selectedTheme.dark,
      );

      setState(() => _loadingMessage = 'Finalizing design...');

      await Future.delayed(const Duration(milliseconds: 500));

      // The API is expected to return a compiled, renderable HTML file
      // even when requesting a Vue.js framework.
      if (response.success && response.htmlCode.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PortfolioPreviewScreen(
                htmlCode: response.htmlCode,
                resumeData: widget.resumeData,
              ),
            ),
          );
        }
      } else {
        throw Exception(response.error ?? 'Failed to generate portfolio');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error: ${e.toString().replaceAll('Exception:', '').trim()}'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _generatePortfolio,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _loadingMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTheme = _colorThemes[_selectedThemeIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: 18), // was 20
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'Extracted Data',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18, // smaller font
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildExtractedDataView(),
          if (_isGenerating) _buildLoadingOverlay(),
        ],
      ),
      floatingActionButton: _isGenerating
          ? null
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14), // was 24
              child: Row(
                children: [
                  // Theme selector button
                  GestureDetector(
                    onTap: _showThemeSelector,
                    child: Container(
                      width: 42, // was 54
                      height: 42, // was 54
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6), // was 8
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.08), // less shadow
                            blurRadius: 6, // was 10
                            offset: const Offset(0, 2), // was 0,4
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Color preview circles
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: selectedTheme.colors
                                .take(3)
                                .map((color) => Container(
                                      width: 8, // was 12
                                      height: 8, // was 12
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // was 12
                  // Generate button
                  Expanded(
                    child: FloatingActionButton.extended(
                      onPressed: _showThemeSelector,
                      backgroundColor: selectedTheme.colors[0],
                      elevation: 3, // was 4
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6), // was 8
                      ),
                      label: const Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: Colors.white, size: 18), // was 20
                          SizedBox(width: 6), // was 10
                          Text(
                            'GENERATE PORTFOLIO',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: Colors.white,
                              fontSize: 13, // smaller font
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLoadingOverlay() {
    final selectedTheme = _colorThemes[_selectedThemeIndex];

    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(18), // was 32
          padding: const EdgeInsets.all(18), // was 32
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(6), // was 8
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // less shadow
                blurRadius: 12, // was 20
                offset: const Offset(0, 6), // was 0,10
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 38, // was 60
                height: 38, // was 60
                child: CircularProgressIndicator(
                  color: selectedTheme.colors[0],
                  strokeWidth: 2.2, // was 3
                ),
              ),
              const SizedBox(height: 14), // was 24
              const Text(
                'Creating Your Portfolio',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 15, // smaller font
                ),
              ),
              const SizedBox(height: 4), // was 8
              Text(
                _loadingMessage,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13, // smaller font
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8), // was 16
              // Theme colors indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: selectedTheme.colors
                    .map((color) => Container(
                          width: 14, // was 20
                          height: 3, // was 4
                          margin: const EdgeInsets.symmetric(
                              horizontal: 1), // was 2
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtractedDataView() {
    final data = widget.resumeData;
    final skills = (data['skills'] as List<dynamic>?) ?? [];
    final experience = (data['experience'] as List<dynamic>?) ?? [];
    final education = (data['education'] as List<dynamic>?) ?? [];
    final projects = (data['projects'] as List<dynamic>?) ?? [];
    final certifications = (data['certifications'] as List<dynamic>?) ?? [];
    final languages = (data['languages'] as List<dynamic>?) ?? [];
    final awards = (data['awards'] as List<dynamic>?) ?? [];
    final interests = (data['interests'] as List<dynamic>?) ?? [];
    final publications = (data['publications'] as List<dynamic>?) ?? [];
    final volunteerWork = (data['volunteerWork'] as List<dynamic>?) ?? [];
    final sectionsFound = (data['sectionsFound'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80), // Adjusted padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10), // was 16
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withOpacity(0.8)
                ],
              ),
              borderRadius: BorderRadius.circular(6), // was 8
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('${sectionsFound.length}', 'Sections'),
                _buildStatItem('${skills.length}', 'Skills'),
                _buildStatItem('${experience.length}', 'Jobs'),
                _buildStatItem('${education.length}', 'Degrees'),
              ],
            ),
          ),

          const SizedBox(height: 14), // was 24

          // Profile Section
          _buildSectionTitle('PROFILE INFORMATION'),
          const SizedBox(height: 8), // was 16
          _buildDataCard([
            _buildDataRow('Name', data['name'] ?? 'Not found'),
            if ((data['jobTitle'] ?? '').toString().isNotEmpty)
              _buildDataRow('Title', data['jobTitle']),
            _buildDataRow('Email', data['email'] ?? 'Not found'),
            _buildDataRow('Phone', data['phone'] ?? 'Not found'),
            if ((data['location'] ?? '').toString().isNotEmpty)
              _buildDataRow('Location', data['location']),
            if ((data['linkedin'] ?? '').toString().isNotEmpty)
              _buildDataRow('LinkedIn', data['linkedin']),
            if ((data['github'] ?? '').toString().isNotEmpty)
              _buildDataRow('GitHub', data['github']),
            if ((data['website'] ?? '').toString().isNotEmpty)
              _buildDataRow('Website', data['website']),
          ]),

          // Summary Section
          if ((data['summary'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('PROFESSIONAL SUMMARY'),
            const SizedBox(height: 8), // was 16
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10), // was 16
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6), // was 8
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                data['summary'] ?? '',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  height: 1.5, // was 1.6
                  fontSize: 13, // smaller font
                ),
              ),
            ),
          ],

          // Skills Section
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildSectionTitle('SKILLS (${skills.length})'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills.map<Widget>((skill) {
                return _buildSkillChip(skill.toString(), AppColors.primaryBlue);
              }).toList(),
            ),
          ],

          // Experience Section
          if (experience.isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('WORK EXPERIENCE (${experience.length})'),
            const SizedBox(height: 8), // was 16
            ...experience
                .map((exp) => _buildExperienceCard(exp as Map<String, dynamic>))
                .toList(),
          ],

          // Education Section
          if (education.isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('EDUCATION (${education.length})'),
            const SizedBox(height: 8), // was 16
            ...education
                .map((edu) => _buildEducationCard(edu as Map<String, dynamic>))
                .toList(),
          ],

          // Projects Section
          if (projects.isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('PROJECTS (${projects.length})'),
            const SizedBox(height: 8), // was 16
            ...projects
                .map((proj) => _buildProjectCard(proj as Map<String, dynamic>))
                .toList(),
          ],

          // Certifications Section
          if (certifications.isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('CERTIFICATIONS (${certifications.length})'),
            const SizedBox(height: 8), // was 16
            _buildListCard(
                certifications, Icons.verified_outlined, AppColors.primaryBlue),
          ],

          // Awards Section
          if (awards.isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('AWARDS & ACHIEVEMENTS (${awards.length})'),
            const SizedBox(height: 8), // was 16
            _buildListCard(awards, Icons.emoji_events_outlined, Colors.amber),
          ],

          // Languages Section
          if (languages.isNotEmpty) ...[
            const SizedBox(height: 18),
            _buildSectionTitle('LANGUAGES (${languages.length})'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: languages.map<Widget>((lang) {
                return _buildSkillChip(lang.toString(), AppColors.accentRed);
              }).toList(),
            ),
          ],

          // Publications Section
          if (publications.isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('PUBLICATIONS (${publications.length})'),
            const SizedBox(height: 8), // was 16
            _buildListCard(
                publications, Icons.article_outlined, AppColors.textSecondary),
          ],

          // Volunteer Work Section
          if (volunteerWork.isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('VOLUNTEER WORK (${volunteerWork.length})'),
            const SizedBox(height: 8), // was 16
            _buildListCard(
                volunteerWork, Icons.volunteer_activism_outlined, Colors.green),
          ],

          // Interests Section
          if (interests.isNotEmpty) ...[
            const SizedBox(height: 18), // was 32
            _buildSectionTitle('INTERESTS & HOBBIES'),
            const SizedBox(height: 8), // was 16
            Wrap(
              spacing: 6, // was 8
              runSpacing: 6, // was 8
              children: interests.map<Widget>((interest) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6), // was 14,8
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(6), // was 8
                  ),
                  child: Text(interest.toString(),
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13)),
                );
              }).toList(),
            ),
          ],

          // Raw Text Section
          const SizedBox(height: 18), // was 32
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'RAW EXTRACTED TEXT (${data['totalLines'] ?? 0} lines)',
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                  fontSize: 13),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10), // was 16
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(6), // was 8
                ),
                child: SelectableText(
                  data['rawText'] ?? '',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4, // was 1.6
                      fontFamily: 'monospace',
                      fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 15)), // smaller font
        Text(label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 2,
            fontSize: 12));
  }

  Widget _buildDataCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10), // was 14
          border: Border.all(color: AppColors.divider)),
      child: Column(children: children),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // was 16,14
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 60, // was 80
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> exp) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8), // was 12
      padding: const EdgeInsets.all(10), // was 16
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6), // was 8
          border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28, // was 40
                height: 28, // was 40
                decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)), // was 8
                child: const Icon(Icons.work_outline,
                    color: AppColors.primaryBlue, size: 16), // was 20
              ),
              const SizedBox(width: 8), // was 12
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exp['title'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 13)),
                    if ((exp['company'] ?? '').toString().isNotEmpty)
                      Text(exp['company'] ?? '',
                          style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if ((exp['duration'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4), // was 8
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: AppColors.textSecondary), // was 14
                const SizedBox(width: 3), // was 4
                Text(exp['duration'] ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ],
          if ((exp['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 6), // was 12
            Text(exp['description'] ?? '',
                style: const TextStyle(
                    color: AppColors.textPrimary, height: 1.4, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> edu) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8), // was 12
      padding: const EdgeInsets.all(10), // was 16
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6), // was 8
          border: Border.all(color: AppColors.divider)),
      child: Row(
        children: [
          Container(
            width: 28, // was 40
            height: 28, // was 40
            decoration: BoxDecoration(
                color: AppColors.accentLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)), // was 8
            child: const Icon(Icons.school_outlined,
                color: AppColors.accentRed, size: 16), // was 20
          ),
          const SizedBox(width: 8), // was 12
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu['degree'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 13)),
                if ((edu['institution'] ?? '').toString().isNotEmpty)
                  Text(edu['institution'] ?? '',
                      style: const TextStyle(
                          color: AppColors.primaryBlue, fontSize: 12)),
                if ((edu['year'] ?? '').toString().isNotEmpty)
                  Text(edu['year'] ?? '',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> proj) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.folder_outlined,
                    color: Colors.purple, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(proj['name'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontSize: 13))),
            ],
          ),
          if ((proj['technologies'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(proj['technologies'] ?? '',
                style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontStyle: FontStyle.italic,
                    fontSize: 12)),
          ],
          if ((proj['description'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(proj['description'] ?? '',
                style: const TextStyle(
                    color: AppColors.textPrimary, height: 1.4, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _buildListCard(List<dynamic> items, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6), // was 8
          border: Border.all(color: AppColors.divider)),
      child: Column(
        children: items.asMap().entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 8), // was 16,12
            decoration: BoxDecoration(
              border: entry.key < items.length - 1
                  ? const Border(bottom: BorderSide(color: AppColors.divider))
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: iconColor, size: 15), // was 18
                const SizedBox(width: 8), // was 12
                Expanded(
                    child: Text(entry.value.toString(),
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            height: 1.3,
                            fontSize: 12))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

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
//  in projects card some ui issue and some unnessary code remove that and give me complete file code