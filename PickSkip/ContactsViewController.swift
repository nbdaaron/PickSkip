//
//  ContactsViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/31/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import TokenField
import Contacts
import Firebase
import PhoneNumberKit


class ContactsViewController: UIViewController {
    
    
    @IBOutlet weak var tokenField: TokenField!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var tokenFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(colorLiteralRed:33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0).cgColor
        button.titleLabel?.textAlignment = .center
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: Constants.defaultFont, size: 30)
        button.layer.cornerRadius = 20
        button.isHidden = true
        return button
    }()
    
    var selectedContacts: [CNContact] = []
    var filtered : [CNContact] = []
    var searchActive = false
    var keyboardIsActive = false
    var buttonBottomConstraint: NSLayoutConstraint!
    var dateComponenets: DateComponents!
    var releaseDate: Date!
    var image: Data?
    var video: URL?
    let phoneNumberKit = PhoneNumberKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Constants.contacts.count == 0 {
            Util.loadContacts()
        }
        
        contactTableView.delegate = self
        contactTableView.dataSource = self
        tokenField.dataSource = self
        tokenField.delegate = self
        setupSendButton()
        
        timeLabel.adjustsFontSizeToFitWidth = true
        infoLabel.adjustsFontSizeToFitWidth = true
        timeLabel.lineBreakMode = .byWordWrapping
        timeLabel.textAlignment = .right
        timeLabel.numberOfLines = 0
        timeLabel.text = dateToString(dateComponents: dateComponenets)
        timeLabel.sizeToFit()
        
        self.navigationItem.titleView?.tintColor = .blue
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "Raleway-Light", size: 15.0)!
            ], for: .normal)
        
        setupKeyboardObserver()
        // Do any additional setup after loading the view.
    }
    
    func dateToString(dateComponents: DateComponents) -> String {
        var timeString = ""
        if dateComponents.year == 0 && dateComponents.month == 0 && dateComponents.day == 0 && dateComponents.hour == 0 && dateComponents.minute == 0 {
            infoLabel.text = "Your message will arrive"
            return "now"
        }
        if let year = dateComponents.year, year != 0 {
            timeString += (year == 1) ? String(describing: year) + " year" + "\n" : String(describing: year) + " years" + "\n"
        }
        if let month = dateComponents.month, month != 0 {
            timeString += (month == 1) ? String(describing: month) + " month" + "\n" : String(describing: month) + " months" + "\n"
        }
        if let day = dateComponents.day, day != 0 {
            timeString += (day == 1) ? String(describing: day) + " day" + "\n" : String(describing: day) + " days" + "\n"
        }
        if let hour = dateComponents.hour, hour != 0 {
            timeString += (hour == 1) ? String(describing: hour) + " hour" + "\n" : String(describing: hour) + " hours" + "\n"
        }
        if let minute = dateComponents.minute, minute != 0 {
            timeString += (minute == 1) ? String(describing: minute) + " minute" + "\n" : String(describing: minute) + " minutes" + "\n"
        }
        return timeString
        
    }
    
    private func setupSendButton() {
        self.view.addSubview(sendButton)
        
        let constraints = [
            sendButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
        
        buttonBottomConstraint = NSLayoutConstraint(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10)
        buttonBottomConstraint?.isActive = true
        
        let sendGesture = UITapGestureRecognizer(target: self, action: #selector(sendContent(gesture:)))
        sendButton.addGestureRecognizer(sendGesture)
        
    }
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    ///Called when keyboard will be shown.
    func handleKeyboardWillShow(notification: NSNotification) {
        
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.buttonBottomConstraint.constant = -(keyboardSize?.height)! - 10
            if !self.keyboardIsActive {
                self.view.layoutIfNeeded()
                self.keyboardIsActive = true
            }
        })
    }
    
    ///Called when keyboard will be hidden.
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.buttonBottomConstraint.constant = -10
            if !self.keyboardIsActive {
                self.view.layoutIfNeeded()
                self.keyboardIsActive = false
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSendButton(){
        if selectedContacts.count == 0 {
            sendButton.isHidden = true
            contactTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        } else {
            sendButton.isHidden = false
            contactTableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tokenField.endEditing(true)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        dateComponenets = nil
        releaseDate = nil
    }
    
    func sendContent(gesture: UITapGestureRecognizer) {
        var recipients: [String] = []
        for selectedContact in selectedContacts {
            do {
                let phoneNumber = try phoneNumberKit.parse(selectedContact.phoneNumbers[0].value.stringValue)
                let parsedNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
                recipients.append(parsedNumber)
            } catch {
                print("error trying to parse phone number")
            }
            
        }

        
        if let videoURL = video {
            let videoName = "\(NSUUID().uuidString)\(videoURL)"
            let ref = DataService.instance.videosStorageRef.child(videoName)
            _ = ref.putFile(from: videoURL, metadata: nil, completion: { (metadata, error) in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                } else {
                    let downloadURL = metadata?.downloadURL()
                    DataService.instance.sendMedia(senderNumber: Auth.auth().currentUser!.providerData[0].phoneNumber!, recipients: recipients, mediaURL: downloadURL!, mediaType: "video", releaseDate: Int(self.releaseDate.timeIntervalSince1970))
                }
            })
        } else if let image = image {
            let uid = NSUUID().uuidString
            let ref = DataService.instance.imagesStorageRef.child("\(uid).jpg")
            _ = ref.putData(image, metadata: nil, completion: {(metadata, error) in
                if let error  = error {
                    print("error: \(error.localizedDescription))")
                } else {
                    let downloadURL = metadata?.downloadURL()
                    DataService.instance.sendMedia(senderNumber: Auth.auth().currentUser!.providerData[0].phoneNumber!, recipients: recipients, mediaURL: downloadURL!, mediaType: "image", releaseDate: Int(self.releaseDate.timeIntervalSince1970))
                }
            })
            
        }
        let presentingVC = self.presentingViewController as! PreviewController
        self.dismiss(animated: false, completion: {
            presentingVC.previewContent.removeExistingContent()
            presentingVC.dismiss(animated: false, completion: nil)
        })
    }

    

}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //implement
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        cell.textLabel?.font = UIFont(name: Constants.defaultFont, size: 20)
        cell.textLabel?.isUserInteractionEnabled = false
        cell.selectionStyle = .none
        
        if searchActive {
            contactTableView.isHidden = false
            infoLabel.isHidden = true
            timeLabel.isHidden = true
            if selectedContacts.contains(filtered[indexPath.row]) {
                cell.backgroundColor = UIColor(colorLiteralRed:33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
            } else {
                cell.backgroundColor = .white
            }
            cell.contact = filtered[indexPath.row]
            cell.textLabel?.text = Util.getNameFromContact(filtered[indexPath.row])
        } else {
            contactTableView.isHidden = true
            infoLabel.isHidden = false
            timeLabel.isHidden = false
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //implement
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        } else {
            return Constants.contacts.count
        }
    }
    
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            if selectedContacts.contains(cell.contact) {
                selectedContacts = selectedContacts.filter({$0 != cell.contact})
                if selectedContacts.isEmpty {
                    tableView.isHidden = true
                }
                tokenField.reloadData()
                updateSendButton()
                cell.backgroundColor = .clear
            } else {
                selectedContacts.append(cell.contact)
                tokenField.reloadData()
                updateSendButton()
                cell.backgroundColor = UIColor(colorLiteralRed:33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            selectedContacts = selectedContacts.filter({$0 != cell.contact})
            if selectedContacts.isEmpty {
                tableView.isHidden = true
            }
            tokenField.reloadData()
            updateSendButton()
            cell.backgroundColor = .clear
        }
    }
    
}

extension ContactsViewController: TokenFieldDataSource {
    func tokenField(_ tokenField: TokenField, titleForTokenAtIndex index: Int) -> String {
        //implement
        return Util.getNameFromContact(selectedContacts[index]) + ","
    }
    
    func numberOfTokensInTokenField(_ tokenField: TokenField) -> Int {
        //implement
        return selectedContacts.count
    }
    
    func tokenField(_ tokenField: TokenField, colorSchemedForTokenAtIndex index: Int) -> UIColor {
        return UIColor(colorLiteralRed:33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    }
    
    func tokenFieldCollapsedText(_ tokenField: TokenField) -> String {
        //implement
        return "temp"
    }
}

extension ContactsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tokenField.endEditing(true)
    }
}

extension ContactsViewController: TokenFieldDelegate {
    
    func tokenFieldDidBeginEditing(_ tokenField: TokenField) {
        //implement
        searchActive = true
    }
    
    func tokenField(_ tokenField: TokenField, didEnterText text: String) {
        
        searchActive = false
        tokenField.endEditing(true)
    }
    
    func tokenField(_ tokenField: TokenField, didDeleteTokenAtIndex index: Int) {
        //implement
        selectedContacts.remove(at: index)
        if selectedContacts.count == 0 {
            self.contactTableView.isHidden = true
            infoLabel.isHidden = false
            timeLabel.isHidden = false
        } else {
            contactTableView.reloadData()
        }

        tokenField.reloadData()
        updateSendButton()
    }
    
    func tokenField(_ tokenField: TokenField, didChangeText text: String) {
        
        if text.characters.count == 0 {
            filtered.removeAll()
            filtered = Constants.contacts
            searchActive = false
        } else {
            filtered.removeAll()
            searchActive = true
            for contact in Constants.contacts {
                let nameRange: NSRange = (Util.getNameFromContact(contact) as NSString).range(of: text, options: ([.caseInsensitive, .diacriticInsensitive]))
                if nameRange.location != NSNotFound {
                    filtered.append(contact)
                }
            }
        }
        contactTableView.reloadData()
    }
    
    func tokenField(_ tokenField: TokenField, didChangeContentHeight height: CGFloat) {
        //implement
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
            self.tokenFieldHeight.constant = height
            //self.view.layoutIfNeeded()
        })

    }
}
