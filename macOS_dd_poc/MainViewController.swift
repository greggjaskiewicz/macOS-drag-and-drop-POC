//
//  ViewController.swift
//  DraggieViewer
//
//  Created by Gregg Jaskiewicz on 13/07/2017.
//  Copyright © 2017 k4lab. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {

//    private lazy var destinationURL: URL = {
//        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("xDrops")
//        try? FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
//        return destinationURL
//    }()

    fileprivate var document: DraggieDocument? {
        return view.window?.windowController?.document as? DraggieDocument
    }

    private lazy var workQueue: OperationQueue = {
        let providerQueue = OperationQueue()
        providerQueue.qualityOfService = .userInitiated
        return providerQueue
    }()

    fileprivate var currentlySelectedElement: ElementDataSource?

    override var representedObject: Any? {

        get {
            guard self.currentDraggie.isEmpty() == false else {
                return nil
            }
            return self.currentDraggie
        }

        set {

            guard let draggieObject = newValue as? DraggieDocumentModel else {
                self.currentDraggie = DraggieDocumentModel.empty
                return
            }

            self.currentDraggie = draggieObject
        }
    }

    fileprivate var currentDraggie: DraggieDocumentModel = DraggieDocumentModel.empty {
        didSet {
            DispatchQueue.main.async { [weak self] in

                guard let strongSelf = self else {
                    return
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        strongSelf.documentElementTreeOutlineView?.reloadData()
                        strongSelf.documentElementTreeOutlineView?.deselectAll(strongSelf)
                    }
                }
            }
        }
    }

    private var currentFilePath: String?

    @IBOutlet weak var documentElementTreeOutlineView: NSOutlineView?

    private let NameTableColumn = NSUserInterfaceItemIdentifier("Name")
    private let DetailTableColumn = NSUserInterfaceItemIdentifier("Detail")

    fileprivate var preferencesChangedObserver: DataChangedObserver?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.documentElementTreeOutlineView?.registerForDraggedTypes(AcceptedDraggableTypes)
        self.documentElementTreeOutlineView?.registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String)])

        self.documentElementTreeOutlineView?.registerForDraggedTypes(NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) })
        self.documentElementTreeOutlineView?.registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String)])

        self.documentElementTreeOutlineView?.registerForDraggedTypes([.draggieElement])

        self.documentElementTreeOutlineView?.setDraggingSourceOperationMask(.private, forLocal: true)
        self.documentElementTreeOutlineView?.setDraggingSourceOperationMask(.copy, forLocal: false)
    }

    fileprivate func currentlySelectedElements() -> [ElementDataSource] {

        if let selection = self.documentElementTreeOutlineView?.selectedRowIndexes {

            var items: [ElementDataSource] = []

            for selectedIndex in selection {
                if let item = self.documentElementTreeOutlineView?.item(atRow: selectedIndex) as? ElementDataSource {
                    items.append(item)
                }
            }

            return items
        }

        return []
    }

    func refresh() {
        guard self.isViewLoaded == true else {
            return
        }
        self.documentElementTreeOutlineView?.reloadData()
    }

    fileprivate func createOverlayViewController() -> NSViewController? {
        let overlayStoryboardName = "LoadingOverlayViewController"

        let storyboardName = NSStoryboard.Name(stringLiteral: "Main")
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)

        let sceneIdentifier = NSStoryboard.SceneIdentifier(stringLiteral: overlayStoryboardName)
        guard let viewController = storyboard.instantiateController(withIdentifier: sceneIdentifier) as? NSViewController else {
            return nil
        }

        //        let blurFilter = CIFilter(name: "CIGaussianBlur")
        //        blurFilter?.setDefaults()
        //        blurFilter?.setValue(2.5, forKey: kCIInputRadiusKey)
        //        viewController.view.layer?.backgroundFilters?.append(blurFilter!)

        return viewController
    }
}

// NSDraggingDestination
extension ViewController: NSOutlineViewDataSource, NSOutlineViewDelegate, NSControlTextEditingDelegate {
    // Show all Routes, Waypoints and Tracks as sections?
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return self.currentDraggie.draggie().count
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {

        return false
    }

    public func child(_ index: Int, ofItem item: Any?) -> Any? {

        return nil
    }


    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {


        if index < self.currentDraggie.draggie().count {
            return self.currentDraggie.draggie()[index]
        }
        // should never be called
        return "end nil"
    }

    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        if let identifier = tableColumn?.identifier {
            switch(identifier) {
            case NameTableColumn:

                var name = ""
                if let element = (item as? Int) {
                    name = "\(element)"
                }

                return name

            case DetailTableColumn:
                return "Int"

            default:
                return ""
            }
        }

        return ""
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outline =  self.documentElementTreeOutlineView else {
            return
        }
        if let selection = self.documentElementTreeOutlineView?.selectedRowIndexes {

            for selectedIndex in selection {
                if let item = outline.item(atRow: selectedIndex) as? Int {
                    // do stuff

                }
            }
        }
    }
}

extension ViewController: NSDraggingDestination  {
/*
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {

        //        let pasteBoard = sender.draggingPasteboard
        //        let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]

        //        let canAccept = pasteBoard.canReadObject(forClasses: AcceptedDraggableTypes, options: [:])

        let supportedClasses = [
            NSFilePromiseReceiver.self,
            NSURL.self
        ]

        let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
            //            ,
            //            .urlReadingContentsConformToTypes: [ kUTTypeImage ]
        ]


        sender.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) { (draggingItem, _, _) in
            switch draggingItem.item {
            case let filePromiseReceiver as NSFilePromiseReceiver:
                filePromiseReceiver.receivePromisedFiles(atDestination: self.destinationURL, options: [:],
                                                         operationQueue: self.workQueue) { (fileURL, error) in
                                                            if let error = error {
                                                                print("error: \(error)")
                                                                //                                                                self.handleError(error)
                                                            } else {
                                                                print("promised fileURL: \(fileURL)")
                                                                //                                                                self.handleFile(at: fileURL)
                                                            }
                }
            case let fileURL as URL:
                print("fileURL: \(fileURL)")
            //                self.handleFile(at: fileURL)
            default: break
            }
        }

        return .copy
    }
*/
    func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }

    //    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
    //        return true
    //    }
//
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {

        let copy = (info.draggingSourceOperationMask == .copy)
        let source = (info.draggingSource) ?? ""
        let pasteboard = info.draggingPasteboard

        print("# acceptDrop: is this a copy: \(copy), source: \(source)")

        if let sourceOutlineView = (source as? NSOutlineView) {

            DispatchQueue.main.async {
                sourceOutlineView.backgroundColor = .blue
            }

            // get selected items, since its in the same space - and copy the items - simples ¯\_(ツ)_/¯
            // find first track
            let selection = outlineView.selectedRowIndexes

            for selectedIndex in selection {
                if let item = sourceOutlineView.item(atRow: selectedIndex) as? ElementDataSource {
                    print("### item: \(item)")
                }
            }
//            return true

            let items = pasteboard.pasteboardItems ?? []
            print("### items: \(items)")
            let types = pasteboard.types ?? []

            info.enumerateDraggingItems(options: .concurrent,
                                        for: sourceOutlineView,
                                        classes: [ElementDataSource.self],
                                        searchOptions: [:]) { (item, int, obj) in
                                            print("### \(item), \(int), \(obj)")
            }

            for item in items {
                for type in types {
//
//                    if let l = item.string(forType: type), l.count > 0 {
//                        print("## \(l) of type \(type)" ?? "N/A")
//                    }

                    if let d = item.data(forType: type), d.count > 0 {
                        print("## data \(d), type: \(type)")

                        if let string = NSString(data: d, encoding: String.Encoding.utf8.rawValue) {
                            print("### string \(string)")
                        }

                        if let element = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ElementDataSource.self, from: d) {
                            print("### \(element)")
                        }


                    }

                    if type == .draggieElement {
                        print("######")
                    }

                }
            }

            return true

//
//            var fileType: NSPasteboard.PasteboardType?
//            print("pasteboard types: \(types)")
//
//            print("# internal")
//
//            var pasteboardFiles: [AnyObject]?
//
//            for type in types {
//                let x = pasteboard.propertyList(forType: type) as? [AnyObject]
//                if x?.isEmpty == false  {
//                    fileType = type
//                    pasteboardFiles = x
//                    break
//                }
//            }
//
//            guard let files = pasteboardFiles else {
//                return false
//            }
//
//            for file in files {
//                print("file \(file)")
//                if let f = file as? NSPasteboardWriting, let type = fileType {
//                    print("file: \(f)")
//
//                    let x = f.pasteboardPropertyList(forType: type)
//                    print("property list \(x)")
//                }
//            }


            // internal
        } else {
            print("# external")
            // external
/*
            let fileURLType = NSPasteboard.PasteboardType.fileURL

            let NSFilenamesPboardTypeTemp = NSPasteboard.PasteboardType("NSFilenamesPboardType")

            guard pasteboard.types?.contains(fileURLType) == true else {
                return false
            }

            guard let files = pasteboard.propertyList(forType: fileURLType) as? [AnyObject] else {
                return false
            }

            let type = files.self

            print("files \(files) , type \(type)")
*/
/*
 else if( [pboard.types containsObject:NSFilenamesPboardType] ) {

        NSPasteboard *filenamePasteBoard = [info draggingPasteboard];
        if ( [pboard.types containsObject:NSFilenamesPboardType] ) {

            NSArray *files = [filenamePasteBoard propertyListForType:NSFilenamesPboardType];
            BOOL returnCode = YES;

 */

            // are we interested in any of the objects?
//            let fileURLType = kUTTypeFileURL as NSPasteboard.PasteboardType
            let filenamePboardType = NSPasteboard.PasteboardType.fileURL
            guard let pasteboardTypes = pasteboard.types, Set(pasteboardTypes).intersection(AcceptedDraggableTypes).count > 0 else {
                return false
            }

//            guard Set([fileURLType]).intersection(AcceptedDraggableTypes).count > 0 else {
//                return false
//            }

            var accepted = false

//            let numberOfItems = info.numberOfValidItemsForDrop
            guard let items = pasteboard.pasteboardItems else {
                return false
            }

            var itemFileNames: [String] = []

            for item in items {

                // try filenames first
                guard let fileObject = item.propertyList(forType: filenamePboardType) as? String else {
                    continue
                }

                let fileURL = URL(string:fileObject)

                guard let fileString = fileURL?.path else {
                    continue
                }
                itemFileNames.append(fileString)

            }

            var draggieParsers: [ParseDraggieFile] = []

            for file in itemFileNames {

                //                    let fileURL = URL(fileURLWithPath: file)
                //                    let data = NSData(contentsOf: fileURL)
                //                    print("datacount \(data?.count)")

                //                    let file = fileURL.path

                //                    guard (file as NSString).pathExtension.lowercased() == "draggie" else {
                //                        continue
                //                    }

                guard let parser = try? ParseDraggieFile(draggieFilePath: file) else {
                    continue
                }

                guard let draggieParser = try? ParseDraggieFile(draggieFilePath: file) else {
                    continue
                }

                draggieParsers.append(draggieParser)

                // do this in the background in the future
                accepted = true
            }

            guard let document = self.document else {
                return false
            }

            document.addContentsOf(draggieParsers) {
                DispatchQueue.main.async {
                    self.documentElementTreeOutlineView?.reloadData()
                }
            }

            print("# external")
            return accepted
        }

        // don't accept drops for now
//        return false

/*
        let supportedClasses = [
            NSFilePromiseReceiver.self,
            NSURL.self
        ]

        let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
            //            ,
            //            .urlReadingContentsConformToTypes: [ kUTTypeImage ]
        ]

        var url: URL?

        info.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) { (draggingItem, _, _) in
            switch draggingItem.item {
            case let filePromiseReceiver as NSFilePromiseReceiver:
                filePromiseReceiver.receivePromisedFiles(atDestination: self.destinationURL, options: [:],
                                                         operationQueue: self.workQueue) { (fileURL, error) in
                                                            if let error = error {
                                                                print("error: \(error)")
                                                                //                                                                self.handleError(error)
                                                            } else {
                                                                print("fileURL: \(fileURL)")
                                                                //                                                                self.handleFile(at: fileURL)
                                                            }
                }
            case let fileURL as URL:
                url = fileURL
                print("fileURL: \(fileURL)")
                return
            default:
                break
            }
        }

        guard let fileURL = url else {
            return false
        }

        guard let data = try? Data(contentsOf: fileURL, options: .alwaysMapped) else {
            return false
        }
        print("data length \(data.count)")

        let parser = try? ParseDraggieFile(draggieFileData: data)

        guard parser?.fastVerification() == true else {
            print("not Draggie dragged in")
            return false
        }

        //        print("draggie: \(draggie)")

//        return true

        //        NSPasteboard* pboard = [info draggingPasteboard];
        let pasteBoard = info.draggingPasteboard

        if let urlString = pasteBoard.string(forType: NSPasteboard.PasteboardType(kUTTypeFileURL as String)) {
            let url = NSURL(fileURLWithPath: urlString)
            print("file url \(url)")

            let data = try? Data(contentsOf: url as URL, options: .alwaysMapped)
            print("data length \(data?.count)")

            return true

            // try loading the draggie file

        }

        return false


        let firstItem = pasteBoard.pasteboardItems?.first
        if let fileUrlData = pasteBoard.data(forType: NSPasteboard.PasteboardType(rawValue: "public.file-url")) {
            let fileUrlString = String(data: fileUrlData, encoding: .utf8)
            print("file url \(fileUrlString)")
        }

        print("\(firstItem)")

        guard let draggedItem = item else {
            return false
        }

        print("item type -> \(draggedItem)")

        return false
 */
    }

    func outlineView(_ outlineView: NSOutlineView, namesOfPromisedFilesDroppedAtDestination dropDestination: URL, forDraggedItems items: [Any]) -> [String] {

        let elements = items.compactMap({ $0 as? ElementDataSource})

        let elementsName = elements.compactMap({ $0.suggestedFilename() })

        return elementsName
    }


    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {

//        print("# validateDrop destination vc: \(info.draggingDestinationWindow?.contentViewController)")

        guard let _ = item as? ElementDataSource else {
            return .generic
        }

        if (info.draggingDestinationWindow?.contentViewController)?.isKind(of: ViewController.self) == true {
            return .copy
        }

        return .every
/*
        print("validateDrop validateDrop \(info) ")

        let supportedClasses = [
            NSFilePromiseReceiver.self,
            NSURL.self
        ]

        let searchOptions: [NSPasteboard.ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
            //            .urlReadingContentsConformToTypes: [ kUTTypeImage ]
        ]


        info.enumerateDraggingItems(options: [], for: nil, classes: supportedClasses, searchOptions: searchOptions) { (draggingItem, _, _) in
            switch draggingItem.item {
            case let filePromiseReceiver as NSFilePromiseReceiver:
                filePromiseReceiver.receivePromisedFiles(atDestination: self.destinationURL, options: [:],
                                                         operationQueue: self.workQueue) { (fileURL, error) in
                                                            if let error = error {
                                                                print("error: \(error)")
                                                                //                                                                self.handleError(error)
                                                            } else {
                                                                print("fileURL: \(fileURL)")
                                                                //                                                                self.handleFile(at: fileURL)
                                                            }
                }
            case let fileURL as URL:
                print("fileURL: \(fileURL)")
            //                self.handleFile(at: fileURL)
            default: break
            }
        }

        return .every
 */
    }

    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
        print("### outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]")
    }

    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        print("### outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard)")
        let elements = items.compactMap({$0 as? ElementDataSource})
        print("### elements count (\(elements.count))")
        return elements.count > 0
    }

    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        print("### outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation)")
    }

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        print("### outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any)")

        guard let element = item as? ElementDataSource else {
            return nil
        }

        return element.promiseExporter()
    }
}

final class MainDocumentWindowController: NSWindowController {
    @IBOutlet weak var addItemToolbarItem: NSToolbarItem?

}

extension ViewController: MenuOutlineViewDelegate {

    @IBAction func contextMenuDeleteItem(_ x: Any) {

        let items = self.currentlySelectedElements()
        guard items.count > 0 else {
            return
        }

        let prompt = NSAlert()
        prompt.informativeText = "Do you want to delete selected element(s)?"
        _ = prompt.addButton(withTitle: "Delete")
        _ = prompt.addButton(withTitle: "Cancel")
        prompt.alertStyle = .warning
        let output = prompt.runModal()
        guard output == .alertFirstButtonReturn else {
            return
        }

        // confirm from users
        for item in items {
            self.currentDraggie.remove(item: item)
        }

        self.refresh()

        //  TODO: delete element
    }

    @IBAction func contextMenuItemsExport(_ x: Any) {

        let items = self.currentlySelectedElements()
        guard items.count > 0 else {
            return
        }

        guard let window = self.view.window else {
            return
        }

        let suggestedName = items.first?.suggestedFilename() ?? "file.draggie"

        // get the save dialog to the user
        DispatchQueue.main.async {

            let savePanel = NSSavePanel()
            savePanel.nameFieldStringValue = suggestedName

            savePanel.beginSheetModal(for: window, completionHandler: { (modalResponse) in

                guard modalResponse == .OK else {
                    return
                }

                guard let path = savePanel.url?.path else {
                    return
                }

                DispatchQueue.global(qos: .userInitiated).async {
                    let exporter = ElementDataSourcesExporter(data: items)
                    exporter.save(to: path)
                }
            })

        }
    }

    func outlineView(outlineView: NSOutlineView, willOpenMenu menu: NSMenu?, forItem item: ElementDataSource) {

        guard let contextMenu = menu as? FileContextMenu else {
            return
        }

        contextMenu.deleteItem.isEnabled = true
        contextMenu.details.isEnabled = true
        contextMenu.export.isEnabled = true

        print("for item \(item)")
    }

    func outlineView(outlineView: NSOutlineView, willOpenMenu menu: NSMenu?, forItems items: [ElementDataSource]) {

        guard let contextMenu = menu as? FileContextMenu else {
            return
        }
        contextMenu.deleteItem.isEnabled = true
        contextMenu.details.isEnabled = false
        contextMenu.export.isEnabled = true

        print("for items \(items)")
    }

    @IBAction func addItemAction(_ sender: Any) {
        self.document?.addRandomElement()
        self.refresh()
    }
}
