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
    var date: Date!
    var listenerHandle: UInt?
    var uid: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareMediaView()
        date = Date()
        tableView.tableHeaderView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UnopenedMediaCell.self, forCellReuseIdentifier: "unopenedCell")
        tableView.register(OpenedMediaCell.self, forCellReuseIdentifier: "openedCell")
        tableView.separatorColor = .clear
        tableView.reloadData()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(titlePressed(gesture:)))
        viewTitle.addGestureRecognizer(gesture)
        
        
        loadContent()
    }
    
    func loadContent() {
        
        let number = Auth.auth().currentUser!.providerData.first!.phoneNumber!
        
        dataService.usersRef.child(number).child("media").queryOrderedByKey().observe(DataEventType.childAdded, with: { (snapshot) in
                
                for media in self.unopenedMediaArray {
                    if media.key == snapshot.key {
                        return
                    }
                }
                
                print(snapshot)
                
                let httpsReference = Storage.storage().reference(forURL: snapshot.childSnapshot(forPath: "mediaURL").value as! String)
                
                let mediaInstance = Media(senderNumber: snapshot.childSnapshot(forPath: "senderNumber").value as! String,
                                          key: snapshot.key,
                                          type: snapshot.childSnapshot(forPath: "mediaType").value as! String,
                                          releaseDateInt: snapshot.childSnapshot(forPath: "releaseDate").value as! Int,
                                          sentDateInt: snapshot.childSnapshot(forPath: "sentDate").value as! Int,
                                          url: httpsReference)
            
            if snapshot.childSnapshot(forPath: "opened").value as! Int == -1 {
                self.unopenedMediaArray.append(mediaInstance)
            } else {
                self.openedMediaArray.append(mediaInstance)
            }
                self.tableView.reloadData()

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
        tableView.reloadData()
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("error signing out")
        }
    }

    
    
    func titlePressed(gesture: UITapGestureRecognizer) {
        if tableView.numberOfRows(inSection: 1) > 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        }
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
        
        if indexPath.section == 0 && openedMediaArray.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "openedCell", for: indexPath) as! OpenedMediaCell
            cell.selectionStyle = .gray
            cell.backgroundColor = .white
            cell.nameLabel.text = openedMediaArray[indexPath.row].senderNumber
            cell.dateLabel.text = Util.formateDateLabelDate(date: openedMediaArray[indexPath.row].sentDate)
            return cell
        } else if indexPath.section == 1 && unopenedMediaArray.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "unopenedCell", for: indexPath) as! UnopenedMediaCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.cellFrame.layer.borderWidth = 1
            cell.nameLabel.text = unopenedMediaArray[indexPath.row].senderNumber

            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("current time: \(date)")
        
        if indexPath.section == 0 {
            if openedMediaArray[indexPath.row].loadState == .loaded {
                if openedMediaArray[indexPath.row].mediaType == "image" {
                    let image = UIImage(data: openedMediaArray[indexPath.row].image!)
                    mediaView.displayImage(image!)
                } else {
                    mediaView.displayVideo(openedMediaArray[indexPath.row].video!)
                }
                view.bringSubview(toFront: mediaView)
                mediaView.isHidden = false
                
            } else if openedMediaArray[indexPath.row].loadState == .unloaded {
                
                openedMediaArray[indexPath.row].load() {
                    //CODE TO EXECUTE WHEN DONE LOADING
                    self.tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.green
                }
                //CODE TO EXECUTE WHILE LOADING
                self.tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.blue
            }
        } else {
            date = Date()
            if date < unopenedMediaArray[indexPath.row].releaseDate {
                print("current time is less")
            } else {
                if unopenedMediaArray[indexPath.row].loadState == .loaded {
                    if unopenedMediaArray[indexPath.row].mediaType == "image" {
                        let image = UIImage(data: unopenedMediaArray[indexPath.row].image!)
                        mediaView.displayImage(image!)
                    } else {
                        mediaView.displayVideo(unopenedMediaArray[indexPath.row].video!)
                    }
                    view.bringSubview(toFront: mediaView)
                    mediaView.isHidden = false
                    
                    DataService.instance.setOpened(key: unopenedMediaArray[indexPath.row].key, releaseDate: Int(unopenedMediaArray[indexPath.row].releaseDate.timeIntervalSince1970))
                    self.openedMediaArray.append(self.unopenedMediaArray.remove(at: indexPath.row))

                } else if unopenedMediaArray[indexPath.row].loadState == .unloaded {
                    unopenedMediaArray[indexPath.row].load() {
                        //CODE TO EXECUTE WHEN DONE LOADING
                        self.tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.green
                    }
                    //CODE TO EXECUTE WHILE LOADING
                    self.tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.blue
                }
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
