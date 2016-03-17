import UIKit

extension UIImage {

    // Retreive intensity (alpha) of each pixel from this image
    func pixelsArray()->(pixelValues: [Float], width: Int, height: Int){
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        var pixelsArray = [Float]()
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerRow = CGImageGetBytesPerRow(self.CGImage)
        let bytesPerPixel = (CGImageGetBitsPerPixel(self.CGImage) / 8)
        var position = 0
        for _ in 0..<height {
            for _ in 0..<width {
                let alpha = Float(data[position + 3])
                pixelsArray.append(alpha / 255)
                position += bytesPerPixel
            }
            if position % bytesPerRow != 0 {
                position += (bytesPerRow - (position % bytesPerRow))
            }
        }
        
        return (pixelsArray,width,height)
    }
    

    // Resize UIImage to the given size
    // No ratio check - no scale check
    func toSize(newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
    // Extract sub image based on the given frame
    // x,y top left | x,y bottom right | pixels margin above this frame
    func extractFrame(var topLeft: CGPoint, var bottomRight: CGPoint, pixelMargin: CGFloat) ->UIImage {
        
        topLeft.x = topLeft.x - pixelMargin
        topLeft.y = topLeft.y - pixelMargin
        bottomRight.x = bottomRight.x + pixelMargin
        bottomRight.y = bottomRight.y + pixelMargin
        
        let size:CGSize = CGSizeMake(bottomRight.x-topLeft.x, bottomRight.y-topLeft.y)
        let rect = CGRectMake(-topLeft.x, -topLeft.y, self.size.width, self.size.height)
        UIGraphicsBeginImageContext(size)
        
        self.drawInRect(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }

}