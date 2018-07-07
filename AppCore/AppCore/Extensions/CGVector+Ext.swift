//
//  CGVector+Ext.swift
//  AppCore
//
//  Created by GEORGE QUENTIN on 07/07/2018.
//  Copyright © 2018 Geo Games. All rights reserved.
//

public extension CGVector {

    var magnitude: CGFloat { return sqrt(dx * dx + dy * dy) }
}

public  func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
}

public func *(lhs: CGVector, rhs: Double) -> CGVector {
    return lhs * CGFloat(rhs)
}
