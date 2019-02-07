//
//  TrailsDescriptionVC.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-20.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation


class HikeMapVC: UIViewController, MGLMapViewDelegate, DrawerViewControllerDelegate {
    
    /// Container View Top Constraint
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!

    /// Previous Container View Top Constraint
    private var previousContainerViewTopConstraint: CGFloat = 0.0

    /// Background Overlay Alpha
    private static let kBackgroundColorOverlayTargetAlpha: CGFloat = 0.4

    var mapView: NavigationMapView!
    var navigateButton: UIButton!
    var backButton: UIButton!
    var directionsRoute: Route?
   // var hike: Trail?
    
    var startOfHikeLocation: CLLocationCoordinate2D!
    var startHikeLocationString: [String] = []
    var userLocation: CLLocationCoordinate2D!
    let hikeModel = Hike()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            let group = DispatchGroup()
            group.enter()
        
            DispatchQueue.main.async {
                group.leave()
            }
        
      
            self.mapView = NavigationMapView(frame: self.view.bounds)
            self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.addSubview(self.mapView)
            self.view.sendSubviewToBack(self.mapView)
            self.mapView.delegate = self
            self.mapView.showsUserLocation = true
            //mapView.setUserTrackingMode(.follow, animated: true)
            // Do any additional setup after loading the view.
            self.pinRoute()
            self.addNavigationButton()
            self.addBackButton()
            
        
      
        
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // tableView.reloadData()
        self.configureDrawerViewController()

        
    }
    
    func initData(trail: Trail, userLocation: CLLocationCoordinate2D){
       
        //print(trail.startLocation)
        startHikeLocationString = trail.startLocation!.components(separatedBy: ",") // what if there is no location??
        
        self.startOfHikeLocation = CLLocationCoordinate2D(latitude: Double(startHikeLocationString[0])!, longitude: Double(startHikeLocationString[1])!)
        self.userLocation = userLocation

       self.hikeModel.initVariables(hike: trail)
        print("initData trail id: \(trail.id!)")
    }
}



//Map created features
extension HikeMapVC {
    
    func addBackButton() {
        let backbtnImg = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
        backButton = UIButton(frame: CGRect(x: view.frame.width * 0.025, y: view.frame.height * 0.05, width: 100, height: 50))
        backButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        backButton.layer.cornerRadius = 25
        backButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        backButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        backButton.layer.shadowRadius = 5
        backButton.layer.shadowOpacity = 0.3
        
        backButton.setImage(backbtnImg, for: .normal)
        backButton.tintColor = #colorLiteral(red: 0.2225596011, green: 0.5376087427, blue: 0.8762643933, alpha: 1)
        backButton.setTitle("  Back", for: .normal)
        backButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        backButton.setTitleColor(#colorLiteral(red: 0.2225596011, green: 0.5376087427, blue: 0.8762643933, alpha: 1), for: .normal)
        backButton.addTarget(self, action: #selector( backButtonWasPressed(_:)), for: .touchUpInside)
        //backButton.contentHorizontalAlignment = .left
        //view.addSubview(backButton)
        view.insertSubview(backButton, aboveSubview: mapView)

        
    }
    
    @objc func backButtonWasPressed(_ sender: UIButton){
        dismissDetail()
    }
    
    func addNavigationButton() {
        navigateButton = UIButton(frame: CGRect(x: (view.frame.width/2) - 100, y: view.frame.height - 215, width: 200, height: 50))
        navigateButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigateButton.setTitle("Get directions to Hike", for: .normal)
        navigateButton.setTitleColor(#colorLiteral(red: 0.2225596011, green: 0.5376087427, blue: 0.8762643933, alpha: 1), for: .normal)
        navigateButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        navigateButton.layer.cornerRadius = 25
        navigateButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigateButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigateButton.layer.shadowRadius = 5
        navigateButton.layer.shadowOpacity = 0.3
        navigateButton.addTarget(self, action: #selector(navigateButtonWasPressed(_:)), for: .touchUpInside)
        //view.addSubview(navigateButton)
        view.insertSubview(navigateButton, aboveSubview: mapView)
      
    }
    @objc func navigateButtonWasPressed(_ sender: UIButton){
        let navigationVC = NavigationViewController(for: directionsRoute!)
        present(navigationVC, animated: true, completion: nil)
    }
    
}

//Mapbox features
extension HikeMapVC {
    
    func pinRoute(){
        mapView.setUserTrackingMode(.none, animated: true)
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = startOfHikeLocation
        annotation.title = "Start Navigation"
        
        mapView.addAnnotation(annotation)
        //print("User location \(userLocation) vs \(mapView.userLocation!.coordinate)")
        calculateRoute(from: userLocation, to: startOfHikeLocation) { (route, error) in
            if error != nil {
                print("Error getting route")
            }
            
        }
    }
    
    func calculateRoute(from originCoor: CLLocationCoordinate2D, to destinationCoor: CLLocationCoordinate2D, completion: @escaping (Route?, Error?) -> Void){
        let origin = Waypoint(coordinate: originCoor, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destinationCoor, coordinateAccuracy: -1, name: "Finish")
        
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in
            self.directionsRoute = routes?.first
            
            //draw line
            if self.directionsRoute != nil{
                self.drawRoute(route: self.directionsRoute!)
                
                
                let coordinateBounds = MGLCoordinateBounds(sw: destinationCoor, ne: originCoor)
                let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
                let routeCam = self.mapView.cameraThatFitsCoordinateBounds(coordinateBounds, edgePadding: insets)
                self.mapView.setCamera(routeCam, animated: true)
            }else{
                // TO-DO: Banner saying no valid route found
            }
            
            
        })
    }
    
    func drawRoute(route: Route){
        guard route.coordinateCount > 0 else {return}
        var routeCoordinates = route.coordinates!
        
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        }else{
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(mglJSONObject: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
            lineStyle.lineWidth = NSExpression(mglJSONObject: 4.0)
            
            mapView.style?.addSource(source)
            mapView.style?.addLayer(lineStyle)
            
            
        }
        
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        let navigationVC = NavigationViewController(for: directionsRoute!)
        present(navigationVC, animated: true, completion: nil)
    }
    
    
}

//Firebase
extension HikeMapVC {
    
    
}

// DrawerVC relation
extension HikeMapVC {
    
   
    
    private func configureDrawerViewController() {
        
        let compressedHeight = ExpansionState.height(forState: .compressed, inContainer: view.bounds)
        let compressedTopConstraint = view.bounds.height - compressedHeight
        containerViewTopConstraint.constant = compressedTopConstraint
        previousContainerViewTopConstraint = containerViewTopConstraint.constant
        
        // NB: Handle this in a more clean and production ready fashion.
        if let drawerViewController = children.first as? DrawerViewController {
            //send distnace too
            drawerViewController.delegate = self
            print("configureDrawerViewController hike id: \(self.hikeModel.id!)")
            drawerViewController.fillDrawer(hike: self.hikeModel, userLocation: self.userLocation) // change to hike model
        }
        
        
        
        
        
    }
    
    // MARK: - DrawerViewControllerDelegate
    
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didChangeTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint) {
        /// Disable selection on drawerViewController's content while translating it.
        drawerViewController.view.isUserInteractionEnabled = false
        
        let newConstraintConstant = previousContainerViewTopConstraint + translationPoint.y
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        let constraintPadding: CGFloat = 50.0
        
        /// Limit the user from translating the drawer too far to the top
        if (newConstraintConstant >= fullHeightTopConstraint - constraintPadding/2) {
            containerViewTopConstraint.constant = newConstraintConstant
        }
    }
    
    /// Animates the top constraint of the drawerViewController by a given constant
    /// using velocity to calculate a spring and damping animation effect.
    private func animateTopConstraint(constant: CGFloat, withVelocity velocity: CGPoint) {
        let previousConstraint = containerViewTopConstraint.constant
        let distance = previousConstraint - constant
        let springVelocity = max(1 / (abs(velocity.y / distance)), 0.08)
        let springDampening = CGFloat(0.6)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: springDampening,
                       initialSpringVelocity: springVelocity,
                       options: [.curveLinear],
                       animations: {
                        self.containerViewTopConstraint.constant = constant
                        self.previousContainerViewTopConstraint = constant
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }
    
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didEndTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint) {
        let compressedHeight = ExpansionState.height(forState: .compressed, inContainer: view.bounds)
        let expandedHeight = ExpansionState.height(forState: .expanded, inContainer: view.bounds)
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let compressedTopConstraint = view.bounds.height - compressedHeight
        let expandedTopConstraint = view.bounds.height - expandedHeight
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        let constraintPadding: CGFloat = 50.0
        let velocityThreshold: CGFloat = 50.0
        drawerViewController.view.isUserInteractionEnabled = true
        
        if velocity.y > velocityThreshold {
            // Handle High Velocity Pan Gesture
            if previousContainerViewTopConstraint == fullHeightTopConstraint {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                    // From Full Height to Expanded
                    drawerViewController.expansionState = .expanded
                    animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
                } else {
                    // From Full Height to Compressed
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            } else if previousContainerViewTopConstraint == expandedTopConstraint {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                    // From Expanded to Full Height
                    drawerViewController.expansionState = .fullHeight
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } else {
                    // From Expanded to Compressed
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            } else {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                    // From Compressed to Full Height
                    drawerViewController.expansionState = .fullHeight
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } else {
                    // From Compressed back to Compressed
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            }
        } else {
            // Handle Low Velocity Pan Gesture
            if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                // Animate to the full height top constraint with velocity
                drawerViewController.expansionState = .fullHeight
                animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
            } else if containerViewTopConstraint.constant < compressedTopConstraint - constraintPadding {
                // Animate to the expanded top constraint with velocity
                drawerViewController.expansionState = .expanded
                animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
            } else {
                // Animate to the compressed top constraint with velocity
                drawerViewController.expansionState = .compressed
                animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
            }
        }
    }
    
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didChangeExpansionState expansionState: ExpansionState) {
        /// User tapped on the search bar, animate to FullHeight (NB: Abandoned this as it's not important to the demo,
        /// but it could be animated better and add support for dismissing the keyboard).
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: CGPoint(x: 0, y: -4536))
    }
    
}
