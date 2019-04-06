//
//  TrailsDescriptionVC.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-22.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase

class DrawerViewController: UIViewController, UIGestureRecognizerDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hikeName: UILabel!
    @IBOutlet weak var userDistanceFromHike: UILabel!
    
     let hikeModel = Hike() // THIS SHOULD BE PRIVATE - make request function in model get/set
    
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
       
        configure(forExpansionState: expansionState)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        configureTableView()
        
        
        
        
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

    
    func fillDrawer(hike: Hike, userLocation: CLLocationCoordinate2D){

         let hikeLocation = hike.coordinates?[0].components(separatedBy: ",")
        setDistanceFromTwoLocations(hikeLocation: hikeLocation!, userLocation: userLocation)
        
        //if no weather return make sure to show a text with that
        //add loading to cell
        getWeatherConditions(trailId: hike.id)
        hikeName.text = hike.name
        hikeModel.copyData(hike: hike)
    }
    
     func setDistanceFromTwoLocations(hikeLocation: [String], userLocation: CLLocationCoordinate2D){
        let coordinate₀ = userLocation
        let coordinate₁ = CLLocationCoordinate2D(latitude: Double(hikeLocation[0])!, longitude: Double(hikeLocation[1])!)
        let distanceInKms = Int(coordinate₀.distance(to: coordinate₁)/1000) // result is in kms

        
        userDistanceFromHike.text = distanceInKms > 900 ? "You're too far" : String(distanceInKms) + "km away";
    }
}


//Firebase
extension DrawerViewController {
    
    
    func getDirectionOfWind(degree: Double)-> String{
        //print("degree:\(degree)")
        switch degree {
            case 0, 360:
                return "N"
            case 90:
                 return "E"
            case 180:
                return "S"
            case 270:
                return "W"
            case _ where degree > 0 && degree < 90:
                return "NE"
            case _ where degree > 90 && degree < 180:
                return "SE"
            case _ where degree > 180 && degree < 270:
                return "SW"
            case _ where degree > 270 && degree < 360:
                 return "NW"
            
            default:
                return "--"
        }
        
    }
    
    
    
    func getWeatherConditions(trailId: String?){
        
        //print("getWeatherConfitions trailid: \(trailId!)")
        let trailsReference = Database.database().reference()
        trailsReference.keepSynced(true)
        let itemsRef = trailsReference.child("weatherStartLocation").child(trailId!)
        itemsRef.queryOrderedByValue().observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as AnyObject
            print("Weather data form api:\(value)")
            
            if let tempNSNumber = value["temperature"] {
                self.hikeModel.temperature = String(format:"%.1f", tempNSNumber as! Double)
            }else{
                self.hikeModel.temperature = "--"
            }
            
            if let windSpeedNSNumber = value["windSpeed"] {
                let windSpeed = windSpeedNSNumber as? Double
                self.hikeModel.windSpeed = String(format:"%.1f", windSpeed as! CVarArg)
            }else{
                self.hikeModel.windSpeed = "--"
            }
            
            if let windDegree = value["windDeg"] {
                if let validWindDegree = windDegree as? Double {
                    self.hikeModel.windDirection = self.getDirectionOfWind(degree: validWindDegree)
                }
                else {
                      self.hikeModel.windDirection = self.getDirectionOfWind(degree: -1)
                }
                
            }else{
                 self.hikeModel.windDirection = "--"
            }
            
            if let barometer = value["barometer"] {
                self.hikeModel.barometer =  String(format: "%@", barometer as! CVarArg)
            }else{
                 self.hikeModel.barometer = "--"
            }
            
            if let weather = value["weather"] {
               self.hikeModel.weather = weather as? String
            }else{
                self.hikeModel.weather = "--"
            }
            
            if let weatherIcon = value["weatherIcon"] {
                self.hikeModel.weatherIcon = weatherIcon as? String
            }else{
                self.hikeModel.weatherIcon = "--"
            }
            
            if let barometer = value["barometer"] {
                self.hikeModel.barometer =  String(format: "%@", barometer as! CVarArg)
            }else{
                self.hikeModel.barometer = "--"
            }
            
            if let humidity = value["humidity"]{
                self.hikeModel.humidity = String(format: "%@", humidity as! CVarArg)
                
            }else{
                self.hikeModel.humidity = "--"
            }
            
            if let sunrise = value["sunrise"] {
                   self.hikeModel.sunrise = sunrise as? String
            }else{
                self.hikeModel.sunrise = "--"
            }
            
            if let sunset = value["sunset"] {
                self.hikeModel.sunset = sunset as? String
            }else{
                self.hikeModel.sunset = "--"
            }
            
            if let visibility = value["visibility"] {
                self.hikeModel.visibility = String(format: "%@", visibility as! CVarArg)
                
            }else {
                self.hikeModel.visibility = "No Data"
            }
            
            if let tempMin = value["tempMin"] {
                 self.hikeModel.tempMin = String(format:"%.1f", tempMin as! Double)
            }else{
                self.hikeModel.tempMin = "--"
            }
            
            if let tempMax = value["tempMax"] {
                self.hikeModel.tempMax = String(format:"%.1f", tempMax as! Double)
            }else{
                self.hikeModel.tempMax = "--"
            }
                
            if let clouds = value["clouds"] {
                self.hikeModel.clouds = String(format: "%@", clouds as! CVarArg)
                
            }else {
                self.hikeModel.clouds = "--"
            }
            
            
            
            let indexPath = IndexPath(item: 1, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .top)
            
            
        }){ (error) in
            print("getWeatherConditions Error: \(error.localizedDescription)")
        }
    }
    
    
}

