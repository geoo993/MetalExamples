//
//  String+Ext.swift
//  UITableViewApp
//
//  Created by GEORGE QUENTIN on 15/10/2016.
//  Copyright © 2016 GEORGE QUENTIN. All rights reserved.
//

import Foundation
import UIKit

public  extension UIImage {


    static func collage(images: [UIImage], size: CGSize) -> UIImage {
        let rows = images.count < 3 ? 1 : 2
        let columns = Int(round(Double(images.count) / Double(rows)))
        let tileSize = CGSize(width: round(size.width / CGFloat(columns)),
                              height: round(size.height / CGFloat(rows)))

        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        for (index, image) in images.enumerated() {
            image.scaled(tileSize).draw(at: CGPoint(
                x: CGFloat(index % columns) * tileSize.width,
                y: CGFloat(index / columns) * tileSize.height
            ))
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }

    func scaled(_ newSize: CGSize) -> UIImage {
        guard size != newSize else {
            return self
        }

        let ratio = max(newSize.width / size.width, newSize.height / size.height)
        let width = size.width * ratio
        let height = size.height * ratio

        let scaledRect = CGRect(
            x: (newSize.width - width) / 2.0,
            y: (newSize.height - height) / 2.0,
            width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0);
        defer { UIGraphicsEndImageContext() }

        draw(in: scaledRect)

        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    /// Resizes an image to the specified size.
    ///
    /// - Parameters:
    ///     - size: the size we desire to resize the image to.
    ///
    /// - Returns: the resized image.
    ///
    public  func imageWithSize(size: CGSize) -> UIImage {
        
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)){
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        }
        else
        {
            UIGraphicsBeginImageContext(size);
        }
        
        let rect = CGRect(x:0.0, y:0.0,width: size.width, height:size.height);
        draw(in: rect)
        guard let resultingImage = UIGraphicsGetImageFromCurrentImageContext() else { print("UIGraphicsGetImageFromCurrentImageContext is Nil "); return UIImage() };
        UIGraphicsEndImageContext();
        
        return resultingImage
    }
    
    public  func resizeImage(with size: CGSize, opaque: Bool = false, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        
        if UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale)){
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        }
        else
        {
            UIGraphicsBeginImageContext(size);
        }
        
        let rect = CGRect(x:0.0, y:0.0,width: size.width, height:size.height);
        draw(in: rect)
        guard let resultingImage = UIGraphicsGetImageFromCurrentImageContext() else { print("UIGraphicsGetImageFromCurrentImageContext is Nil "); return UIImage() };
        UIGraphicsEndImageContext();
        
        return resultingImage
    }
    
    
    /// Resizes an image to the specified size and adds an extra transparent margin at all sides of
    /// the image.
    ///
    /// - Parameters:
    ///     - size: the size we desire to resize the image to.
    ///     - extraMargin: the extra transparent margin to add to all sides of the image.
    ///
    /// - Returns: the resized image.  The extra margin is added to the input image size.  So that
    ///         the final image's size will be equal to:
    ///         `CGSize(width: size.width + extraMargin * 2, height: size.height + extraMargin * 2)`
    ///
    public func imageWithSize(size: CGSize, extraMargin: CGFloat) -> UIImage {
        
        let imageSize = CGSize(width: size.width + extraMargin * 1.5, height: size.height + extraMargin * 1.5)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale);
        let rect = CGRect(x: extraMargin, y: extraMargin, width: size.width, height: size.height)
        draw(in: rect)
        
        guard let resultingImage = UIGraphicsGetImageFromCurrentImageContext() else { print("UIGraphicsGetImageFromCurrentImageContext is Nil "); return UIImage() };
        UIGraphicsEndImageContext();
        
        return resultingImage
    }
    
    //Summon this function VVV
    public  func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage
    {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight
        
        let newHeight = oldHeight * scaleFactor
        let newWidth = oldWidth * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        return self.imageWithSize(size: newSize)
    }
    
    public static func drawDottedImage(width: CGFloat, height: CGFloat, color: UIColor) -> UIImage {
        // https://stackoverflow.com/questions/26018302/draw-dotted-not-dashed-line-with-ibdesignable-in-2017
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 1.0, y: 1.0))
        path.addLine(to: CGPoint(x: width, y: 1))
        path.lineWidth = 1.5           
        let dashes: [CGFloat] = [path.lineWidth, path.lineWidth * 5]
        path.setLineDash(dashes, count: 2, phase: 0)
        path.lineCapStyle = .butt
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 2)
        color.setStroke()
        path.stroke()
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func circularImage(with size: CGSize?) -> UIImage {
        let newSize = size ?? self.size
        
        let minEdge = min(newSize.height, newSize.width)
        let size = CGSize(width: minEdge, height: minEdge)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: size), blendMode: .copy, alpha: 1.0)
        
        
        context!.setBlendMode(.copy)
        context!.setFillColor(UIColor.clear.cgColor)
        
        let rectPath = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
        let circlePath = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: size))
        rectPath.append(circlePath)
        rectPath.usesEvenOddFillRule = true
        rectPath.fill()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result!
    }
    
    public func resizeByByte(maxByte: Int) {
        
        var compressQuality: CGFloat = 1
        var imageByte = UIImageJPEGRepresentation(self, 1)?.count
        
        while imageByte! > maxByte {
            
            imageByte = UIImageJPEGRepresentation(self, compressQuality)?.count
            compressQuality -= 0.1
        }
    }
    
    public var uncompressedPNGData: Data?      { return UIImagePNGRepresentation(self)        }
    public var highestQualityJPEGNSData: Data? { return UIImageJPEGRepresentation(self, 1.0)  }
    public var highQualityJPEGNSData: Data?    { return UIImageJPEGRepresentation(self, 0.75) }
    public var mediumQualityJPEGNSData: Data?  { return UIImageJPEGRepresentation(self, 0.5)  }
    public var lowQualityJPEGNSData: Data?     { return UIImageJPEGRepresentation(self, 0.25) }
    public var lowestQualityJPEGNSData:Data?   { return UIImageJPEGRepresentation(self, 0.01)  }

    func getPixelColor(pos: CGPoint) -> UIColor {
        // https://stackoverflow.com/questions/39548344/getting-pixel-color-from-an-image-using-cgpoint-in-swift-3
        // https://gist.github.com/akirahrkw/ce3c52ae79f3b5de5a01
        // https://gist.github.com/jokester/948616a1b881451796d6
        if let pixelData = self.cgImage?.dataProvider?.data {
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

            let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

            let r = CGFloat(data[pixelInfo+0]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

            return UIColor(red: b, green: g, blue: r, alpha: a)
        } else {
            //IF something is wrong I returned WHITE, but change as needed
            return UIColor.white
        }

        // usage
        // let colorAtPixel : UIColor = (theView.image?.getPixelColor(pos: CGPoint(x: 2, y: 2)))!
    }

    func getPixelColor(atLocation location: CGPoint, withFrameSize size: CGSize) -> UIColor {
        let x: CGFloat = (self.size.width) * location.x / size.width
        let y: CGFloat = (self.size.height) * location.y / size.height

        let pixelPoint: CGPoint = CGPoint(x: x, y: y)

        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelIndex: Int = ((Int(self.size.width) * Int(pixelPoint.y)) + Int(pixelPoint.x)) * 4

        let r = CGFloat(data[pixelIndex]) / CGFloat(255.0)
        let g = CGFloat(data[pixelIndex+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelIndex+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelIndex+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)

        // usage
        // let color = yourImageView.image!.getPixelColor(atLocation: location, withFrameSize: yourImageView.frame.size)

    }

}
