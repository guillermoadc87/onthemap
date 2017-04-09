//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Guillermo Diaz on 3/26/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("number of student locations: \(StudentDataModel.studentLocations.count)")
        return StudentDataModel.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        let student = StudentDataModel.studentLocations[(indexPath as NSIndexPath).row]
        cell.nameLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.websiteLabel?.text = "\(student.website)"
        //print("*** cell ***")
        //print(cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = StudentDataModel.studentLocations[indexPath.row]
        if let url = URL(string: selectedCell.website) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }else{
                performUIUpdatesOnMain {
                    print("Selected web link could not be opened.")
                }
            }
        }else{
            performUIUpdatesOnMain {
                print("Not a valid web link.")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
