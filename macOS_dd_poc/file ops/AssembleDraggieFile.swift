//
//  AssembleDraggieFile.swift
//  Draggie
//
//  Created by Gregg Jaskiewicz on 07/07/2019.
//  Copyright © 2019 k4lab. All rights reserved.
//

import Foundation

final class AssembleDraggieFile {

    fileprivate let draggie_data: DraggieData

    init(draggie: DraggieData) {
        self.draggie_data = draggie
    }

    func assemble() -> Data {

        let rootDraggieElement = self.draggie_data
        let resultData = (try? JSONEncoder().encode(rootDraggieElement)) ?? ("[]".data(using: .utf8)!)

        return resultData
    }

}
