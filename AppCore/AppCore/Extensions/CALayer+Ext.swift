//
//  CALayer+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 03/01/2019.
//  Copyright © 2019 Geo Games. All rights reserved.
//

import Foundation

public extension CALayer {
    
    // Recursive remove sublayers
    public func removeNestedSublayers<T>(with type : T.Type) {
        if let sublayers = self.sublayers {
            for sublayer in sublayers where sublayer is T {
                sublayer.removeNestedSublayers(with: type)
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
}
