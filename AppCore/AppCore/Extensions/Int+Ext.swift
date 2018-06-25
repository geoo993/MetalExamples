import Foundation

public extension Int {

    /// Returns a random integer between min and max
    public static func random(min: Int, max: Int) -> Int {
        guard min < max else { return min }
        return Int(arc4random_uniform(UInt32(1 + max - min))) + min
    }

    public var toDigits: [Int] {
        var number = self
        var digits: [Int] = []
        while number > 0 {
            digits.insert(number % 10, at: 0)
            number /= 10
        }
        return digits
    }
    
    /// Returns a Double
    public var toDouble: Double {
        return Double(self)
    }

    /// Returns a Float
    public var toFloat: Float {
        return Float(self)
    }

    /// Returns a CGFloat {
    public var toCGFloat: CGFloat {
        return CGFloat(self)
    }
}

