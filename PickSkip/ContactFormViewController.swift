//
//  ContactFormViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 9/25/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import UIKit

class ContactFormViewController: UIViewController {

    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTF.textColor = UIColor(colorLiteralRed: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        lastNameTF.textColor = UIColor(colorLiteralRed: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        submitButton.layer.cornerRadius = 20
        submitButton.layer.borderWidth = 2
        submitButton.layer.borderColor = UIColor(colorLiteralRed: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        DataService.instance.saveName(firstname: firstNameTF.text!, lastname: lastNameTF.text!)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
