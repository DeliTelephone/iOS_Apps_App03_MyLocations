//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Nick "Fox" Borer on 02/10/2023.
//

import Foundation
import UIKit
import CoreLocation

private let dateFormatter: DateFormatter =
{
   let formatter = DateFormatter()
   formatter.dateStyle = .medium
   formatter.timeStyle = .short
   return formatter
} ()

class LocationDetailsViewController: UITableViewController
{
   
   var coordinate = CLLocationCoordinate2D(
      latitude: 0,
      longitude: 0)
   
   var placemark: CLPlacemark?
   var categoryName = "No Category"
   
   
   @IBOutlet var descriptionTextView: UITextView!
   @IBOutlet var categoryLabel: UILabel!
   @IBOutlet var latitudeLabel: UILabel!
   @IBOutlet var longitudeLabel: UILabel!
   @IBOutlet var addressLabel: UILabel!
   @IBOutlet var dateLabel: UILabel!
   
   //MARK: - Actions
   @IBAction func done()
   {
      guard let mainView = navigationController?.parent?.view
      else {return}
      
      let hudView = HUDView.HUD(inView: mainView, animated: true)

      hudView.text = "Tagged"

      afterDelay(2.12)
      {
	 hudView.hide()
	 self.navigationController?.popViewController(animated: true)
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
   
   
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      
      descriptionTextView.text = ""
      categoryLabel.text = categoryName
      
      latitudeLabel.text = String(
	 format: "%.8f",
	 coordinate.latitude)
      
      longitudeLabel.text = String(
	 format: "%.8f",
	 coordinate.longitude)
      
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
   func string(from placemark: CLPlacemark) -> String
   {
      var text = ""
       
	 if let temp = placemark.subThoroughfare
	 {
	    text = text + temp + " "
	 }
	 
	 if let temp =  placemark.thoroughfare
	 {
	    text = text + temp + ", "
	 }
	 
	 if let temp = placemark.locality
	 {
	    text = text + temp + ", "
	 }
	 
         if let temp = placemark.administrativeArea
         {
	    text = text + temp + " "
	 }
      
	 if let temp = placemark.postalCode
	 {
	    text = text + temp + ", "
	 }
      
         if let temp = placemark.country
         {
	    text = text + temp
         }
      
      return text
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

}

