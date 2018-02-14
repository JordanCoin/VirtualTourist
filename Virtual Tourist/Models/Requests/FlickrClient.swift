//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/10/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import Foundation
import MapKit

class FlickrClient: NSObject {
    
    static let shared = FlickrClient()
    
    private static func requestImages(location: CLLocation, completion: @escaping (_ error: NSError?, _ flickrPhoto: [FlickrPhoto]?) -> Void) {
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let url = URL(string: "\(Constants.EndPoint)?method=\(Constants.SearchPoint)&format=\(Constants.DataFormat)&api_key=\(Constants.ApiKey)&lat=\(latitude)&lon=\(longitude)&radius=\(3)")!
        
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completion(NSError(domain: "requestImage", code: 1, userInfo: userInfo), nil)
            }
            
            guard (error == nil) else {
                sendError(error: "Error Requesting Images from Flickr")
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode, httpStatusCode != 403 else {
                sendError(error: "Unathorized request, check your API Key")
                return
            }
            
            guard httpStatusCode >= 200 && httpStatusCode <= 299 else {
                sendError(error: "Check your internet connection")
                return
            }
            
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            
            if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String: Any],
                let photosMeta = json?["photos"] as? [String: Any],
                let photos = photosMeta["photo"] as? [Any] {
                
                var flickrPhotos: [FlickrPhoto] = []
                
                for photo in photos {
                    if let flickrPhoto = photo as? [String: Any],
                        let farmId = flickrPhoto["farm"] as? Int,
                        let serverId = flickrPhoto["server"] as? String,
                        let id = flickrPhoto["id"] as? String,
                        let secret = flickrPhoto["secret"] as? String {
                        
                        flickrPhotos.append(FlickrPhoto(farmId: farmId, serverId: serverId, id: id, secret: secret))
                    }
                }
                completion(nil, flickrPhotos)
            }
        }
        task.resume()
    }
    
    static func getFlickrImages(location: CLLocation, completion: @escaping (_ error: Error?, _ flickrPhoto: [FlickrPhoto]?) -> Void) {
        
        var flickrRequestResults: [FlickrPhoto] = []
        
        FlickrClient.requestImages(location: location) { (error: Error?, flickrPhotos: [FlickrPhoto]?) in
            
            guard (error == nil) else {
                completion(error!, nil)
                return
            }

            if flickrPhotos!.count > 25 {
                var randomArray: [Int] = []
                
                while randomArray.count < 25 {
                    let random = arc4random_uniform(UInt32(flickrPhotos!.count))
                    if !randomArray.contains(Int(random)) { randomArray.append(Int(random)) }
                }
                for random in randomArray {
                    flickrRequestResults.append(flickrPhotos![random])
                }
                completion(nil, flickrRequestResults)
            } else {
                completion(nil, flickrRequestResults)
            }
        }
    }
}
