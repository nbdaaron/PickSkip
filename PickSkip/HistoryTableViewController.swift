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
    var keysLoaded: Dictionary<String, AnyObject> = [:]
    var date: Date!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
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
        loadContent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dataService.usersRef.child(Auth.auth().currentUser!.providerData.first!.phoneNumber!).child("media").removeAllObservers()
        print("observer removed")
    }
    
    func loadContent() {
        _ = dataService.usersRef.child(Auth.auth().currentUser!.providerData.first!.phoneNumber!).child("media").observe(.value, with: { (snapshot) in
            if let valueDict = snapshot.value as? Dictionary<String, AnyObject> {
                for (key, _) in valueDict {
                    if self.keysLoaded.keys.contains(key) {
                        print("repeated key")
                    } else {
                        self.grabMedia(at: key)
                    }
                }
                self.keysLoaded = valueDict
            }
        })
        
    }
    
    func grabMedia(at key: String) {
        self.dataService.mainRef.child("media").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
            if let content = snapshot.value as? Dictionary<String, AnyObject> {
                let url = content["mediaURL"] as! String
                let type = content["mediaType"] as! String
                let id = content["senderID"] as! String
                let date = content["releaseDate"] as! Int
                let httpsReference = Storage.storage().reference(forURL: url)
                httpsReference.getData(maxSize: 1024 * 1024 * 1024, completion: {(data, error) in
                    if let error = error {
                        print("something is wrong: \(error.localizedDescription)")
                    } else if type == "image" {
                        let mediaInstance = Media(id: id, type: type, image: data, video: nil, dateInt: date)
                        self.mediaArray.append(mediaInstance)
                        
                        //orders cells by date placing the earliers on top
                        if self.mediaArray.count > 1 {
                            self.mediaArray.sort(by: {$0.date.compare($1.date) == .orderedAscending})
                        }
                        
                        self.tableView.reloadData()
                    } else if type == "video" {
                        //implement video handling
                        //                            let mediaInstance = Media(id: id, type: type, image: nil, video: data)
                    } else {
                        print("Something went wrong during load")
                    }
                })
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
            _ = try Auth.auth().signOut()
            self.dismiss(animated: false, completion: nil)
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
        tableView.deselectRow(at: indexPath, animated: true)
        date = Date()
        print("current time: \(date)")
        if date < mediaArray[indexPath.row].date {
            print("current time is less")
        } else {
            let image = UIImage(data: mediaArray[indexPath.row].image!)
            mediaView.displayImage(image!)
            view.bringSubview(toFront: mediaView)
            mediaView.isHidden = false
            
        }
        
//        let image = UIImage(data: mediaArray[indexPath.row].image!)
//        mediaView.displayImage(image!)
//        mediaView.isHidden = false
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel!.text = "\(mediaArray[indexPath.row].date!)"
        
        
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
