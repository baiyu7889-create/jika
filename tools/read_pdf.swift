#!/usr/bin/env swift

import AppKit
import Foundation
import PDFKit
import Vision

struct Options {
    var pdfPath = ""
    var pages: Set<Int>? = nil
    var outputPath: String? = nil
}

func usage() -> Never {
    fputs("Usage: read-pdf <file.pdf> [--pages 1,3-5] [--output result.txt]\n", stderr)
    exit(2)
}

func parsePages(_ value: String) -> Set<Int> {
    var result = Set<Int>()
    for part in value.split(separator: ",") {
        let bounds = part.split(separator: "-", maxSplits: 1).compactMap { Int($0) }
        if bounds.count == 1, bounds[0] > 0 {
            result.insert(bounds[0])
        } else if bounds.count == 2, bounds[0] > 0, bounds[1] >= bounds[0] {
            for page in bounds[0]...bounds[1] { result.insert(page) }
        }
    }
    return result
}

func parseOptions() -> Options {
    let args = Array(CommandLine.arguments.dropFirst())
    guard let first = args.first, !first.hasPrefix("--") else { usage() }
    var options = Options(pdfPath: first)
    var index = 1
    while index < args.count {
        switch args[index] {
        case "--pages":
            guard index + 1 < args.count else { usage() }
            options.pages = parsePages(args[index + 1])
            index += 2
        case "--output":
            guard index + 1 < args.count else { usage() }
            options.outputPath = args[index + 1]
            index += 2
        default:
            usage()
        }
    }
    return options
}

func recognize(page: PDFPage) throws -> String {
    let bounds = page.bounds(for: .mediaBox)
    let width: CGFloat = 1800
    let image = page.thumbnail(
        of: NSSize(width: width, height: width * bounds.height / bounds.width),
        for: .mediaBox
    )
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        throw NSError(domain: "read-pdf", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to render page"])
    }
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["zh-Hans", "en-US"]
    request.usesLanguageCorrection = true
    try VNImageRequestHandler(cgImage: cgImage).perform([request])
    return (request.results ?? [])
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: "\n")
}

let options = parseOptions()
let url = URL(fileURLWithPath: options.pdfPath)
guard let document = PDFDocument(url: url) else {
    fputs("Unable to open PDF: \(options.pdfPath)\n", stderr)
    exit(1)
}

var sections: [String] = []
for pageIndex in 0..<document.pageCount {
    let pageNumber = pageIndex + 1
    if let selected = options.pages, !selected.contains(pageNumber) { continue }
    guard let page = document.page(at: pageIndex) else { continue }
    do {
        let text = try recognize(page: page)
        sections.append("===== PAGE \(pageNumber) / \(document.pageCount) =====\n\(text)")
    } catch {
        fputs("Page \(pageNumber) failed: \(error.localizedDescription)\n", stderr)
        exit(1)
    }
}

let result = sections.joined(separator: "\n\n") + "\n"
if let outputPath = options.outputPath {
    try result.write(toFile: outputPath, atomically: true, encoding: .utf8)
    print("Wrote \(sections.count) page(s) to \(outputPath)")
} else {
    print(result, terminator: "")
}
