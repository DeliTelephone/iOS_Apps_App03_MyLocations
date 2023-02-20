//
//  LocationCell.swift
//  MyLocations
//
//  Created by Nick "Fox" Borer on 02/16/2023.
//

import UIKit
import CoreData
import CoreLocation
import Foundation


class LocationCell: UITableViewCell {

   @IBOutlet var descriptionLabel: UILabel!
   @IBOutlet var addressLabel: UILabel!
   @IBOutlet var photoImageView: UIImageView!
   
   
    override func awakeFromNib() {
        super.awakeFromNib()
       
       photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
       photoImageView.clipsToBounds = true
       separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
    }

   
    override func setSelected(_ selected: Bool, animated: Bool)
   {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
   
   //MARK:  - Helper Method
   
   func configure(for location: Location)
   {
      if location.locationDesription.isEmpty
      {
	 descriptionLabel.text = "(No Description)"
      }
      else
      {
	 descriptionLabel.text = location.locationDesription
      }
      
      if let placemark = location.placemark
      {
	 var text = ""
	 
	 text.add(text: placemark.subThoroughfare)
	 text.add(text: placemark.thoroughfare, separatedBy: " ")
	 text.add(text: placemark.locality, separatedBy: ", ")
	 
	 addressLabel.text = text
      }
      else
      {
	 addressLabel.text = String(
	    format: "Lat: %.8f, Long:  %.8f",
	    location.latitude,
	    location.longitude)
      }
      
      photoImageView.image = thumbnail(for: location)
   }
   
   func thumbnail(for location: Location) -> UIImage
   {
      if location.hasPhoto, let image = location.photoImage
      {
	 return image.resized(withBounds: CGSize(width: 52, height: 52))
      }
      return UIImage(named: "No Photo")!
   }

}
