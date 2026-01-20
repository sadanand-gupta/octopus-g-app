import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/app_colors.dart';

class PortfolioPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> resumeData;
  final String htmlCode;

  PortfolioPreviewScreen({
    Key? key,
    required this.htmlCode,
    required this.resumeData,
  }) : super(key: key);

  @override
  State<PortfolioPreviewScreen> createState() => _PortfolioPreviewScreenState();
}

class _PortfolioPreviewScreenState extends State<PortfolioPreviewScreen>
    with SingleTickerProviderStateMixin {
  late final WebViewController _webViewController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// 🔹 Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    /// 🔹 WebView setup
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) {
            setState(() => _isLoading = false);
            _animationController.forward();
          },
        ),
      )
      ..loadHtmlString(widget.htmlCode);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🔹 Minimal professional AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your Portfolio',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
      ),

      /// 🔹 Fullscreen portfolio
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: WebViewWidget(controller: _webViewController),
            ),
          ),

          /// 🔹 Thin loading bar (elegant)
          if (_isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primaryBlue,
                backgroundColor: AppColors.divider,
              ),
            ),
        ],
      ),

      /// 🔹 Floating Deploy CTA
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Deploy logic
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deploy feature coming soon 🚀'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 6,
        icon: const Icon(Icons.rocket_launch, size: 18, color: Colors.white),
        label: const Text(
          'DEPLOY',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
