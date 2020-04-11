//
//  DraggieWizardView.swift
//  Draggie
//
//  Created by Gregg Jaskiewicz on 24/07/2019.
//
//

import Foundation
import AppKit

@objc protocol MenuOutlineViewDelegate: NSOutlineViewDelegate {
    func outlineView(outlineView: NSOutlineView, willOpenMenu menu: NSMenu?, forItem item: ElementDataSource)
    func outlineView(outlineView: NSOutlineView, willOpenMenu menu: NSMenu?, forItems items: [ElementDataSource])
}

final class DraggieWizardView: NSOutlineView {

    @IBOutlet weak var topLevelContextMenu: FileContextMenu!
    var location: NSNumber?

    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {

        guard let delegate = self.delegate as? MenuOutlineViewDelegate else {
            return
        }

        if self.selectedRowIndexes.count > 1 {
            var selectedItems: [ElementDataSource] = []
            let selectedRows = self.selectedRowIndexes
            for row in selectedRows {
                if let item = self.item(atRow: row) as? ElementDataSource {
                    selectedItems.append(item)
                }
            }
            if selectedItems.count > 0 {
                delegate.outlineView(outlineView: self, willOpenMenu: menu, forItems: selectedItems)
            }
        } else {
            let point = self.convert(event.locationInWindow, from: nil)
            let row = self.row(at: point)

            let item: ElementDataSource? = self.item(atRow: row) as? ElementDataSource

            guard let selectedItem = item else {
                return
            }

            delegate.outlineView(outlineView: self, willOpenMenu: menu, forItem: selectedItem)
        }
    }

    override func menu(for event: NSEvent) -> NSMenu? {

//        let point = self.convert(event.locationInWindow, from: nil)
//        let row = self.row(at: point)

        if let menu = super.menu(for: event) {
            return menu
        }

        return self.topLevelContextMenu
    }
}
