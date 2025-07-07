import Flutter
import UIKit

public class FlutterPdvViewersPlugin: NSObject, FlutterPlugin {
    private static let kDirectory = "FlutterPluginPdfViewer"
    private static var kFileName = ""

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_plugin_pdf_viewer", binaryMessenger: registrar.messenger())
        let instance = FlutterPdvViewersPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        DispatchQueue.global(qos: .default).async {
            switch call.method {
            case "getPage":
                guard let arguments = call.arguments as? [String: Any],
                      let pageNumber = arguments["pageNumber"] as? Int,
                      let filePath = arguments["filePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                    return
                }
                result(self.getPage(filePath, ofPage: pageNumber))

            case "getNumberOfPages":
                guard let arguments = call.arguments as? [String: Any],
                      let filePath = arguments["filePath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                    return
                }
                result(self.getNumberOfPages(filePath))

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func getNumberOfPages(_ url: String) -> String? {
        let sourcePDFUrl = URL(fileURLWithPath: url)

        guard let sourcePDFDocument = CGPDFDocument(sourcePDFUrl as CFURL) else {
            return nil
        }

        let numberOfPages = sourcePDFDocument.numberOfPages

        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let temporaryDirectory = paths.first else {
            return nil
        }

        let filePathAndDirectory = temporaryDirectory.appendingPathComponent(Self.kDirectory)

        // Clear cache folder
        if FileManager.default.fileExists(atPath: filePathAndDirectory) {
            print("[FlutterPluginPDFViewer] Removing old documents cache")
            do {
                try FileManager.default.removeItem(atPath: filePathAndDirectory)
            } catch {
                print("Error removing cache: \(error)")
            }
        }

        // Create directory
        do {
            try FileManager.default.createDirectory(atPath: filePathAndDirectory,
                                                  withIntermediateDirectories: true,
                                                  attributes: nil)
        } catch {
            print("Create directory error: \(error)")
            return nil
        }

        // Generate random file name for this document
        Self.kFileName = UUID().uuidString
        print("[FlutterPluginPdfViewer] File has \(numberOfPages) pages")
        return String(numberOfPages)
    }

    private func getPage(_ url: String, ofPage pageNumber: Int) -> String? {
        let sourcePDFUrl = URL(fileURLWithPath: url)

        guard let sourcePDFDocument = CGPDFDocument(sourcePDFUrl as CFURL) else {
            return nil
        }

        let numberOfPages = sourcePDFDocument.numberOfPages
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let temporaryDirectory = paths.first else {
            return nil
        }

        let filePathAndDirectory = temporaryDirectory.appendingPathComponent(Self.kDirectory)

        var actualPageNumber = pageNumber
        if pageNumber > numberOfPages {
            actualPageNumber = numberOfPages
        }

        // Create directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(atPath: filePathAndDirectory,
                                                  withIntermediateDirectories: true,
                                                  attributes: nil)
        } catch {
            print("Create directory error: \(error)")
            return nil
        }

        guard let sourcePDFPage = sourcePDFDocument.page(at: actualPageNumber) else {
            return nil
        }

        let relativeOutputFilePath = "\(Self.kDirectory)/\(Self.kFileName)-\(actualPageNumber).png"
        let imageFilePath = temporaryDirectory.appendingPathComponent(relativeOutputFilePath)

        let sourceRect = sourcePDFPage.getBoxRect(.mediaBox)

        // Calculate resolution - Set DPI to 300
        let dpi: CGFloat = 300.0 / 72.0
        let width = sourceRect.size.width * dpi
        let height = sourceRect.size.height * dpi

        UIGraphicsBeginImageContext(CGSize(width: width, height: height))

        guard let currentContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        // Change interpolation settings
        currentContext.interpolationQuality = .high

        // Fill background with white color
        currentContext.setRGBFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        currentContext.fill(currentContext.clipBoundingBox)

        currentContext.translateBy(x: 0.0, y: height)
        currentContext.scaleBy(x: dpi, y: -dpi)

        currentContext.saveGState()
        currentContext.drawPDFPage(sourcePDFPage)
        currentContext.restoreGState()

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }

        UIGraphicsEndImageContext()

        // Write image to file
        guard let imageData = image.pngData() else {
            return nil
        }

        do {
            try imageData.write(to: URL(fileURLWithPath: imageFilePath))
        } catch {
            print("Error writing image: \(error)")
            return nil
        }

        return imageFilePath
    }
}