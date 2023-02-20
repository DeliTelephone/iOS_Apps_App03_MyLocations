//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Nick "Fox" Borer on 02/10/2023.
//

import Foundation
import UIKit
import CoreLocation
import CoreData


private let dateFormatter: DateFormatter =
{
   let formatter = DateFormatter()
   formatter.dateStyle = .medium
   formatter.timeStyle = .short
   return formatter
} ()

class LocationDetailsViewController: UITableViewController
{
   
   var managedObjectContext: NSManagedObjectContext!
   
   var image: UIImage?
   var observer: Any!
   
   var coordinate = CLLocationCoordinate2D(
      latitude: 0,
      longitude: 0)
   
   var placemark: CLPlacemark?
   var categoryName = "No Category"
   var descriptionText = ""
   var date = Date()
   var locationToEdit: Location?
   {
      didSet{
	if let location = locationToEdit
	  {
	   descriptionText = location.locationDesription
	   categoryName = location.category
	   date = location.date
	   coordinate = CLLocationCoordinate2DMake(
	    location.latitude,
	    location.longitude)
	   placemark = location.placemark
	  }
	}
     }
   
   
   
   @IBOutlet var descriptionTextView: UITextView!
   @IBOutlet var categoryLabel: UILabel!
   @IBOutlet var latitudeLabel: UILabel!
   @IBOutlet var longitudeLabel: UILabel!
   @IBOutlet var addressLabel: UILabel!
   @IBOutlet var dateLabel: UILabel!
   
   @IBOutlet var imageView: UIImageView!
   @IBOutlet var addPhotoLabel: UILabel!
   @IBOutlet var imageHeight: NSLayoutConstraint!
   
   
   
   //MARK: - Actions
   @IBAction func done()
   {
      guard let mainView = navigationController?.parent?.view
      else {return}
      
      let hudView = HUDView.HUD(inView: mainView, animated: true)

      let location: Location
      if let temp = locationToEdit
      {
	 hudView.text = "Updated"
	 location = temp
      }
      else
      {
	 hudView.text = "Tagged"
	 location = Location(context: managedObjectContext)
	 location.photoID = nil
      }
      
      location.locationDesription = descriptionTextView.text
      location.category = categoryName
      location.latitude = coordinate.latitude
      location.longitude = coordinate.longitude
      location.date = date
      location.placemark = placemark
      
      
      if let image = image
      {
	 if !location.hasPhoto
	 {
	    location.photoID = Location.nextPhotoID() as NSNumber
	 }
	 
	 if let data = image.jpegData(compressionQuality: 0.5)
	 {
	    do
	    {
	       try data.write(to: location.photoURL, options: .atomic)
	    }
	    catch
	    {
	       print("Error writing file: \(error)")
	    }
	 }
      }
      
      
      do
      {
	 try managedObjectContext.save()
	 afterDelay(2.12)
	 {
	    hudView.hide()
	    self.navigationController?.popViewController(animated: true)
	 }
      }
      catch
      {
	 fatalCoreDataError(error)
      }

   }
   
   @IBAction func cancel()
   {
      navigationController?.popViewController(animated: true)
   }
   
   @IBAction func categoryPickerDidPickCategory(
      segue: UIStoryboardSegue)
   {
      let controller = segue.source as! CategoryPickerViewController
      
      categoryName = controller.selectedCategoryName
      categoryLabel.text = categoryName
   }
   
   func show(image: UIImage)
   {
      imageView.image = image
      imageView.isHidden = false
      addPhotoLabel.text = ""
      
      imageHeight.constant = 260
      tableView.reloadData()
   }
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      listenForBackgroundNotification()
      
      if let location = locationToEdit
      {
	 title = "Edit Location"
	 if location.hasPhoto
	 {
	    if let theImage = location.photoImage
	    {
	       show(image: theImage)
	    }
	 }
      }
      
      descriptionTextView.text = descriptionText
      categoryLabel.text = categoryName
      
      latitudeLabel.text = String(
	 format: "%.8f",
	 coordinate.latitude)
      
      longitudeLabel.text = String(
	 format: "%.8f",
	 coordinate.longitude)
      
      dateLabel.text = format(date: date)
      
      if let placemark = placemark
      {
	 addressLabel.text = string(from: placemark)
      }
      else
      {
	 addressLabel.text = "No Address Found"
      }
      
      dateLabel.text = format(date: Date())
      
      
      //Hide Keyboard action
      let gestureRecognizer = UITapGestureRecognizer(
	 target: self,
	 action: #selector(hideKeyboard))
      gestureRecognizer.cancelsTouchesInView = false
      tableView.addGestureRecognizer(gestureRecognizer)
   }
   
   //MARK: - Helper Methods
   
   //Formats the Address returned into the Address Cell
   func string (from placemark: CLPlacemark) -> String
   {
      var line = ""
      
      line.add(text: placemark.subThoroughfare)
      line.add(text: placemark.thoroughfare, separatedBy: " ")
      line.add(text: placemark.locality, separatedBy: ", ")
      line.add(text: placemark.administrativeArea, separatedBy: ", ")
      line.add(text: placemark.postalCode, separatedBy: " ")
      line.add(text: placemark.country, separatedBy: ", ")
      
      return line
   }
      
   func format(date: Date) -> String
   {
      return dateFormatter.string(from: date)
   }
   
   //MARK: - Navigation
   override func prepare(
      for segue: UIStoryboardSegue,
      sender: Any?)
   {
      if segue.identifier == "PickCategory"
      {
	 let controller = segue.destination as! CategoryPickerViewController
	 
	 controller.selectedCategoryName = categoryName
      }
   }
   
   //MARK: - Table View Delegates
   override func tableView(
      _ tableView: UITableView,
      willSelectRowAt indexPath: IndexPath) -> IndexPath?
   {
      if indexPath.section == 0 || indexPath.section == 1
      {
	 return indexPath
      }
      else
      {
	 return nil
      }
   }
   
   override func tableView(
      _ tableview: UITableView,
      didSelectRowAt indexPath: IndexPath)
   {
      if indexPath.section == 0 && indexPath.row == 0
      {
	 descriptionTextView.becomeFirstResponder()
      }
      else if indexPath.section == 1 && indexPath.row == 0
      {
	 tableView.deselectRow(at: indexPath, animated: true)
	 pickPhoto()
      }
   }
   
   func pickPhoto()
   {   //added "true || " to trick the Simulator into thinking it has a Camera and display the Alert Box to choose anyway.  This should be standard behavior IMO.
      if true || UIImagePickerController.isSourceTypeAvailable(.camera)
      {
	 showPhotoMenu()
      }
      else
      {
	 choosePhotoFromLibrary()
      }
   }
   
   func showPhotoMenu()
   {
      let alert = UIAlertController(
	 title: nil,
	 message: nil,
	 preferredStyle: .actionSheet)
      
      let actCancel = UIAlertAction(
	 title: "Cancel",
	 style: .cancel,
	 handler: nil)
      alert.addAction(actCancel)
      
      let actPhoto = UIAlertAction(
	 title: "Take Photo",
	 style: .default)
      { _ in
	 self.takePhotoWithCamera()
      }
      alert.addAction(actPhoto)
      
      let actLibrary = UIAlertAction(
	 title: "Choose From Photo Library",
	 style: .default)
      { _ in
	 self.choosePhotoFromLibrary()
      }
      alert.addAction(actLibrary)
      
      present(alert, animated: true, completion: nil)
   }
   
   
   
   @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer)
   {
      let point = gestureRecognizer.location(in: tableView)
      let indexPath = tableView.indexPathForRow(at: point)
      
      if indexPath != nil && indexPath!.section == 0 &&
	    indexPath!.row == 0 {
	 return
      }
      descriptionTextView.resignFirstResponder()
   }
   
   deinit
   {
      print("*** deInIt \(self)")
      NotificationCenter.default.removeObserver(observer!)
   }

}

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
   //MARK: - Image Helper Methods
   
   func takePhotoWithCamera()
   {
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .camera
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      present(imagePicker, animated: true, completion: nil)
   }
   
   //MARK: - Image Picker Delegates
   func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any] )
   {
      image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
      if let theImage = image
      {
	 show(image:theImage)
      }

      dismiss(animated: true, completion: nil)
   }
   
   func imagePickerControllerDidCancel(
      _ picker: UIImagePickerController)
   {
      dismiss(animated: true, completion: nil)
   }
   
   func choosePhotoFromLibrary()
   {
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .photoLibrary
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      
      present(imagePicker, animated: true, completion: nil)
   }
   
   
   func listenForBackgroundNotification()
   {
      observer = NotificationCenter.default.addObserver(
	 forName: UIApplication.didEnterBackgroundNotification,
	 object: nil,
	 queue: OperationQueue.main)
      {	  [weak self] _ in
	 if let weakSelf = self
	 {
	    if weakSelf.presentedViewController != nil
	    {
	       weakSelf.dismiss(animated: false, completion: nil)
	    }
	    
	    weakSelf.descriptionTextView.resignFirstResponder()
	 }
      }
   }

   
   
}
