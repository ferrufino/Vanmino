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
import SystemConfiguration

class HikeMapVC: UIViewController, MGLMapViewDelegate, DrawerViewControllerDelegate {
    
    /// Container View Top Constraint
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    
    /// Previous Container View Top Constraint
    private var previousContainerViewTopConstraint: CGFloat = 0.0
    
    /// Background Overlay Alpha
    private static let kBackgroundColorOverlayTargetAlpha: CGFloat = 0.4
    
    /// Array of offline packs for the delegate work around (and your UI, potentially)
    var offlinePacks = [MGLOfflinePack]()
    
    var mapView: NavigationMapView!
    var navigateButton: UIButton!
    var backButton: UIButton!
    var saveButton: UIButton!
    var directionsRoute: Route?
    var hikeRoute: Route?
    // var hike: Trail?
    
    var startOfHikeLocation: CLLocationCoordinate2D!
    var startHikeLocationString: [String] = []
    var userLocation: CLLocationCoordinate2D!
    let hikeModel = Hike()
    
    var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setMapViewServices()
        addFeaturesToMap()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureDrawerViewController()
   
    }
    
    func setMapViewServices(){
        let styleURL = URL(string: "mapbox://styles/mapbox/outdoors-v9")
        self.mapView = NavigationMapView(frame: self.view.bounds,
                                         styleURL: styleURL)
        
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(self.mapView)
        self.view.sendSubviewToBack(self.mapView)
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
    }
    
    func addFeaturesToMap(){
        // Do any additional setup of features after loading the view.
        self.setupNavigationCapabilityFromUserLocation()
        self.addNavigationButton()
        self.drawHike()
        self.addBackButton()
        //self.addSaveButton()
    }
    
    func initData(hike: Hike, userLocation: CLLocationCoordinate2D){
        
        if hike.startLocation != nil {
            startHikeLocationString = hike.startLocation!.components(separatedBy: ",") // what if there is no location??
            
            self.startOfHikeLocation = CLLocationCoordinate2D(latitude: Double(startHikeLocationString[0])!, longitude: Double(startHikeLocationString[1])!)
            self.userLocation = userLocation
            
            self.hikeModel.copyData(hike: hike)
            print("initData trail id: \(hike.id!)")
        }else{
            
            print("No start location found for Hike \(hike.name)")
        }
        
    }
    
    deinit {
        // Remove offline pack observers.
        NotificationCenter.default.removeObserver(self)
    }

////////////////////////////////////////////////////////////////
//OFFLINE MAPDOWNLOAD AVAILABILITY
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // Start downloading tiles and resources for z13-16.
        
        //Add feature to save Map if button pressed or paid version
        // startOfflinePackDownload()
    }
    
    
    func startOfflinePackDownload() {
        // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
        // Because tile count grows exponentially with the maximum zoom level, you should be conservative with your `toZoomLevel` setting.
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: 16)
        
        // Store some data for identification purposes alongside the downloaded resources.
        let userInfo = ["name": "My Offline Pack"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        // Create and register an offline pack with the shared offline storage object.
        
        MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                // The pack couldn’t be created for some reason.
                print("Error downloading map: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // Start downloading.
            pack!.resume()
            
            // Retain reference to pack to work around it being lost and not sending delegate messages
            self.offlinePacks.append(pack!)
        }
        
    }
    
    // MARK: - MGLOfflinePack notification handlers
    
    @objc func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // Setup the progress bar.
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: .default)
                let frame = view.bounds.size
                progressView.frame = CGRect(x: frame.width / 4, y: frame.height * 0.75, width: frame.width / 2, height: 10)
                view.addSubview(progressView)
            }
            
            progressView.progress = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
                print("Offline pack “\(userInfo["name"] ?? "unknown")” completed: \(byteCount), \(completedResources) resources")
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    
    @objc func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
        }
    }
    
    @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
        }
    }
//END OF OFFLINE MAP DOWNLOAD AVAILABILITY
/////////////////////////////////////////////////////////////////
}



//Map created features
extension HikeMapVC {
    func addSaveButton() {
        ///https://stackoverflow.com/questions/41477775/why-does-my-uitableview-only-show-the-list-of-available-mglofflinepacks-after-i
        saveButton = UIButton(frame: CGRect(x: view.frame.width * 0.70, y: view.frame.height * 0.05, width: 100, height: 50))
        saveButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        saveButton.layer.cornerRadius = 25
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        saveButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        saveButton.layer.shadowRadius = 5
        saveButton.layer.shadowOpacity = 0.3
        
        
        saveButton.tintColor = #colorLiteral(red: 0.2225596011, green: 0.5376087427, blue: 0.8762643933, alpha: 1)
        saveButton.setTitle("Save Offline", for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        saveButton.setTitleColor(#colorLiteral(red: 0.2225596011, green: 0.5376087427, blue: 0.8762643933, alpha: 1), for: .normal)
        saveButton.addTarget(self, action: #selector( saveButtonWasPressed(_:)), for: .touchUpInside)
        
        view.insertSubview(saveButton, aboveSubview: mapView)
        
        
    }
    
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
    
    @objc func saveButtonWasPressed(_ sender: UIButton){
        startOfflinePackDownload()
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
    
    func drawHike(){
        let hikeCoordinates = hikeModel.coordinates ?? []
        if  hikeCoordinates != [] {
            let coor: [CLLocationCoordinate2D] = convertCoordinates(coordinatesArray: hikeCoordinates)
            drawHikeTrail(coordinates: coor)
        }else{
            print("No Coordinates found for Hike \(hikeModel.name)")
        }
        
    }
    
    func setupNavigationCapabilityFromUserLocation(){
        // erase this line if nothing changes here: mapView.setUserTrackingMode(.none, animated: true)
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
            
            
        })
    }
    
    func  drawHikeTrail(coordinates: [CLLocationCoordinate2D])-> Void{
        
        if !isConnectedToNetwork(){
             print("no wifi")
            for map in offlinePacks{
                 print(map)
            }
            print(MGLOfflineStorage.shared.packs)
            
        }else{
            
            let options = NavigationRouteOptions(coordinates: coordinates, profileIdentifier: MBDirectionsProfileIdentifier.walking)
            
            _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in
                self.hikeRoute = routes?.first
                
                //Set where map will focus on
                self.mapView?.setVisibleCoordinates(
                    coordinates,
                    count: UInt(coordinates.count),
                    edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100),
                    animated: true
                )
                
                //draw line
                if self.hikeRoute != nil{
                    
                    self.drawRoute(route: self.hikeRoute!)
                    
                }else{
                    // TO-DO: Banner saying no valid route found
                    print("No valid route found")
                }
                
            })
            
            
            
            // Point Annotations
            // Add a custom point annotation for every coordinate (vertex) in the polyline.
            var pointAnnotations = [CustomPointAnnotation]()
            for coordinate in coordinates {
                let count = pointAnnotations.count + 1
                let point = CustomPointAnnotation(coordinate: coordinate,
                                                  title: "Custom Point Annotation \(count)",
                    subtitle: nil)
                
                // Set the custom `image` and `reuseIdentifier` properties, later used in the `mapView:imageForAnnotation:` delegate method.
                // Create a unique reuse identifier for each new annotation image.
                point.reuseIdentifier = "customAnnotation\(count)"
                // This dot image grows in size as more annotations are added to the array.
                point.image = dot(size: 15)
                
                // Append each annotation to the array, which will be added to the map all at once.
                pointAnnotations.append(point)
            }
            
            // Add the point annotations to the map. This time the method name is plural.
            // If you have multiple annotations to add, batching their addition to the map is more efficient.
            mapView.addAnnotations(pointAnnotations)
            
            //Fix the map to see exact position
            //mapView.setCenter(coordinates[3], zoomLevel: 10, direction: 0, animated: false)
        }
        
        
       
        
        
    }
    func drawRoute(route: Route){
        guard route.coordinateCount > 0 else {return}
        var routeCoordinates = route.coordinates!
        
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        let source = MGLShapeSource(identifier: "route-line", features: [polyline], options: nil)
        
        let layer = MGLLineStyleLayer(identifier: "line-layer", source: source)
        layer.lineDashPattern = NSExpression(forConstantValue: [2, 1.5])
        
        
        
        
        layer.lineColor = NSExpression(mglJSONObject: #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1))
        layer.lineWidth = NSExpression(mglJSONObject: 3.0)
        
        mapView.style?.addSource(source)
        mapView.style?.addLayer(layer)
        
        
        
    }
    
    
    
    func dot(size: Int) -> UIImage {
        let floatSize = CGFloat(size)
        let rect = CGRect(x: 0, y: 0, width: floatSize, height: floatSize)
        let strokeWidth: CGFloat = 1
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let ovalPath = UIBezierPath(ovalIn: rect.insetBy(dx: strokeWidth, dy: strokeWidth))
        #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1).setFill()
        ovalPath.fill()
        
        UIColor.white.setStroke()
        ovalPath.lineWidth = strokeWidth
        ovalPath.stroke()
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func convertCoordinates(coordinatesArray: [String])-> [CLLocationCoordinate2D]{
        var coordinates: [CLLocationCoordinate2D] = []
        for var coor in coordinatesArray{
            
            var coorTemp = coor.components(separatedBy: ",")
            print("Coordinates: \(coorTemp[0]), \(coorTemp[1])")
            
            
            coordinates.append(
                CLLocationCoordinate2D(latitude: Double(coorTemp[0])!, longitude: Double(coorTemp[1])!)
            )
            
        }
        
        
        return coordinates
    }
    
}


// MARK: - MGLMapViewDelegate methods
extension HikeMapVC {
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let point = annotation as? CustomPointAnnotation,
            let image = point.image,
            let reuseIdentifier = point.reuseIdentifier {
            
            if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: reuseIdentifier) {
                // The annotatation image has already been cached, just reuse it.
                return annotationImage
            } else {
                // Create a new annotation image.
                return MGLAnnotationImage(image: image, reuseIdentifier: reuseIdentifier)
            }
        }
        
        // Fallback to the default marker image.
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if let annotation = annotation as? CustomPolyline {
            // Return orange if the polyline does not have a custom color.
            return annotation.color ?? .orange
        }
        
        // Fallback to the default tint color.
        return mapView.tintColor
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        let navigationVC = NavigationViewController(for: directionsRoute!)
        present(navigationVC, animated: true, completion: nil)
    }
    
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
            //print("configureDrawerViewController hike id: \(self.hikeModel.id!)")
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

//Secondary Functions
extension HikeMapVC {
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
        
    }
}
