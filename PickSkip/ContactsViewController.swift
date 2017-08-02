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


class ContactsViewController: UIViewController {
    
    var selectedNames: [CNContact] = []
    var contacts : [CNContact] = []
    var filtered : [CNContact] = []
    var searchActive = false
    
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
        button.layer.borderColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        button.titleLabel?.textAlignment = .center
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Light", size: 30)
        button.layer.cornerRadius = 20
        button.isHidden = true
        return button
    }()
    
    var keyboardIsActive = false
    var buttonBottomConstraint: NSLayoutConstraint!
    var dateComponenets: DateComponents!
    var releaseDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactTableView.delegate = self
        contactTableView.dataSource = self
        tokenField.dataSource = self
        tokenField.delegate = self
        loadContacts()
        layoutSendButton()
        
        timeLabel.adjustsFontSizeToFitWidth = true
        infoLabel.adjustsFontSizeToFitWidth = true
        timeLabel.lineBreakMode = .byWordWrapping
        timeLabel.textAlignment = .right
        timeLabel.numberOfLines = 0
        timeLabel.text = formatDateComponenets(date: dateComponenets)
        timeLabel.sizeToFit()
        
        print("datecomponenets: \(dateComponenets)")
        print("release: \(releaseDate)")
        
        setupKeyboardObserver()
        // Do any additional setup after loading the view.
    }
    
    func formatDateComponenets(date: DateComponents) -> String {
        var timeString = ""
        if let year = date.year, year != 0 {
            timeString += String(describing: year) + " year" + "\n"
        }
        if let month = date.month, month != 0 {
            timeString += String(describing: month) + " month " + "\n"
        }
        if let day = date.day, day != 0 {
            timeString += String(describing: day) + " day " + "\n"
        }
        if let hour = date.hour, hour != 0 {
            timeString += String(describing: hour) + " hour " + "\n"
        }
        if let minute = date.minute, minute != 0 {
            timeString += String(describing: minute) + " minute"
        }
        return timeString
        
    }
    
    private func layoutSendButton() {
        self.view.addSubview(sendButton)
        
        let constraints = [
            sendButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.7),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        NSLayoutConstraint.activate(constraints)
        
        buttonBottomConstraint = NSLayoutConstraint(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10)
        buttonBottomConstraint?.isActive = true
    }
    
    private func loadContacts() {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactOrganizationNameKey]
        
        var allContainers : [CNContainer] = []
        do {
            allContainers = try store.containers(matching: nil)
        } catch {
            print("Error fetching containers from ComposeViewController#loadContacts: \(error)")
        }
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
                for contact in containerResults {
                    if !contact.phoneNumbers.isEmpty && !contacts.contains(contact) {
                        contacts.append(contact)
                    }
                }
                
            } catch {
                print("Error fetching results for container from ComposeViewController#loadContacts: \(error)")
            }
        }
        
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
        if selectedNames.count == 0 {
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

    

}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //implement
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        cell.textLabel?.font = UIFont(name: "Raleway-Light", size: 20)
        cell.textLabel?.isUserInteractionEnabled = false
        
        if searchActive {
            contactTableView.isHidden = false
            infoLabel.isHidden = true
            timeLabel.isHidden = true
            if selectedNames.contains(filtered[indexPath.row]) {
                cell.backgroundColor = .green
            } else {
                cell.backgroundColor = .clear
            }
            cell.contact = filtered[indexPath.row]
            cell.textLabel?.text = Util.getNameFromContact(filtered[indexPath.row])
        } else {
//            if selectedNames.contains(contacts[indexPath.row]) {
//                cell.backgroundColor = .green
//            } else {
//                cell.backgroundColor = .clear
//            }
//            cell.contact = contacts[indexPath.row]
//            cell.textLabel?.text = Util.getNameFromContact(contacts[indexPath.row])
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
            return contacts.count
        }
    }
    
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            selectedNames.append(cell.contact)
            tokenField.reloadData()
            updateSendButton()

        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            selectedNames = selectedNames.filter({$0 != cell.contact})
            tokenField.reloadData()
            updateSendButton()

        }
    }
    
}

extension ContactsViewController: TokenFieldDataSource {
    func tokenField(_ tokenField: TokenField, titleForTokenAtIndex index: Int) -> String {
        //implement
        print("Index: \(index)")
        return Util.getNameFromContact(selectedNames[index]) + ","
    }
    
    func numberOfTokensInTokenField(_ tokenField: TokenField) -> Int {
        //implement
        return selectedNames.count
    }
    
    func tokenField(_ tokenField: TokenField, colorSchemedForTokenAtIndex index: Int) -> UIColor {
        return .blue
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
        //implement
        searchActive = false
        tokenField.endEditing(true)
    }
    
    func tokenField(_ tokenField: TokenField, didDeleteTokenAtIndex index: Int) {
        //implement
        print(Util.getNameFromContact(selectedNames[index]))
        print("count before deleting \(selectedNames.count)")
        selectedNames.remove(at: index)
        print("count after deleting \(selectedNames.count)")
        if selectedNames.count == 0 {
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
            filtered = contacts
            searchActive = false
        } else {
            filtered.removeAll()
            searchActive = true
            for contact in contacts {
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