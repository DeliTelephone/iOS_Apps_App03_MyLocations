   //
   //  Location+CoreDataProperties.swift
   //  MyLocations
   //
   //  Created by Nick "Fox" Borer on 02/14/2023.
   //

import Foundation
import CoreData
import CoreLocation



extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location>
    {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var locationDesription: String
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?
    @NSManaged public var photoID: NSNumber?
   

}

extension Location : Identifiable
{

}
