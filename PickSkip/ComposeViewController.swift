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

class ComposeViewController: UIViewController {

    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var listOfContactsTable: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    
    @IBOutlet weak var yearButton: CounterButton!
    @IBOutlet weak var monthButton: CounterButton!
    @IBOutlet weak var weekButton: CounterButton!
    @IBOutlet weak var dayButton: CounterButton!
    @IBOutlet weak var hourButton: CounterButton!
    @IBOutlet weak var minButton: CounterButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contactViewTop: NSLayoutConstraint!
    
    
    var sendBarView: UIView!
    var selectedContactsText: UILabel!
    var sendButton: UIButton!
    
    
    var filtered : [String] = []
    var searchActive = false
    
    var nowDate = ""
    var nowTime = ""
    
    var dateComponents : DateComponents!
    var date : Date!
    var futureDate: Date!
    
    var tracker: CGFloat = 0.0
    var lowerPanLimit: CGFloat = 0.0
    var upperPanLimit: CGFloat = 0.0
    
    var contactsToDisplayArray: [String] = []
    var selectedNames: [String] = []
    
    var contacts : [CNContact] = {
        let store = CNContactStore()
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        
        var allContainers : [CNContainer] = []
        do {
            allContainers = try store.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results : [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        date = Date()
        
        dateComponents = DateComponents()
        dateComponents.year = 0
        dateComponents.month = 0
        dateComponents.day = 0
        dateComponents.hour = 0
        dateComponents.minute = 0
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateStyle = DateFormatter.Style.long
        
        nowDate = dateformatter.string(from: date)
        
        let timeformatter = DateFormatter()
        timeformatter.timeStyle = DateFormatter.Style.short
        nowTime = timeformatter.string(from: date)
        
        
        listOfContactsTable.dataSource = self
        listOfContactsTable.delegate = self
        listOfContactsTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        listOfContactsTable.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        listOfContactsTable.tableFooterView = UIView()
        listOfContactsTable.allowsMultipleSelection = true
        listOfContactsTable.isScrollEnabled = true
        
        
        
        contactsToDisplayArray = {
            var array: [String] = []
            for contact in contacts {
                array.append("\(contact.givenName) \(contact.familyName)")
            }
            return array
        }()
        
        
        setupButtons()
        self.view.bringSubview(toFront: contactView)
        contactView.layer.cornerRadius = contactView.frame.width / 50
        setup()
        setupKeyboardObserver()
    
    }

    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        sendBarBottomAnchorConstraint?.constant = -(keyboardSize?.height)!
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        })
        
//
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            let keyboardHeight = keyboardSize.height
//            sendBarBottomAnchorConstraint?.constant = -keyboardHeight
//            
//        }
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        sendBarBottomAnchorConstraint?.constant = 0
        UIView.animate(withDuration: keyboardAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    func setupButtons(){
        yearButton.type = "year"
        monthButton.type = "month"
        weekButton.type = "week"
        dayButton.type = "day"
        hourButton.type = "hour"
        minButton.type = "min"
        
//        yearButton.addTarget(self, action: #selector(changeDate(sender:)), for: .touchUpInside)
//        
//        monthButton.addTarget(self, action: #selector(changeDate(sender:)), for: .touchUpInside)
//        weekButton.addTarget(self, action: #selector(changeDate(sender:)), for: .touchUpInside)
//        dayButton.addTarget(self, action: #selector(changeDate(sender:)), for: .touchUpInside)
//        hourButton.addTarget(self, action: #selector(changeDate(sender:)), for: .touchUpInside)
//        minButton.addTarget(self, action: #selector(changeDate(sender:)), for: .touchUpInside)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        let tapGesture6 = UITapGestureRecognizer(target: self, action: #selector(tapGesture(gesture:)))
        
        let longTap1 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap2 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap3 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap4 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap5 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        let longTap6 = UILongPressGestureRecognizer(target: self, action: #selector(longTapGesture(gesture:)))
        yearButton.addGestureRecognizer(tapGesture1)
        monthButton.addGestureRecognizer(tapGesture2)
        weekButton.addGestureRecognizer(tapGesture3)
        dayButton.addGestureRecognizer(tapGesture4)
        hourButton.addGestureRecognizer(tapGesture5)
        minButton.addGestureRecognizer(tapGesture6)
        minButton.addGestureRecognizer(longTap1)
        yearButton.addGestureRecognizer(longTap2)
        monthButton.addGestureRecognizer(longTap3)
        weekButton.addGestureRecognizer(longTap4)
        dayButton.addGestureRecognizer(longTap5)
        hourButton.addGestureRecognizer(longTap6)
        

        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("frambefore: \(contactView.frame.minY)")
        upperPanLimit = -(contactView.frame.minY - headerView.frame.height)
        print("upperpanlimi: \(upperPanLimit)")
    }
    
    var sendBarBottomAnchorConstraint: NSLayoutConstraint?
    
    func setup() {
        
        let headerTap = UITapGestureRecognizer(target: self, action: #selector(headerTap(sender:)))
        headerView.addGestureRecognizer(headerTap)
        
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        
        sendBarView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        sendBarView.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
        sendBarView.translatesAutoresizingMaskIntoConstraints = false
        sendBarView.isHidden = true
        self.view.addSubview(sendBarView)
        
        selectedContactsText = UILabel()
        selectedContactsText.translatesAutoresizingMaskIntoConstraints = false
        
        selectedContactsText.textColor = .black
        selectedContactsText.text = "hello"
        selectedContactsText.font = UIFont(name: "Raleway-Light", size: 20)
        
        sendBarView.addSubview(selectedContactsText)
        
        
        sendButton = UIButton()
        sendButton.setImage(#imageLiteral(resourceName: "RewindButton"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        sendBarView.addSubview(sendButton)
        
        
        
        let constraints:[NSLayoutConstraint] = [
            
            sendBarView.heightAnchor.constraint(equalToConstant: 70),
            sendBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            sendBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            selectedContactsText.leadingAnchor.constraint(equalTo: sendBarView.leadingAnchor, constant: 15),
            selectedContactsText.widthAnchor.constraint(equalTo: sendBarView.widthAnchor, multiplier: 0.8),
            selectedContactsText.heightAnchor.constraint(equalTo: sendBarView.heightAnchor, multiplier: 0.8),
            selectedContactsText.centerYAnchor.constraint(equalTo: sendBarView.centerYAnchor),
            
            sendButton.trailingAnchor.constraint(equalTo: sendBarView.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: sendBarView.centerYAnchor),
            sendButton.leadingAnchor.constraint(equalTo: selectedContactsText.trailingAnchor, constant: 10),
            
            ]
        
        sendBarBottomAnchorConstraint = NSLayoutConstraint(item: sendBarView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        sendBarBottomAnchorConstraint?.isActive = true
        NSLayoutConstraint.activate(constraints)
        
        self.view.bringSubview(toFront: sendBarView)
        
    }
    
    func headerTap(sender: UITapGestureRecognizer) {
        searchActive = false
        searchBar.endEditing(true)
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
            self.contactViewTop.constant = 0
            self.view.layoutIfNeeded()
            
        })
        
    }
    
//    func handlePan(sender: UIPanGestureRecognizer) {
//        let translation = sender.translation(in: sender.view)
//        if (sender.state == UIGestureRecognizerState.changed) {
//            print(upperPanLimit)
//            if (contactView.frame.minY <= self.headerView.frame.maxY) {
//                contactViewTop.constant = self.upperPanLimit + 1
//                listOfContactsTable.isScrollEnabled = true
//                if (translation.y - tracker) < 0 {
//                listOfContactsTable.contentOffset.y = -(translation.y - upperPanLimit)
//                }
//            } else if (contactViewTop.constant > 0)  {
//                contactViewTop.constant += (translation.y - tracker) / 2
//                listOfContactsTable.isScrollEnabled = false
//            }
//            else if (listOfContactsTable.contentOffset.y == 0){
//                contactViewTop.constant += (translation.y - tracker)
//                listOfContactsTable.isScrollEnabled = false
//            } else {
//                contactViewTop.constant += (translation.y - tracker)
//                listOfContactsTable.isScrollEnabled = false
//            }
//            
//        }
//        print("Y: \(translation)")
//        tracker = translation.y
//        
//        if (sender.state == UIGestureRecognizerState.ended){
//            if (contactViewTop.constant > 0 ){
//                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
//                    self.contactViewTop.constant = 0
//                    self.view.layoutIfNeeded()
//                })
//            } else if (contactView.frame.minY < self.headerView.frame.maxY){
//                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
//                    self.contactViewTop.constant = self.upperPanLimit
//                    self.view.layoutIfNeeded()
//                })
//                
//            }
//        }
//
//
//        
//    }
    
    
    func tapGesture(gesture: UITapGestureRecognizer) {
        guard let button = gesture.view as? CounterButton else {return}
        button.count += 1
        if button.type == "min" {
            button.setTitle(String(button.count) + "\n" + button.type, for: .normal)
        } else {
            button.setTitle(String(button.count) + " " + button.type, for: .normal)
        }
        changeDate()
    }
    
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
    
    func updateSendBar(listOfNames: [String]){
        var tempList: [String] = []
        for name in listOfNames {
            let trimmedString = name.trimmingCharacters(in: .whitespacesAndNewlines)
            tempList.append(trimmedString)
        }
        selectedContactsText.text = tempList.joined(separator: ", ")
        
        if listOfNames.count == 0 {
            sendBarView.isHidden = true
        } else {
            sendBarView.isHidden = false
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
            return contactsToDisplayArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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
            cell.textLabel?.text = filtered[indexPath.row]
            return cell
        } else {
            if selectedNames.contains(contactsToDisplayArray[indexPath.row]) {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                view.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
                view.layer.cornerRadius = 10
                cell.accessoryView = view
                cell.isSelected = true
            } else {
                cell.accessoryView = UIView()
            }
            cell.textLabel?.text = contactsToDisplayArray[indexPath.row]
            return cell
        }
    }
    

}

extension ComposeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            view.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
            view.layer.cornerRadius = 10
            cell.accessoryView = view
        
            if selectedNames.contains((cell.textLabel?.text)!){
                
                selectedNames.append((cell.textLabel?.text)!)
                selectedNames = selectedNames.filter({$0 != tableView.cellForRow(at: indexPath)?.textLabel?.text})
                cell.isSelected = false
                cell.accessoryView = UIView()
                updateSendBar(listOfNames: selectedNames)
                return
            }else {
                selectedNames.append((cell.textLabel?.text)!)
                updateSendBar(listOfNames: selectedNames)
            }
        }
        
        print(selectedNames)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryView = UIView()
        selectedNames = selectedNames.filter({$0 != tableView.cellForRow(at: indexPath)?.textLabel?.text})
        updateSendBar(listOfNames: selectedNames)
        print(selectedNames)
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
            filtered = contactsToDisplayArray
        }
        else {
            filtered.removeAll()
            for string: String in contactsToDisplayArray {
                let nameRange: NSRange = (string as NSString).range(of: searchBar.text!, options: ([.caseInsensitive, .diacriticInsensitive]))
                if nameRange.location != NSNotFound {
                    filtered.append(string)
                }
            }
        }
        listOfContactsTable.reloadData()
    }
    
    
}
