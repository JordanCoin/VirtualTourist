//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Jordan Jackson on 2/5/18.
//  Copyright © 2018 Jordan Jackson. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override var isSelected: Bool {
        didSet {
            self.alpha = self.isSelected ? 0.5 : 1.0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityIndicator.startAnimating()
    }

    func initWithPhoto(_ photo: Photo) {
        if photo.imageData == nil {
            downloadImage(photo)
            return
        } else {
            self.imageView.image = UIImage(data: photo.imageData! as Data)
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func downloadImage(_ photo: Photo) -> Void {
        URL(string: photo.imageURL!)!.fetchImage(imageKey: photo.imageURL!) { (image, data)  in
            DispatchQueue.main.async {
                self.imageView.image = image
                self.activityIndicator.stopAnimating()
                self.saveImageDataToCoreData(photo: photo, imageData: data! as NSData)
            }
        }
    }
    
    func saveImageDataToCoreData(photo: Photo, imageData: NSData) {
        photo.imageData = imageData
        CoreDataStack.shared.save()
    }
}
