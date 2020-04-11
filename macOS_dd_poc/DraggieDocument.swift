//
//  Document.swift
//  Draggie Viewer
//
//  Created by Gregg Jaskiewicz on 27/09/2017.
//  Copyright © 2017 k4lab. All rights reserved.
//

import Cocoa

class DraggieDocument: NSDocument {

    private var failed = false

    // use representedObject, which is built into the nsviewcontroller
    private var draggie: DraggieData? {
        didSet {
            DispatchQueue.main.async {
                guard let viewController = self.windowControllers.first?.contentViewController as? ViewController else {
                    return
                }

                if let draggie = self.draggie {
                    let documentModel = DraggieDocumentModel(draggie, undoManager: self.undoManager ?? UndoManager() )
                    documentModel.documentUpdatedCallback = { [weak self] in
                        self?.documentRefreshed()
                    }
                    viewController.representedObject = documentModel

                } else {
                    viewController.representedObject = nil
                }
            }
        }
    }

    override func fileNameExtension(forType typeName: String, saveOperation: NSDocument.SaveOperationType) -> String? {
        if typeName == "com.k4lab.draggie" {
            return "draggie"
        }
        return nil
    }

    override init() {
        super.init()

        self.draggie = DraggieData([])
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    fileprivate func documentRefreshed() {
        guard let viewController = self.windowControllers.first?.contentViewController as? ViewController else {
            return
        }

        viewController.refresh()
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)

        guard let viewController = windowController.contentViewController as? ViewController else {
            return
        }

        if let draggie = self.draggie {
            viewController.representedObject = DraggieDocumentModel(draggie, undoManager: self.undoManager ?? UndoManager() )
        } else {
            viewController.representedObject = nil
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

        guard DraggieDocument.validFormats.contains(typeName) == true else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }

        if let draggie = self.draggie {
            let exporter = AssembleDraggieFile(draggie: draggie)
            let data = exporter.assemble()
            if data.count > 0 {
                return data
            } else {
                throw NSError(domain: NSOSStatusErrorDomain, code: vTypErr, userInfo: nil)
            }
        } else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
    }

    override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
        return true
    }

    override var isEntireFileLoaded: Bool {
        get {
            return self.draggie != nil
        }
    }

    fileprivate var draggieParser: ParseDraggieFile?

    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {

        guard DraggieDocument.validFormats.contains(typeName) == true else {
            throw NSError(domain: NSOSStatusErrorDomain, code: badFileFormat, userInfo: nil)
        }

        guard let data = fileWrapper.regularFileContents else {
            throw NSError(domain: NSOSStatusErrorDomain, code: notEnoughBufferSpace, userInfo: nil)
        }

        self.draggie = nil

        DispatchQueue.global(qos: .userInitiated).async {
            self.draggie = nil
            self.draggieParser = try? ParseDraggieFile(draggieFileData: data)

            if let draggie = self.draggieParser?.parse() {
                self.continueAsynchronousWorkOnMainThread {
                    self.draggie = draggie
                    let name = String(format: "(%d)", draggie.count)
                    if name.isEmpty == false {
                        self.displayName = name
                    }
                }
            } else {
                // TODO, show error message to user
//                throw NSError(domain: NSOSStatusErrorDomain, code: badFormat, userInfo: nil)
            }
        }
    }

    fileprivate static var validFormats = ["JSON", "com.k4lab.draggie"]

    override func close() {

        for controller in self.windowControllers {
            self.removeWindowController(controller)
        }
        self.draggie = nil

        super.close()
    }

    open override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        if DraggieDocument.validFormats.contains(typeName) {
            return true
        }

        return false
    }

    func addContentsOf(_ draggieParsers: [ParseDraggieFile], completed: @escaping ()->()) {

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            var currentDraggie = strongSelf.draggie

            for draggieParser in draggieParsers {

                guard let draggie = draggieParser.parse() else {
                    return
                }

                if var documentDraggie = currentDraggie {
                    documentDraggie.append(contentsOf: draggie)
                    currentDraggie = documentDraggie
                } else {
                    currentDraggie = draggie
                }
            }

            strongSelf.draggie = currentDraggie

            completed()

//            strongSelf.isDocumentEdited = true
        }
    }

    func addRandomElement() {
        self.draggie?.append(Int(arc4random()))
    }

    func foo() {
        self.undoManager?.registerUndo(withTarget: self, handler: { (target) in
        })
    }

//    override func read(from data: Data, ofType typeName: String) throws {
//        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
//        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
//        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
//
//        let parser = try? ParseDraggieFile(draggieFileData: data)
//        if let draggie = parser?.parse() {
//            self.draggie = draggie
//        } else {
//            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
//        }
//    }

}

