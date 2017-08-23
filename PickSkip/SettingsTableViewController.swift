//
//  SettingsTableViewController.swift
//  PickSkip
//
//  Created by Eric Duong on 8/20/17.
//  Copyright © 2017 Eric Duong. All rights reserved.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {
    
    let more = ["Logout"]
    let moreInfo = ["Terms of Use", "Privacy Policy", "Support"]
    var webAddress: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView?.tintColor = .blue
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "Raleway-Light", size: 15.0)!
            ], for: .normal)

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.sectionHeaderHeight))
        let headerTitle = UILabel(frame: CGRect(x: 15, y: tableView.sectionHeaderHeight, width: tableView.frame.width, height: tableView.sectionHeaderHeight))
        headerTitle.textColor = Constants.defaultBlueColor
        headerTitle.font = UIFont(name: "Raleway-SemiBold", size: 15.0)
        headerView.backgroundColor = .clear
        
        if section == 0 {
            headerTitle.text = "Information"
            headerView.addSubview(headerTitle)
        } else if section == 1 {
            headerTitle.text = "More"
            headerView.addSubview(headerTitle)
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 3
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: Constants.defaultFont, size: 15.0)
        if indexPath.section == 0 {
            cell.textLabel?.text = moreInfo[indexPath.row]
            return cell
        } else if indexPath.section == 1 {
            cell.textLabel?.text = more[indexPath.row]
            return cell
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                alert.dismiss(animated: false, completion: nil)
            })
            let logoutAction = UIAlertAction(title: "Logout", style: .default, handler: { (action) in
                do {
                    try Auth.auth().signOut()
                    self.dismiss(animated: true, completion: nil)
                } catch {
                    print("error signing out")
                }
            })
            alert.addAction(cancelAction)
            alert.addAction(logoutAction)
            self.present(alert, animated: true, completion: nil)
        } else if indexPath.section == 0 {
            if indexPath.row == 0 {
                webAddress = "https://sites.google.com/site/pickskiplegal/terms-o"
            } else if indexPath.row == 1 {
                webAddress = "https://sites.google.com/site/pickskiplegal/privacy-policy"
            } else if indexPath.row == 2 {
                webAddress = "https://sites.google.com/site/pickskiplegal/contact"
            }
            if (webAddress) != nil {
               performSegue(withIdentifier: "showWebView", sender: self) 
            }
            
        }
        // todo: implement webview for support/privacy policy/terms of use
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            let vc = segue.destination as! WebViewController
            vc.webAddress = webAddress
        }
    }
    
 
    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
