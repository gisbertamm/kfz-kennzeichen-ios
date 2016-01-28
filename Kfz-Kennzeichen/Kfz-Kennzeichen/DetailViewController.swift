//
//  DetailViewController.swift
//  Kfz-Kennzeichen
//
//  Created by Gisbert Amm on 15.07.15.
//  Copyright (c) 2015 Gisbert Amm. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var savedEntry: SavedEntry?
    var textField: UITextField?
    let maxLengthOfProposal = 30
    
    @IBOutlet weak var crestImage: UIImageView!
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var district: UILabel!
    @IBOutlet weak var districtCenter: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var dynamicTVHeight: NSLayoutConstraint!
    
    @IBAction func proposeJoke(sender: UIButton) {
        let proposeAlert = UIAlertController(title: "Eigenen Spruch vorschlagen", message: "Bitte Text eingeben (maximal " + String(self.maxLengthOfProposal) + " Zeichen).", preferredStyle: UIAlertControllerStyle.Alert)
        
        proposeAlert.addAction(UIAlertAction(title: "Vorschlagen", style: .Default, handler: { (action: UIAlertAction) in
            if (self.textField!.text!.isEmpty) {
                let emptyJokeAlert = UIAlertController(title: "Kein Text eingegeben", message: "Bitte Text eingeben.", preferredStyle: UIAlertControllerStyle.Alert)
                emptyJokeAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction) in
                    print("Proposal was empty.")
                    // do nothing
                }))
                self.presentViewController(emptyJokeAlert, animated: true, completion: nil)
            } else {
                if (self.textField!.text!.utf16.count > self.maxLengthOfProposal) {
                    let tooLongJokeAlert = UIAlertController(title: "Text ist zu lang", message: "Der Text darf nicht länger sein als " + String(self.maxLengthOfProposal) + " Zeichen.", preferredStyle: UIAlertControllerStyle.Alert)
                    tooLongJokeAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction) in
                        print("Proposal was too long.")
                        // do nothing
                    }))
                    self.presentViewController(tooLongJokeAlert, animated: true, completion: nil)
                } else {
                    print("Proposal: " + self.textField!.text!);
                    let fileName = "api_key"

                    let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil)
                    
                        
                        let api_key_content = try? String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
                        let api_key = String(String(api_key_content!).characters.dropLast())
                    
                        let url = NSURL(string: "https://api.mailgun.net/v3/sandbox47fa9b0a752440c794641c362d468402.mailgun.org/messages")
                        let request = NSMutableURLRequest(URL: url!)
                        request.HTTPMethod = "POST"
                        let loginString = NSString(format: "%@:%@", "api", api_key)
                        let loginData: NSData! = loginString.dataUsingEncoding(NSUTF8StringEncoding)
                        let base64LoginString = loginData.base64EncodedStringWithOptions([])
                        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                        
                        let bodyData = "from=In-App-Proposal <kfz-kennzeichen-spruch-vorschlag@web.de>&to=kfz-kennzeichen-spruch-vorschlag@web.de&subject=Neuer Vorschlag für Kennzeichen-Joke (iOS)&text=code: " + self.code!.text! + ", Vorschlag: " + self.textField!.text!
                        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
                        
                        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
                            {
                                (response, data, error) in
                                if (error != nil) {
                                    self.displayProposalError(error!.description)
                                } else {
                                    if let HTTPResponse = response as? NSHTTPURLResponse {
                                        let statusCode = HTTPResponse.statusCode
                                        
                                        if statusCode == 200 {
                                            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                                            let successAlert = UIAlertController(title: "Danke!", message: "Der Vorschlag wurde erfolgreich übermittelt", preferredStyle: UIAlertControllerStyle.Alert)
                                            successAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction) in
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
        
        proposeAlert.addAction(UIAlertAction(title: "Abbrechen", style: .Default, handler: { (action: UIAlertAction) in
            print("Cancelled. No proposal made.")
        }))
        
        proposeAlert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        presentViewController(proposeAlert, animated: true, completion: nil)
    }
    
    func displayProposalError(error: String) {
        print(error)
        let errorAlert = UIAlertController(title: "Tut uns leid", message: "Der Vorschlag konnte leider nicht übermittelt werden. Fehler: " + error, preferredStyle: UIAlertControllerStyle.Alert)
        errorAlert.addAction(UIAlertAction(title: "Zurück", style: .Default, handler: { (action: UIAlertAction) in
            // do nothing
        }))
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
    
    func configurationTextField(textField: UITextField!)
    {
        if let _ = textField {
            self.textField = textField! //Save reference to the UITextField
        }
    }

    
    required init?(coder aDecoder: NSCoder) {
        savedEntry = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "jokeCell")
        
        // Do any additional setup after loading the view.
        code.text = savedEntry!.code
        district.text = savedEntry!.district
        districtCenter.text = savedEntry!.district_center
        
        if (isNumbersOnly(savedEntry!.code)) {
            // there are only images for letter codes
        } else {
            let cleanedString = replaceUmlauts(savedEntry!.code)
            let imagePath = NSBundle.mainBundle().pathForResource(cleanedString.lowercaseString, ofType: "png")
            if (imagePath != nil) {
                crestImage.image = UIImage(contentsOfFile: imagePath!)
            } else {
                print("No crest image found for code " + savedEntry!.code)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        let height: CGFloat = min(self.view.bounds.size.height, self.tableView.contentSize.height)
        self.dynamicTVHeight.constant = height;
        self.view.layoutIfNeeded();
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    func isNumbersOnly(input: String) -> Bool {
        let regexNumbersOnly = try! NSRegularExpression(pattern: ".*[^0-9].*", options: [])
        return regexNumbersOnly.firstMatchInString(input, options: [], range: NSMakeRange(0, input.characters.count)) == nil
    }
    
    func replaceUmlauts(string: String) -> String {
        if string.containsString("Ä") {return string.stringByReplacingOccurrencesOfString("Ä", withString: "AE")}
        else if string.containsString("Ö") {return string.stringByReplacingOccurrencesOfString("Ö", withString: "OE")}
        else if string.containsString("Ü") {return string.stringByReplacingOccurrencesOfString("Ü", withString: "UE")}
        else {return string}
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (savedEntry?.jokes.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (self.tableView.dequeueReusableCellWithIdentifier("jokeCell")! as UITableViewCell)
        
        cell.textLabel?.text = savedEntry?.jokes[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // do nothing
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
