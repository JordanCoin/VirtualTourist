//
//  URL.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/11/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    public typealias ImageCacheCompletion = (UIImage, Data?) -> Void
    
    public func fetchImage(imageKey: String, completion: @escaping ImageCacheCompletion) {
        if let image = ImageCache.cache.object(forKey: imageKey as NSString) {
            completion(image, nil)
            return
        } else {
            URLSession.shared.dataTask(with: self, completionHandler: { (data, response, error) in
                guard error == nil else { return }
                guard data != nil else { return }
                
                if let image = UIImage(data: data!) {
                    ImageCache.cache.setObject(image, forKey: imageKey as NSString)
                    completion(image, data!)
                    return
                }
            }).resume()
        }
    }
}
