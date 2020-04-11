//
//  ElementDataSourcesExporter.swift
//  Draggie
//
//  Created by Gregg Jaskiewicz on 14/08/2019.
//  Copyright © 2019 k4lab. All rights reserved.
//

import Foundation

final class ElementDataSourcesExporter {
    private let data: [ElementDataSource]

    init(data: [ElementDataSource]) {
        self.data = data
    }

    func save(to path: String) {

        var elements: [Int] = []

        for element in self.data {
            let single = element.allValues()
            elements.append(contentsOf: single)
        }

        guard let data = try? JSONEncoder().encode(elements) else {
            return
        }

        do {
            try (data as NSData).write(toFile: path, options: .atomicWrite)
        }
        catch {
            return
        }

    }
}
