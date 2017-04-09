
//
//  ViewController.swift
//  OnTheMap
//
//  Created by Guillermo Diaz on 11/6/16.
//  Copyright © 2016 Guillermo Diaz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var appDelegate: AppDelegate!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if username.text!.isEmpty || self.password.text!.isEmpty {
            print("Username or Password is empty")
        } else {
            UdacityLogin.sharedInstance().getUserID(username: username.text!, password: password.text!) { (result, error) in
                if let error = error {
                    print(error)
                }
                performUIUpdatesOnMain {
                    StudentDataModel.accountKey = result as! String
                    self.completeLogin()
                }
            }
        }
    }
    
    func getUserData(userID: String) {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userID)")!)
        let task = appDelegate.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let range = Range(uncheckedBounds: (5, data!.count))
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            

        }
        task.resume()
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navViewController")
            self.present(controller, animated: true, completion: nil)
        }
    }
}

