import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class GeneratedSiteScreen extends StatefulWidget {
  final String htmlCode;

  const GeneratedSiteScreen({super.key, required this.htmlCode});

  @override
  State<GeneratedSiteScreen> createState() => _GeneratedSiteScreenState();
}

class _GeneratedSiteScreenState extends State<GeneratedSiteScreen> {
  late WebViewController _controller;
  bool showUI = true; // toggle state

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_wrapHtml(widget.htmlCode));
  }

String _wrapHtml(String html) {
  return """
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">

<style>
  * {
    box-sizing: border-box;
    max-width: 100%;
  }

  body {
    margin: 0;
    padding: 0;
    width: 100%;
  }

  /* Make images responsive */
  img {
    width: 100%;
    height: auto;
  }

  /* Responsive text */
  h1, h2, h3, p {
    word-wrap: break-word;
  }

  /* Flex layouts wrap automatically */
  .row {
    display: flex;
    flex-wrap: wrap;
    width: 100%;
  }

  /* Prevent overflow */
  .container {
    width: 100%;
    padding: 10px;
  }

  /* Media query for mobile */
  @media (max-width: 600px) {
    .section {
      padding: 10px !important;
    }
    .card {
      width: 100% !important;
      margin-bottom: 12px;
    }
  }
</style>
</head>

<body>
$html
</body>
</html>
""";
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Portfolio Preview")),

      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toggleButton("See UI", showUI, () {
                setState(() => showUI = true);
              }),
              _toggleButton("View Code", !showUI, () {
                setState(() => showUI = false);
              }),
            ],
          ),

          const SizedBox(height: 10),

          /// UI Preview or Code View
          Expanded(
            child: showUI
                ? WebViewWidget(controller: _controller)
                : Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black,
              child: SingleChildScrollView(
                child: SelectableText(
                  widget.htmlCode,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),

          /// Copy Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.htmlCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("HTML Copied!")),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text("Copy Code"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
        decoration: BoxDecoration(
          color: active ? Colors.deepPurple : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
