//
//  SideBarController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-04-05.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import MessageUI

protocol ChildToParentProtocol:class {

    func OrderHikeListBy(Order: String)
}

class SideBarController: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var closestHikeDot: UIImageView!
    @IBOutlet weak var hikeNameDot: UIImageView!
    @IBOutlet weak var hikeDistanceDot: UIImageView!
    @IBOutlet weak var hikeDifficultyDot: UIImageView!
    @IBOutlet weak var hikeRegionDot: UIImageView!
    
    weak var delegate:ChildToParentProtocol? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = false
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = true
    }
    

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("Order the list by", comment: "Order options")
        case 1:
            sectionName = NSLocalizedString("More", comment: "Detail options")
        // ...
        default:
            sectionName = ""
        }
        return sectionName
    }
    
    @IBAction func ClosesHikeToYouBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "closest")
        closestHikeDot.isHidden = false
        hikeNameDot.isHidden = true
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = true
    }
    
    @IBAction func HikeNameBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "name")
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = false
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = true
    }
    @IBAction func HikeDistanceBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "distance")
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = true
        hikeDistanceDot.isHidden = false
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = true
    }
    @IBAction func HikeDifficultyBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "difficulty")
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = true
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = false
        hikeRegionDot.isHidden = true
    }
    
    @IBAction func HikeRegionBtn_Pressed(_ sender: Any) {
        delegate?.OrderHikeListBy(Order: "region")
        closestHikeDot.isHidden = true
        hikeNameDot.isHidden = true
        hikeDistanceDot.isHidden = true
        hikeDifficultyDot.isHidden = true
        hikeRegionDot.isHidden = false
    }
    
    @IBAction func feedbackButtonPressed(_ sender: Any) {
        notifyUser(title: "Stay tuned for more improvements 👷🏼‍♂️👷🏼‍♀️", message: "If you have feedback please write to: outdoorsyclient@gmail.com or click on Send email", imageName: "", rate: true, extraOption: "Send email", handleComplete: sendEmail)
    }
    
    @IBAction func rateAppButtonPressed(_ sender: Any) {
        rateApp()
    }
    
    func mailComposeController( _ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismissDetail()
    }
    func createMailComposeViewController() -> MFMailComposeViewController {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients(["outdoorsyclient@gmail.com"])
        mailComposeViewController.setSubject("Feedback")
        mailComposeViewController.setMessageBody("Hey mate,", isHTML: false)
        return mailComposeViewController
    }
    func sendEmail() -> () {
        let composeVC = createMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
            return
        }else{
            print("Mail services are not available")
        }
    }
    
    
    
}
