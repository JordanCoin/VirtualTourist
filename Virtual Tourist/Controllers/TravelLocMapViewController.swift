//
//  TravelLocMapViewController.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 1/26/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocMapViewController: Utils, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    var pins: [Pin] = []
    var touchedMapPin: MKPointAnnotation? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        loadPins()
    }
    
    func configView() {
        longPressGestureRecognizer.delegate = self
        mapView.delegate = self
        mapView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func loadPins() {
        let savedPins = loadSavedPins()
        
        if savedPins != nil {
            pins = savedPins!
            
            for pin in pins {
                let annotation = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                annotation.coordinate = coordinate
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func loadSavedPins() -> [Pin]? {
        do {
            var pins: [Pin] = []
            let fetchedResultsController = self.fetchedResultsController()
            
            try fetchedResultsController.performFetch()
            let pinCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0..<pinCount {
                pins.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Pin)
            }
            return pins
        } catch {
            return nil
        }
    }
    
    func addToCoreData(pin: MKPointAnnotation) {
        let pin = Pin(annotation: pin, context: CoreDataStack.shared.context)
        pins.append(pin)
        CoreDataStack.shared.save()
    }
    
    func getLocation(location: CLLocation, completion: @escaping (_ placemark: CLPlacemark) -> Void) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: Error?) in
            guard error == nil else {
                Utils.errorAlert(title: "Couldn't Find Location", message: "\(error.debugDescription), Please Try Again", view: self)
                return
            }
            guard placemarks != nil else {
                Utils.errorAlert(title: "Couldn't Find Location", message: "Please Try Again", view: self)
                return
            }
            completion(placemarks![0])
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
        } else {
            pinView!.annotation = annotation
            pinView?.animatesDrop = false
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let mapAnnotation = view.annotation! as? MKPointAnnotation
        self.touchedMapPin = mapAnnotation
        performSegue(withIdentifier: "PhotoAlbumViewController", sender: self)
        mapView.deselectAnnotation(mapAnnotation, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        mapView.deselectAnnotation(annotation, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoAlbumController = segue.destination as? PhotoAlbumViewController
        var touchedPin: Pin?
        
        for pin in pins {
            let isLatitudeMatch = touchedMapPin!.coordinate.latitude == pin.latitude
            let isLongitudeMatch = touchedMapPin!.coordinate.longitude == pin.longitude

            if isLatitudeMatch && isLongitudeMatch {
                touchedPin = pin
                break
            }
        }
        photoAlbumController?.touchedPin = touchedPin
        photoAlbumController?.touchedMapPin = touchedMapPin
    }
}

// MARK: - GestureReocgnizerDelegate Method
extension TravelLocMapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // Check if the network is connected
        guard connectedToNetwork() == true else {
            Utils.errorAlert(title: "Connection Error!", message: "It looks like you aren't connected to wifi, check your network prefrences.", view: self)
            return false
        }
        
        let gestureTouchPoint = gestureRecognizer.location(in: mapView)
        let pin = CGPoint(x: gestureTouchPoint.x, y: gestureTouchPoint.y)
        let coordinate = mapView.convert(pin, toCoordinateFrom: self.view)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        getLocation(location: location, completion: { (placemark: CLPlacemark) in
            
            let mapPointAnnotation = MKPointAnnotation()
            mapPointAnnotation.coordinate = placemark.location!.coordinate
            
            // We are adding the pin to core data
            self.addToCoreData(pin: mapPointAnnotation)
            
            for pin in self.pins {
                
                let isLatitudeMatch = pin.latitude == mapPointAnnotation.coordinate.latitude
                let isLongitudeMatch = pin.longitude == mapPointAnnotation.coordinate.longitude
                
                if isLatitudeMatch && isLongitudeMatch  {
                    self.touchedMapPin = mapPointAnnotation
                    print("point is found, the point is \(pin)")
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotation(mapPointAnnotation)
            }
        })
        return true
    }
}
