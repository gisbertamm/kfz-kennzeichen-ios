//
//  SQLiteDatabase.swift
//  SwiftSQLite
//
//  Created by Chris on 4/07/2014.
//  Copyright (c) 2014 Victory One Media Pty Ltd. All rights reserved.
//

import Foundation

let blankDatabaseFilename:String = "NumberplateCodesManager.sqlite"
let instanceDatabaseFilename:String = "NumberplateCodesManager.sqlite"

var _SQLiteDatabase:SQLiteDatabase?

class SQLiteDatabase : NSObject {
    
    var cDb:COpaquePointer = nil
    
    override init () {
        
    }
    
    func open( filename:String ) -> SQLiteStatusCode {
        
        var cFilename = filename.cStringUsingEncoding(NSUTF8StringEncoding)
        
        return SQLiteStatusCode(rawValue: sqlite3_open(cFilename!, &self.cDb))!
    }
    
    class func deleteDatabase() {
        
        if let pathToResources = NSBundle.mainBundle().resourcePath {
            
            var pathToDocuments = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            
            var documentsDirectory:AnyObject = pathToDocuments[0]
            
            var databasePath = documentsDirectory.stringByAppendingPathComponent(instanceDatabaseFilename)
            
            if ( NSFileManager.defaultManager().isReadableFileAtPath(databasePath) ) {
                
                var error:NSError?
                
                if ( !NSFileManager.defaultManager().removeItemAtPath(databasePath, error: &error) ) {
                    
                    println(error)
                    
                    println("Failed to delete database")
                }
            }
        }
    }
    
    func copyDatabase() -> String? {
        
        if let pathToResources = NSBundle.mainBundle().resourcePath {
            
            var blankDatabasePath = pathToResources.stringByAppendingPathComponent(blankDatabaseFilename)
            
            var pathToDocuments = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            
            var documentsDirectory:AnyObject = pathToDocuments[0]
            
            var databasePath = documentsDirectory.stringByAppendingPathComponent(instanceDatabaseFilename)
            
            println( "database path: \(databasePath)" )
            
            if ( !NSFileManager.defaultManager().isReadableFileAtPath(databasePath) ) {
                
                var error:NSError?
                
                if ( !NSFileManager.defaultManager().copyItemAtPath(blankDatabasePath, toPath: databasePath, error: &error)) {
                    
                    println(error)
                    
                    println("Failed to initialize database")
                    
                    return nil
                }
            }
            
            return databasePath
        }
        
        return nil
    }
    
    // MARK: Transaction
    
    func beginTransaction() -> SQLiteStatusCode {
        
        var cSqlQuery = "BEGIN TRANSACTION".cStringUsingEncoding(NSUTF8StringEncoding)
        
        var cStatusCode = sqlite3_exec(self.cDb, cSqlQuery!, nil, nil, nil)
        
        return SQLiteStatusCode(rawValue: cStatusCode)!
    }
    
    func commitTransaction() -> SQLiteStatusCode {
        
        var cSqlQuery = "COMMIT TRANSACTION".cStringUsingEncoding(NSUTF8StringEncoding)
        
        var cStatusCode = sqlite3_exec(self.cDb, cSqlQuery!, nil, nil, nil)
        
        return SQLiteStatusCode(rawValue: cStatusCode)!
    }
    
    // MARK: Error
    
    func getErrorMessage() -> String? {
        return String.fromCString(sqlite3_errmsg(self.cDb))
    }
}


