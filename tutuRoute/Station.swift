//
//  Station.swift
//  tutuRoute
//
//  Created by Артмеий Шлесберг on 14/05/16.
//  Copyright © 2016 Shlesberg. All rights reserved.
//

import Foundation
import UIKit

enum Direction : Int {
    case To = 0
    case From = 1
}

//класс представляющий станции в приложении
class Station : NSObject {
        // именование страны – денормализация данных, дубль из города
    var countryTitle : String
        // Координаты станции (в общем случае отличаются от координат города)
    var point : CGPoint
    
    var districtTitle : String
        // идентификатор города (обратная ссылка на город)
    var cityId : Int
        // наименование города (обратная ссылка на город)
    var cityTitle : String
        // именование региона
    var regionTitle : String
        // идентификатор станции
    var stationId : Int
        // полное именование станции
    var stationTitle : String
        // станция отпрааления или прибытия
    var direction : Direction
    
    //конструктор для создания станции из джисона с указанием направления
    
    init (jsonDict : [NSObject : AnyObject], withDirection direct : Direction) {
        countryTitle = jsonDict["countryTitle"] as! String
        let p = jsonDict["point"] as! NSDictionary
        point = CGPoint(x: p["longitude"] as! CGFloat, y: p["latitude"] as! CGFloat)
        districtTitle = jsonDict["districtTitle"] as! String
        cityId = jsonDict["cityId"] as! Int
        cityTitle = jsonDict["cityTitle"] as! String
        regionTitle = jsonDict["regionTitle"] as! String
        stationId = jsonDict["stationId"] as! Int
        stationTitle = jsonDict["stationTitle"] as! String
        direction = direct
    }
    //конструктор для создания из ответа базы данных с указанием направления
    
    init (dict : [NSObject : AnyObject], withDirection direct : Direction) {
        countryTitle = dict["countryTitle"] as! String
        point = CGPoint(x: dict["longitude"] as! CGFloat, y: dict["latitude"] as! CGFloat)
        districtTitle = dict["districtTitle"] as! String
        cityId = dict["cityId"] as! Int
        cityTitle = dict["cityTitle"] as! String
        regionTitle = dict["regionTitle"] as! String
        stationId = dict["stationId"] as! Int
        stationTitle = dict["stationTitle"] as! String
        direction = direct
    }
    //создание из джисона с входящим в него направлением
    
    init (jsonDict : [NSObject : AnyObject]) {
        countryTitle = jsonDict["countryTitle"] as! String
        let p = jsonDict["point"] as! NSDictionary
        point = CGPoint(x: p["longitude"] as! CGFloat, y: p["latitude"] as! CGFloat)
        districtTitle = jsonDict["districtTitle"] as! String
        cityId = jsonDict["cityId"] as! Int
        cityTitle = jsonDict["cityTitle"] as! String
        regionTitle = jsonDict["regionTitle"] as! String
        stationId = jsonDict["stationId"] as! Int
        stationTitle = jsonDict["stationTitle"] as! String
        direction = Direction(rawValue: jsonDict["direction"] as! Int)!

    }
    //создание из ответа базы с входящим в него направлением
    init (dict : [NSObject : AnyObject]) {
        countryTitle = dict["countryTitle"] as! String
        point = CGPoint(x: dict["longitude"] as! CGFloat, y: dict["latitude"] as! CGFloat)
        districtTitle = dict["districtTitle"] as! String
        cityId = dict["cityId"] as! Int
        cityTitle = dict["cityTitle"] as! String
        regionTitle = dict["regionTitle"] as! String
        stationId = dict["stationId"] as! Int
        stationTitle = dict["stationTitle"] as! String
        direction = Direction(rawValue: dict["direction"] as! Int)!
        
    }
    


    
}