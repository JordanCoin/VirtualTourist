//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 1/26/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: Utils, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var touchedPin: Pin!
    var touchedMapPin: MKPointAnnotation!
    var pinFetchResults: NSFetchRequest<Photo>?
    var photos = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configMap()
        
        guard let savedPhotos = loadSavedPhotos() else {
            return
        }

        if savedPhotos.count > 0 {
            loadingLabel.isHidden = true
            photos = savedPhotos
        } else {
            requestFlickrPhotos()
        }
    }
    
    func configUI() {
        self.isEditing = true
        self.collectionView.allowsMultipleSelection = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelectedPhotos))

        collectionView.delegate = self
        collectionView.dataSource = self
        
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        collectionFlow.minimumInteritemSpacing = 3.0
        collectionFlow.minimumLineSpacing = 3.0
        collectionFlow.itemSize = CGSize(width: dimension, height: dimension)
        self.collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
    }
    
    func configMap() {
        // Set the region and annotation of the map
        let latitudeDelta = 0.05
        let longitudeDelta = 0.05
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let region = MKCoordinateRegionMake(touchedMapPin.coordinate, span)
        mapView.setRegion(region, animated: true)
        mapView.isUserInteractionEnabled = false
        mapView.addAnnotation(touchedMapPin)
    }
    
    func requestFlickrPhotos() {
        self.isEditing = false
        self.loadingLabel.isHidden = false

        guard connectedToNetwork() == true else {
           Utils.errorAlert(title: "Error", message: "Plese connect to the internet and try again", view: self)
            return
        }
        
        // Clear currently saved photos from touchedPin
        removeFromCoreData(photos: photos)
        photos.removeAll()
        collectionView.reloadData()
        newCollectionButton.isEnabled = false
     
        let location = CLLocation(latitude: (touchedPin?.latitude)!, longitude: (touchedPin?.longitude)!)
        
        FlickrClient.getFlickrPhotos(location: location) { (error, flickrPhotos) in
   
            guard error == nil else {
                Utils.errorAlert(title: "Couldn't load from Flickr", message: "We are having trouble getting the flickr request.", view: self)
                self.loadingLabel.isHidden = true
                return
            }
            
            DispatchQueue.main.async {
                if flickrPhotos?.count != 0 {
                    self.addToCoreData(of: flickrPhotos!, at: self.touchedPin)
                    self.photos = self.loadSavedPhotos()!
                    self.loadingLabel.isHidden = true
                    self.newCollectionButton.isEnabled = true
                } else {
                    Utils.errorAlert(title: "Error!", message: "We couldn't find any photos from flickr at this location 😔", view: self)
                }
            }
        }
    }
    
    func loadSavedPhotos() -> [Photo]? {
        do {
            var photos: [Photo] = []
            let fetchedResultsController = self.fetchedResultsController()
            try fetchedResultsController.performFetch()
            
            let photosCount = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0..<photosCount {
                photos.append(fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Photo)
            }
            return photos
        } catch {
            return nil
        }
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "pin = %@", argumentArray: [touchedPin!])
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func addToCoreData(of objects: [FlickrPhoto], at pin: Pin?) {
        for index in 0..<objects.count {
            let photo = Photo(imageData: nil, imageURL: objects[index].photoURL(), pin: pin!, context: CoreDataStack.shared.context)
            photos.append(photo)
            CoreDataStack.shared.save()
        }
    }
    
    func removeFromCoreData(photos: [Photo]) {
        for photo in photos {
            CoreDataStack.shared.context.delete(photo)
        }
    }
    
    @objc func deleteSelectedPhotos() {
        removeCoreDataPhotos {
            DispatchQueue.main.async {
                self.isEditing = false
            }
        }
    }
    
    func removeCoreDataPhotos(completion: @escaping () -> Void) {
        let indexes = getIndexesFromSelectedIndexPath().sorted { return $0 < $1 }
        
        var counter = 0
        for index in indexes {
            let indexPath = IndexPath(row: index, section: 0)
            collectionView.deselectItem(at: indexPath, animated: true)
            CoreDataStack.shared.context.delete(photos[index - counter])
            photos.remove(at: index - counter)
            counter += 1
        }
        
        CoreDataStack.shared.save()
        completion()
    }
    
    @IBAction func newCollectionTouched(_ sender: Any) {
        requestFlickrPhotos()
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    func getIndexesFromSelectedIndexPath() -> [Int] {
        var indexes:[Int] = []
        let indexPaths = collectionView.indexPathsForSelectedItems!

        for indexPath in indexPaths {
            indexes.append(indexPath.row)
        }
        return indexes
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.prepareForReuse()
        
        let photo = photos[indexPath.row]
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
        cell.initWithPhoto(photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacingBetweenItems: CGFloat = 3.0
        let width = (UIScreen.main.bounds.width / 3) - spacingBetweenItems
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        let spacingBetweenItems: CGFloat = 5.0
        return spacingBetweenItems
    }
}
