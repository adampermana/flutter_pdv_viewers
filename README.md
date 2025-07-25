# Flutter PDV Viewers

[![pub package](https://img.shields.io/pub/v/flutter_pdv_viewers.svg)](https://pub.dev/packages/flutter_pdv_viewers)
[![license](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/adampermana/flutter_pdv_viewers/blob/main/LICENSE)

A comprehensive Flutter plugin for viewing PDF documents with advanced features including zoom, pan, navigation controls, and customizable UI components.

## ☕ Support My Work
If you find my work valuable, your support means the world to me! It helps me focus on creating more, learning, and growing.
Thank you for your generosity and support! ☕

[![Sponsor](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/adampermana)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/adampermana)

## 🌟 Features

- **📄 Multiple PDF Loading Sources**
  - Load from local files
  - Load from network URLs with caching support
  - Load from application assets

- **🎮 Interactive Controls**
  - Zoom in/out with pinch gestures
  - Pan to navigate zoomed content
  - Swipe navigation between pages
  - Tap-to-zoom functionality

- **🧭 Navigation Features**
  - Built-in page navigation bar
  - Page picker dialog
  - Jump to first/last page
  - Navigate to previous/next page
  - Page indicator with customizable position

- **🎨 Customizable UI**
  - Customizable colors and styles
  - Configurable tooltip text
  - Custom navigation builder support
  - Flexible indicator positioning
  - Progress indicator customization

- **⚡ Performance Optimizations**
  - Lazy loading for better performance
  - Page preloading option
  - Efficient memory management
  - Smooth animations

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_pdv_viewers: ^0.0.1
```

Then run:

```bash
$ flutter pub get
```

## 🚀 Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_pdv_viewers/advance_pdv_viewer.dart';

class PDFViewerPage extends StatefulWidget {
  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  PDFDocument? document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    // Load from assets
    document = await PDFDocument.fromAsset('assets/sample.pdf');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: document != null
          ? PDFViewer(document: document!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
```

### Loading PDF from Different Sources

#### From Asset

```dart
PDFDocument document = await PDFDocument.fromAsset('assets/document.pdf');
```

#### From File

```dart
File file = File('/path/to/document.pdf');
PDFDocument document = await PDFDocument.fromFile(file);
```

#### From URL

```dart
PDFDocument document = await PDFDocument.fromURL(
  'https://example.com/document.pdf',
  headers: {'Authorization': 'Bearer token'}, // Optional
);
```

#### From URL with Custom Cache Manager

```dart
PDFDocument document = await PDFDocument.fromURL(
  'https://example.com/document.pdf',
  cacheManager: DefaultCacheManager(),
);
```

## 🎛️ Advanced Configuration

### Customizing the PDFViewer

```dart
PDFViewer(
  document: document,
  // Visual customization
  indicatorText: Colors.white,
  indicatorBackground: Colors.black54,
  pickerButtonColor: Colors.blue,
  pickerIconColor: Colors.white,
  
  // UI elements visibility
  showIndicator: true,
  showPicker: true,
  showNavigation: true,
  
  // Behavior settings
  enableSwipeNavigation: true,
  lazyLoad: true,
  scrollDirection: Axis.horizontal,
  
  // Zoom settings
  zoomSteps: 3,
  minScale: 0.5,
  maxScale: 4.0,
  panLimit: 1.0,
  
  // Position settings
  indicatorPosition: IndicatorPosition.topRight,
  
  // Custom widgets
  numberPickerConfirmWidget: Text('Confirm'),
  progressIndicator: CircularProgressIndicator(),
  
  // Custom tooltips
  tooltip: PDFViewerTooltip(
    first: "First Page",
    previous: "Previous Page",
    next: "Next Page",
    last: "Last Page",
    pick: "Go to Page",
    jump: "Jump to Page",
  ),
  
  // Callbacks
  onPageChanged: (page) {
    print('Current page: ${page + 1}');
  },
  
  // Custom navigation
  navigationBuilder: (context, pageNumber, totalPages, jumpToPage, animateToPage) {
    return Container(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.first_page),
            onPressed: () => jumpToPage(page: 0),
          ),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: pageNumber! > 1 
                ? () => animateToPage(page: pageNumber - 2)
                : null,
          ),
          Text('$pageNumber / $totalPages'),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: pageNumber < totalPages! 
                ? () => animateToPage(page: pageNumber)
                : null,
          ),
          IconButton(
            icon: Icon(Icons.last_page),
            onPressed: () => jumpToPage(page: totalPages! - 1),
          ),
        ],
      ),
    );
  },
)
```

### Working with Individual Pages

```dart
// Get a specific page
PDFPage page = await document.get(
  page: 1,
  onZoomChanged: (double zoom) {
    print('Zoom level: $zoom');
  },
  zoomSteps: 3,
  minScale: 0.5,
  maxScale: 4.0,
  panLimit: 1.0,
);

// Preload all pages for better performance
await document.preloadPages(
  onZoomChanged: (double zoom) {
    print('Page zoom: $zoom');
  },
  maxScale: 3.0,
);

// Stream all pages
document.getAll().listen((PDFPage? page) {
  if (page != null) {
    print('Loaded page: ${page.num}');
  }
});
```

### Page Picker Dialog

```dart
// Show page picker dialog
int? selectedPage = await showDialog<int>(
  context: context,
  builder: (BuildContext context) {
    return PagePicker(
      title: 'Go to Page',
      maxValue: document.count,
      initialValue: currentPage,
      numberPickerConfirmWidget: Icon(Icons.check),
    );
  },
);

if (selectedPage != null) {
  // Navigate to selected page
  jumpToPage(page: selectedPage - 1);
}
```

## 📚 API Reference

### PDFDocument

Main class for handling PDF documents.

#### Static Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `fromFile(File file)` | Load PDF from local file | `file`: File object |
| `fromURL(String url, {Map<String, String>? headers, CacheManager? cacheManager})` | Load PDF from URL | `url`: PDF URL, `headers`: HTTP headers, `cacheManager`: Cache configuration |
| `fromAsset(String asset)` | Load PDF from assets | `asset`: Asset path |

#### Instance Methods

| Method | Description | Parameters |
|--------|-------------|------------|
| `get({int page, Function(double)? onZoomChanged, ...})` | Get specific page | `page`: Page number (1-based), zoom configuration |
| `preloadPages({...})` | Preload all pages | Zoom and callback configuration |
| `getAll({Function(double)? onZoomChanged})` | Stream all pages | `onZoomChanged`: Zoom callback |

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `count` | `int` | Total number of pages |
| `filePath` | `String?` | Path to loaded PDF file |

### PDFViewer

Main widget for displaying PDF documents.

#### Constructor Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `document` | `PDFDocument` | Required | PDF document to display |
| `indicatorText` | `Color` | `Colors.white` | Page indicator text color |
| `indicatorBackground` | `Color` | `Colors.black54` | Page indicator background color |
| `showIndicator` | `bool` | `true` | Show/hide page indicator |
| `showPicker` | `bool` | `true` | Show/hide page picker button |
| `showNavigation` | `bool` | `true` | Show/hide navigation bar |
| `enableSwipeNavigation` | `bool` | `true` | Enable swipe gestures |
| `lazyLoad` | `bool` | `true` | Load pages on demand |
| `scrollDirection` | `Axis?` | `Axis.horizontal` | Scroll direction |
| `indicatorPosition` | `IndicatorPosition` | `topRight` | Page indicator position |
| `zoomSteps` | `int?` | `3` | Number of zoom steps |
| `minScale` | `double?` | `1.0` | Minimum zoom scale |
| `maxScale` | `double?` | `5.0` | Maximum zoom scale |
| `panLimit` | `double?` | `1.0` | Pan limit factor |
| `onPageChanged` | `ValueChanged<int>?` | `null` | Page change callback |

### PDFPage

Widget representing a single PDF page.

| Parameter | Type | Description |
|-----------|------|-------------|
| `imgPath` | `String?` | Path to page image |
| `num` | `int` | Page number |
| `onZoomChanged` | `Function(double)?` | Zoom change callback |
| `zoomSteps` | `int` | Number of zoom steps |
| `minScale` | `double` | Minimum zoom scale |
| `maxScale` | `double` | Maximum zoom scale |
| `panLimit` | `double` | Pan limit factor |

### IndicatorPosition

Enum for page indicator positioning:

- `IndicatorPosition.topLeft`
- `IndicatorPosition.topRight`
- `IndicatorPosition.bottomLeft`
- `IndicatorPosition.bottomRight`

### PDFViewerTooltip

Customizable tooltip text configuration:

```dart
PDFViewerTooltip(
  first: "First",      // First page button tooltip
  previous: "Previous", // Previous page button tooltip
  next: "Next",        // Next page button tooltip
  last: "Last",        // Last page button tooltip
  pick: "Pick a page", // Page picker dialog title
  jump: "Jump",        // Jump button tooltip
)
```

## 🎯 Examples

### Complete Example with Error Handling

```dart
import 'package:flutter/material.dart';
import 'package:flutter_pdv_viewers/advance_pdv_viewer.dart';

class AdvancedPDFViewer extends StatefulWidget {
  final String pdfUrl;

  const AdvancedPDFViewer({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _AdvancedPDFViewerState createState() => _AdvancedPDFViewerState();
}

class _AdvancedPDFViewerState extends State<AdvancedPDFViewer> {
  PDFDocument? document;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  Future<void> loadDocument() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      document = await PDFDocument.fromURL(widget.pdfUrl);
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load PDF: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced PDF Viewer'),
        actions: [
          if (document != null)
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Document Info'),
                    content: Text(
                      'Total Pages: ${document!.count}\n'
                      'Current Page: $currentPage\n'
                      'File Path: ${document!.filePath ?? 'N/A'}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadDocument,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return PDFViewer(
      document: document!,
      indicatorText: Colors.white,
      indicatorBackground: Colors.blue.withOpacity(0.8),
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
      tooltip: PDFViewerTooltip(
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
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }
}
```

### Custom Navigation Builder Example

```dart
PDFViewer(
  document: document,
  navigationBuilder: (context, pageNumber, totalPages, jumpToPage, animateToPage) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // First page button
          IconButton(
            icon: Icon(Icons.first_page),
            onPressed: pageNumber! > 1 
                ? () => jumpToPage(page: 0)
                : null,
          ),
          
          // Previous page button
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: pageNumber > 1 
                ? () => animateToPage(page: pageNumber - 2)
                : null,
          ),
          
          // Page info
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  // Show page picker
                  int? selectedPage = await showDialog<int>(
                    context: context,
                    builder: (context) => PagePicker(
                      title: 'Go to Page',
                      maxValue: totalPages!,
                      initialValue: pageNumber,
                    ),
                  );
                  
                  if (selectedPage != null) {
                    jumpToPage(page: selectedPage - 1);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pageNumber / $totalPages',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Next page button
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: pageNumber < totalPages! 
                ? () => animateToPage(page: pageNumber)
                : null,
          ),
          
          // Last page button
          IconButton(
            icon: Icon(Icons.last_page),
            onPressed: pageNumber < totalPages 
                ? () => jumpToPage(page: totalPages - 1)
                : null,
          ),
        ],
      ),
    );
  },
)
```

## 🔧 Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| Android | ✅ | Full support |
| iOS | ✅ | Full support |
| Web | ❌ | Not supported yet |
| Desktop | ❌ | Not supported yet |

## 📱 Minimum Requirements

- Flutter: `>=3.3.0`
- Dart: `>=3.3.0 <4.0.0`
- Android: API level 16+ (Android 4.1+)
- iOS: iOS 11.0+

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/flutter_pdv_viewers.git`
3. Create a feature branch: `git checkout -b my-new-feature`
4. Make your changes and add tests
5. Run tests: `flutter test`
6. Commit your changes: `git commit -am 'Add some feature'`
7. Push to the branch: `git push origin my-new-feature`
8. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ using Flutter
- Inspired by the need for a comprehensive PDF viewing solution
- Thanks to all contributors and the Flutter community

## 📞 Support

If you encounter any issues or have questions:

1. Check the [documentation](#-api-reference)
2. Search through [existing issues](https://github.com/adampermana/flutter_pdv_viewers/issues)
3. Create a [new issue](https://github.com/adampermana/flutter_pdv_viewers/issues/new) if needed

## 📈 Roadmap

- [ ] Web platform support
- [ ] Desktop platform support
- [ ] Text selection and search functionality
- [ ] Bookmark support
- [ ] Annotation features
- [ ] Dark mode support
- [ ] Performance improvements
- [ ] Accessibility enhancements

---

Made with ❤️ by [Adam Permana](https://github.com/adampermana)