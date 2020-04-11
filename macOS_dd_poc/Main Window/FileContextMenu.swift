//
//  FileContextMenu.swift
//  Draggie
//
//  Created by Gregg Jaskiewicz on 24/07/2019.
//  Copyright © 2019 k4lab. All rights reserved.
//

import Foundation
import AppKit

final class FileContextMenu: NSMenu {
    @IBOutlet weak var export: NSMenuItem!
    @IBOutlet weak var details: NSMenuItem!
    @IBOutlet weak var deleteItem: NSMenuItem!
}
