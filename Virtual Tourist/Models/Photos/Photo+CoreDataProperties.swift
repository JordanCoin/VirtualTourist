//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/12/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var pin: Pin?

}
