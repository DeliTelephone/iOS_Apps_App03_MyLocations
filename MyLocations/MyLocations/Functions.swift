//
//  Functions.swift
//  MyLocations
//
//  Created by Fox on 2/12/23.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void)
{
   DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
