//
//  ComposeViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 7/14/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import Contacts

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
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var contactViewTop: NSLayoutConstraint!
    
    var nowDate = ""
    var nowTime = ""
    
    var dateComponents : DateComponents!
    var date : Date!
    
    var tracker: CGFloat = 0.0
    var lowerPanLimit: CGFloat = 0.0
    var upperPanLimit: CGFloat = 0.0
    
    var contactsToDisplayArray: [String] = []
    var selectedPaths: [IndexPath] = []
    
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
        listOfContactsTable.register(ContactCell.self, forCellReuseIdentifier: "cell")
        listOfContactsTable.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        listOfContactsTable.tableFooterView = UIView()
        listOfContactsTable.allowsMultipleSelection = true
        
        contactsToDisplayArray = {
            var array: [String] = []
            for contact in contacts {
                array.append("\(contact.givenName) \(contact.familyName)")
            }
            return array
        }()
        
        
        setup()
        setupButtons()
        self.view.bringSubview(toFront: contactView)
        contactView.layer.cornerRadius = contactView.frame.width / 50
        // Do any additional setup after loading the view.
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
    
    
    func setup() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        contactView.addGestureRecognizer(panGesture)
        print(contactViewTop.constant)
        
        listOfContactsTable.isScrollEnabled = true
        
        let headerTap = UITapGestureRecognizer(target: self, action: #selector(headerTap(sender:)))
        headerView.addGestureRecognizer(headerTap)
        
    }
    
    func headerTap(sender: UITapGestureRecognizer) {
        listOfContactsTable.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view)
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
        

        
    }
    
    
    func tapGesture(gesture: UITapGestureRecognizer) {
        guard let button = gesture.view as? CounterButton else {return}
        button.count += 1
        if button.type == "min" {
            button.setTitle(String(button.count) + "\n" + button.type, for: .normal)
        } else {
            button.setTitle(String(button.count) + " " + button.type, for: .normal)
        }
        changeDate(sender: button)
    }
    
    func longTapGesture(gesture: UILongPressGestureRecognizer){
        guard let button = gesture.view as? CounterButton else {return}
        button.count = 0
        if button.type == "min" {
            button.setTitle(String(button.count) + "\n" + button.type, for: .normal)
        } else {
            button.setTitle(String(button.count) + " " + button.type, for: .normal)
        }
        changeDate(sender: button)
    }


    
    func changeDate(sender: CounterButton) {
        dateComponents.year = yearButton.count
        dateComponents.month = monthButton.count
        dateComponents.day = weekButton.count * 7 + dayButton.count
        dateComponents.hour = hourButton.count
        dateComponents.minute = minButton.count
        
        let futureDate = Calendar.current.date(byAdding: dateComponents, to: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        nowDate = dateFormatter.string(from: futureDate!)
        dateLabel.text = nowDate
        
        let timeformatter = DateFormatter()
        timeformatter.timeStyle = DateFormatter.Style.short
        nowTime = timeformatter.string(from: futureDate!)
        timeLabel.text = nowTime
    }

}

extension ComposeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(searchActive){
//            return filtered.count
//        } else {
            return contactsToDisplayArray.count
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        cell.backgroundColor = .red
        //cell.textLabel?.font = UIFont(name: "Raleway-Light", size: 25)
        //cell.textLabel?.isUserInteractionEnabled = false
        //cell.textLabel?.backgroundColor = .clear
        //cell.backgroundColor = UIColor(colorLiteralRed: 255.0/255.0, green: 65.0/255.0, blue: 98.0/255.0, alpha: 1)
        //cell.textLabel?.textColor = .white
        
        if (selectedPaths as NSArray).index(of: indexPath) != NSNotFound {
            cell.textLabel?.text = contactsToDisplayArray[indexPath.row]
            print(cell.state)
            return cell
        }
        else {
            cell.textLabel?.text = contactsToDisplayArray[indexPath.row]
            return cell
        }
    }
}

extension ComposeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (selectedPaths as NSArray).index(of: indexPath) != NSNotFound {
            selectedPaths.remove(at: selectedPaths.index(of: indexPath)!)
        }
        else {
            selectedPaths.append(indexPath)
        }
        print(selectedPaths)
    }
}

extension ComposeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if contactViewTop.constant == 0 {
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
            self.contactViewTop.constant = self.upperPanLimit
            self.view.layoutIfNeeded()})
        } else if scrollView.contentOffset.y == 0 {
                UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations:{
                    self.contactViewTop.constant = 0
                    self.view.layoutIfNeeded()})
            
        }
    }
}
