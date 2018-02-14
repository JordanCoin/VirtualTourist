//
//  ImageCache.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/11/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import Foundation
import UIKit

public class ImageCache {
    
    public static var cache: NSCache<NSString, UIImage> {
        let cache = NSCache<NSString, UIImage>()
        
        cache.name = "SLKImageCache"
        cache.countLimit = 20
        cache.totalCostLimit = 10*1024*1024
        
        return cache
    }
}
