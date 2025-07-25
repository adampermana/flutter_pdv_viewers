import 'package:flutter/material.dart';
import 'package:flutter_pdv_viewers/advance_pdv_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDV Viewers Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PDFViewerDemo(),
    );
  }
}

class PDFViewerDemo extends StatefulWidget {
  const PDFViewerDemo({super.key});

  @override
  State<PDFViewerDemo> createState() => _PDFViewerDemoState();
}

class _PDFViewerDemoState extends State<PDFViewerDemo> {
  PDFDocument? document;
  bool isLoading = false;
  String? errorMessage;
  int currentPage = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter PDV Viewers Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (document != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showDocumentInfo,
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLoadOptionsDialog,
        label: const Text('Load PDF'),
        icon: const Icon(Icons.picture_as_pdf),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error Loading PDF',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showLoadOptionsDialog,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (document == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No PDF Loaded',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to load a PDF document',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return PDFViewer(
      document: document!,
      indicatorText: Colors.white,
      indicatorBackground: Colors.blue.withValues(alpha: 0.8),
      pickerButtonColor: Colors.blue,
      pickerIconColor: Colors.white,
      showIndicator: true,
      showPicker: true,
      showNavigation: true,
      enableSwipeNavigation: true,
      scrollDirection: Axis.horizontal,
      lazyLoad: true,
      zoomSteps: 3,
      minScale: 0.5,
      maxScale: 3.0,
      panLimit: 1.0,
      indicatorPosition: IndicatorPosition.topRight,
      tooltip: const PDFViewerTooltip(
        first: "First Page",
        previous: "Previous",
        next: "Next",
        last: "Last Page",
        pick: "Go to Page",
        jump: "Jump to Page",
      ),
      onPageChanged: (page) {
        setState(() {
          currentPage = page + 1;
        });
      },
      progressIndicator: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  void _showLoadOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load PDF Document'),
        content: const Text('Choose how to load your PDF document:'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _loadFromAssets();
            },
            icon: const Icon(Icons.folder),
            label: const Text('From Assets'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _loadFromUrl();
            },
            icon: const Icon(Icons.cloud_download),
            label: const Text('From URL'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFromAssets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      document = null;
    });

    try {
      // Note: This is a demo - you would need to add a PDF file to assets
      // For now, we'll show an error message
      throw Exception('Please add a PDF file to assets folder and update this code');
      
      // Uncomment and modify this line when you have a PDF in assets:
      // final document = await PDFDocument.fromAsset('assets/sample.pdf');
      // setState(() {
      //   isLoading = false;
      // });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load PDF from assets: $e';
      });
    }
  }

  Future<void> _loadFromUrl() async {
    final urlController = TextEditingController(
      text: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    );

    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter PDF URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'URL',
            hintText: 'https://example.com/document.pdf',
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, urlController.text),
            child: const Text('Load'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        document = null;
      });

      try {
        document = await PDFDocument.fromURL(url);
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load PDF from URL: $e';
        });
      }
    }
  }

  void _showDocumentInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Total Pages:', '${document!.count}'),
            _buildInfoRow('Current Page:', '$currentPage'),
            _buildInfoRow('File Path:', document!.filePath ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}