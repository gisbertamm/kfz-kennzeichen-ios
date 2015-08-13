//
//  ViewController.swift
//  Kfz-Kennzeichen
//
//  Created by Gisbert Amm on 15.07.15.
//  Copyright (c) 2015 Gisbert Amm. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    let databaseName = "NumberplateCodesManager.sqlite"

    @IBOutlet weak var carSymbol: UILabel!
    @IBOutlet weak var CodeInput: UITextField!
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var RandomButton: UIButton!
    
    @IBAction func SearchAction(sender: UIButton) {
    }
    
    
    @IBAction func RandomAction(sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        carSymbol.text = "\u{1f697}"
        carSymbol.font = carSymbol.font.fontWithSize(72)
        carSymbol.textAlignment = .Center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let savedEntry = SavedEntry()
        
        createEditableCopyOfDatabaseIfNeeded()
        
        var db = SQLiteDatabase();
        db.open(getWritableDBPath());
        
        var code = "";

        if (segue!.identifier! == "showDetail") {
            
            var statement = SQLiteStatement(database: db);
            
            if ( statement.prepare("SELECT * FROM numberplate_codes WHERE code = ?") != .Ok )
            {
                /* handle error */
            }
            
            statement.bindString(1, value: CodeInput.text);
            
            if ( statement.step() == .Row )
            {
                code = mapData(statement, savedEntry: savedEntry);
            }
            
            statement.finalizeStatement();
        }
        else if (segue!.identifier! == "showRandomDetail") {
            var statement = SQLiteStatement(database: db);
            
            if ( statement.prepare("SELECT * FROM numberplate_codes ORDER BY RANDOM() LIMIT 1") != .Ok )
            {
                /* handle error */
            }
            
            statement.bindString(1, value: CodeInput.text);
            
            if ( statement.step() == .Row )
            {
                code = mapData(statement, savedEntry: savedEntry);
            }
            
            statement.finalizeStatement();
        } else {
            savedEntry.code = "unknown segue"
        }
        
        // add jokes
        var statement = SQLiteStatement(database: db);
        if ( statement.prepare("SELECT jokes FROM jokes WHERE code = ?") != .Ok )
        {
            /* handle error */
        }
        
        statement.bindString(1, value: code);
        
        while ( statement.step() == .Row )
        {
            savedEntry.jokes.append(statement.getStringAt(0)!)
        }
        
        statement.finalizeStatement();
        
        
        // display data
        var detailViewControler: DetailViewController = segue!.destinationViewController as DetailViewController
        detailViewControler.savedEntry = savedEntry
    }
    
    func mapData(statement: SQLiteStatement, savedEntry: SavedEntry) -> String {
        savedEntry.code = statement.getStringAt(1)!
        savedEntry.district = statement.getStringAt(2)!
        savedEntry.district_center = statement.getStringAt(3)!
        savedEntry.state = statement.getStringAt(3)!
        savedEntry.district_wikipedia_url = statement.getStringAt(5)!
        
        return savedEntry.code;
    }
    
    func getWritableDBPath() -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        return docsDir + databaseName
    }
    
    func createEditableCopyOfDatabaseIfNeeded() {
        var databasePath = getWritableDBPath()
        
    var fileManager = NSFileManager()
        if (fileManager.fileExistsAtPath(databasePath)) {
            return
        } else {
            // copy the database to the appropriate location
            let defaultDBPath = NSBundle.mainBundle().pathForResource(databaseName, ofType: nil)
            var error:NSError?
            var success = fileManager.copyItemAtPath(defaultDBPath!, toPath: databasePath, error: &error)
            
            if (!success){
               exit(Int32(error!.code))
            }
        }
    }
}

