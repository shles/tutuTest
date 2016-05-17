//
//  StationDataController.swift
//  tutuRoute
//
//  Created by Артмеий Шлесберг on 17/05/16.
//  Copyright © 2016 Shlesberg. All rights reserved.
//

import Foundation


protocol  StationDataControllerDelegate {
    func didRecievedStations(cities : [String], stations : [String : [Station]])
}
class StationsLoader {
    var actual : Bool = true
    var delegate : StationDataControllerDelegate?
    
    func getStations(withSearchString searchText : String, byDirection direction : Direction){
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            
            let newCitiesForFilteredStations =  Datamodel.searchForCitiesWithStations(containsString: searchText, direction: direction)
            var newFilteredStations = [String:[Station]]()
            
            for city in newCitiesForFilteredStations {
                if self.actual {
                    newFilteredStations[city] = Datamodel.searchForStationsOfCity(nammed: city, containsString: searchText, direction: direction)
                } else {
                    return
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if self.actual {
                    self.delegate?.didRecievedStations(newCitiesForFilteredStations, stations: newFilteredStations)
                }
            })
        })
    }
}