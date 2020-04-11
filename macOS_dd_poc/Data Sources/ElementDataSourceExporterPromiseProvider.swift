//
//  ElementDataSourceExporterPromiseProvider.swift
//  Draggie
//
//  Created by Gregg Jaskiewicz on 11/07/2019.
//  Copyright © 2019 k4lab. All rights reserved.
//

import Foundation
import AppKit

final class ElementDataSourceExporterPromiseProvider: NSFilePromiseProvider {

//    var fileType = String(kUTTypeData

    public override func writableTypes(for pasteboard: NSPasteboard)
        -> [NSPasteboard.PasteboardType] {

            var types = super.writableTypes(for: pasteboard)
            types.append(.draggieElement)

            print("#1 types: \(types)")

            return types
    }

    public override func writingOptions(forType type: NSPasteboard.PasteboardType,
                                        pasteboard: NSPasteboard)
        -> NSPasteboard.WritingOptions {

            if type == .draggieElement {
                print("#2 types: .promised, type: \(type)")
                return .promised
            }

            print("#3 type: \(type) - default")

            return super.writingOptions(forType: type, pasteboard: pasteboard)
    }

    public override func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType)
        -> Any? {

            if type == .draggieElement {
                guard let element = self.delegate as? ElementDataSource else {
                    print("#4 type == nil")
                    return nil
                }

                let pl = element.pasteboardPropertyList(forType: type)
                if let x = pl {
                    print("#5 property list: \(x)")
                } else {
                    print("#5 property list: nil")
                }
                return pl
            }

            print("#6 type: \(type)")
            return super.pasteboardPropertyList(forType: type)
    }
}
