//
//  Datamodel.swift
//  doutra
//
//  Created by Artemiy Shlesberg on 28.02.16.
//  Copyright © 2016 Shlesberg. All rights reserved.
//

import Foundation

 class Datamodel {
    
    static var databaseInstance : FMDatabase?
    static var currentUser : User?
    
    class func initBase() -> Bool {
        
        let filemgr = NSFileManager.defaultManager()
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as NSString
        
        let databasePath = docsDir.stringByAppendingPathComponent("doutra.db")
        
        databaseInstance = FMDatabase(path: databasePath as String)
        
        if !filemgr.fileExistsAtPath(databasePath as String) {
            
            
            
            if databaseInstance == nil {
                print("Error: \(databaseInstance!.lastErrorMessage())")
                return false
            }
            if databaseInstance!.open() {
                
                
                let sql_stmt_user = "CREATE TABLE IF NOT EXISTS USER (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, SURNAME TEXT, PHONE TEXT, PHOTO_URL TEXT)"
                if !databaseInstance!.executeStatements(sql_stmt_user) {
                    print("Error: \(databaseInstance!.lastErrorMessage())")
                     return false
                }
                let sql_stmt_place = "CREATE TABLE IF NOT EXISTS PLACE (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADRESS TEXT, RATE REAL, PHOTO_URL TEXT, NUMBEROFRATES INTEGER)"
                if !databaseInstance!.executeStatements(sql_stmt_place) {
                    print("Error: \(databaseInstance!.lastErrorMessage())")
                     return false
                }
                let sql_stmt_comment = "CREATE TABLE IF NOT EXISTS COMMENT (ID INTEGER PRIMARY KEY AUTOINCREMENT, MESSAGE TEXT, USER_ID INTEGER, PLACE_ID INTEGER, DATE TEXT)"
                if !databaseInstance!.executeStatements(sql_stmt_comment) {
                    print("Error: \(databaseInstance!.lastErrorMessage())")
                     return false
                }
                
                databaseInstance?.close()
                return true
            }
        }
        
        
        return true
    }
    
    class func saveItem (comment : Comment) -> Bool{
        databaseInstance?.open()
        let insertSQL = "INSERT INTO COMMENT (MESSAGE, USER_ID, PLACE_ID, DATE) VALUES ('\(comment.message)', '\(comment.userID)', '\(comment.placeID)','\(comment.dateAsString())' )"
        
        let result = databaseInstance!.executeUpdate(insertSQL, withArgumentsInArray: nil)
        databaseInstance?.close()

        if !result {
            print("Failed to add contact")
            print("Error: \(databaseInstance!.lastErrorMessage())")
            return false
        } else {
            return true
        }
    }
    class func saveItem (user : User)-> Bool {
        databaseInstance?.open()
        let insertSQL = "INSERT INTO USER (name, surname, phone, photo_url) VALUES ('\(user.name)', '\(user.surname)', '\(user.phone)', '\(user.photoURL)')"
        
        let result = databaseInstance!.executeUpdate(insertSQL, withArgumentsInArray: nil)
        databaseInstance?.close()

        if !result {
            print("Failed to add contact")
            print("Error: \(databaseInstance!.lastErrorMessage())")
            return false
        } else {
            return true
        }
    }
    class func saveItem (place : Place) -> Bool{
        databaseInstance?.open()
        
        let insertSQL = "INSERT INTO PLACE (name, adress, rate, photo_url, NUMBEROFRATES) VALUES  ('\(place.name)', '\(place.adress)', \(place.rate), '\(place.photoURL)', 0 )"
        
        let result = databaseInstance!.executeUpdate(insertSQL, withArgumentsInArray: nil)
        databaseInstance?.close()

        if !result {
            print("Failed to add contact")
            print("Error: \(databaseInstance!.lastErrorMessage())")
            return false
        } else {
            return true
        }
    }
    
    class func getPlacesByRate() -> [Place] {
        
        var places : [Place] = []
        databaseInstance?.open()
        
        let querySQL = "SELECT * FROM PLACE ORDER BY rate DESC"
        
        let results:FMResultSet? = databaseInstance!.executeQuery(querySQL,
            withArgumentsInArray: nil)
        
        while results?.next() == true {
            let r = (results?.resultDictionary())!
            let p = Place(dict: r)
            places.append(p)
            
        }
        databaseInstance?.close()
        
        return places
    }
    
    class func getCommentsOfPlace(placeID : Int) -> [Comment] {
        
        var comments : [Comment] = []
        databaseInstance?.open()
        let querySQL = "SELECT * FROM COMMENT WHERE PLACE_ID = \(placeID) ORDER BY DATE"
        
        let results:FMResultSet? = databaseInstance!.executeQuery(querySQL,
            withArgumentsInArray: nil)
        
        while results?.next() == true {
            let r = (results?.resultDictionary())!
            let p = Comment(dict: r)
            comments.append(p)
            
        }
        databaseInstance?.close()

        return comments
    }
    
    class func getCommentAuthor(comment : Comment)-> User {
        databaseInstance?.open()

        
        let querySQL = "SELECT * FROM USER WHERE ID = '\(comment.userID)'"
        let results:FMResultSet? = databaseInstance!.executeQuery(querySQL,
            withArgumentsInArray: nil)
        
        var u : User = User()
        if results?.next() == true {
            let r = (results?.resultDictionary())!
            u = User(dict: r)
            
        }
        databaseInstance?.close()
        return u
    }
    
    class func setCurrentUser(surname : String, phone : String) {
        databaseInstance?.open()
        
        let querySQL = "SELECT * FROM USER WHERE SURNAME = '\(surname)' AND PHONE = '\(phone)'"
        
        let results:FMResultSet? = databaseInstance!.executeQuery(querySQL,
            withArgumentsInArray: nil)
        
        if results?.next() == true {
            let r = (results?.resultDictionary())!
            let u = User(dict: r)
            currentUser = u
            print(u.id)
            NSUserDefaults.standardUserDefaults().setValue(surname, forKey: "currentUserSurname")
            NSUserDefaults.standardUserDefaults().setValue(phone, forKey: "currentUserPhone")
        }
        
        
        databaseInstance?.close()
        
    }
    
    class func dropTable(tableName : String) {
        databaseInstance?.open()
        let querySQL = "DROP TABLE \(tableName)"
        
        let results = databaseInstance!.executeQuery(querySQL,
            withArgumentsInArray: nil)
        
        
        databaseInstance?.close()
    }
    
    class func updatePlace(place : Place) {
        databaseInstance?.open()
        
        let querySQL = "UPDATE PLACE SET NUMBEROFRATES = \(place.numberOfRates), RATE = \(place.rate) WHERE ID = \(place.id)"
        
        let result = databaseInstance!.executeUpdate(querySQL, withArgumentsInArray:nil)
        
        if !result {
            print("Failed to add contact")
            print("Error: \(databaseInstance!.lastErrorMessage())")
        }
        
        
        databaseInstance?.close()
    }
    
}