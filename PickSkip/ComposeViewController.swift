//
//  ComposeViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/14/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import Contacts
import NotificationCenter
import FirebaseAuth
import PhoneNumberKit

class ComposeViewController: UIViewController {

    ///Encloses the contacts table and search bar
    @IBOutlet weak var contactView: UIView!
    
    ///Contents of the Contacts View
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var listOfContactsTable: UITableView!
    
    ///Contains the buttons to increment/decrement delay
    @IBOutlet weak var buttonsView: UIView!
    
    ///Contents of the Buttons View
    @IBOutlet weak var yearButton: CounterButton!
    @IBOutlet weak var monthButton: CounterButton!
    @IBOutlet weak var weekButton: CounterButton!
    @IBOutlet weak var dayButton: CounterButton!
    @IBOutlet weak var hourButton: CounterButton!
    @IBOutlet weak var minButton: CounterButton!
    @IBOutlet weak var resetButton: UIButton!
    
    ///Contains the date/time to send.
    @IBOutlet weak var headerView: UIView!
    
    ///Contents of the Header View
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contactViewTop: NSLayoutConstraint!
    
    
    @IBOutlet weak var sendBarView: UIView!
    
    @IBOutlet weak var selectedContactsText: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    ///Floating Send Bar
    
    
    var filtered : [CNContact] = []
    var searchActive = false
    
    var nowDate = ""
    var nowTime = ""
    var dateComponents : DateComponents!
    var date : Date!
    var futureDate: Date!

    var upperPanLimit: CGFloat = 0.0
    
    var selectedNames: [CNContact] = []
    var contacts : [CNContact] = []
    
    var sendBarBottomAnchorConstraint: NSLayoutConstraint!
    
    
    let phoneNumberKit = PhoneNumberKit()
    
    var image: Data?
    var video: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContacts()
        
        date = Date()
        futureDate = Date()
        
        dateComponents = DateComponents()
        dateComponents.year = 0
        dateComponents.month = 0
        dateComponents.day = 0
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = DateFormatter.Style.long
        
        nowDate = dateformatter.string(from: date)
        dateLabel.text = nowDate
        
        let timeformatter = DateFormatter()
        timeformatter.timeStyle = DateFormatter.Style.short
        nowTime = timeformatter.string(from: date)
        timeLabel.text = nowTime
        
        listOfContactsTable.dataSource = self
        listOfContactsTable.delegate = self
        listOfContactsTable.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        listOfContactsTable.tableFooterView = UIView()
        listOfContactsTable.allowsMultipleSelection = true
        listOfContactsTable.isScrollEnabled = true
        
        setupButtons()
        self.view.bringSubview(toFront: contactView)
        contactView.layer.cornerRadius = contactView.frame.width / 50
        setupMisc()
        setupKeyboardObserver()
    }
    
    ///Adds login listener to automatically send users to the login screen if not logged in.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Util.addLoginCheckListener(self)
    }
    
    ///Removes login listener when the view disappears.
    override func viewWillDisappear(_ animated: Bool) {
        Util.removeCurrentLoginCheckListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        upperPanLimit = -(contactView.frame.minY - headerView.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    ///Load Contacts into the contacts array
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

    ///Add listeners when keyboard opens/closes.
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    ///Called when keyboard will be shown.
    func handleKeyboardWillShow(notification: NSNotification) {
        
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        sendBarBottomAnchorConstraint?.constant = -(keyboardSize?.height)!
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    ///Called when keyboard will be hidden.
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        sendBarBottomAnchorConstraint?.constant = 0
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    ///Sets up the delay buttons.
    private func setupButtons(){
        yearButton.type = "year"
        monthButton.type = "month"
        weekButton.type = "week"
        dayButton.type = "day"
        hourButton.type = "hour"
        minButton.type = "min"
      
        let longTap1 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap2 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap3 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap4 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap5 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap6 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))

        minButton.addGestureRecognizer(longTap1)
        yearButton.addGestureRecognizer(longTap2)
        monthButton.addGestureRecognizer(longTap3)
        weekButton.addGestureRecognizer(longTap4)
        dayButton.addGestureRecognizer(longTap5)
        hourButton.addGestureRecognizer(longTap6)
        
    }
    
    ///Sets up Header, Search Bar, Footer/Send bar,
    private func setupMisc() {
        
        let headerTap = UITapGestureRecognizer(target: self, action: #selector(headerTap(sender:)))
        headerView.addGestureRecognizer(headerTap)
        
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        
        sendBarView.isHidden = true
        selectedContactsText.textColor = .black
        selectedContactsText.font = UIFont(name: "Raleway-Light", size: 20)
        
        sendButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        sendBarBottomAnchorConstraint = NSLayoutConstraint(item: sendBarView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        sendBarBottomAnchorConstraint?.isActive = true
        
        self.view.bringSubview(toFront: sendBarView)
        
    }
    
    @IBAction func sendContent(_ sender: Any) {
        
        var recipients: [String] = []
        print(Int(self.futureDate!.timeIntervalSince1970))
        for selectedContact in selectedNames {
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
                    DataService.instance.sendMedia(phoneNumber: Auth.auth().currentUser!.providerData[0].phoneNumber!, recipients: recipients, mediaURL: downloadURL!, mediaType: "video", releaseDate: Int(self.futureDate!.timeIntervalSince1970))
                    
                }
            })
            self.dismiss(animated: true, completion: nil)
        } else if let image = image {
            let ref = DataService.instance.imagesStorageRef.child("\(NSUUID().uuidString).jpg")
            _ = ref.putData(image, metadata: nil, completion: {(metadata, error) in
                if let error  = error {
                    print("error: \(error.localizedDescription))")
                } else {
                    let downloadURL = metadata?.downloadURL()
                    DataService.instance.sendMedia(phoneNumber: Auth.auth().currentUser!.providerData[0].phoneNumber!, recipients: recipients, mediaURL: downloadURL!, mediaType: "image", releaseDate: Int(self.futureDate!.timeIntervalSince1970))
                }
            })
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    ///Called when the header of the screen is tapped.
    func headerTap(sender: UITapGestureRecognizer) {
        searchActive = false
        searchBar.endEditing(true)
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
            self.contactViewTop.constant = 0
            self.view.layoutIfNeeded()
            
        })
        
    }

    
    @IBAction func count(_ sender: Any) {
        if let button = sender as? CounterButton {
            button.count += 1
            button.setTitle(String(button.count) + " " + button.type, for: .normal)
        }
        changeDate()
    }
    
    @IBAction func countMin(_ sender: Any) {
        if let button = sender as? CounterButton {
            button.count += 5
            button.setTitle(String(button.count) + " " + button.type, for: .normal)
        }
        changeDate()
    }
    
    ///Called when a delay button is tapped. Resets delays from that button.
    func longTapGesture(gesture: UILongPressGestureRecognizer){
        guard let button = gesture.view as? CounterButton else {return}
        button.count = 0
        if button.type == "min" {
            button.setTitle(String(button.count) + "\n" + button.type, for: .normal)
        } else {
            button.setTitle(String(button.count) + " " + button.type, for: .normal)
        }
        changeDate()
    }


    ///Called when the reset button is hit. Resets delays from all buttons.
    @IBAction func resetCounters(_ sender: Any) {
        yearButton.count = 0
        monthButton.count = 0
        weekButton.count = 0
        dayButton.count = 0
        hourButton.count = 0
        minButton.count = 0
        
        yearButton.setTitle(String(yearButton.count) + " " + yearButton.type, for: .normal)
        monthButton.setTitle(String(monthButton.count) + " " + monthButton.type, for: .normal)
        weekButton.setTitle(String(weekButton.count) + " " + weekButton.type, for: .normal)
        dayButton.setTitle(String(dayButton.count) + " " + dayButton.type, for: .normal)
        hourButton.setTitle(String(hourButton.count) + " " + hourButton.type, for: .normal)
        minButton.setTitle(String(minButton.count) + "\n" + minButton.type, for: .normal)
        changeDate()
    }

    ///Called when back is pressed. Exits the view.
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    ///Called when the date is changed. Updates the new delayed send time.
    func changeDate() {
        dateComponents.year = yearButton.count
        dateComponents.month = monthButton.count
        dateComponents.day = weekButton.count * 7 + dayButton.count
        dateComponents.hour = hourButton.count
        dateComponents.minute = minButton.count
        
        futureDate = Calendar.current.date(byAdding: dateComponents, to: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        nowDate = dateFormatter.string(from: futureDate!)
        dateLabel.text = nowDate
        
        let timeformatter = DateFormatter()
        timeformatter.timeStyle = DateFormatter.Style.short
        nowTime = timeformatter.string(from: futureDate!)
        timeLabel.text = nowTime
        
        
    }
    
    ///Called when contacts are selected/deselected from the table.
    func updateSendBar(listOfContacts: [CNContact]){
        var tempList: [String] = []
        for contact in listOfContacts {
            tempList.append(Util.getNameFromContact(contact))
        }
        selectedContactsText.text = tempList.joined(separator: ", ")
        
        if listOfContacts.count == 0 {
            sendBarView.isHidden = true
            listOfContactsTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        } else {
            sendBarView.isHidden = false
            listOfContactsTable.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
        }
    }

}

extension ComposeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            return filtered.count
        } else {
            return contacts.count
        }
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        cell.textLabel?.font = UIFont(name: "Raleway-Light", size: 20)
        cell.textLabel?.isUserInteractionEnabled = false
        cell.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        cell.textLabel?.textColor = .white
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        if searchActive {
            if selectedNames.contains(filtered[indexPath.row]) {
                
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                view.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
                view.layer.cornerRadius = 10
                cell.accessoryView = view
                cell.isSelected = true
                
            } else {
                
                cell.accessoryView = UIView()
                
            }
            cell.contact = filtered[indexPath.row]
            cell.textLabel?.text = Util.getNameFromContact(filtered[indexPath.row])
            return cell
        } else {
            if selectedNames.contains(contacts[indexPath.row]) {
                
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                view.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
                view.layer.cornerRadius = 10
                cell.accessoryView = view
                cell.isSelected = true
                
            } else {
                
                cell.accessoryView = UIView()
                
            }
            cell.contact = contacts[indexPath.row]
            cell.textLabel?.text = Util.getNameFromContact(contacts[indexPath.row])
            
            return cell
        }
    }
    

}

extension ComposeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            view.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
            view.layer.cornerRadius = 10
            cell.accessoryView = view

            if selectedNames.contains(cell.contact){
                selectedNames.append(cell.contact)
                selectedNames = selectedNames.filter({$0 != cell.contact})
                cell.isSelected = false
                cell.accessoryView = UIView()
                updateSendBar(listOfContacts: selectedNames)
                return
            }else {
                selectedNames.append(cell.contact)
                updateSendBar(listOfContacts: selectedNames)
            }
            
            print(cell.contact)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ContactCell {
            cell.accessoryView = UIView()
            selectedNames = selectedNames.filter({$0 != cell.contact})
            updateSendBar(listOfContacts: selectedNames)
        }

    }
    
    
}

extension ComposeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
        if contactViewTop.constant == 0 {
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .allowUserInteraction], animations:{
            self.contactViewTop.constant = self.upperPanLimit
            self.view.layoutIfNeeded()})
        } else if scrollView.contentOffset.y == 0 {
                UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
                    self.contactViewTop.constant = 0
                    self.view.layoutIfNeeded()})
            
        }
    }
}

extension ComposeViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
            self.contactViewTop.constant = self.upperPanLimit
            self.view.layoutIfNeeded()})
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            filtered.removeAll()
            filtered = contacts
        }
        else {
            filtered.removeAll()
            for contact in contacts {
                let nameRange: NSRange = (Util.getNameFromContact(contact) as NSString).range(of: searchBar.text!, options: ([.caseInsensitive, .diacriticInsensitive]))
                if nameRange.location != NSNotFound {
                    filtered.append(contact)
                }
            }
        }
        listOfContactsTable.reloadData()
    }
    
    
}
