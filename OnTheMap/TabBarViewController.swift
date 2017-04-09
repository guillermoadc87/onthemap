//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Guillermo Diaz on 3/26/17.
//  Copyright © 2017 Guillermo Diaz. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func reloadModel(_ sender: Any) {
        let	mapViewController = self.viewControllers![0] as! MapViewController
        mapViewController.getStudentInfo()
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        UdacityLogin.sharedInstance().udacityLogout { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.dismiss(animated:true,completion:nil)
                }
            }else{
                print(errorString)
            }
        }
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        UdacityLogin.sharedInstance().getUserData { (success, error) in
            if error != nil {
                self.displayAlert(title: "User Data", message: "No Matching Location Found")
                
            } else {
                ParsedLogin.sharedInstance().haveSetALocation()
                print(StudentDataModel.objectId)
                performUIUpdatesOnMain {
                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addPinViewController")
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
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
