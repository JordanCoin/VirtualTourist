//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/10/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import Foundation

struct FlickrPhoto {
    
    let farmId: Int
    let serverId: String
    let id: String
    let secret: String
    
    init(farmId: Int, serverId: String, id: String, secret: String) {
        self.farmId = farmId
        self.serverId = serverId
        self.id = id
        self.secret = secret
    }
    
    func photoURL() -> String {
        return "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret)_q.jpg"
    }
}
