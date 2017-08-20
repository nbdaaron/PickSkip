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
import AVFoundation
import PhoneNumberKit
import Photos

class HistoryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mediaView: PreviewView!
    @IBOutlet weak var viewTitle: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var showSettingsButton: UIButton!
    @IBOutlet weak var titlePanel: UIView!
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var downloadMediaButton: UIButton!
    @IBOutlet weak var mediaDateLabel: UILabel!
    
    var dataService = DataService.instance
    var openedMediaArray: [Media] = []
    var unopenedMediaArray: [Media] = []
    var uid: String?
    var timerRefresh: Timer!
    
    var loadingMore: Bool = false
    var initialFetch: Bool = true
    
    let phoneNumberKit = PhoneNumberKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Constants.contacts.count == 0 {
            Util.loadContacts()
        }
        
        mediaDateLabel.adjustsFontSizeToFitWidth = true
        mediaDateLabel.layer.cornerRadius = 10
        mediaDateLabel.clipsToBounds = true
        
        //refreshes table every minute 
        self.timerRefresh = Timer(timeInterval: 60.0, repeats: true, block: {_ in
            self.tableView.reloadData()
        })
        RunLoop.main.add(timerRefresh, forMode: .defaultRunLoopMode)
        
        additionalLayout()
        setupGestures()
        setupLoadMore()
        loadContent()
    }
    
    func setupGestures() {
        //gesture setup for when title pressed scroll to upcoming
        let gesture = UITapGestureRecognizer(target: self, action: #selector(titlePressed(gesture:)))
        viewTitle.addGestureRecognizer(gesture)
        //gesture setup for when presented media is pressed to hide media
        let closeMediaGesture = UITapGestureRecognizer(target: self, action: #selector(hideMedia(gesture:)))
        optionsView.addGestureRecognizer(closeMediaGesture)
    }
    
    func additionalLayout() {
        titlePanel.addBottomBorder(with: UIColor(colorLiteralRed: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0) , andWidth: 1.0)
        
        downloadMediaButton.imageView?.contentMode = .scaleAspectFit
        showSettingsButton.imageView?.contentMode = .scaleAspectFit
        cameraButton.imageView?.contentMode = .scaleAspectFit
        
        tableView.tableHeaderView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UnopenedMediaCell.self, forCellReuseIdentifier: "unopenedCell")
        tableView.register(OpenedMediaCell.self, forCellReuseIdentifier: "openedCell")
        tableView.separatorColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if initialFetch == false {
            if self.tableView.numberOfSections == 2 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: true)
            }
            
        }
    }
    
    func loadContent() {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
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
                    
                    self.unopenedMediaArray.insert(mediaInstance, at: i)
                    break
                }
            }
            self.tableView.reloadData()
        })

    }

    func setupLoadMore() {
        self.tableView.refreshControl = UIRefreshControl()
        
        self.tableView.refreshControl!.attributedTitle = NSAttributedString(string: "Load more opened media", attributes: [NSForegroundColorAttributeName: UIColor.black, NSFontAttributeName: UIFont(name: "Raleway-Light", size: 15.0)!])
        self.tableView.refreshControl!.addTarget(self, action: #selector(loadMoreOpened), for: UIControlEvents.valueChanged)
    }
    
    public func loadMoreOpened() {
        
        let number = Auth.auth().currentUser!.providerData.first!.phoneNumber!
        let startingPoint = -(openedMediaArray.first?.openDate ?? Int.max)
        
        //Load X opened.
        dataService.usersRef.child(number).child("opened").queryOrderedByPriority().queryStarting(atValue: startingPoint).queryLimited(toFirst: Constants.loadCount).observe(DataEventType.childAdded, with: { (snapshot) in
            for media in self.openedMediaArray {
                if media.key == snapshot.key {
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                    return
                }
            }
            
            
            let httpsReference = Storage.storage().reference(forURL: snapshot.childSnapshot(forPath: "mediaURL").value as! String)
            let thumbnailReference = Storage.storage().reference(forURL: snapshot.childSnapshot(forPath: "thumbnail").value as! String)
            
            let mediaInstance = Media(senderNumber: snapshot.childSnapshot(forPath: "senderNumber").value as! String,
                                      key: snapshot.key,
                                      type: snapshot.childSnapshot(forPath: "mediaType").value as! String,
                                      releaseDateInt: snapshot.childSnapshot(forPath: "releaseDate").value as! Int,
                                      sentDateInt: snapshot.childSnapshot(forPath: "sentDate").value as! Int,
                                      url: httpsReference,
                                      openDate: snapshot.childSnapshot(forPath: "opened").value as! Int,
                                      thumbnailReference: thumbnailReference)
            self.openedMediaArray.insert(mediaInstance, at: 0)
            
            thumbnailReference.getData(maxSize: Constants.maxDownloadSize, completion: { (data,error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    if let index = self.openedMediaArray.index(where: {$0.key == snapshot.key}) {
                        self.openedMediaArray[index].thumbnailData = data!
                        self.tableView.reloadData()
                    }
                }
            })
            
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            
            
        })
        self.tableView.refreshControl?.endRefreshing()
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
            
            if mediaInstance.releaseDate < Date() {
                UIApplication.shared.applicationIconBadgeNumber += 1
            }
            
            for i in 0..<self.unopenedMediaArray.count {
                if mediaInstance.releaseDate < self.unopenedMediaArray[i].releaseDate {
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
    
    func hideMedia(gesture: UITapGestureRecognizer) {
        mediaView.isHidden = true
        optionsView.isHidden = true
        mediaDateLabel.text = ""
        mediaView.removeExistingContent()
        tableView.reloadData()
    }
    
    func showMedia() {
        view.bringSubview(toFront: mediaView)
        view.bringSubview(toFront: optionsView)
        mediaView.isHidden = false
        optionsView.isHidden = false
    }

    
    @IBAction func showSettings(_ sender: Any) {
        performSegue(withIdentifier: "showSettings", sender: self)
        
    }

    @IBAction func goToCamera(_ sender: Any) {
        if let parentController = self.parent as? MainPagesViewController {
           parentController.setViewControllers([parentController.pages[Constants.initialViewPosition]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    //Gesture that scrolls to Upcoming if title is pressed
    func titlePressed(gesture: UITapGestureRecognizer) {
        if tableView.numberOfRows(inSection: 1) > 1 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: true)
        }
    }
    
    //delete cell on long press
    func deleteCell(gesture: UILongPressGestureRecognizer) {
        print(self.openedMediaArray)
        let point: CGPoint = gesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        let alert = UIAlertController(title: "Delete media", message: "Are you sure you want to delete this picture or video?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action) in
            alert.dismiss(animated: false, completion: nil)
        })
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            (action) in
            if let indexPath = indexPath {
                DataService.instance.remove(key: self.openedMediaArray[indexPath.row].key, thumbnailRef: self.openedMediaArray[indexPath.row].thumbnailRef, mediaRef: self.openedMediaArray[indexPath.row].url)
                self.openedMediaArray.remove(at: indexPath.row)
            }
            
            self.tableView.reloadData()
        })
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Gets the name of contact correpsonding to number if possible
    func getCorrespondingName(of number: String) -> String {
        if number == Auth.auth().currentUser?.providerData[0].phoneNumber! {
            return "Me"
        } else {
            for contact in Constants.contacts {
                do {
                    let phoneNumber = try phoneNumberKit.parse(contact.phoneNumbers[0].value.stringValue)
                    let parsedNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
                    if number == parsedNumber {
                        return Util.getNameFromContact(contact)
                    }
                } catch {
                    print("error trying to parse phone number")
                }
            }
            return number
        }
    }
    
    //Download media to photo library
    @IBAction func downloadMedia(_ sender: Any) {
        if let image = mediaView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else if let videoPlayer = mediaView.playerLayer?.player {
            let url = (videoPlayer.currentItem?.asset as! AVURLAsset).url
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }, completionHandler: { (saved, error) in
                if let error = error {
                    print("Error downloading video: \(error.localizedDescription)")
                } else {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //tableView datasource methods
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
            
            let cancelGesture = UILongPressGestureRecognizer(target: self, action: #selector(deleteCell(gesture:)))
            cancelGesture.minimumPressDuration = 1.0
            cell.addGestureRecognizer(cancelGesture)

            // cell data
            cell.media = self.openedMediaArray[indexPath.row]
            cell.nameLabel.text = getCorrespondingName(of: cell.media.senderNumber)
            cell.dateLabel.text = Util.formatDateLabelDate(date: Date(timeIntervalSince1970: TimeInterval(cell.media.openDate)), split: true)
            
            cell.thumbnailImageView.image = nil
            if let thumbnailData = cell.media.thumbnailData{
                cell.thumbnailImageView.image = UIImage(data: thumbnailData)
            }
            //Default cell aspects
            
            //Format cell appearance based on state
            if cell.media.loadState == .loaded {
                cell.cancelAnimation()
            } else if cell.media.loadState == .loading{
                cell.loadAnimation()
            } else {
                cell.dateLabel.textColor = .black
                cell.nameLabel.textColor = .black
            }
            
            return cell
        } else if indexPath.section == 1 && unopenedMediaArray.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "unopenedCell", for: indexPath) as! UnopenedMediaCell
            
            //cell data
            cell.media = self.unopenedMediaArray[indexPath.row]
            cell.nameLabel.text = getCorrespondingName(of: cell.media.senderNumber)
            cell.dateLabel.text = Util.getBiggestComponenet(release: cell.media.releaseDate)
            cell.cellFrame.layer.borderWidth = 1.0

            //Check how to display cell
            if cell.media.loadState == .loaded {
                cell.cancelAnimation()
            } else if cell.media.loadState == .loading{
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
        
        if indexPath.section == 0 {
            let cell = self.tableView.cellForRow(at: indexPath) as! OpenedMediaCell
            if cell.media.loadState == .loaded {
                
                if cell.media.mediaType == "image" {
                    let image = UIImage(data: openedMediaArray[indexPath.row].image!)
                    mediaView.displayImage(image!)
                } else {
                    mediaView.displayVideo(openedMediaArray[indexPath.row].video!)
                }
                
                showMedia()
                mediaDateLabel.text = "Sent " + Util.formatDateLabelDate(date: cell.media.sentDate, split: false)
                
            } else if cell.media.loadState == .unloaded {
                cell.media.load() {
                    //CODE TO EXECUTE WHEN DONE LOADING
                    cell.cancelAnimation()
                }
                //CODE TO EXECUTE WHILE LOADING
                cell.loadAnimation()
            }
        } else {
            
            let cell = self.tableView.cellForRow(at: indexPath) as! UnopenedMediaCell
            if Date() < cell.media.releaseDate {
                cell.shake()
            } else {
                if cell.media.loadState == .loaded {
                    if cell.media.mediaType == "image" {
                        
                        let image = UIImage(data: cell.media.image!)
                        mediaView.displayImage(image!)
                        let thumbnailRef = DataService.instance.imagesStorageRef.child("\(NSUUID().uuidString)_thumbnail.jpg")
                        let thumbnailData = Util.getThumbnail(imageData: cell.media.image!, videoURL: nil)
                        //start thumbnail upload
                        createThumbnail(cell: cell, indexPath: indexPath, thumbnailData: thumbnailData, thumbnailRef: thumbnailRef)
                        
                    } else {
                        mediaView.displayVideo(cell.media.video!)
                        
                        //get image from video
                        let url = (cell.media.video?.currentItem?.asset as! AVURLAsset).url
                        let thumbnailRef = DataService.instance.imagesStorageRef.child("\(NSUUID().uuidString)_thumbnail.jpg")
                        let thumbnailData = Util.getThumbnail(imageData: nil, videoURL: url)
                        //start thumbnail upload
                        createThumbnail(cell: cell, indexPath: indexPath, thumbnailData: thumbnailData, thumbnailRef: thumbnailRef)
                    }
                    showMedia()
                    mediaDateLabel.text = "Sent " + Util.formatDateLabelDate(date: cell.media.sentDate, split: false)
                    UIApplication.shared.applicationIconBadgeNumber  -= 1
                    
                } else if cell.media.loadState == .unloaded {
                    cell.media.load() {
                        //CODE TO EXECUTE WHEN DONE LOADING
                        cell.cancelAnimation()
                    }
                    //CODE TO EXECUTE WHILE LOADING
                    cell.loadAnimation()
                }
            }
        }
    }
    
    //uploads thumbnail data and sets the media to opened
    func createThumbnail(cell: UnopenedMediaCell, indexPath: IndexPath, thumbnailData: Data, thumbnailRef: StorageReference) {
        _ = thumbnailRef.putData(thumbnailData, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print("error: \(error.localizedDescription)")
            } else {
                let downloadURL = metadata?.downloadURL()
                let openDate = Int(Date().timeIntervalSince1970)
                self.unopenedMediaArray[indexPath.row].openDate = openDate
                cell.media.openDate = openDate
                self.unopenedMediaArray[indexPath.row].thumbnailData = thumbnailData
                cell.media.thumbnailData = thumbnailData
                DataService.instance.setOpened(key: self.unopenedMediaArray[indexPath.row].key, openDate: openDate, thumbnailURL: downloadURL!.absoluteString)
                
                self.openedMediaArray.append(self.unopenedMediaArray.remove(at: indexPath.row))
                self.tableView.reloadData()
                
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
        let headerTitle = UILabel(frame: CGRect(x: 15, y: 3, width: tableView.frame.width, height: 23))
        headerTitle.font = UIFont(name: "Raleway-SemiBold", size: 15.0)
        headerTitle.textColor = Constants.defaultBlueColor
        headerView.backgroundColor = .white
        
        // Checks if rows exist in each section before adding section header
        if openedMediaArray.count > 0 && section == 0 {
            headerTitle.text = "Opened"
        } else if unopenedMediaArray.count > 0 && section == 1 {
            headerTitle.text = "Upcoming"
        }
        
        headerView.addSubview(headerTitle)
        return headerView
        
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

