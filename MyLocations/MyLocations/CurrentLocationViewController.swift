//
//  ViewController.swift
//  MyLocations
//
//  Created by Nick "Fox" Borer on 02/09/2023.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate
{
   @IBOutlet weak var messageLabel: UILabel!
   @IBOutlet weak var latitudeLabel: UILabel!
   @IBOutlet weak var longitudeLabel: UILabel!
   @IBOutlet weak var addressLabel: UILabel!
   @IBOutlet weak var tagButton: UIButton!
   @IBOutlet weak var getButton: UIButton!

   //Declare Location Manager Variables
   let locationManager = CLLocationManager()
   var location: CLLocation?
   var updatingLocation = false
   var lastLocationError: Error?
   
   //Declare GeoCoding Variables
   let geoCoder = CLGeocoder()
   var placemark: CLPlacemark?
   var performingReverseGeoCoding = false
   var lastGeoCodingError: Error?
   var timer: Timer?
   
   
   override func viewDidLoad()
   {
      super.viewDidLoad()
      updateLabels()
   }
   
   override func viewWillAppear(_ animated: Bool)
   {
      super.viewWillAppear(animated)
      navigationController?.isNavigationBarHidden = true
   }
   
   override func viewWillDisappear(_ animated: Bool)
   {
      super.viewWillDisappear(animated)
      navigationController?.isNavigationBarHidden = false
   }
   
   
   //MARK: - Navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?)
   {
      if segue.identifier == "TagLocation"
      {
	 let controller = segue.destination as! LocationDetailsViewController
	 
	 controller.coordinate = location!.coordinate
	 controller.placemark = placemark
      }
   }
   
   
   //MARK:  - Actions
   @IBAction func getLocation()
   {
      let authStatus = locationManager.authorizationStatus
      
      if authStatus == .notDetermined
      {
	 locationManager.requestWhenInUseAuthorization()
	 return
      }
      
      if authStatus == .denied || authStatus == .restricted
      {
	 showLocationServicesDeniedAlert()
	 return
      }
            
      // My own code, designed to set to Only When Using App,
      //  to ensure the user is not draining their battery unnecessarily
      if authStatus != .authorizedWhenInUse
      {
	 locationManager.requestWhenInUseAuthorization()
	 return
      }
      
       
      if updatingLocation
      {
	 stopLocationManager()
      }
      else
      {
	 location = nil
	 lastLocationError = nil
	 placemark = nil
	 lastLocationError = nil
	 lastGeoCodingError = nil
	 
	 startLocationManager()
      }
      
      updateLabels()
   }
   
   //MARK: - CLLocationManagerDelegate
   func locationManager(
      _ manager: CLLocationManager,
      didUpdateLocations locations: [CLLocation])
   {
      
      var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
      
      let newLocation = locations.last!
      print("didUpdateLocations \(newLocation)")
      
      if newLocation.timestamp.timeIntervalSinceNow < -5
      {
	 return
      }
      
      if newLocation.horizontalAccuracy < 0
      {
	 return
      }
      
      if let location = location
      {
	 distance = newLocation.distance(from: location)
      }
      
      if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy
      {
	 lastLocationError = nil
	 location = newLocation
	 
	 if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy
	 {
	    print("*** We are Done! ***")
	    stopLocationManager()
	    
	    if distance > 0
	    {
	       performingReverseGeoCoding = false
	    }
	 }
	 //updateLabels()
	 
	 if !performingReverseGeoCoding
	 {
	    print("*** Going to GeoCode now... ***")
	    
	    performingReverseGeoCoding = true
	    
	    geoCoder.reverseGeocodeLocation(newLocation)
	    {
	       placemarks, error in
	       
	       self.lastGeoCodingError = error
	       
	       if error == nil, let places = placemarks, !places.isEmpty
	       {
		  self.placemark = places.last!
	       }
	       else
	       {
		  self.placemark = nil
	       }
	       
	       self.performingReverseGeoCoding = false
	       self.updateLabels()
	    }
	 }
	 updateLabels()
      }
      else if distance < 1
      {
	 let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
	 
	 if timeInterval > 10
	 {
	    print("*** Force done!")
	    stopLocationManager()
	    updateLabels()
	 }
      }
   }
   
   func locationManager(
      _ manager: CLLocationManager,
      didFailWithError error: Error)
   {
      print("didFailWithError \(error.localizedDescription)")
      
      if (error as NSError).code == CLError.locationUnknown.rawValue
      {
	 return
      }
      
      lastLocationError = error
      stopLocationManager()
      updateLabels()
      
   }
   
   
   //MARK: - Helper Methods
   func showLocationServicesDeniedAlert()
   {
      let alert = UIAlertController(
	 title: "Location Services Disabled",
	 message: "Please Enable Location Services for this app in Settings",
	 preferredStyle: .alert)
      
      let okAction = UIAlertAction(
	 title: "OK",
	 style: .default,
	 handler: nil)
      
      alert.addAction(okAction)
      
      present(alert, animated: true, completion: nil)
   }

   func updateLabels()
   {
      if let location = location
      {
	 latitudeLabel.text = String(
	    format: "%.8f",
	    location.coordinate.latitude)
	 
	 longitudeLabel.text = String(
	    format: "%.8f",
	    location.coordinate.longitude)
	 
	 tagButton.isHidden = false
	 messageLabel.text = ""
	 
	 //Start New GeoCoding Code
	 
	 if let placemark = placemark
	 {
	    addressLabel.text = string(from: placemark)
	 }
	 else if performingReverseGeoCoding
	 {
	    addressLabel.text = "Searching for Address..."
	 }
	 else if lastGeoCodingError != nil
	 {
	    addressLabel.text = "Error Finding Address"
	 }
	 else
	 {
	    addressLabel.text = "No Address Found"
	 }
      }
      else
      {
	 latitudeLabel.text = ""
	 longitudeLabel.text = ""
	 addressLabel.text = ""
	 tagButton.isHidden = true
	 //messageLabel.text = "Tap 'Get My Location' to Start"
	 
	 let statusMessage: String
	 if let error = lastLocationError as NSError?
	 {
	    if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue
	    {
	       statusMessage = "Location Services Disabled"
	    }
	    else
	    {
	       statusMessage = "Error Getting Location"
	    }
	 }
	 else if  !CLLocationManager.locationServicesEnabled()
	 {
	    statusMessage = "Location Services are Disabled"
	 }
	 else if updatingLocation
	 {
	    statusMessage = "Searching..."
	 }
	 else
	 {
	    statusMessage = "Tap 'Get My Location' to Start"
	 }
	 
	 messageLabel.text = statusMessage
      }
      configureGetButton()
   }
   
   func startLocationManager()
   {
      
      if CLLocationManager.locationServicesEnabled()
      {
	 locationManager.delegate = self
	 locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
	 locationManager.startUpdatingLocation()
	 updatingLocation = true
	 
	 timer = Timer.scheduledTimer(
	    timeInterval: 60,
	    target: self,
	    selector: #selector(didTimeOut),
	    userInfo: nil,
	    repeats: false)
      }
   }

   func stopLocationManager()
   {
      if updatingLocation
      {
	 locationManager.stopUpdatingLocation()
	 locationManager.delegate = nil
	 updatingLocation = false
	 
	 if let timer = timer
	 {
	    timer.invalidate()
	 }
      }
   }
   
   func configureGetButton()
   {
      if updatingLocation
      {
	 getButton.setTitle("Stop", for: .normal)
      }
      else
      {
	 getButton.setTitle("Get My Location", for: .normal)
      }
   }
   
   func string (from placemark: CLPlacemark) -> String
   {
      var line1 = ""
      var line2 = ""
      
      if let temp = placemark.subThoroughfare
      {
	 line1 = line1 + temp + " "
      }
      
      if let temp =  placemark.thoroughfare
      {
	 line1 = line1 + temp
      }
      
      if let temp = placemark.locality
      {
	 line2 = line2 + temp + " "
      }
      
      if let temp = placemark.postalCode
      {
	 line2 = line2 + temp + " "
      }
      
      return line1 + "\n" + line2
   }
   
   @objc func didTimeOut()
   {
      print("*** Time Out")
      
      if location == nil
      {
	 stopLocationManager()
	 lastLocationError = NSError(
	    domain: "MyLocationsErrorDomain",
	    code: 1,
	    userInfo: nil)
	 
	 updateLabels()
      }
   }
}

