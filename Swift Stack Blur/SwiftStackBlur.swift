//
//  SwiftStackBlur.swift
//  Swift Stack Blur
//
// Copyright (c) 2015 __MyCompanyName__
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer. Redistributions in binary
// form must reproduce the above copyright notice, this list of conditions and
// the following disclaimer in the documentation and/or other materials
// provided with the distribution. Neither the name of the nor the names of
// its contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

// Stackblur algorithm
// from
// http://incubator.quasimondo.com/processing/fast_blur_deluxe.php
// by  Mario Klingemann

import Foundation
import UIKit

// Define operator for squaring a number.
postfix operator ^^ {}

// Function that squares a given Integer.
postfix func ^^ (operand: Int) -> Int {
    
    return operand * operand
}

extension UIImage {
    
    // Get stackBlur image from normal image.
    func swiftStackBlur(inRadius: Int) -> UIImage? {
        
        let imageref = self.CGImage
        let w = CGImageGetWidth(imageref)
        let h = CGImageGetHeight(imageref)
        let wm = w - 1
        let hm = h - 1
        let wh = w * h
        let div = inRadius + inRadius + 1
        
        // Create new bitmap context.
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bitsPerComponent * bytesPerPixel
        let bytesPerRow = w * bytesPerPixel
        let byteCount = bytesPerRow * h
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let context = CGBitmapContextCreate(nil, w, h, bitsPerComponent, bytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        // Draw image to context.
        let rect = CGRectMake(0, 0, CGFloat(w), CGFloat(h))
        CGContextDrawImage(context, rect, imageref)
        
        var data = CGBitmapContextGetData(context)
        var dataType = UnsafeMutablePointer<UInt8>(data)
        
        var out = CGBitmapContextGetData(context)
        var outData = UnsafeMutablePointer<UInt8>(data)
        
        // Pointers for rgb.
        var r = UnsafeMutablePointer<Int>.alloc(sizeof(Int) * wh)
        var g = UnsafeMutablePointer<Int>.alloc(sizeof(Int) * wh)
        var b = UnsafeMutablePointer<Int>.alloc(sizeof(Int) * wh)
        
        // Pointers for process stacks.
        var vmin = UnsafeMutablePointer<Int>.alloc(max(w,h))
        var stack = UnsafeMutablePointer<Int>.alloc(div * 3)
        
        // Return pointer within alloced memory.
        func getArray(i:Int) -> UnsafeMutablePointer<Int> {
            
            return withUnsafeMutablePointer(&stack[i], { $0 })
        }
        
        // Pointer for another stack.
        let divsum : Int = ((div + 1) >> 1)^^
        let dvcount : size_t  = 256 * divsum
        let dv = UnsafeMutablePointer<Int>.alloc((sizeof(Int) * dvcount))
        
        for i in 0..<dvcount {
            
            dv[i] = Int(i/divsum)
            
        }
        
        // Variables.
        var stackPointer : Int
        var stackStart : Int
        var sir : UnsafeMutablePointer<Int>
        var rbs : Int
        let r1 : Int = Int(inRadius) + 1
        var routsum : Int = 0
        var goutsum : Int = 0
        var boutsum : Int = 0
        var rinsum : Int = 0
        var ginsum : Int = 0
        var binsum : Int = 0
        var offset : Int = 0
        var rsum : Int = 0
        var gsum : Int = 0
        var bsum : Int = 0
        let i : Int = -inRadius
        var p : Int
        var yp : Int = 0
        var yi : Int = 0
        var yw : Int = 0
        
        // Loop through pixels and alter.
        for y in 0..<h {
            
            rinsum = 0
            ginsum = 0
            binsum = 0
            routsum = 0
            goutsum = 0
            boutsum = 0
            rsum = 0
            gsum = 0
            bsum = 0
            
            for i in i...inRadius {
                
                offset = (yi + min(wm, max(i, 0))) * 4
                
                sir = getArray(((i + inRadius) * 3))
                
                sir[0] = Int(dataType[offset + 1])
                sir[1] = Int(dataType[offset + 2])
                sir[2] = Int(dataType[offset + 3])

                rbs = r1 - abs(i);

                rsum = rsum + (sir[0] * rbs)
                gsum = gsum + (sir[1] * rbs)
                bsum = bsum + (sir[2] * rbs)
                
                if i > 0 {
                    rinsum = rinsum + sir[0]
                    ginsum = ginsum + sir[1]
                    binsum = binsum + sir[2]
                }
                else {
                    routsum = routsum + sir[0]
                    goutsum = goutsum + sir[1]
                    boutsum = boutsum + sir[2]
                }
            }
            
            stackPointer = inRadius
            
            for x in 0..<w {
                
                r[yi] = Int(dv[rsum])
                g[yi] = Int(dv[gsum])
                b[yi] = Int(dv[bsum])
                
                rsum -= routsum
                gsum -= goutsum
                bsum -= boutsum
                
                stackStart = stackPointer - inRadius + div
                
                sir = getArray((stackStart % div) * 3)
                
                routsum -= sir[0]
                goutsum -= sir[1]
                boutsum -= sir[2]
                
                if y == 0 {
                    
                    vmin[x] = min((x + inRadius + 1), wm)
                }

                offset = (yw + vmin[x]) * 4
                
                sir[0] = Int(dataType[offset + 1])
                sir[1] = Int(dataType[offset + 2])
                sir[2] = Int(dataType[offset + 3])
                
                rinsum += sir[0]
                ginsum += sir[1]
                binsum += sir[2]
                
                rsum += rinsum
                gsum += ginsum
                bsum += binsum
                
                stackPointer = (stackPointer + 1) % div
                sir = getArray((stackPointer % div) * 3)
                
                routsum += sir[0]
                goutsum += sir[1]
                boutsum += sir[2]
                
                rinsum -= sir[0]
                ginsum -= sir[1]
                binsum -= sir[2]
                
                yi += 1
            }
            
            yw += w
        }
        
        for x in 0..<w {
            
            rinsum = 0
            ginsum = 0
            binsum = 0
            routsum = 0
            goutsum = 0
            boutsum = 0
            rsum = 0
            gsum = 0
            bsum = 0
            
            yp = -(inRadius * w)
            
            for i in i...inRadius {
                
                yi = max(0, yp) + x
                sir = getArray((i + inRadius) * 3)
                
                sir[0] = r[yi]
                sir[1] = g[yi]
                sir[2] = b[yi]
                
                rbs = r1 - Int(abs(i))
                
                rsum = rsum + (r[yi] * rbs)
                gsum = gsum + (g[yi] * rbs)
                bsum = bsum + (b[yi] * rbs)
                
                if i > 0 {
                    
                    rinsum = rinsum + sir[0]
                    ginsum = ginsum + sir[1]
                    binsum = binsum + sir[2]
                }
                else {
                    
                    routsum = routsum + sir[0]
                    goutsum = goutsum + sir[1]
                    boutsum = boutsum + sir[2]
                }
                
                if i < hm {
                    yp += w
                }
            }
            
            yi = x
            stackPointer = inRadius
            
            for y in 0..<h {

                offset = yi * 4
                
                outData[offset + 1] = UInt8(dv[rsum])
                outData[offset + 2] = UInt8(dv[gsum])
                outData[offset + 3] = UInt8(dv[bsum])
                
                rsum = rsum - routsum
                gsum = gsum - goutsum
                bsum = bsum - boutsum
                
                stackStart = stackPointer - inRadius + div
                sir = getArray(abs((stackStart % div) * 3))
                
                routsum = routsum - sir[0]
                goutsum = goutsum - sir[1]
                boutsum = boutsum - sir[2]
                
                if x == 0 {
                    
                    vmin[y] = min((y + Int(r1)), hm) * w
                }
                
                p = x + vmin[y]
                
                sir[0] = r[p]
                sir[1] = g[p]
                sir[2] = b[p]
                
                rinsum = rinsum + sir[0]
                ginsum = ginsum + sir[1]
                binsum = binsum + sir[2]
                
                rsum = rsum + rinsum
                gsum = gsum + ginsum
                bsum = bsum + binsum
                
                stackPointer = (stackPointer + 1) % div
                sir = getArray(stackPointer * 3)
                
                routsum = routsum + sir[0]
                goutsum = goutsum + sir[1]
                boutsum = boutsum + sir[2]
                
                rinsum = rinsum - sir[0]
                ginsum = ginsum - sir[1]
                binsum = binsum - sir[2]
                
                yi += w
            }
        }
        
        // Free allocated memory.
        free(dv)
        free(r)
        free(g)
        free(b)
        free(vmin)
        free(stack)
        
        // Copy from output back over old data.
        memcpy(data, out, byteCount)

        // Create a new context.
        let contextOut = CGBitmapContextCreate(data, w, h, 8, bytesPerRow, colorSpace, CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let cgimageOut = CGBitmapContextCreateImage(contextOut)
        
        // Clear data.
        if data != nil {
            data = nil
        }
        
        if (out != nil) {
            out = nil
        }
        
        // Return the blurred image.
        return UIImage(CGImage: cgimageOut!)
    }
}
