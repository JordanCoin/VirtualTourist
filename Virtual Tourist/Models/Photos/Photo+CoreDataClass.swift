//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/12/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//
//

import Foundation
import CoreData


public class Photo: NSManagedObject {
    
    // MARK: Initializer
    
    convenience init(imageData: NSData?, imageURL: String, pin: Pin, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.imageData = imageData ?? nil
            self.imageURL = imageURL
            self.pin = pin
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
