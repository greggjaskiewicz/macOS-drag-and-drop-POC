//
//  ElementDataSource.swift
//  DraggieViewer
//
//  Created by Gregg Jaskiewicz on 29/08/2017.
//  Copyright © 2017 k4lab. All rights reserved.
//

import Foundation
import Cocoa

let FileClassDraggieElement = "com.k4lab.draggie"

extension NSPasteboard.PasteboardType {
    static let draggieElement = NSPasteboard.PasteboardType(FileClassDraggieElement)
}

var AcceptedDraggableTypes: [NSPasteboard.PasteboardType] {
    get {
        let draggieFileType = NSPasteboard.PasteboardType.fileContentsType(forPathExtension: ".draggie")!
        return [draggieFileType,
                .draggieElement,
                kUTTypeFileURL as NSPasteboard.PasteboardType]
    }
}


protocol ElementDataSourceInterface: NSPasteboardWriting, NSPasteboardReading, NSSecureCoding {
    func name() -> String
    func displayDetail() -> String
    func suggestedFilename() -> String
}

final class ElementDataSource: NSObject, ElementDataSourceInterface {

    fileprivate let values: [Int]

    init(values: [Int]) {
        self.values = values
        super.init()
    }

    func allValues() -> [Int] {
        return self.values
    }

    func name() -> String {
        return "items \(self.values.first ?? 0)"
    }

    static var supportsSecureCoding: Bool {
        get {
            return true
        }
    }

    func displayDetail() -> String {
        return "foobar"
    }

    // Pasteboard, drag and drop stuff
    @objc convenience init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {

        return nil
        //        self.coordinates = [CLLocationCoordinate2D(latitude: CLLocationDegrees(floatLiteral: 0), longitude: CLLocationDegrees(floatLiteral: 0))]
    }

    //    @objc override func pasteboard(_ sender: NSPasteboard, provideDataForType type: NSPasteboard.PasteboardType) {
    //    }

    func asDraggieObject() -> DraggieData? {

        let draggie = self.values

        return draggie
    }

    func promiseExporter() -> NSFilePromiseProvider? {

        let filePromise = ElementDataSourceExporterPromiseProvider(fileType: FileClassDraggieElement, delegate: self)

        return filePromise
    }

    @objc class func readingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {

        let name = pasteboard.name;
        print("### name\(name), type: \(type)")

        if type == .draggieElement {
            return NSPasteboard.ReadingOptions.asKeyedArchive
        }

        return NSPasteboard.ReadingOptions.asData
    }

    @objc func readingOptions(forType type: String, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
        return .asKeyedArchive
    }

    @objc static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return AcceptedDraggableTypes
    }

    @objc func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return AcceptedDraggableTypes
    }

    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        print("## pasteboardPropertyList \(type)")
        if type == .draggieElement {
//            return try? PropertyListEncoder().encode(self)
//            let archived = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
//            return archived
        }

        return nil
    }

    fileprivate static let FilenameUnsafeCharacterSet = CharacterSet(charactersIn: #"\/:+?%*|"<>"# )

    func suggestedFilename() -> String {
        var name = self.name()

        if name.isEmpty == true {
            name = "file"
        }

        var fileName = "\(name).draggie"
        fileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        fileName = fileName.trimmingCharacters(in: ElementDataSource.FilenameUnsafeCharacterSet)

        return fileName
    }

    //NSCoding
    @objc func encode(with aCoder: NSCoder) {

        guard let draggie = self.asDraggieObject() else {
            return
        }

        print("# element data source Coder")

        let assembler = AssembleDraggieFile(draggie: draggie)
        let assembledData = assembler.assemble()

        aCoder.encode(assembledData, forKey: "draggie")
    }

    @objc init?(coder aDecoder: NSCoder) {

        print("# element data source init from coder")

        guard let draggie = aDecoder.decodeObject(forKey: "draggie") as? Data else {
            return nil
        }

        let parser = try? ParseDraggieFile(draggieFileData: draggie)
        guard let draggieObject = parser?.parse() else {
            return nil
        }

        self.values = draggieObject

        super.init()
    }

    func writingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.WritingOptions {
        return .promised
    }
}

extension ElementDataSource: NSPasteboardItemDataProvider {
    func pasteboard(_ pasteboard: NSPasteboard?, item: NSPasteboardItem, provideDataForType type: NSPasteboard.PasteboardType) {

        print("#NSPasteboardItemDataProvider \(pasteboard), \(item), \(type) ")
    }
}

extension ElementDataSource: NSFilePromiseProviderDelegate {
    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {

        let fileName = self.suggestedFilename()
        print("# suggested name: \(fileName)")
        return fileName
    }

    func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue {
        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .userInitiated)
        return queue
    }

    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, writePromiseTo url: URL, completionHandler: @escaping (Error?) -> Void) {

        filePromiseProvider.userInfo = [self]

        print("# exporting file to \(url)")

        guard let draggie = self.asDraggieObject() else {
            let error = NSError(domain: "draggie export failed", code: 1, userInfo: [:])
            completionHandler(error)
            return
        }

        let assembler = AssembleDraggieFile(draggie: draggie)
        let assembledData = assembler.assemble()

        do {
           try (assembledData as NSData).write(toFile: url.path, options: .atomicWrite)
        }
        catch {
            let returnedError = NSError(domain: "draggie write to \(url) failed", code: 2, userInfo: ["error":error])
            completionHandler(returnedError)
            return
        }

        completionHandler(nil)

        return
    }
}
