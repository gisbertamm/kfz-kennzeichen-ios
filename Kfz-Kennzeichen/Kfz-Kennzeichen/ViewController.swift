//
//  ViewController.swift
//  Kfz-Kennzeichen
//
//  Created by Gisbert Amm on 15.07.15.
//  Copyright (c) 2015 Gisbert Amm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        let savedEntry = SavedEntry()

        if (segue!.identifier! == "showDetail") {
            savedEntry.code = "Search"
            savedEntry.district = "SearchDistrict"
            savedEntry.district_center = "SearchDistrictCenter"
            savedEntry.jokes.append("SearchJoke 1")
            savedEntry.jokes.append("SearchJoke 2")
        }
        else if (segue!.identifier! == "showRandomDetail") {
            savedEntry.code = "Random"
            savedEntry.district = "RandomDistrict"
            savedEntry.district_center = "RandomDistrictCenter"
            savedEntry.jokes.append("RandomJoke 1")
            savedEntry.jokes.append("RandomJoke 2")
        } else {
            savedEntry.code = "unknown segue"
        }
        
        var detailViewControler: DetailViewController = segue!.destinationViewController as DetailViewController
        detailViewControler.savedEntry = savedEntry
    }
}

