//
//  Functions.swift
//  MyLocations
//
//  Created by Nick "Fox" Borer on 02/14/2023.
//

import Foundation
import CoreData
import CoreLocation

func afterDelay(_ seconds: Double, run: @escaping () -> Void)
{
   DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

let dataSaveFailedNotification = Notification.Name(rawValue: "DataSaveFailedNotification")

func fatalCoreDataError(_ error: Error)
{
   print("*** Fatal Error: \(error)")
   NotificationCenter.default.post(name: dataSaveFailedNotification, object: nil)
}

let applicationDocumentsDirectory: URL =
{
   let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

   return paths[0]
} ()


