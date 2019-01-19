//
//  TrailsDescriptionVC.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-22.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import CoreLocation

class DrawerViewController: UIViewController, UIGestureRecognizerDelegate  {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hikeName: UILabel!
    @IBOutlet weak var userDistanceFromHike: UILabel!
    
     let hikeModel = Hike() // THIS SHOULD BE PRIVATE - make request function in model get/set
    
   // @IBOutlet weak var searchbar: UISearchBar!
    
    
    /// Pan Gesture Recognizer
    internal var panGestureRecognizer: UIPanGestureRecognizer?
    
    /// Current Expansion State
    var expansionState: ExpansionState = .compressed {
        didSet {
            if expansionState != oldValue {
                configure(forExpansionState: expansionState)
            }
        }
    }
    
    /// Delegate used to send panGesture events to the Parent View Controller
    /// to enable translation of the viewController in it's parent's coordinate system.
    weak var delegate: DrawerViewControllerDelegate?
    
    /// Determines if the panGestureRecognizer should ignore or handle a gesture. Used
    /// in the case of subview's with gestureRecognizers conflicting with the `panGestureRecognizer`
    /// such as the tableView's scrollView recognizer.
    private var shouldHandleGesture: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGestureRecognizers()
        configureAppearance()
        configureTableView()
        configure(forExpansionState: expansionState)
        
      
        
    }
    
    private func configureAppearance() {
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
       
    }
    
    // MARK: - Expansion State
    
    private func configure(forExpansionState expansionState: ExpansionState) {
        switch expansionState {
        case .compressed:
           
            tableView.panGestureRecognizer.isEnabled = false
            break
        case .expanded:
            
            tableView.panGestureRecognizer.isEnabled = false
            break
        case .fullHeight:
            
            if tableView.contentOffset.y > 0.0 {
                panGestureRecognizer?.isEnabled = false
            } else {
                panGestureRecognizer?.isEnabled = true
            }
            tableView.panGestureRecognizer.isEnabled = true
            break
        }
    }
    
 
    
    // MARK: - Gesture Recognizers
    
    private func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(panGestureDidMove(sender:)))
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = self
        
        view.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer
    }
    
    @objc private func panGestureDidMove(sender: UIPanGestureRecognizer) {
        guard shouldHandleGesture else { return }
        let translationPoint = sender.translation(in: view.superview)
        let velocity = sender.velocity(in: view.superview)
        
        switch sender.state {
        case .changed:
            delegate?.drawerViewController(self, didChangeTranslationPoint: translationPoint, withVelocity: velocity)
        case .ended:
            delegate?.drawerViewController(self,
                                           didEndTranslationPoint: translationPoint,
                                           withVelocity: velocity)
        default:
            return
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    /// Called when the `panGestureRecognizer` has to simultaneously handle gesture events with the
    /// tableView's gesture recognizer. Chooses to handle or ignore events based on the state of the drawer
    /// and the tableView's y contentOffset.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGestureRecognizer.velocity(in: view.superview)
        tableView.panGestureRecognizer.isEnabled = true
        
        if otherGestureRecognizer == tableView.panGestureRecognizer {
            switch expansionState {
            case .compressed:
                return false
            case .expanded:
                return false
            case .fullHeight:
                if velocity.y > 0.0 {
                    // Panned Down
                    if tableView.contentOffset.y > 0.0 {
                        return true
                    }
                    shouldHandleGesture = true
                    tableView.panGestureRecognizer.isEnabled = false
                    return false
                } else {
                    // Panned Up
                    shouldHandleGesture = false
                    return true
                }
            }
        }
        return false
    }
    
    /// Called when the user scrolls the tableView's scroll view. Resets the scrolling
    /// when the user hits the top of the scrollview's contentOffset to support seamlessly
    /// transitioning between the scroll view and the panGestureRecognizer under the user's finger.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let panGestureRecognizer = panGestureRecognizer else { return }
        
        let contentOffset = scrollView.contentOffset.y
        if contentOffset <= 0.0 &&
            expansionState == .fullHeight &&
            panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview).y != 0.0 {
            shouldHandleGesture = true
            scrollView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
        }
    }
    

    
   

}


extension DrawerViewController {

    
    func fillDrawer(hike: Trail, userLocation: CLLocationCoordinate2D){
       // print("drawer name of hike: \(hike.name!)")
        
        hikeName.text = hike.name
        
        //HOW OFTEN DOES THIS GET UPDATED?
        let hikelocation = hike.startLocation!.components(separatedBy: ",")
        let coordinate₀ = userLocation
        let coordinate₁ = CLLocationCoordinate2D(latitude: Double(hikelocation[0])!, longitude: Double(hikelocation[1])!)
        let distanceInKms = coordinate₀.distance(to: coordinate₁)/1000 // result is in meters
        
        let urlRequestPath = "api.openweathermap.org/data/2.5/weather?lat="+hikelocation[0]+"&lon="+hikelocation[1]+"&APPID=40007f41ed0a8967d15e8207d7cc71b6"
        //Make APPID more secure. Maybe get it from firebase..
        //
        let url = URL(string: urlRequestPath)!
          
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        
        
        
        userDistanceFromHike.text = String(distanceInKms.rounded(.up))
        hikeModel.difficulty = hike.difficulty
        hikeModel.distance = hike.distance
        hikeModel.elevation = hike.elevation
        hikeModel.startLocation = hike.startLocation
        hikeModel.time = hike.time
        
    }
    
    func getDistanceFromTwoLocations(userLocation: CLLocationCoordinate2D){
        //move here that code you know
    }
    
}

