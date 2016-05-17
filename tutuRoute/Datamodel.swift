//
//  Datamodel.swift
//  doutra
//
//  Created by Artemiy Shlesberg on 28.02.16.
//  Copyright © 2016 Shlesberg. All rights reserved.
//

import Foundation
import FMDB

//класс для работы с базой данных, испольщующий библиотеку FMDB
class Datamodel {
    
    static var databaseInstance : FMDatabase?
    static var databaseQueue : FMDatabaseQueue?
    
    class func initBase() -> Bool {
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        
        let databasePath = docsDir.stringByAppendingPathComponent("tutu.db")
        
        databaseInstance = FMDatabase(path: databasePath as String)
        
        databaseQueue = FMDatabaseQueue(path: databasePath as String)
        
            
            
        if databaseInstance == nil {
            print("Error: \(databaseInstance!.lastErrorMessage())")
            return false
        }
        if databaseInstance!.open() {
            
            
            let sql_stmt_station_from_base = "CREATE TABLE IF NOT EXISTS STATION (ID INTEGER PRIMARY KEY AUTOINCREMENT, countryTitle TEXT, districtTitle TEXT, cityId INTEGER, cityTitle TEXT, regionTitle TEXT, stationId INTEGER, stationTitle TEXT,longitude REAL, latitude REAL, direction INTEGER)"
            if !databaseInstance!.executeStatements(sql_stmt_station_from_base) {
                print("Error: \(databaseInstance!.lastErrorMessage())")
                 return false
            }
            
            databaseInstance?.close()
            return true
        }
        
        return true
    }
    
    //сохранение станции в базу данных 
    
    class func saveStation(station : Station) -> Bool{
        databaseInstance?.open()
        let insertSQL = "INSERT INTO STATION (countryTitle , districtTitle , cityId , cityTitle , regionTitle , stationId , stationTitle ,longitude , latitude, direction) VALUES ('\(station.countryTitle)', '\(station.districtTitle)', \(station.cityId),'\(station.cityTitle)', '\(station.regionTitle)', \(station.stationId), '\(station.stationTitle)', \(station.point.x), \(station.point.y), \(station.direction.rawValue))"
        
        let result = databaseInstance!.executeUpdate(insertSQL, withArgumentsInArray: nil)
        databaseInstance?.close()

        if !result {
            print("Failed to add station")
            print("Error: \(databaseInstance!.lastErrorMessage())")
            return false
        } else {
            return true
        }
    }
    
    //метод, который переписывает содержимое json файла в базу данных
    //для каждой станции указывается ее направление 
    
    class func fillBase() {
        if let path = NSBundle.mainBundle().pathForResource("stations", ofType: "json")
        {
            do {
               let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    
                let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                    if let citiesFrom : NSArray = jsonResult["citiesFrom"] as? NSArray
                    {
                        for city in citiesFrom {
                            if let stations = city["stations"] as? NSArray {
                                for stationDict in stations {
                                    
                                    
                                    let station = Station(jsonDict: stationDict as! [NSObject : AnyObject], withDirection: Direction.From)
                                    
                                    saveStation(station)
                                    
                                }
                            }
                        }
                    }
                    
                    if let citiesFrom : NSArray = jsonResult["citiesTo"] as? NSArray
                    {
                        for city in citiesFrom {
                            if let stations = city["stations"] as? NSArray {
                                for stationDict in stations {
                                    let station = Station(jsonDict: stationDict as! [NSObject : AnyObject], withDirection: Direction.To)
                                    saveStation(station)
                                }
                            }
                        }
                    }

                }
            } catch {
                print("error while reading file")
            }
            
        }
    }
    
    class func getCitiesList(direction : Direction) -> [String]  {
        databaseInstance?.open()
        
        let querySQL = "SELECT DISTINCT cityTitle FROM STATION WHERE direction = \(direction.rawValue) ORDER BY cityTitle ASC"
        
                var cities : [String] = []
        databaseQueue!.inTransaction { db, rollback in
            
            let results:FMResultSet? = db.executeQuery(querySQL,
                withArgumentsInArray: nil)
            while results?.next() == true {
                
                let r = (results?.resultDictionary())!
                let city = r["cityTitle"] as! String
                
                cities.append(city)
            }
            
        }
        databaseInstance?.close()
        return cities
    }
    
    class func getStationsOfCity(nammed city: String, direction : Direction) -> [Station]  {
        databaseInstance?.open()
        let querySQL = "SELECT * FROM STATION WHERE cityTitle = '\(city)' AND direction = \(direction.rawValue)"
        var stations : [Station] = []
        
        databaseQueue!.inTransaction { db, rollback in
            let results:FMResultSet? = db.executeQuery(querySQL,
                                                                      withArgumentsInArray: nil)
            
            while results?.next() == true {
                
                let r = (results?.resultDictionary())!
                let station = Station(dict: r)
                
                stations.append(station)
            }
        }
        databaseInstance?.close()
        return stations
    }
    
    class func searchForCitiesWithStations(containsString str: String, direction : Direction) -> [String] {
        databaseInstance?.open()
        let querySQL = "SELECT DISTINCT cityTitle FROM STATION WHERE stationTitle LIKE '%\(str)%' AND direction = \(direction.rawValue) ORDER BY cityTitle ASC"
        var cities : [String] = []
        databaseQueue!.inTransaction { db, rollback in
            
            let results:FMResultSet? = db.executeQuery(querySQL,
                withArgumentsInArray: nil)
            while results?.next() == true {
                
                let r = (results?.resultDictionary())!
                let city = r["cityTitle"] as! String
                
                cities.append(city)
            }
            
        }
        databaseInstance?.close()

        return cities
    }
    
    class func searchForStationsOfCity(nammed city: String, containsString str: String, direction : Direction)->[Station] {
        databaseInstance?.open()
        let querySQL = "SELECT * FROM STATION WHERE stationTitle LIKE '%\(str)%' AND cityTitle = '\(city)' AND direction = \(direction.rawValue)"
        var stations : [Station] = []
        databaseQueue!.inTransaction { db, rollback in
            let results:FMResultSet? = db.executeQuery(querySQL,
                                                                      withArgumentsInArray: nil)
            
            while results?.next() == true {
                
                let r = (results?.resultDictionary())!
                let station = Station(dict: r)
                
                stations.append(station)
            }
        }
        databaseInstance?.close()

        return stations
    }

}