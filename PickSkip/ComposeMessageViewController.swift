//
//  ComposeMessageViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/11/17.
//
//

import UIKit
import Contacts


class ComposeMessageViewController: UIViewController {
    
    var buttonsView: HeaderButtonsView!
    var searchBar: UISearchBar!
    var contactView: UIView!
    var listOfContactsTable: UITableView!
    var headerHeightConstraint:NSLayoutConstraint!
    var sendBarView: UIView!
    var selectedContactsText : UILabel!
    var dateMonthYearLabel : UILabel!
    var timeLabel : UILabel!
    var amPMLabel : UILabel!
    var backButton : UIButton!
    var sendButton : UIButton!
    var date : Date!
    var calendar : Calendar!
    var timeInterval : TimeInterval!
    var searchActive = false
    var contactsToDisplayArray: [String] = []
    var filtered : [String] = []
    var nowDate = ""
    var nowTime = ""
    var selectedPaths: [IndexPath] = []
    var selectedContacts: [String] = []
    var dateComponents : DateComponents!
    
    
    
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
        
        print(nowDate)
        print(nowTime)
        
        view.backgroundColor = UIColor(colorLiteralRed: 16.0/255.0, green: 174.0/255.0, blue: 178.0/255.0, alpha: 1)
        
        contactsToDisplayArray = {
            var array: [String] = []
            for contact in contacts {
                array.append("\(contact.givenName) \(contact.familyName)")
            }
            return array
        }()
        
        //self.clearsSelectionOnViewWillAppear = false
        setUpHeader()
        setUpContactView()
        setupTableView()
        setupSendBar()
        // Do any additional setup after loading the view.
    }
    
    func setUpHeader() {
        
        buttonsView = HeaderButtonsView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        buttonsView.yearButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        buttonsView.monthButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        buttonsView.weekButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        buttonsView.dayButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        buttonsView.hourButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
        buttonsView.minButton.addTarget(self, action: #selector(didPress(sender:)), for: .touchUpInside)
         
        dateMonthYearLabel = UILabel()
        dateMonthYearLabel.translatesAutoresizingMaskIntoConstraints = false
        dateMonthYearLabel.text = nowDate
        dateMonthYearLabel.textColor = .white
        dateMonthYearLabel.textAlignment = .center
        dateMonthYearLabel.font = UIFont(name: "Raleway-Light", size: 20)
        buttonsView.addSubview(dateMonthYearLabel)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = nowTime
        timeLabel.textColor = .white
        timeLabel.font = UIFont(name: "Raleway-Light", size: 20)
        timeLabel.textAlignment = .center
        buttonsView.addSubview(timeLabel)
        
//        amPMLabel = UILabel()
//        amPMLabel.translatesAutoresizingMaskIntoConstraints = false
//        amPMLabel.text = "PM"
//        amPMLabel.textColor = .white
//        amPMLabel.font = UIFont(name: "Raleway-Light", size: 20)
//        buttonsView.addSubview(amPMLabel)
        
        backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        buttonsView.addSubview(backButton)
        
        let constraints:[NSLayoutConstraint] = [
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.topAnchor.constraint(equalTo: view.topAnchor),
            buttonsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
            backButton.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 30),
            backButton.bottomAnchor.constraint(equalTo: buttonsView.yearButton.topAnchor, constant: -25),
            backButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 25),
            
            dateMonthYearLabel.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 20),
            dateMonthYearLabel.bottomAnchor.constraint(equalTo: buttonsView.yearButton.topAnchor, constant: -10),
            dateMonthYearLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10),
            dateMonthYearLabel.widthAnchor.constraint(equalToConstant: 210),
            
            timeLabel.topAnchor.constraint(equalTo: buttonsView.topAnchor, constant: 20),
            timeLabel.bottomAnchor.constraint(equalTo: buttonsView.yearButton.topAnchor, constant: -10),
            timeLabel.leadingAnchor.constraint(equalTo: dateMonthYearLabel.trailingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor, constant: -20)
            
//            amPMLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20),
//            amPMLabel.bottomAnchor.constraint(equalTo: buttonsView.yearButton.topAnchor, constant: -10),
//            amPMLabel.leadingAnchor.constraint(equalTo: dateMonthYearLabel.trailingAnchor, constant: 20),
//            amPMLabel.widthAnchor.constraint(equalToConstant: 60)
            
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func didPress(sender: CounterButton) {
        sender.count += 1
        if sender.type == "min" {
            sender.setTitle(String(sender.count) + "\n" + sender.type, for: .normal)
        }else {
            sender.setTitle(String(sender.count) + " " + sender.type, for: .normal)
        }
        
        switch sender.type {
            case "year":
                dateComponents.year = sender.count
            case "month":
                dateComponents.month = sender.count
            case "week":
                dateComponents.day = sender.count * 7
            case "day":
                dateComponents.day = sender.count
            case "hour":
                dateComponents.hour = sender.count
            case "min":
                dateComponents.minute = sender.count
            default:
                print("timebutton didn't fire")
        }
        
        let futureDate = Calendar.current.date(byAdding: dateComponents, to: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        nowDate = dateFormatter.string(from: futureDate!)
        dateMonthYearLabel.text = nowDate
        
        let timeformatter = DateFormatter()
        timeformatter.timeStyle = DateFormatter.Style.short
        nowTime = timeformatter.string(from: futureDate!)
        timeLabel.text = nowTime
        
    }
    
    
    func setUpContactView() {
        
        contactView = UIView()
        contactView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contactView)
        
        contactView.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        contactView.layer.cornerRadius = 10
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        contactView.addGestureRecognizer(panGesture)
        
        let constraints:[NSLayoutConstraint] = [
            contactView.topAnchor.constraint(equalTo: buttonsView.bottomAnchor, constant: -15),
            contactView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contactView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contactView.heightAnchor.constraint(equalToConstant: 700)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.changed) {
            var center = sender.view?.center
            let translation = sender.translation(in: sender.view)
            if (center?.y)! <= CGFloat(655.0) && (center?.y)! >= CGFloat(435.0) {
                center = CGPoint(x: (sender.view?.frame.midX)!, y: center!.y + translation.y)
                sender.view?.center = center!
                sender.setTranslation(CGPoint(), in: sender.view)
            }
            if (center?.y)! <= CGFloat(435.0) && translation.y > 0.0 {
                center = CGPoint(x: (sender.view?.frame.midX)!, y: center!.y + translation.y)
                sender.view?.center = center!
                sender.setTranslation(CGPoint(), in: sender.view)
                listOfContactsTable.isScrollEnabled = false
            }
            if (center?.y)! <= CGFloat(435.0) && translation.y < 0.0 {
                listOfContactsTable.isScrollEnabled = true
            }
            if (center?.y)! >= CGFloat(655.0) && translation.y < 0.0 {
                center = CGPoint(x: (sender.view?.frame.midX)!, y: 650)
                sender.view?.center = center!
                sender.setTranslation(CGPoint(), in: sender.view)
            }
        }
    }
    
    func setupTableView() {
        listOfContactsTable = UITableView(frame: CGRect(x: 20, y: 80, width: 335, height: 300), style: .plain)
        listOfContactsTable.translatesAutoresizingMaskIntoConstraints = false
        contactView.addSubview(listOfContactsTable)
        listOfContactsTable.register(ContactCell.self, forCellReuseIdentifier: "cell")
        listOfContactsTable.separatorColor = UIColor(colorLiteralRed: 214.0/255.0, green: 39.0/255.0, blue: 65.0/255.0, alpha: 1)
        listOfContactsTable.dataSource = self
        listOfContactsTable.delegate = self
        listOfContactsTable.isScrollEnabled = false
        listOfContactsTable.bounces = false
        listOfContactsTable.isEditing = false
        listOfContactsTable.allowsSelection = true
        listOfContactsTable.allowsMultipleSelection = true
        
        
        listOfContactsTable.backgroundColor = .white
            //UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        listOfContactsTable.tableFooterView = UIView()
        
        let constraints:[NSLayoutConstraint] = [
            
            listOfContactsTable.topAnchor.constraint(equalTo: contactView.topAnchor, constant: 80),
            listOfContactsTable.leadingAnchor.constraint(equalTo: contactView.leadingAnchor, constant: 15),
            listOfContactsTable.trailingAnchor.constraint(equalTo: contactView.trailingAnchor, constant: -15),
            listOfContactsTable.bottomAnchor.constraint(equalTo: contactView.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        searchBar = UISearchBar(frame: CGRect(x: 15, y: 10, width: 345, height: 50))
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        contactView.addSubview(searchBar)
        
    }
    
    
    func setupSendBar() {
        
        
        
        sendBarView = UIView()
        sendBarView.backgroundColor = UIColor(colorLiteralRed: 231.0/255.0, green: 237.0/255.0, blue: 143.0/255.0, alpha: 1)
        sendBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendBarView)
        view.bringSubview(toFront: sendBarView)
        
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
            sendBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sendBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sendBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            selectedContactsText.leadingAnchor.constraint(equalTo: sendBarView.leadingAnchor, constant: 15),
            selectedContactsText.widthAnchor.constraint(equalToConstant: 300),
            selectedContactsText.heightAnchor.constraint(equalToConstant: 50),
            selectedContactsText.centerYAnchor.constraint(equalTo: sendBarView.centerYAnchor),
            
            sendButton.trailingAnchor.constraint(equalTo: sendBarView.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: sendBarView.centerYAnchor),
            sendButton.leadingAnchor.constraint(equalTo: selectedContactsText.trailingAnchor, constant: 10),
            
        ]
        NSLayoutConstraint.activate(constraints)
        sendBarView.isHidden = true
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }
    

//    func animateHeader(height: Int) {
//        self.headerHeightConstraint.constant = CGFloat(height)
//        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
//        self.view.layoutIfNeeded()
//        }, completion: nil)
//    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ComposeMessageViewController: UITableViewDataSource {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        //cell.textLabel?.font = UIFont(name: "Raleway-Light", size: 25)
        //cell.textLabel?.isUserInteractionEnabled = false
        //cell.textLabel?.backgroundColor = .clear
        //cell.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        //cell.textLabel?.textColor = .white
        
        if (selectedPaths as NSArray).index(of: indexPath) != NSNotFound {
            print("selectedcell")
            cell.textLabel?.text = contactsToDisplayArray[indexPath.row]
            cell.setHighlighted(true, animated: false)
            cell.setSelected(true, animated: false)
            return cell
        }
        else {
            cell.textLabel?.text = contactsToDisplayArray[indexPath.row]
            return cell
        }
    }
    
    
    
}


extension ComposeMessageViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setSelected(true, animated: false)
            let trimmedString = (cell.textLabel?.text!)!.trimmingCharacters(in: .whitespacesAndNewlines)
            selectedContacts.append(trimmedString)
        
            if (selectedPaths as NSArray).index(of: indexPath) != NSNotFound {
                selectedPaths.remove(at: selectedPaths.index(of: indexPath)!)
                cell.setSelected(false, animated: false)
            }
            else {
                selectedPaths.append(indexPath)
                cell.setSelected(true, animated: false)
            }
        }
        
        if selectedPaths.count > 0 {
            sendBarView.isHidden = false
            selectedContactsText.text = selectedContacts.joined(separator: ", ")
            
        } else {
            sendBarView.isHidden = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.setHighlighted(true, animated: false)
        }
    }
    
    
    
}

extension ComposeMessageViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
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



