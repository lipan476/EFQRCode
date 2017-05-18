//
//  UIImage+.swift
//  Pods
//
//  Created by EyreFree on 2017/4/9.
//
//  Copyright (c) 2017 EyreFree <eyrefree@eyrefree.org>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#if os(macOS)
    import AppKit

    public extension NSImage {

        public func toCIImage() -> CIImage? {
            if let data = self.tiffRepresentation(using: NSTIFFCompression.none, factor: 0) {
                return CIImage(data: data)
            }
            return nil
        }

        public func toCGImage() -> CGImage? {
            return self.toCIImage()?.toCGImage()
        }
    }
#elseif os(iOS) || os(tvOS)
    import UIKit

    public extension UIImage {

        public func toCIImage() -> CIImage? {
            return CIImage(image: self)
        }

        public func toCGImage() -> CGImage? {
            return self.toCIImage()?.toCGImage()
        }

        public func binarization() -> UIImage {


            CGSize size = [img size];

            int width = size.width;

            int height = size.height;

            // the pixels will be painted to this array

            uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));

            // clear the pixels so any transparency is preserved

            memset(pixels, 0, width * height * sizeof(uint32_t));

            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

            // create a context with RGBA pixels

            CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,

                                                         kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);

            // paint the bitmap to our context which will fill in the pixels array

            CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);

            int tt = 1;

            CGFloat intensity;

            int bw;

            for(int y = 0; y < height; y++) {

                for(int x = 0; x < width; x++) {

                    uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];

                    intensity = (rgbaPixel[tt] + rgbaPixel[tt + 1] + rgbaPixel[tt + 2]) / 3. / 255.;

                    if (intensity > 0.45) {

                        bw = 255;

                    } else {

                        bw = 0;

                    }

                    rgbaPixel[tt] = bw;
                    
                    rgbaPixel[tt + 1] = bw;
                    
                    rgbaPixel[tt + 2] = bw;
                    
                }
                
            }
            
            // create a new CGImageRef from our context with the modified pixels
            
            CGImageRef image = CGBitmapContextCreateImage(context);
            
            // we're done with the context, color space, and pixels
            
            CGContextRelease(context);
            
            CGColorSpaceRelease(colorSpace);
            
            free(pixels);
            
            // make a new UIImage to return
            
            UIImage *resultUIImage = [UIImage imageWithCGImage:image];
            
            // we're done with image now too
            
            CGImageRelease(image);
            
            return resultUIImage;
        }
    }
#endif
