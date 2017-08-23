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
    
    @IBAction func proposeJoke(_ sender: UIButton) {
        let proposeAlert = UIAlertController(title: "Eigenen Spruch vorschlagen", message: "Bitte Text eingeben (maximal " + String(self.maxLengthOfProposal) + " Zeichen).", preferredStyle: UIAlertControllerStyle.alert)
        
        proposeAlert.addAction(UIAlertAction(title: "Vorschlagen", style: .default, handler: { (action: UIAlertAction) in
            if (self.textField!.text!.isEmpty) {
                let emptyJokeAlert = UIAlertController(title: "Kein Text eingegeben", message: "Bitte Text eingeben.", preferredStyle: UIAlertControllerStyle.alert)
                emptyJokeAlert.addAction(UIAlertAction(title: "Zurück", style: .default, handler: { (action: UIAlertAction) in
                    print("Proposal was empty.")
                    // do nothing
                }))
                self.present(emptyJokeAlert, animated: true, completion: nil)
            } else {
                if (self.textField!.text!.utf16.count > self.maxLengthOfProposal) {
                    let tooLongJokeAlert = UIAlertController(title: "Text ist zu lang", message: "Der Text darf nicht länger sein als " + String(self.maxLengthOfProposal) + " Zeichen.", preferredStyle: UIAlertControllerStyle.alert)
                    tooLongJokeAlert.addAction(UIAlertAction(title: "Zurück", style: .default, handler: { (action: UIAlertAction) in
                        print("Proposal was too long.")
                        // do nothing
                    }))
                    self.present(tooLongJokeAlert, animated: true, completion: nil)
                } else {
                    print("Proposal: " + self.textField!.text!);
                    let fileName = "api_key"

                    let path = Bundle.main.path(forResource: fileName, ofType: nil)
                    
                        
                        let api_key_content = try? String(contentsOfFile: path!, encoding: String.Encoding.utf8)
                        let api_key = String(String(api_key_content!).characters.dropLast())
                    
                        let url = URL(string: "https://api.mailgun.net/v3/sandbox47fa9b0a752440c794641c362d468402.mailgun.org/messages")
                        let request = NSMutableURLRequest(url: url!)
                        request.httpMethod = "POST"
                        let loginString = NSString(format: "%@:%@", "api", api_key)
                        let loginData: Data! = loginString.data(using: String.Encoding.utf8.rawValue)
                        let base64LoginString = loginData.base64EncodedString(options: [])
                        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
                        
                        let bodyData = "from=In-App-Proposal <kfz-kennzeichen-spruch-vorschlag@web.de>&to=kfz-kennzeichen-spruch-vorschlag@web.de&subject=Neuer Vorschlag für Kennzeichen-Joke (iOS)&text=code: " + self.code!.text! + ", Vorschlag: " + self.textField!.text!
                        request.httpBody = bodyData.data(using: String.Encoding.utf8);
                        
                        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main)
                            {
                                (response, data, error) in
                                if (error != nil) {
                                    self.displayProposalError(error!.localizedDescription)
                                } else {
                                    if let HTTPResponse = response as? HTTPURLResponse {
                                        let statusCode = HTTPResponse.statusCode
                                        
                                        if statusCode == 200 {
                                            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
                                            let successAlert = UIAlertController(title: "Danke!", message: "Der Vorschlag wurde erfolgreich übermittelt", preferredStyle: UIAlertControllerStyle.alert)
                                            successAlert.addAction(UIAlertAction(title: "Zurück", style: .default, handler: { (action: UIAlertAction) in
                                                // do nothing
                                            }))
                                            self.present(successAlert, animated: true, completion: nil)
                                        } else {
                                            self.displayProposalError("HTTP " + String(statusCode) + ": " + self.description)
                                        }
                                    }
                                }
                        }
                    }
            }
        }))
        
        proposeAlert.addAction(UIAlertAction(title: "Abbrechen", style: .default, handler: { (action: UIAlertAction) in
            print("Cancelled. No proposal made.")
        }))
        
        proposeAlert.addTextField(configurationHandler: configurationTextField)
        
        present(proposeAlert, animated: true, completion: nil)
    }
    
    func displayProposalError(_ error: String) {
        print(error)
        let errorAlert = UIAlertController(title: "Tut uns leid", message: "Der Vorschlag konnte leider nicht übermittelt werden. Fehler: " + error, preferredStyle: UIAlertControllerStyle.alert)
        errorAlert.addAction(UIAlertAction(title: "Zurück", style: .default, handler: { (action: UIAlertAction) in
            // do nothing
        }))
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    func configurationTextField(_ textField: UITextField!)
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

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "jokeCell")
        
        // Do any additional setup after loading the view.
        code.text = savedEntry!.code
        district.text = savedEntry!.district
        districtCenter.text = savedEntry!.district_center
        
        if (isNumbersOnly(savedEntry!.code)) {
            // there are only images for letter codes
        } else {
            let cleanedString = replaceUmlauts(savedEntry!.code)
            let imagePath = Bundle.main.path(forResource: cleanedString.lowercased(), ofType: "png")
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    func isNumbersOnly(_ input: String) -> Bool {
        let regexNumbersOnly = try! NSRegularExpression(pattern: ".*[^0-9].*", options: [])
        return regexNumbersOnly.firstMatch(in: input, options: [], range: NSMakeRange(0, input.characters.count)) == nil
    }
    
    func replaceUmlauts(_ string: String) -> String {
        if string.contains("Ä") {return string.replacingOccurrences(of: "Ä", with: "AE")}
        else if string.contains("Ö") {return string.replacingOccurrences(of: "Ö", with: "OE")}
        else if string.contains("Ü") {return string.replacingOccurrences(of: "Ü", with: "UE")}
        else {return string}
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (savedEntry?.jokes.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: "jokeCell")! as UITableViewCell)
        
        cell.textLabel?.text = savedEntry?.jokes[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
