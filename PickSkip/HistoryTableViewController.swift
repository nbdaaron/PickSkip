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
    
    var dataService = DataService.instance
    var mediaArray: [Media] = []
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
//        tableView.refreshControl = UIRefreshControl()
//        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(refreshControl:)), for: .valueChanged)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        loadContent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dataService.usersRef.child(Auth.auth().currentUser!.providerData.first!.phoneNumber!).child("media").removeAllObservers()
    }
    
//    func loadContent() {
//        
//        dataService.usersRef.child(Auth.auth().currentUser!.providerData.first!.phoneNumber!).child("media").observe(.value, with: { (snapshot) in
//            if let valueDict = snapshot.value as? Dictionary<String, AnyObject> {
//                let keys = Array(valueDict.keys)
//                self.grabMedia(at: 0, from: keys)
//            }
//        })
//        
//    }
//    
//    func grabMedia(at index: Int, from keys: [String]) {
//        if index >= keys.count {
//            self.tableView.reloadData()
//            return
//        }
//        let key = keys[index]
//        
//        
//        //Skip existing content
//        for media in mediaArray {
//            if media.key == key {
//                grabMedia(at: index + 1, from: keys)
//                return
//            }
//        }
//        
//        self.dataService.mainRef.child("media").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
//            if let content = snapshot.value as? Dictionary<String, AnyObject> {
//                let url = content["mediaURL"] as! String
//                let type = content["mediaType"] as! String
//                let id = content["senderID"] as! String
//                let date = content["releaseDate"] as! Int
//                let httpsReference = Storage.storage().reference(forURL: url)
//                
//                let mediaInstance = Media(id: id, key: key, type: type, dateInt: date, url: httpsReference)
//                self.mediaArray.append(mediaInstance)
//                
//                self.grabMedia(at: index + 1, from: keys)
//            } else {
//                print("Problem grabbing media in HistoryTableViewController#grabMedia: Incorrect database format")
//            }
//            
//        })
//    }
    
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
    

}

extension HistoryTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mediaArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        date = Date()
        print("current time: \(date)")
        if date < mediaArray[indexPath.row].date {
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel!.text = "\(mediaArray[indexPath.row].date!)"
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
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
