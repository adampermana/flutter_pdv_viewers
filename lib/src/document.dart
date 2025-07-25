import 'dart:async';
import 'dart:io';

// import 'package:advance_pdf_viewer/src/page.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../advance_pdv_viewer.dart';

/// A class that represents a PDF document and provides methods to load and interact with PDF files.
/// 
/// This class allows you to load PDF documents from various sources including:
/// - Local files
/// - URLs with optional headers and cache management
/// - Asset files bundled with the application
/// 
/// Example usage:
/// ```dart
/// // Load from file
/// File pdfFile = File('/path/to/document.pdf');
/// PDFDocument document = await PDFDocument.fromFile(pdfFile);
/// 
/// // Load from URL
/// PDFDocument document = await PDFDocument.fromURL('https://example.com/document.pdf');
/// 
/// // Load from assets
/// PDFDocument document = await PDFDocument.fromAsset('assets/document.pdf');
/// 
/// // Get a specific page
/// PDFPage page = await document.get(page: 1);
/// ```
class PDFDocument {
  static const MethodChannel _channel =
      MethodChannel('flutter_plugin_pdf_viewer');

  String? _filePath;
  
  /// The total number of pages in the PDF document.
  late int count;
  
  final _pages = <PDFPage>[];
  bool _preloaded = false;
  
  /// Gets the file path of the loaded PDF document.
  /// 
  /// Returns `null` if no document has been loaded yet.
  String? get filePath => _filePath;

  /// Load a PDF File from a given File.
  /// 
  /// This method loads a PDF document from a local file and returns a [PDFDocument] instance.
  /// The method will throw an [Exception] if the file cannot be read or is not a valid PDF.
  /// 
  /// Parameters:
  /// - [file]: The [File] object pointing to the PDF file to be loaded.
  /// 
  /// Returns:
  /// A [Future] that completes with a [PDFDocument] instance.
  /// 
  /// Throws:
  /// - [Exception] if the PDF file cannot be read or parsed.
  /// 
  /// Example:
  /// ```dart
  /// File pdfFile = File('/path/to/document.pdf');
  /// try {
  ///   PDFDocument document = await PDFDocument.fromFile(pdfFile);
  ///   print('PDF loaded with ${document.count} pages');
  /// } catch (e) {
  ///   print('Error loading PDF: $e');
  /// }
  /// ```
  static Future<PDFDocument> fromFile(File file) async {
    final document = PDFDocument();
    document._filePath = file.path;
    try {
      final pageCount = await _channel
          .invokeMethod('getNumberOfPages', {'filePath': file.path});
      document.count = document.count = int.parse(pageCount as String);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  /// Load a PDF File from a given URL.
  /// 
  /// This method downloads a PDF file from the specified URL and saves it in the cache.
  /// The cached file is then used to create a [PDFDocument] instance.
  /// 
  /// Parameters:
  /// - [url]: The URL string pointing to the PDF file to be downloaded and loaded.
  /// - [headers]: Optional HTTP headers to include with the download request.
  /// - [cacheManager]: Optional custom [CacheManager] for cache configuration. 
  ///   If not provided, uses [DefaultCacheManager].
  /// 
  /// Returns:
  /// A [Future] that completes with a [PDFDocument] instance.
  /// 
  /// Throws:
  /// - [Exception] if the PDF file cannot be downloaded, cached, or parsed.
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   PDFDocument document = await PDFDocument.fromURL(
  ///     'https://example.com/document.pdf',
  ///     headers: {'Authorization': 'Bearer token'},
  ///   );
  ///   print('PDF loaded from URL with ${document.count} pages');
  /// } catch (e) {
  ///   print('Error loading PDF from URL: $e');
  /// }
  /// ```
  static Future<PDFDocument> fromURL(String url,
      {Map<String, String>? headers, CacheManager? cacheManager}) async {
    // Download into cache
    final f = await (cacheManager ?? DefaultCacheManager())
        .getSingleFile(url, headers: headers);
    final document = PDFDocument();
    document._filePath = f.path;
    try {
      final pageCount =
          await _channel.invokeMethod('getNumberOfPages', {'filePath': f.path});
      document.count = document.count = int.parse(pageCount as String);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  /// Load a PDF File from the application's assets folder.
  /// 
  /// This method loads a PDF file that has been bundled with the application in the assets folder.
  /// The asset file is first copied to a temporary location before being loaded.
  /// 
  /// Parameters:
  /// - [asset]: The asset path relative to the assets folder (e.g., 'assets/document.pdf').
  /// 
  /// Returns:
  /// A [Future] that completes with a [PDFDocument] instance.
  /// 
  /// Throws:
  /// - [Exception] if the asset file cannot be found, parsed, or loaded.
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   PDFDocument document = await PDFDocument.fromAsset('assets/manual.pdf');
  ///   print('PDF loaded from assets with ${document.count} pages');
  /// } catch (e) {
  ///   print('Error loading PDF from assets: $e');
  /// }
  /// ```
  /// 
  /// Note: Make sure the PDF file is properly declared in your `pubspec.yaml` assets section.
  static Future<PDFDocument> fromAsset(String asset) async {
    File file;
    try {
      final dir = await getApplicationDocumentsDirectory();
      file = File("${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf");
      final data = await rootBundle.load(asset);
      final bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    final document = PDFDocument();
    document._filePath = file.path;
    try {
      final pageCount = await _channel
          .invokeMethod('getNumberOfPages', {'filePath': file.path});
      document.count = document.count = int.parse(pageCount as String);
    } catch (e) {
      throw Exception('Error reading PDF!');
    }
    return document;
  }

  /// Load and return a specific page from the PDF document.
  /// 
  /// This method retrieves a specific page from the PDF document and returns it as a [PDFPage] instance.
  /// If pages have been preloaded using [preloadPages], it returns the cached page; otherwise,
  /// it loads the page on demand.
  /// 
  /// Parameters:
  /// - [page]: The page number to load (1-based index). Must be greater than 0 and not exceed [count].
  /// - [onZoomChanged]: Optional callback function that gets called when the zoom level changes.
  /// - [zoomSteps]: Number of zoom steps available. Defaults to 3.
  /// - [minScale]: Minimum zoom scale factor. Defaults to 1.0.
  /// - [maxScale]: Maximum zoom scale factor. Defaults to 5.0.
  /// - [panLimit]: Pan limit factor for controlling pan boundaries. Defaults to 1.0.
  /// 
  /// Returns:
  /// A [Future] that completes with a [PDFPage] instance for the requested page.
  /// 
  /// Throws:
  /// - [AssertionError] if [page] is less than or equal to 0.
  /// 
  /// Example:
  /// ```dart
  /// PDFPage firstPage = await document.get(
  ///   page: 1,
  ///   onZoomChanged: (double zoom) => print('Zoom changed to: $zoom'),
  ///   minScale: 0.5,
  ///   maxScale: 3.0,
  /// );
  /// ```
  Future<PDFPage> get({
    int page = 1,
    final Function(double)? onZoomChanged,
    final int? zoomSteps,
    final double? minScale,
    final double? maxScale,
    final double? panLimit,
  }) async {
    assert(page > 0);
    if (_preloaded && _pages.isNotEmpty) return _pages[page - 1];
    final data = await _channel
        .invokeMethod('getPage', {'filePath': _filePath, 'pageNumber': page});
    return PDFPage(
      data as String?,
      page,
      onZoomChanged: onZoomChanged,
      zoomSteps: zoomSteps ?? 3,
      minScale: minScale ?? 1.0,
      maxScale: maxScale ?? 5.0,
      panLimit: panLimit ?? 1.0,
    );
  }

  /// Preload all pages of the PDF document into memory.
  /// 
  /// This method loads all pages of the PDF document into memory for faster access.
  /// After calling this method, subsequent calls to [get] will return cached pages
  /// instead of loading them on demand. This can improve performance for documents
  /// that will be accessed frequently, but will use more memory.
  /// 
  /// Parameters:
  /// - [onZoomChanged]: Optional callback function that gets called when the zoom level changes on any page.
  /// - [zoomSteps]: Number of zoom steps available for all pages. Defaults to 3.
  /// - [minScale]: Minimum zoom scale factor for all pages. Defaults to 1.0.
  /// - [maxScale]: Maximum zoom scale factor for all pages. Defaults to 5.0.
  /// - [panLimit]: Pan limit factor for controlling pan boundaries on all pages. Defaults to 1.0.
  /// 
  /// Returns:
  /// A [Future] that completes when all pages have been preloaded.
  /// 
  /// Example:
  /// ```dart
  /// await document.preloadPages(
  ///   onZoomChanged: (double zoom) => print('Zoom: $zoom'),
  ///   maxScale: 4.0,
  /// );
  /// print('All ${document.count} pages have been preloaded');
  /// ```
  /// 
  /// Warning: This method can consume significant memory for large PDF documents.
  /// Consider the memory implications before preloading documents with many pages.
  Future<void> preloadPages({
    final Function(double)? onZoomChanged,
    final int? zoomSteps,
    final double? minScale,
    final double? maxScale,
    final double? panLimit,
  }) async {
    int countvar = 1;
    for (final _ in List.filled(count, null)) {
      final data = await _channel.invokeMethod(
          'getPage', {'filePath': _filePath, 'pageNumber': countvar});
      _pages.add(PDFPage(
        data as String?,
        countvar,
        onZoomChanged: onZoomChanged,
        zoomSteps: zoomSteps ?? 3,
        minScale: minScale ?? 1.0,
        maxScale: maxScale ?? 5.0,
        panLimit: panLimit ?? 1.0,
      ));
      countvar++;
    }
    _preloaded = true;
  }

  /// Stream all pages of the PDF document.
  /// 
  /// This method returns a [Stream] that emits all pages of the PDF document.
  /// Each page is loaded asynchronously and emitted as a [PDFPage] object.
  /// 
  /// Parameters:
  /// - [onZoomChanged]: Optional callback function that gets called when the zoom level changes on any page.
  /// 
  /// Returns:
  /// A [Stream] of [PDFPage] objects representing all pages in the document.
  /// 
  /// Example:
  /// ```dart
  /// document.getAll().listen((PDFPage? page) {
  ///   if (page != null) {
  ///     print('Loaded page: ${page.number}');
  ///   }
  /// });
  /// ```
  /// 
  /// Note: This method may have performance implications for large documents.
  /// Consider using [get] for loading individual pages on demand instead.
  Stream<PDFPage?> getAll({final Function(double)? onZoomChanged}) {
    return Future.forEach<PDFPage?>(List.filled(count, null), (i) async {
      final data = await _channel
          .invokeMethod('getPage', {'filePath': _filePath, 'pageNumber': i});
      return PDFPage(
        data as String?,
        1,
        onZoomChanged: onZoomChanged,
      );
    }).asStream() as Stream<PDFPage?>;
  }

  /// Determines whether two [PDFDocument] instances are equal.
  /// 
  /// Two [PDFDocument] instances are considered equal if they have the same file path
  /// and are of the same runtime type.
  /// 
  /// Returns:
  /// `true` if the documents are equal, `false` otherwise.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PDFDocument &&
          runtimeType == other.runtimeType &&
          _filePath == other._filePath;

  /// Generates a hash code for this [PDFDocument] instance.
  /// 
  /// The hash code is based on the file path and page count.
  /// 
  /// Returns:
  /// An integer hash code for this instance.
  @override
  int get hashCode => Object.hash(_filePath, count);
}