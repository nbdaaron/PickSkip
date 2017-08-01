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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactTableView.delegate = self
        contactTableView.dataSource = self
        tokenField.dataSource = self
        tokenField.delegate = self
        loadContacts()
        // Do any additional setup after loading the view.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            selectedNames = selectedNames.filter({$0 != cell.contact})
            tokenField.reloadData()
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
        } else {
            contactTableView.reloadData()
        }
        tokenField.reloadData()
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
            self.view.layoutIfNeeded()})
    }
}
