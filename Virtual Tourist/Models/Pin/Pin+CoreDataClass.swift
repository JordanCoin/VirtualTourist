//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/12/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit


public class Pin: NSManagedObject {
    
    // MARK: Initializer
    
    convenience init(annotation: MKPointAnnotation, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.longitude = Double(annotation.coordinate.longitude)
            self.latitude = Double(annotation.coordinate.latitude)
            
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
