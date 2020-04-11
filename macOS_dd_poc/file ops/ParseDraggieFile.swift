//
//  ParseComplexDraggie.swift
//  Gregg Jaskiewicz
//
//  Created by Gregg Jaskiewicz on 10/07/2017.
//

import Foundation

extension String {
    func countInstances(of stringToFind: String, stopAfter: Int = Int.max) -> Int {
        var stringToSearch = self
        var count = 0
        while let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive) {
            stringToSearch = stringToSearch.replacingCharacters(in: foundRange, with: "")
            count += 1

            if count >= stopAfter {
                break
            }
        }
        return count
    }
}

final class ParseDraggieFile {

    private let draggieData: Data

    init(draggieFileData: Data) throws {
        self.draggieData = draggieFileData
    }

    init(draggieFilePath: String) throws {
        let draggiePath = URL(fileURLWithPath: draggieFilePath)

        guard let data = try? Data.init(contentsOf: draggiePath , options: .mappedRead) else {
            throw NSError()
        }

        self.draggieData = data
    }

    var reassembleVerification = false

    func parse() -> DraggieData? {

        let timeStart = Date()
        let draggieParsed = try? JSONDecoder().decode(DraggieData.self, from: self.draggieData)
        let timeEnd = Date()

        let interval = timeEnd.timeIntervalSince(timeStart)
        print("parse took: \(interval)")

        guard let draggie = draggieParsed else {
            return nil
        }

        return draggie
    }
}
