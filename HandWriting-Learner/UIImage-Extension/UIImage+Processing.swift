import UIKit

extension UIImage {

    // Retreive intensity (alpha) of each pixel from this image
    func pixelsArray()->(pixelValues: [Float], width: Int, height: Int){
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        var pixelsArray = [Float]()
        
        let pixelData = self.cgImage?.dataProvider?.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerRow = self.cgImage?.bytesPerRow
        let bytesPerPixel = ((self.cgImage?.bitsPerPixel)! / 8)
        var position = 0
        for _ in 0..<height {
            for _ in 0..<width {
                let alpha = Float(data[position + 3])
                pixelsArray.append(alpha / 255)
                position += bytesPerPixel
            }
            if position % bytesPerRow! != 0 {
                position += (bytesPerRow! - (position % bytesPerRow!))
            }
        }
        
        return (pixelsArray,width,height)
    }
    

    // Resize UIImage to the given size
    // No ratio check - no scale check
    func toSize(_ newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

    
    // Extract sub image based on the given frame
    // x,y top left | x,y bottom right | pixels margin above this frame
    func extractFrame(_ topLeft: CGPoint, bottomRight: CGPoint, pixelMargin: CGFloat) ->UIImage {
        var topLeft = topLeft, bottomRight = bottomRight
        
        topLeft.x = topLeft.x - pixelMargin
        topLeft.y = topLeft.y - pixelMargin
        bottomRight.x = bottomRight.x + pixelMargin
        bottomRight.y = bottomRight.y + pixelMargin
        
        let size:CGSize = CGSize(width: bottomRight.x-topLeft.x, height: bottomRight.y-topLeft.y)
        let rect = CGRect(x: -topLeft.x, y: -topLeft.y, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContext(size)
        
        self.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }

}
