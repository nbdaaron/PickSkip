//
//  HistoryTableViewController.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/15/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import Firebase

class HistoryTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mediaView: PreviewView!
    @IBOutlet weak var viewTitle: UIImageView!
    
    var dataService = DataService.instance
    var openedMediaArray: [Media] = []
    var unopenedMediaArray: [Media] = []
    var testarray1 = ["test1", "test2", "test4", "test5"]
    var testarray2 = ["test7", "test8", "test9"]
    var date: Date!
    var listenerHandle: UInt?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMediaView()
        date = Date()
        tableView.tableHeaderView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UnopenedMediaCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorColor = .clear
        tableView.reloadData()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(titlePressed(gesture:)))
        viewTitle.addGestureRecognizer(gesture)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadContent()
        if testarray2.count < 8 {
            let difference = CGFloat(7 - testarray2.count)
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.view.frame.height * (difference) / 8, right: 0)
            
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dataService.usersRef.child(Auth.auth().currentUser!.providerData.first!.phoneNumber!).child("media").removeAllObservers()
    }
    
    func loadContent() {
        
        dataService.usersRef.child(Auth.auth().currentUser!.providerData.first!.phoneNumber!).child("media").queryOrdered(byChild: "releaseDate").queryLimited(toFirst: 5).observe(.value, with: { (snapshot) in
            
            for snap in snapshot.children.allObjects as! [DataSnapshot] {
                self.grabMedia(from: snap.key)
            }
//            if let valueDict = snapshot.value as? Dictionary<String, AnyObject> {
//                let keys = Array(valueDict.keys)
//                self.grabMedia(at: 0, from: keys)
//                
//            }
            
        })

    }
    
    func grabMedia(from key: String) {
//        if index >= keys.count {
//            self.tableView.reloadData()
//            return
//        }
//        let key = keys[index]
//        
//        
        //Skip existing content
        for media in unopenedMediaArray {
            if media.key == key {
                return
            }
        }
        
        for media in openedMediaArray {
            if media.key == key {
                return
            }
        }
        
        
        
        self.dataService.mainRef.child("media").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
            if let content = snapshot.value as? Dictionary<String, AnyObject> {
                let isOpened = content["opened"] as! Bool
                let url = content["mediaURL"] as! String
                let type = content["mediaType"] as! String
                let senderNumber = content["senderNumber"] as! String
                let releaseDate = content["releaseDate"] as! Int
                let sentDate = content["sentDate"] as! Int

                let httpsReference = Storage.storage().reference(forURL: url)
                let mediaInstance = Media(senderNumber: senderNumber, key: key, type: type, releaseDateInt: releaseDate, sentDateInt: sentDate, url: httpsReference, state: isOpened)
                
                if isOpened {
                    self.openedMediaArray.append(mediaInstance)
                } else {
                    self.unopenedMediaArray.append(mediaInstance)
                }
                print(self.openedMediaArray)
                print(self.unopenedMediaArray)
                self.tableView.reloadData()
//                self.grabMedia(at: index + 1, from: keys)
            } else {
                print("Problem grabbing media in HistoryTableViewController#grabMedia: Incorrect database format")
            }
            
        })
    }
    
    func prepareMediaView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideMedia))
        tapGesture.numberOfTapsRequired = 1
        mediaView.isUserInteractionEnabled = true
        mediaView.addGestureRecognizer(tapGesture)
    }
    
    func hideMedia() {
        mediaView.isHidden = true
        mediaView.removeExistingContent()
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("error signing out")
        }
    }
    
    func titlePressed(gesture: UITapGestureRecognizer) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
    }
    

}

extension HistoryTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return openedMediaArray.count
        } else {
            return unopenedMediaArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UnopenedMediaCell
        if indexPath.section == 0 && openedMediaArray.count != 0 {
            cell.selectionStyle = .gray
            cell.backgroundColor = .white
            cell.cellFrame.layer.borderWidth = 0
            cell.nameLabel.text = openedMediaArray[indexPath.row].senderNumber
            return cell
        } else if indexPath.section == 1 && unopenedMediaArray.count != 0 {
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.cellFrame.layer.borderWidth = 1
            cell.nameLabel.text = unopenedMediaArray[indexPath.row].senderNumber
            return cell
        } else {
            return cell
        }
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("current time: \(date)")
        
        if indexPath.section == 0 {
            displayPicture(mediaArray: openedMediaArray, indexPath: indexPath)
        } else {
            displayPicture(mediaArray: unopenedMediaArray, indexPath: indexPath)
        }
    }
    
    func displayPicture(mediaArray: [Media], indexPath: IndexPath){
        date = Date()
        if date < mediaArray[indexPath.row].releaseDate {
            print("current time is less")
        } else {
            if mediaArray[indexPath.row].loadState == .loaded {
                let image = UIImage(data: mediaArray[indexPath.row].image!)
                mediaView.displayImage(image!)
                view.bringSubview(toFront: mediaView)
                mediaView.isHidden = false
            } else if mediaArray[indexPath.row].loadState == .unloaded {
                mediaArray[indexPath.row].load() {
                    //CODE TO EXECUTE WHEN DONE LOADING
                    self.tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.green
                }
                //CODE TO EXECUTE WHILE LOADING
                self.tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.blue
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70.0
        } else {
            return self.view.frame.height / 8
        }
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
}
