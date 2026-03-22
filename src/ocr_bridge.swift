import Foundation
import Vision
import CoreGraphics

@_cdecl("perform_ocr")
func performOcr(
    imageData: UnsafePointer<UInt8>,
    width: UInt32,
    height: UInt32,
    languages: UnsafePointer<UnsafePointer<CChar>?>?,
    languageCount: UInt32
) -> OcrResult {
    let w = Int(width)
    let h = Int(height)
    let bytesPerRow = w

    let data = Data(bytes: imageData, count: w * h)
    guard let provider = CGDataProvider(data: data as CFData) else {
        return makeEmptyResult()
    }

    let colorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo(rawValue: 0)

    guard let cgImage = CGImage(
        width: w,
        height: h,
        bitsPerComponent: 8,
        bitsPerPixel: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: bitmapInfo,
        provider: provider,
        decode: nil,
        shouldInterpolate: false,
        intent: .defaultIntent
    ) else {
        return makeEmptyResult()
    }

    var resultText = ""
    var resultJson: [[String: String]] = []
    var totalConfidence: Double = 0

    let request = VNRecognizeTextRequest()
    request.usesLanguageCorrection = false
    request.recognitionLevel = VNRequestTextRecognitionLevel.accurate

    if #available(macOS 13.0, *) {
        request.automaticallyDetectsLanguage = true
    }

    if languageCount > 0, let langs = languages {
        var langArray: [String] = []
        for i in 0..<Int(languageCount) {
            if let ptr = langs[i] {
                langArray.append(String(cString: ptr))
            }
        }
        if !langArray.isEmpty {
            request.recognitionLanguages = langArray
        }
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
        try handler.perform([request])
    } catch {
        return makeEmptyResult()
    }

    guard let observations = request.results else {
        return makeEmptyResult()
    }

    for obs in observations {
        guard let candidate = obs.topCandidates(1).first else { continue }

        let text: String = candidate.string
        let confidence: Double = Double(candidate.confidence)
        let box: CGRect = obs.boundingBox

        resultText += text + "\n"
        totalConfidence += confidence

        var entry: [String: String] = [:]
        entry["text"] = text
        entry["conf"] = String(confidence)
        entry["left"] = String(Double(box.origin.x))
        entry["top"] = String(Double(box.origin.y))
        entry["width"] = String(Double(box.size.width))
        entry["height"] = String(Double(box.size.height))
        resultJson.append(entry)
    }

    let textC = strdup(resultText) ?? strdup("")!

    var jsonString = "[]"
    if let jsonData = try? JSONSerialization.data(withJSONObject: resultJson) {
        if let s = String(data: jsonData, encoding: .utf8) {
            jsonString = s
        }
    }
    let jsonC = strdup(jsonString) ?? strdup("[]")!

    return OcrResult(text: textC, json: jsonC, confidence: totalConfidence)
}

@_cdecl("free_ocr_result")
func freeOcrResult(_ result: OcrResult) {
    free(UnsafeMutablePointer(mutating: result.text))
    free(UnsafeMutablePointer(mutating: result.json))
}

func makeEmptyResult() -> OcrResult {
    return OcrResult(text: strdup("")!, json: strdup("[]")!, confidence: 0)
}