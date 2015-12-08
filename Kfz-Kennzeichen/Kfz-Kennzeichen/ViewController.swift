//
//  ViewController.swift
//  Kfz-Kennzeichen
//
//  Created by Gisbert Amm on 15.07.15.
//  Copyright (c) 2015 Gisbert Amm. All rights reserved.
//

import UIKit
import Darwin
import SQLite

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var carSymbol: UILabel!
    @IBOutlet weak var CodeInput: UITextField!
    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var RandomButton: UIButton!
    @IBOutlet weak var baseConstraint: NSLayoutConstraint!
    
    @IBAction func SearchAction(sender: UIButton) {
    }
    
    
    @IBAction func RandomAction(sender: UIButton) {
    }
    
    let databaseName = "NumberplateCodesManager.sqlite"
    let idColumn = Expression<String>("_id")
    let codeColumn = Expression<String>("code")
    let districtColumn = Expression<String>("district")
    let district_centerColumn = Expression<String>("district_center")
    let stateColumn = Expression<String>("state")
    let district_wikipedia_urlColumn = Expression<String>("district_wikipedia_url")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CodeInput.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        carSymbol.text = "\u{1f697}"
        carSymbol.font = carSymbol.font.fontWithSize(96)
        carSymbol.textAlignment = .Center
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let savedEntry = SavedEntry()
        
        createEditableCopyOfDatabaseIfNeeded()
        
        var db:Connection
        var numberplate_codes: Table
        var jokes: Table
        
        do {
            db = try Connection(getWritableDBPath());
            numberplate_codes = Table("numberplate_codes")
            jokes = Table("jokes")
            
            if (segue!.identifier! == "showDetail") {
                
                let row = Array(db.prepare(numberplate_codes.select(idColumn, codeColumn, districtColumn, district_centerColumn, stateColumn, district_wikipedia_urlColumn).filter(codeColumn == CodeInput.text!.uppercaseString)))
                
                if (row.isEmpty) {
                    // nothing found
                    savedEntry.code = "Dieses Kennzeichen gibt es nicht."
                } else {
                    mapData(row.first!, savedEntry: savedEntry);
                }
                
                // empty out input field for next search
                CodeInput.text = ""
            }
            else if (segue!.identifier! == "showRandomDetail") {
                // empty input field
                CodeInput.text = ""
                
                for row in db.prepare("SELECT * FROM numberplate_codes ORDER BY RANDOM() LIMIT 1") {
                    savedEntry.code = row[1] as! String
                    savedEntry.district = row[2] as! String
                    savedEntry.district_center = row[3] as! String
                    savedEntry.state = row[4] as! String
                    savedEntry.district_wikipedia_url = row[5] as! String
                }
                
                
            } else {
                savedEntry.code = "unknown segue"
            }
            
            addJokes(db, jokes: jokes, savedEntry: savedEntry)
            
            if savedEntry.code.isEmpty {
                let emptyEntryAlert = UIAlertController(title: "Unbekannt", message: "Dieses Kennzeichen gibt es nicht.", preferredStyle: UIAlertControllerStyle.Alert)
                emptyEntryAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction) in
                    print("Unknown code or empty search.")
                    // do nothing
                }))
                self.presentViewController(emptyEntryAlert, animated: true, completion: nil)
            } else {
                // display data
                let detailViewControler: DetailViewController = segue!.destinationViewController as! DetailViewController
                detailViewControler.savedEntry = savedEntry
            }
        } catch {
            // TODO
        }
    }
    
    func mapData(row: Row, savedEntry: SavedEntry) {
        //savedEntry.id = row[idColumn]
        savedEntry.code = row[codeColumn]
        savedEntry.district = row[districtColumn]
        savedEntry.district_center = row[district_centerColumn]
        savedEntry.state = row[stateColumn]
        savedEntry.district_wikipedia_url = row[district_wikipedia_urlColumn]
    }
    
    func addJokes(db:Connection, jokes: Table, savedEntry: SavedEntry) {
        let jokesColumn = Expression<String>("jokes")
        
        for jokeRow in db.prepare(jokes.select(jokesColumn).filter(codeColumn == savedEntry.code))
        {
            savedEntry.jokes.append(jokeRow[jokesColumn])
        }
        
    }
    
    func getWritableDBPath() -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        
        let docsDir = dirPaths[0] as String
        return docsDir + "/" + databaseName
    }
    
    func createEditableCopyOfDatabaseIfNeeded() {
        let databasePath = getWritableDBPath()
        
        let fileManager = NSFileManager()
        if (fileManager.fileExistsAtPath(databasePath)) {
            return
        } else {
            // copy the database to the appropriate location
            let defaultDBPath = NSBundle.mainBundle().pathForResource(databaseName, ofType: nil)
            var error:NSError?
            var success: Bool
            do {
                try fileManager.copyItemAtPath(defaultDBPath!, toPath: databasePath)
                success = true
            } catch let error1 as NSError {
                error = error1
                success = false
            }
            
            if (!success){
                print("Could not copy database from " + defaultDBPath! + " to " + databasePath)
                print(error?.description)
                exit(Int32(error!.code))
            }
        }
    }
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    func keyboardWillShow(sender: NSNotification) {
        animateTextFieldWithKeyboard(sender)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        animateTextFieldWithKeyboard(sender)
    }
    
    // move all controls up when the keyboard appers
    // followed some advices from http://stackoverflow.com/questions/25693130/move-textfield-when-keyboard-appears-swift
    // TODO consider orientation changes etc. - see http://macoscope.com/blog/working-with-keyboard-on-ios/
    func animateTextFieldWithKeyboard(notification: NSNotification) {
        
        let userInfo = notification.userInfo!
        
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        // baseContraint is your Auto Layout constraint that pins the
        // text view to the bottom of the superview.
        
        if notification.name == UIKeyboardWillShowNotification {
            baseConstraint.constant = +keyboardSize.height  // move up
        }
        else {
            baseConstraint.constant = 0 // move down
        }
        
        view.setNeedsUpdateConstraints()
        
        let options = UIViewAnimationOptions(rawValue: UInt(curve << 16))
        UIView.animateWithDuration(duration, delay: 0, options: options,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

