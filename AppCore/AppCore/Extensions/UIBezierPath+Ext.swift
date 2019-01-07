
// based on https://github.com/ImJCabus/UIBezierPath-Length
// https://stackoverflow.com/questions/3051760/how-to-get-a-list-of-points-from-a-uibezierpath
// https://stackoverflow.com/questions/12992462/how-to-get-the-cgpoints-of-a-cgpath
// http://www.swiftexample.info/search/bezier-curve-linear-interpolation/3
// https://andreygordeev.com/2017/03/13/uibezierpath-closest-point/

import Foundation
import UIKit

public extension UIBezierPath {
    
    public struct BezierSubpath {
        public var startPoint: CGPoint = CGPoint.zero
        public var controlPoint1: CGPoint = CGPoint.zero
        public var controlPoint2: CGPoint = CGPoint.zero
        public var endPoint: CGPoint = CGPoint.zero
        public var length: CGFloat = 0.0
        public var type: CGPathElementType = CGPathElementType(rawValue: 0)!
        public var description: String {
            switch type {
            case .moveToPoint:
                return "MoveTo(\(endPoint.format(Decimals.one))"
            case .addLineToPoint:
                return "AddLine(from: \(startPoint.format(Decimals.one)), to: \(endPoint.format(Decimals.one)))"
            case .addQuadCurveToPoint:
                return """
                AddQuadCurve(from: \(startPoint.format(Decimals.one)),
                control: \(controlPoint1.format(Decimals.one)),
                to: \(endPoint.format(Decimals.one)))
                """
            case .addCurveToPoint:
                return """
                AddCubicCurve(from: \(startPoint.format(Decimals.one)), \
                control1: \(controlPoint1.format(Decimals.one)), \
                control2: \(controlPoint2.format(Decimals.one)), \
                to: \(endPoint.format(Decimals.one)))
                """
            case .closeSubpath:
                return "ClosePath(from: \(startPoint.format(Decimals.one)), to: \(endPoint.format(Decimals.one))"
            }
        }
    }
    
    // MARK: - Math helpers
    public func linearLineLength(fromPoint: CGPoint, toPoint: CGPoint) -> CGFloat {
        return CGFloat(sqrtf(powf(Float(toPoint.x - fromPoint.x), 2) + powf(Float(toPoint.y - fromPoint.y), 2)))
    }

    public func linearBezierPoint(t: Float, start: CGPoint, end: CGPoint) -> CGPoint {
        let dx: CGFloat = end.x - start.x
        let dy: CGFloat = end.y - start.y
        let px: CGFloat = start.x + (CGFloat(t) * dx)
        let py: CGFloat = start.y + (CGFloat(t) * dy)
        return CGPoint(x: px, y: py)
    }

   
    public static func cubicBezierCurveFactors(t:CGFloat) -> (CGFloat,CGFloat,CGFloat,CGFloat){
        let t1 = pow(1.0-t, 3.0)
        let t2 = 3.0*pow(1.0-t,2.0)*t
        let t3 = 3.0*(1.0-t)*pow(t,2.0)
        let t4 = pow(t, 3.0)
        
        return  (t1,t2,t3,t4)
    }
    
    
    public static func quadBezierCurveFactors(t:CGFloat) -> (CGFloat,CGFloat,CGFloat){
        let t1 = pow(1.0-t,2.0)
        let t2 = 2.0*(1-t)*t
        let t3 = pow(t, 2.0)
        
        return (t1,t2,t3)
    }
    
    // Quadratic Bezier Curve
    public static func bezierCurvef(with t:CGFloat,p0:CGFloat,c1:CGFloat,p1:CGFloat) -> CGFloat{
        let factors = quadBezierCurveFactors(t: t)
        return (factors.0*p0) + (factors.1*c1) + (factors.2*p1)
    }
    
    
    // Quadratic Bezier Curve
    public static func bezierCurve(with t:CGFloat,p0:CGPoint,c1:CGPoint,p1:CGPoint) -> CGPoint{
        let x = bezierCurvef(with: t, p0: p0.x, c1: c1.x, p1: p1.x)
        let y = bezierCurvef(with: t, p0: p0.y, c1: c1.y, p1: p1.y)
        return CGPoint(x: x, y: y)
    }
    
    // Cubic Bezier Curve
    public static func bezierCurvef(with t:CGFloat,p0:CGFloat, c1:CGFloat, c2:CGFloat, p1:CGFloat) -> CGFloat{
        let factors = cubicBezierCurveFactors(t: t)
        return (factors.0*p0) + (factors.1*c1) + (factors.2*c2) + (factors.3*p1)
    }
    
    
    // Cubic Bezier Curve
    public static func bezierCurve(with t: CGFloat, p0:CGPoint, c1:CGPoint, c2: CGPoint, p1: CGPoint) -> CGPoint{
        let x = bezierCurvef(with: t, p0: p0.x, c1: c1.x, c2: c2.x, p1: p1.x)
        let y = bezierCurvef(with: t, p0: p0.y, c1: c1.y, c2: c2.y, p1: p1.y)
        return CGPoint(x: x, y: y)
    }
    
    
    // Cubic Bezier Curve Length
    public static func bezierCurveLength(p0:CGPoint,c1:CGPoint, c2:CGPoint, p1:CGPoint) -> CGFloat{
        let steps = 12 // on greater samples, more presicion
        
        var current  = p0
        var previous = p0
        var length:CGFloat = 0.0
        
        for i in 1...steps{
            let t = CGFloat(i) / CGFloat(steps)
            current = bezierCurve(with: t, p0: p0, c1: c1, c2: c2, p1: p1)
            length += previous.distance(to: current)
            previous = current
        }
        
        return length
    }
    
    
    // Quadratic Bezier Curve Length
    public static func bezierCurveLength(p0:CGPoint,c1:CGPoint, p1:CGPoint) -> CGFloat{
        let steps = 12 // on greater samples, more presicion
        
        var current  = p0
        var previous = p0
        var length:CGFloat = 0.0
        
        for i in 1...steps{
            let t = CGFloat(i) / CGFloat(steps)
            current = bezierCurve(with: t, p0: p0, c1: c1, p1: p1)
            length += previous.distance(to: current)
            previous = current
        }
        return length
    }
    
    
    /*  Cubic Bezier Curve
     *  http://ericasadun.com/2013/03/25/calculating-bezier-points/
     */
    public func cubicBezier(t: Float, start: Float, c1: Float, c2: Float, end: Float) -> Float {
        let t_ = CGFloat((1.0 - t))
        let tt_: CGFloat = t_ * t_
        let ttt_: CGFloat = t_ * t_ * t_
        let tt = CGFloat(t * t)
        let ttt = CGFloat(t * t * t)
        let offset : CGFloat = 3.0
        let t1 = CGFloat(start) * ttt_
        let t2 = offset * CGFloat(c1) * tt_ * CGFloat(t)
        let t3 = offset * CGFloat(c2) * t_ * tt
        let t4 = CGFloat(end) * ttt
        
        return Float(t1 + t2 + t3 + t4)
    }
    
    public func cubicBezierPoint(t: Float, start: CGPoint, c1: CGPoint, c2: CGPoint, end: CGPoint) -> CGPoint {
        let x: Float = cubicBezier(t: t, start: Float(start.x), c1: Float(c1.x), c2: Float(c2.x), end: Float(end.x))
        let y: Float = cubicBezier(t: t, start: Float(start.y), c1: Float(c1.y), c2: Float(c2.y), end: Float(end.y))
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    // Cubic Bezier Curve Length
    public func cubicCurveLength(fromPoint: CGPoint, toPoint: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) -> CGFloat {
        let iterations: Int = 100
        var length: CGFloat = 0
        for idx in 0..<iterations {
            let t = Float(idx) * Float(1.0 / Float(iterations))
            let tt: Float = t + Float(1.0 / Float(iterations))
            let p: CGPoint = cubicBezierPoint(t: t, start: fromPoint, c1: controlPoint1, c2: controlPoint2, end: toPoint)
            let pp: CGPoint = cubicBezierPoint(t: tt, start: fromPoint, c1: controlPoint1, c2: controlPoint2, end: toPoint)
            length += linearLineLength(fromPoint: p, toPoint: pp)
        }
        return length
    }

    /*  Quadratic Bezier Curve
     *  http://ericasadun.com/2013/03/25/calculating-bezier-points/
     */
    public func quadBezier(t: Float, start: Float, c1: Float, end: Float) -> Float {
        let t_ = CGFloat((1.0 - t))
        let tt_: CGFloat = t_ * t_
        let tt = CGFloat(t * t)
        let offset : CGFloat = 2.0
        return Float(CGFloat(start) * tt_ + offset * CGFloat(c1) * t_ * CGFloat(t) + CGFloat(end) * tt)
    }
    
    public func quadBezierPoint(t: Float, start: CGPoint, c1: CGPoint, end: CGPoint) -> CGPoint {
        let x: Float = quadBezier(t: t, start: Float(start.x), c1: Float(c1.x), end: Float(end.x))
        let y: Float = quadBezier(t: t, start: Float(start.y), c1: Float(c1.y), end: Float(end.y))
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }

    // Quadratic Bezier Curve Length
    public func quadCurveLength(fromPoint: CGPoint, toPoint: CGPoint, controlPoint: CGPoint) -> CGFloat {
        let iterations: Int = 100
        var length: CGFloat = 0
        for idx in 0..<iterations {
            let t : Float = Float(idx) * Float(1.0 / Float(iterations))
            let tt: Float = t + Float(1.0 / Float(iterations))
            let p: CGPoint = quadBezierPoint(t: t, start: fromPoint, c1: controlPoint, end: toPoint)
            let pp: CGPoint = quadBezierPoint(t: tt, start: fromPoint, c1: controlPoint, end: toPoint)
            length += linearLineLength(fromPoint: p, toPoint: pp)
        }
        return length
    }
    
    public var length: CGFloat {
        var pathLength:CGFloat = 0.0
        var current = CGPoint.zero
        var first   = CGPoint.zero
        
        self.cgPath.forEach{ element in
            pathLength += element.distance(to: current, startPoint: first)
            
            if element.type == .moveToPoint{
                first = element.point
            }
            if element.type != .closeSubpath{
                current = element.point
            }
        }
        return pathLength
    }
    
    public var magnitude: CGFloat {
        let subpathCount: Int = countSubpaths
        var subpaths = [BezierSubpath](repeating: BezierSubpath(), count: subpathCount)
        subpaths = extractSubpaths(subpaths)
        var length: CGFloat = 0.0
        for i in 0..<subpathCount {
            length += subpaths[i].length
        }
        return length
    }

    
    public func point(atPercentOfLength percent: CGFloat) -> CGPoint {
        var percentage = percent
        
        if percentage < 0.0 {
            percentage = 0.0
        }
        else if percentage > 1.0 {
            percentage = 1.0
        }
        
        let subpathCount: Int = countSubpaths
        var subpaths = [BezierSubpath](repeating: BezierSubpath(), count: subpathCount)
        subpaths = extractSubpaths(subpaths)
        var length: CGFloat = 0.0
        for i in 0..<subpathCount {
            length += subpaths[i].length
        }
        let pointLocationInPath: CGFloat = length * percentage
        var currentLength: CGFloat = 0
        var subpathContainingPoint = BezierSubpath()
        for i in 0..<subpathCount {
            if currentLength + subpaths[i].length >= pointLocationInPath {
                subpathContainingPoint = subpaths[i]
                break
            }
            else {
                currentLength += subpaths[i].length
            }
        }
        let lengthInSubpath: CGFloat = pointLocationInPath - currentLength
        if subpathContainingPoint.length == 0 {
            return subpathContainingPoint.endPoint
        }
        else {
            let t: CGFloat = lengthInSubpath / subpathContainingPoint.length
            return point(atPercent: t, of: subpathContainingPoint)
        }
    }

    func forEachPathElement(body: @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>)
            -> Void = { info, element in
                let body = unsafeBitCast(info, to: Body.self)
                body(element.pointee)
        }
        // print("path element memory: ", MemoryLayout.size(ofValue: body))
        let safeBody = withoutActuallyEscaping(body) { escapableBody in
            unsafeBitCast(escapableBody, to: UnsafeMutableRawPointer.self)
        }
        cgPath.apply(info: safeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }
    
    public var countSubpaths: Int {
        var count: Int = 0
        
        forEachPathElement { element in
            if element.type != CGPathElementType.moveToPoint {
                count += 1
            }
        }
        if count == 0 {
            return 1
        }
        return count
    }
 
    public func extractSubpaths(_ subpathArray: [BezierSubpath]) -> [BezierSubpath]{

        var subpaths = subpathArray, currentPoint = CGPoint.zero, i: Int = 0
        
        //enumerateSubpaths({(_ element: CGPathElement) -> Void in
        forEachPathElement { element in
            let type: CGPathElementType = element.type
            let points = element.points
            var subLength: CGFloat = 0.0
            var endPoint = CGPoint.zero
            var subpath = BezierSubpath()
            subpath.type = type
            subpath.startPoint = currentPoint
            /*
             *  All paths, no matter how complex, are created through a combination of these path elements.
             */
            switch type {
            case .moveToPoint:
                endPoint = points[0]
            case .addLineToPoint:
                endPoint = points[0]
                subLength = linearLineLength(fromPoint: currentPoint, toPoint: endPoint)
            case .addQuadCurveToPoint:
                endPoint = points[1]
                let controlPoint = points[0]
                subLength = quadCurveLength(fromPoint: currentPoint, toPoint: endPoint,
                                                         controlPoint: controlPoint)
                subpath.controlPoint1 = controlPoint
            case .addCurveToPoint:
                endPoint = points[2]
                let controlPoint1 = points[0]
                let controlPoint2 = points[1]
                subLength = cubicCurveLength(fromPoint: currentPoint, toPoint: endPoint,
                                                          controlPoint1: controlPoint1,
                                                          controlPoint2: controlPoint2)
                subpath.controlPoint1 = controlPoint1
                subpath.controlPoint2 = controlPoint2
            default:
                break
            }
            subpath.length = subLength
            subpath.endPoint = endPoint
            if type != .moveToPoint {
                subpaths[i] = subpath
                i += 1
            }
            currentPoint = endPoint
        }
        //})
        if i == 0 {
            subpaths[0].length = 0.0
            subpaths[0].endPoint = currentPoint
        }
        
        return subpaths
    }

    public var extractSubpaths: [BezierSubpath] {
        let subpathCount: Int = countSubpaths
        let subpaths = [BezierSubpath](repeating: BezierSubpath(), count: subpathCount)
        return extractSubpaths(subpaths)
    }
        
    public func point(atPercent t: CGFloat, of subpath: BezierSubpath) -> CGPoint {
        var p = CGPoint.zero
        switch subpath.type {
        case .addLineToPoint:
            p = linearBezierPoint(t: Float(t), start: subpath.startPoint, end: subpath.endPoint)
        case .addQuadCurveToPoint:
            p = quadBezierPoint(t: Float(t), start: subpath.startPoint, c1: subpath.controlPoint1, end: subpath.endPoint)
        case .addCurveToPoint:
            p = cubicBezierPoint(t: Float(t), start: subpath.startPoint, c1: subpath.controlPoint1, c2: subpath.controlPoint2, end: subpath.endPoint)
        default:
            break
        }
        return p
    }

    /// Rotate path anticlockwise around an anchor point defaulting to the center
    public func rotate(inRadians radians: CGFloat, aroundAnchor anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        let tX = bounds.minX + bounds.width * anchor.x
        let tY = bounds.minY + bounds.height * anchor.y
        // Move anchor point to origin
        apply(CGAffineTransform(translationX: -tX, y: -tY))
        // Rotate
        apply(CGAffineTransform(rotationAngle: radians))
        // Move origin back to anchor point
        apply(CGAffineTransform(translationX: tX, y: tY))
    }

    public func translate(x: CGFloat, y: CGFloat) {
        apply(CGAffineTransform(translationX: x, y: y))
    }

    public func scale(x: CGFloat, y: CGFloat) {
        apply(CGAffineTransform(scaleX: x, y: y))
    }
}
