//
//  CGSize+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 08/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

import Foundation

public extension CGSize {

    public var half: CGSize {
        return CGSize(width: self.width / 2, height: self.height / 2)
    }
}
