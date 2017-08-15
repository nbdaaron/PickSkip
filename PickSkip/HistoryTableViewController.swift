//
//  HistoryTableViewController.swift
//  PickSkip
//
//  Created by Aaron Kau on 7/15/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import UIKit
import Firebase
import QuartzCore

class HistoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mediaView: PreviewView!
    @IBOutlet weak var viewTitle: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var titlePanel: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    
    var dataService = DataService.instance
    var openedMediaArray: [Media] = []
    var unopenedMediaArray: [Media] = []
    var date: Date!
    var listenerHandle: UInt?
    var uid: String?
    
    var loadingMore: Bool = false
    var initialFetch: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titlePanel.addBottomBorder(with: UIColor(colorLiteralRed: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0) , andWidth: 1.0)
        prepareMediaView()
        logoutButton.imageView?.contentMode = .scaleAspectFit
        cameraButton.imageView?.contentMode = .scaleAspectFit
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
        setupLoadMore()
        
        loadContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if initialFetch == false {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: true)
        }
    }
    
    func loadContent() {
        
        loadMoreOpened()
        loadMoreUnopened()
        
        let number = Auth.auth().currentUser!.providerData.first!.phoneNumber!
        
        //Listen for new unopened media. Insert if not already in list and falls within range.
        dataService.usersRef.child(number).child("unopened").queryOrderedByKey().queryLimited(toLast: 1).observe(DataEventType.childAdded, with: { (snapshot) in
            let releaseDate = snapshot.childSnapshot(forPath: "releaseDate").value as! Int
            
            if self.unopenedMediaArray.count == 0 || releaseDate > Int(self.unopenedMediaArray.last!.releaseDate.timeIntervalSince1970) {
                return
            }
            
            for media in self.unopenedMediaArray {
                //Don't add new media if already in list
                if media.key == snapshot.key {
                    return
                }
            }
            
            let httpsReference = Storage.storage().reference(forURL: snapshot.childSnapshot(forPath: "mediaURL").value as! String)
            
            let mediaInstance = Media(senderNumber: snapshot.childSnapshot(forPath: "senderNumber").value as! String,
                                      key: snapshot.key,
                                      type: snapshot.childSnapshot(forPath: "mediaType").value as! String,
                                      releaseDateInt: snapshot.childSnapshot(forPath: "releaseDate").value as! Int,
                                      sentDateInt: snapshot.childSnapshot(forPath: "sentDate").value as! Int,
                                      url: httpsReference,
                                      openDate: -1)
            
            
            //New media that should be in the list already are sorted in
            for i in 0..<self.unopenedMediaArray.count {
                if mediaInstance.releaseDate < self.unopenedMediaArray[i].releaseDate {
                    print("Inserting at position \(i)")
                    self.unopenedMediaArray.insert(mediaInstance, at: i)
                    break
                }
            }
            self.tableView.reloadData()
        })

    }

    func setupLoadMore() {
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl!.attributedTitle = NSAttributedString(string: "Load more opened")
        self.tableView.refreshControl!.addTarget(self, action: #selector(loadMoreOpened), for: UIControlEvents.valueChanged)
    }
    
    public func loadMoreOpened() {
        
        let number = Auth.auth().currentUser!.providerData.first!.phoneNumber!
        let startingPoint = -(openedMediaArray.first?.openDate ?? Int.max)
        print("Starting point: \(startingPoint)")
        //Load X opened.
        dataService.usersRef.child(number).child("opened").queryOrderedByPriority().queryStarting(atValue: startingPoint).queryLimited(toFirst: Constants.loadCount).observe(DataEventType.childAdded, with: { (snapshot) in
            for media in self.openedMediaArray {
                if media.key == snapshot.key {
                    self.tableView.refreshControl?.endRefreshing()
                    return
                }
            }
            
            let mediaReference = Storage.storage().reference(forURL: snapshot.childSnapshot(forPath: "mediaURL").value as! String)
            let thumbnailReference = Storage.storage().reference(forURL: snapshot.childSnapshot(forPath: "thumbnail").value as! String)
            thumbnailReference.getData(maxSize: Constants.maxDownloadSize, completion: {(data, error) in
                if let error = error{
                    print(error.localizedDescription)
                } else {
                    let mediaInstance = Media(senderNumber: snapshot.childSnapshot(forPath: "senderNumber").value as! String,
                                              key: snapshot.key,
                                              type: snapshot.childSnapshot(forPath: "mediaType").value as! String,
                                              releaseDateInt: snapshot.childSnapshot(forPath: "releaseDate").value as! Int,
                                              sentDateInt: snapshot.childSnapshot(forPath: "sentDate").value as! Int,
                                              url: mediaReference,
                                              openDate: snapshot.childSnapshot(forPath: "opened").value as! Int,
                                              thumbnail: data!)
                    self.openedMediaArray.insert(mediaInstance, at: 0)
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            })
            
            
        })
    }
    
    func loadMoreUnopened() {
        
        let number = Auth.auth().currentUser!.providerData.first!.phoneNumber!
        let startingPoint = Int(unopenedMediaArray.last?.releaseDate.timeIntervalSince1970 ?? 0)

        
        //Load first X unopened
        dataService.usersRef.child(number).child("unopened").queryOrdered(byChild: "releaseDate").queryStarting(atValue: startingPoint).queryLimited(toFirst: Constants.loadCount).observe(DataEventType.childAdded, with: { (snapshot) in
            for media in self.unopenedMediaArray {
                if media.key == snapshot.key {
                    return
                }
            }
            
            let httpsReference = Storage.storage().reference(forURL: snapshot.childSnapshot(forPath: "mediaURL").value as! String)
            
            let mediaInstance = Media(senderNumber: snapshot.childSnapshot(forPath: "senderNumber").value as! String,
                                      key: snapshot.key,
                                      type: snapshot.childSnapshot(forPath: "mediaType").value as! String,
                                      releaseDateInt: snapshot.childSnapshot(forPath: "releaseDate").value as! Int,
                                      sentDateInt: snapshot.childSnapshot(forPath: "sentDate").value as! Int,
                                      url: httpsReference,
                                      openDate: -1)
            
            print("Appending value with releaseDate: \(snapshot.childSnapshot(forPath:"releaseDate").value as! Int)")
            for i in 0..<self.unopenedMediaArray.count {
                if mediaInstance.releaseDate < self.unopenedMediaArray[i].releaseDate {
                    print("Inserting at position \(i)")
                    self.unopenedMediaArray.insert(mediaInstance, at: i)
                    self.tableView.reloadData()
                    self.loadingMore = false
                    return
                }
            }
            self.unopenedMediaArray.append(mediaInstance)
            self.tableView.reloadData()
            
            if self.tableView.numberOfSections == 2 {
                if self.tableView.numberOfRows(inSection: 0) == 5 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: true)
                    self.initialFetch = false
                }
            }
            
            self.loadingMore = false
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
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            alert.dismiss(animated: false, completion: nil)
        })
        let logoutAction = UIAlertAction(title: "Logout", style: .default, handler: { (action) in
            do {
                try Auth.auth().signOut()
            } catch {
                print("error signing out")
            }
        })
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        self.present(alert, animated: true, completion: nil)
        
        
    }

    @IBAction func goToCamera(_ sender: Any) {
        if let parentController = self.parent as? MainPagesViewController {
           parentController.setViewControllers([parentController.pages[Constants.initialViewPosition]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    func titlePressed(gesture: UITapGestureRecognizer) {
        if tableView.numberOfRows(inSection: 1) > 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: true)
        }
    }
    
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
            
            //Default cell aspects
            cell.selectionStyle = .gray
            cell.backgroundColor = .white
            
            //Cell Content
            cell.nameLabel.text = openedMediaArray[indexPath.row].senderNumber
            cell.dateLabel.text = Util.formatDateLabelDate(date: Date(timeIntervalSince1970: TimeInterval(openedMediaArray[indexPath.row].openDate)))
            cell.thumbnail.imageView.image = UIImage(data: openedMediaArray[indexPath.row].thumbnailData!)
            
            //Format cell appearance based on state
            if openedMediaArray[indexPath.row].loadState == .loaded {
                cell.cancelAnimation()
            } else if openedMediaArray[indexPath.row].loadState == .loading{
                cell.loadAnimation()
            } else {
                cell.dateLabel.font = UIFont(name: "Raleway-Light", size: 20)
                cell.nameLabel.font = UIFont(name: "Raleway-Light", size: 20)
                cell.layer.borderWidth = 0.0
                cell.layer.borderColor = UIColor.clear.cgColor
            }
            
            return cell
        } else if indexPath.section == 1 && unopenedMediaArray.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "unopenedCell", for: indexPath) as! UnopenedMediaCell
            
            //Default cell aspects
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.cellFrame.layer.borderWidth = 1
            
            //Cell content
            cell.nameLabel.text = unopenedMediaArray[indexPath.row].senderNumber
            cell.dateLabel.text = Util.getBiggestComponenet(release: unopenedMediaArray[indexPath.row].releaseDate)
            
            //Check how to display cell
            if unopenedMediaArray[indexPath.row].loadState == .loaded {
                cell.cancelAnimation()
            } else if unopenedMediaArray[indexPath.row].loadState == .loading{
                cell.loadAnimation()
            } else {
                cell.dateLabel.font = UIFont(name: "Raleway-Light", size: 20)
                cell.nameLabel.font = UIFont(name: "Raleway-Light", size: 20)
                cell.cellFrame.layer.borderWidth = 1.0
                cell.cellFrame.layer.borderColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.4).cgColor
            }
            
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
            let cell = self.tableView.cellForRow(at: indexPath) as! OpenedMediaCell
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
                    cell.cancelAnimation()
                }
                //CODE TO EXECUTE WHILE LOADING
                cell.loadAnimation()
            }
        } else {
            date = Date()
            let cell = self.tableView.cellForRow(at: indexPath) as! UnopenedMediaCell
            if date < unopenedMediaArray[indexPath.row].releaseDate {
                cell.shake()
                print("current time is less")
            } else {
                if unopenedMediaArray[indexPath.row].loadState == .loaded {
                    if unopenedMediaArray[indexPath.row].mediaType == "image" {
                        let image = UIImage(data: unopenedMediaArray[indexPath.row].image!)
                        mediaView.displayImage(image!)
                        
                        //start thumbnail upload
                        let thumbnailRef = DataService.instance.imagesStorageRef.child("\(NSUUID().uuidString)_thumbnail.jpg")
                        let thumbnailData = Util.getThumbnail(imageData: unopenedMediaArray[indexPath.row].image!, videoURL: nil)
                        
                        _ = thumbnailRef.putData(thumbnailData, metadata: nil, completion: { (metadata, error) in
                            if let error = error {
                                print("error: \(error.localizedDescription)")
                            } else {
                                let downloadURL = metadata?.downloadURL()
                                let openDate = Int(Date().timeIntervalSince1970)
                                self.unopenedMediaArray[indexPath.row].openDate = openDate
                                self.unopenedMediaArray[indexPath.row].thumbnailData = thumbnailData
                                DataService.instance.setOpened(key: self.unopenedMediaArray[indexPath.row].key, openDate: openDate, thumbnailURL: downloadURL!.absoluteString)
                                
                                self.openedMediaArray.append(self.unopenedMediaArray.remove(at: indexPath.row))
                                self.tableView.reloadData()
                                
                                
                                //update media to opened
                                
                            }
                        })
                        
                        
                    } else {
                        mediaView.displayVideo(unopenedMediaArray[indexPath.row].video!)
                    }
                    view.bringSubview(toFront: mediaView)
                    mediaView.isHidden = false
                    

                } else if unopenedMediaArray[indexPath.row].loadState == .unloaded {
                    unopenedMediaArray[indexPath.row].load() {
                        //CODE TO EXECUTE WHEN DONE LOADING
                        cell.cancelAnimation()
                    }
                    //CODE TO EXECUTE WHILE LOADING
                    cell.loadAnimation()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Checks if rows exist in each section before adding section header
        if openedMediaArray.count > 0 && section == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
            let headerTitle = UILabel(frame: CGRect(x: 15, y: 3, width: tableView.frame.width, height: 23))
            headerTitle.font = UIFont(name: "Raleway-SemiBold", size: 15.0)
            headerTitle.text = "Opened"
            headerTitle.textColor = UIColor(colorLiteralRed: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
            headerView.backgroundColor = .white
            headerView.addSubview(headerTitle)
            return headerView
        } else if unopenedMediaArray.count > 0 && section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 23))
            let headerTitle = UILabel(frame: CGRect(x: 15, y: 5, width: tableView.frame.width, height: 23))
            headerTitle.text = "Upcoming"
            headerTitle.textColor = UIColor(colorLiteralRed: 33.0/255.0, green: 150.0/255.0, blue: 243.0/255.0, alpha: 1.0)
            headerTitle.font = UIFont(name: "Raleway-SemiBold", size: 15.0)
            headerView.backgroundColor = .white
            headerView.addSubview(headerTitle)
            return headerView
        } else {
            let headerView = UIView()
            return headerView
        }
    }
 
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 70.0
        } else {
            return self.view.frame.height / 8
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 1 && indexPath.row + 1 == tableView.numberOfRows(inSection: indexPath.section) && !self.loadingMore) {
            self.loadingMore = true
            self.loadMoreUnopened()
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
