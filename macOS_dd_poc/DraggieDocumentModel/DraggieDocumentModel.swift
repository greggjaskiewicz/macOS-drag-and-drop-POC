//
//  DraggieData.swift
//  Draggie
//
//  Created by Gregg Jaskiewicz on 17/07/2019.
//  Copyright © 2019 k4lab. All rights reserved.
//

import Foundation

typealias DraggieData = [Int]

final class DraggieDocumentModel {

    fileprivate var draggieValue: DraggieData
    fileprivate let undoManager: UndoManager

    var documentUpdatedCallback = {}

    static let empty = DraggieDocumentModel(DraggieData([]), undoManager: UndoManager())

    func isEmpty() -> Bool {
        return self.draggieValue.count == 0
    }

    init(_ draggie: DraggieData, undoManager: UndoManager) {
        self.draggieValue = draggie
        self.undoManager = undoManager
    }

    func draggie() -> DraggieData {
        return self.draggieValue
    }

    func remove(item: ElementDataSourceInterface) {
        if let values = (item as? ElementDataSource)?.allValues() {
            for element in values {
                self.draggieValue.removeLast(element)
            }
        }
    }
}
