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
        var detailViewControler: DetailViewController = segue!.destinationViewController as DetailViewController
        if (segue!.identifier! == "showDetail") {
            detailViewControler.receivedString = "Search"
        }
        else if (segue!.identifier! == "showRandomDetail") {
            detailViewControler.receivedString = "Random"
        } else {
            detailViewControler.receivedString = "unknown segue"
        }
    }
}

