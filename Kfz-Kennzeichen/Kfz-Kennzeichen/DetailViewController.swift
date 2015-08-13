//
//  DetailViewController.swift
//  Kfz-Kennzeichen
//
//  Created by Gisbert Amm on 15.07.15.
//  Copyright (c) 2015 Gisbert Amm. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var savedEntry: SavedEntry?
    
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var district: UILabel!
    @IBOutlet weak var districtCenter: UILabel!
    @IBOutlet weak var jokes: UILabel!
    @IBOutlet weak var jokes2: UILabel!
    @IBOutlet weak var jokes3: UILabel!
    @IBOutlet weak var jokes4: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        savedEntry = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        code.text = savedEntry!.code
        district.text = savedEntry!.district
        districtCenter.text = savedEntry!.district_center
        if (savedEntry?.jokes.count > 0) {
            jokes.text = savedEntry!.jokes[0]
        }
        if (savedEntry?.jokes.count > 1) {
            jokes2.text = savedEntry!.jokes[1]
        }
        if (savedEntry?.jokes.count > 2) {
            jokes3.text = savedEntry!.jokes[2]
        }
        if (savedEntry?.jokes.count > 3) {
            jokes4.text = savedEntry!.jokes[3]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
