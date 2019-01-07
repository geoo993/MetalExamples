//
//  IndexPath+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 04/01/2019.
//  Copyright © 2019 Geo Games. All rights reserved.
//

import Foundation

extension IndexPath {
    static func fromRow(_ row: Int) -> IndexPath {
        return IndexPath(row: row, section: 0)
    }
}
