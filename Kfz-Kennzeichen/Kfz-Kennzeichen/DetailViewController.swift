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
    var textField: UITextField?
    let maxLengthOfProposal = 30
    
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var district: UILabel!
    @IBOutlet weak var districtCenter: UILabel!
    @IBOutlet weak var jokes: UILabel!
    @IBOutlet weak var jokes2: UILabel!
    @IBOutlet weak var jokes3: UILabel!
    @IBOutlet weak var jokes4: UILabel!
    @IBAction func proposeJoke(sender: UIButton) {
        var proposeAlert = UIAlertController(title: "Eigenen Spruch vorschlagen", message: "Bitte Text eingeben (maximal " + String(self.maxLengthOfProposal) + " Zeichen).", preferredStyle: UIAlertControllerStyle.Alert)
        
        proposeAlert.addAction(UIAlertAction(title: "Vorschlagen", style: .Default, handler: { (action: UIAlertAction!) in
            if (self.textField!.text.isEmpty) {
                var emptyJokeAlert = UIAlertController(title: "Kein Text eingegeben", message: "Bitte Text eingeben.", preferredStyle: UIAlertControllerStyle.Alert)
                emptyJokeAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction!) in
                    println("Proposal was empty.")
                    // do nothing
                }))
                self.presentViewController(emptyJokeAlert, animated: true, completion: nil)
            } else {
                if (self.textField!.text.utf16Count > self.maxLengthOfProposal) {
                    var tooLongJokeAlert = UIAlertController(title: "Text ist zu lang", message: "Der Text darf nicht länger sein als " + String(self.maxLengthOfProposal) + " Zeichen.", preferredStyle: UIAlertControllerStyle.Alert)
                    tooLongJokeAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction!) in
                        println("Proposal was too long.")
                        // do nothing
                    }))
                    self.presentViewController(tooLongJokeAlert, animated: true, completion: nil)
                } else {
                    println("Proposal: " + self.textField!.text);
                    var url = NSURL(string: "https://api.mailgun.net/v3/sandbox47fa9b0a752440c794641c362d468402.mailgun.org/messages")
                    var request = NSMutableURLRequest(URL: url!)
                    request.HTTPMethod = "POST"
                    let loginString = NSString(format: "%@:%@", "api", "")
                    let loginData: NSData! = loginString.dataUsingEncoding(NSUTF8StringEncoding)
                    let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
                    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                    
                    var bodyData = "from=In-App-Proposal <kfz-kennzeichen-spruch-vorschlag@web.de>&to=kfz-kennzeichen-spruch-vorschlag@web.de&subject=Neuer Vorschlag für Kennzeichen-Joke (iOS)&text=code: " + self.code!.text! + ", Vorschlag: " + self.textField!.text
                    request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
                    
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
                        {
                            (response, data, error) in
                            if (error != nil) {
                                self.displayProposalError(error.description)
                            } else {
                                if let HTTPResponse = response as? NSHTTPURLResponse {
                                    let statusCode = HTTPResponse.statusCode
                                    let status = HTTPResponse.description
                                    
                                    if statusCode == 200 {
                                        println(NSString(data: data, encoding: NSUTF8StringEncoding))
                                        var successAlert = UIAlertController(title: "Danke!", message: "Der Vorschlag wurde erfolgreich übermittelt", preferredStyle: UIAlertControllerStyle.Alert)
                                            successAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction!) in
                                            // do nothing
                                        }))
                                        self.presentViewController(successAlert, animated: true, completion: nil)
                                    } else {
                                        self.displayProposalError("HTTP " + String(statusCode) + ": " + self.description)
                                    }
                                }
                            }
                    }
                }
            }
        }))
        
        proposeAlert.addAction(UIAlertAction(title: "Abbrechen", style: .Default, handler: { (action: UIAlertAction!) in
            println("Cancelled. No proposal made.")
        }))
        
        proposeAlert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        presentViewController(proposeAlert, animated: true, completion: nil)
    }
    
    func displayProposalError(error: String) {
        var successAlert = UIAlertController(title: "Tut uns leid", message: "Der Vorschlag konnte leider nicht übermittelt werden. Fehler: " + error, preferredStyle: UIAlertControllerStyle.Alert)
        successAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction!) in
            // do nothing
        }))
        self.presentViewController(successAlert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!)
    {
        if let tField = textField {
            self.textField = textField! //Save reference to the UITextField
        }
    }

    
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
