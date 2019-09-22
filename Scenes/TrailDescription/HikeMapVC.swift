//
//  TrailsDescriptionVC.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-20.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Mapbox
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import SystemConfiguration
import Firebase
import FirebaseFirestore

class HikeMapVC: UIViewController, MGLMapViewDelegate, DrawerViewControllerDelegate {
    
    /// Container View Top Constraint
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    
    /// Previous Container View Top Constraint
    private var previousContainerViewTopConstraint: CGFloat = 0.0
    
    /// Background Overlay Alpha
    private static let kBackgroundColorOverlayTargetAlpha: CGFloat = 0.4
    var trailSelected = Hike()
    var coordinates = Coordinates()
    /// Array of offline packs for the delegate work around (and your UI, potentially)
    var offlinePacks = [MGLOfflinePack]()
    //var trailsReference : DatabaseReference! firestore migration
    var mapView: NavigationMapView!
    var navigateButton: UIButton!
    var recenterButton: UIButton!
    var backButton: UIButton!
    var saveButton: UIButton!
    var directionsRoute: Route?
    var hikeRoute: Route?
    var coordinatesOfTrail = [CLLocationCoordinate2D]()
    
    var startOfHikeLocation: CLLocationCoordinate2D!
    var endOfHikeLocation: CLLocationCoordinate2D!
   
    var db : Firestore! //firestore migration
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var progressView: UIProgressView!
    var savedTrail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setMapViewServices()
        self.addBackButton()
        // for public trail
        if self.trailSelected.publicTrail {
            getCoordinatesFromFirestore(){
                self.addFeaturesToMap()
                self.checkStatusOfSavedBtn()
            }
        }else{
          
            self.coordinates.coordinatesForTrail = self.trailSelected.coor.coordinatesForTrail
            self.coordinates.startLocation = self.getCoordinatesFromString(coordinatesString: self.trailSelected.coor.coordinatesForTrail[0])
            self.coordinates.endLocation = self.getCoordinatesFromString(coordinatesString: self.trailSelected.coor.coordinatesForTrail.last!)
            //missing assignments
            self.addFeaturesToMap()
             self.checkStatusOfSavedBtn()
            //make check status for saved btn for private case to delete private trail
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        
    }
    
    func addFeaturesToMap(){
        // Do any additional setup of features after loading the view.
        
        do {
            try self.setupNavigationCapabilityFromUserLocation()
        }catch{
            print("Error in function setupNavigationCapabilityFromUserLocation() \(error)")
        }
        
        self.addNavigationButton()
        
        do {
            try self.drawHike()
        }catch {
            print("Error in function drawHike() \(error)")
        }
        
        self.addSaveButton()
        self.addRecenterButton()
    }
    
    func initTrailDescriptionData(hike: Hike){
        self.trailSelected = hike
       
        self.configureDrawerViewController()
    }
    
    func getCoordinatesFromFirestore(action: @escaping () -> Void) {
        let docRef = self.db.collection("coordinates").document(self.trailSelected.id!).getDocument() { (document, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
              
                self.coordinates.coordinatesForTrail = document?.data()?["coordinatesForTrail"] as? [String] ?? [""]
                self.coordinates.coordinateComments = document?.data()?["coordinateComments"] as? [[String:String?]] ?? [["":""]]
                self.coordinates.coordinatePlaces = document?.data()?["coordinatePlaces"] as? [[String:String?]] ?? [["":""]]
                self.coordinates.endLocation = self.getCoordinatesFromString(coordinatesString: document?.data()?["endLocation"] as! String)
                self.coordinates.startLocation = self.getCoordinatesFromString(coordinatesString: document?.data()?["startLocation"] as! String)
              
                //validate for all cases if null
                action()
                
            }
        }
  
    }
    
}



//Map created features
extension HikeMapVC {
    func addSaveButton() {
        ///https://stackoverflow.com/questions/41477775/why-does-my-uitableview-only-show-the-list-of-available-mglofflinepacks-after-i
        saveButton = UIButton(frame: CGRect(x: (view.frame.width/2) - 50, y: view.frame.height * 0.68, width: 100, height: 50))
        
        saveButton.layer.cornerRadius = 25
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        saveButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        saveButton.layer.shadowRadius = 5
        saveButton.layer.shadowOpacity = 0.3
        saveButton.tintColor = #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        saveButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        
        
        saveButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
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
        backButton.tintColor = #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1)
        backButton.setTitle("  Back", for: .normal)
        backButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        backButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        backButton.addTarget(self, action: #selector( backButtonWasPressed(_:)), for: .touchUpInside)

        view.insertSubview(backButton, aboveSubview: mapView)
        
        
    }
    
    @objc func backButtonWasPressed(_ sender: UIButton){
        
        //for public trail
        if trailSelected.publicTrail {
            validateFirestoreSavedTrailStatus()
        }else {
            
        }
        
        dismissDetail()
 
    }
    
    func validateCoreDataStatus() {
        if User.sharedInstance.savedTrailsStatus[trailSelected.id!]! && User.sharedInstance.savedTrailsStatus[trailSelected.id!] != savedTrail {
            print("Checking coredata save status")
            if !savedTrail {
                print("Enter to delete coredata trail as now not saved")
                deleteTrailFromCoreData(trailSelected.id!)
            }
            // if saved dont do anything
        }
    }
    
    func deleteTrailFromCoreData(_ trailId :String) {
            guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
            let fetchRequest = NSFetchRequest<Trail>(entityName: "Trail")
            fetchRequest.includesPropertyValues = false
            
            do{
                let items = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [NSManagedObject]
                
                for item in items {
                    managedContext.delete(item)
                }
                
            } catch {
                debugPrint("Could not delete entry: \(error.localizedDescription)")
            }
        
            User.sharedInstance.savedTrails.removeAll(where: { trailId == $0.id })
    }
    
    func validateFirestoreSavedTrailStatus(){
     
        if User.sharedInstance.savedTrailsStatus[trailSelected.id!] != savedTrail {
            let docRef = self.db.collection("users").document(User.sharedInstance.userId)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate

            // saved - add
            if savedTrail {
                //public trail
                User.sharedInstance.savedTrailsStatus[trailSelected.id!] = true
                User.sharedInstance.savedTrails.append(trailSelected)
                docRef.collection("savedTrails").document(trailSelected.id!).setData([
                    "trailName": trailSelected.name,
                    "difficulty": trailSelected.difficulty,
                    "distance": trailSelected.distance,
                    "dog-friendly": trailSelected.dogFriendly,
                    "elevation": trailSelected.elevation,
                    "isLoop": trailSelected.isloop,
                    "kids-friendly": trailSelected.kidsFriendly,
                    "locality": trailSelected.region,
                    "season": trailSelected.season,
                    "startLocation": "\(trailSelected.startLocation!.latitude),\(trailSelected.startLocation!.longitude)",
                    "state": trailSelected.state,
                    "time": trailSelected.time,
                    "type": trailSelected.type,
                    "imgUrl": trailSelected.imgURL
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written in firestore!")
                    }
                }
               
            } else { //unsave - delete
                User.sharedInstance.savedTrailsStatus[trailSelected.id!] = false
                User.sharedInstance.savedTrails.removeAll(where: { trailSelected.id == $0.id })
                docRef.collection("savedTrails").document(trailSelected.id!).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed! \(self.trailSelected.name!)")
                    }
                }
            }
        }
        print("count of saved trails HikeMapVC \(User.sharedInstance.savedTrails.count)")
    }
    
    func setBtnAsSaved(){
        self.saveButton.setTitle("Saved", for: .normal)
        self.saveButton.backgroundColor = #colorLiteral(red: 0.9604964852, green: 0.7453318238, blue: 0, alpha: 1)
        self.saveButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        self.saveButton.reloadInputViews()
    }
    
    func setBtnAsSave(){
        self.saveButton.setTitle("Save", for: .normal)
        self.saveButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.saveButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        self.saveButton.reloadInputViews()
    }
    
    func checkStatusOfSavedBtn() {
       // print("trail status of saved btn: \(User.sharedInstance.savedTrailsStatus[trail.id!]!)")
        if User.sharedInstance.savedTrailsStatus[trailSelected.id!] == true { // Trail is already saved
            setBtnAsSaved()
            savedTrail = true
        }else {
            savedTrail = false
        }
    }
    @objc func saveButtonWasPressed(_ sender: UIButton){
        let docRef = self.db.collection("users").document(User.sharedInstance.userId).collection("savedTrails")
        if savedTrail {
            // Unsave trail

            setBtnAsSave()
            savedTrail = false
            print("Unsaved Trail")
            
        }else {
            //Save Trail
            
            setBtnAsSaved()
            
            savedTrail = true
            print("Saved Trail")
            
        }
        
    }
    
    func addNavigationButton() {
        navigateButton = UIButton(frame: CGRect(x: (view.frame.width * 0.1), y: view.frame.height * 0.68, width: 50, height: 50))
        navigateButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let navbtnImg = UIImage(named: "navigation")?.withRenderingMode(.alwaysTemplate)
        navigateButton.setImage(navbtnImg, for: .normal)
        
        navigateButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        navigateButton.layer.cornerRadius = 25
        navigateButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigateButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigateButton.layer.shadowRadius = 5
        navigateButton.layer.shadowOpacity = 0.3
        navigateButton.addTarget(self, action: #selector(navigateButtonWasPressed(_:)), for: .touchUpInside)
        
        view.insertSubview(navigateButton, aboveSubview: mapView)
        
    }
    
    func addRecenterButton() {
        recenterButton = UIButton(frame: CGRect(x: (view.frame.width * 0.90) - 50, y: view.frame.height * 0.68, width: 50, height: 50))
        recenterButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let recenterbtnImg = UIImage(named: "recenter")?.withRenderingMode(.alwaysTemplate)
        recenterButton.setImage(recenterbtnImg, for: .normal)
        
        recenterButton.layer.cornerRadius = 25
        recenterButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        recenterButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        recenterButton.layer.shadowRadius = 5
        recenterButton.layer.shadowOpacity = 0.3
        recenterButton.addTarget(self, action: #selector(recenterButtonWasPressed(_:)), for: .touchUpInside)
        
        view.insertSubview(recenterButton, aboveSubview: mapView)
        
    }
    
    
    @objc func recenterButtonWasPressed(_ sender: UIButton){
         if trailSelected.publicTrail {
            self.mapView?.setVisibleCoordinates(
                self.coordinatesOfTrail,
                count: UInt(self.coordinatesOfTrail.count),
                edgePadding: UIEdgeInsets(top: 150, left: 150, bottom: 150, right: 150),
                animated: true
            )
         }else {
            self.mapView.setCenter(self.coordinates.startLocation!, zoomLevel: 12, animated: false)
        }
        
    }
    
    @objc func navigateButtonWasPressed(_ sender: UIButton){
        let navigationVC = NavigationViewController(for: directionsRoute!)
        present(navigationVC, animated: true, completion: nil)
    }
    
}

//Mapbox features
extension HikeMapVC {
    
    func formatGeoString(_ trailCoordinates: [CLLocationCoordinate2D]) -> String {
        let geoStringStart =  """
            {
            "type": "FeatureCollection",
            "properties": {
                    "name": "Private Trail"
            },
            "features": [
            {
            "type": "Feature",
            "properties": {
            "stroke": "#2F507F",
            "stroke-width": 2,
            "stroke-opacity": 1
            },
            "geometry": {
            "type": "LineString",
            "coordinates": [
        """
        
        var coordinatesBody = ""
       for coordinate in trailCoordinates {
            //  print(coordinate.latitude)
            coordinatesBody.append(contentsOf: "["+String(setPrecision(x: coordinate.longitude))+","+String(setPrecision(x: coordinate.latitude))+"],")
        
        }
        let geoStringBody = String(coordinatesBody.dropLast())
        
        // Longitude, Latitude
        let geoStringEnd =   """
            ]
            }
            }
            ]
        }
        """
        return geoStringStart + geoStringBody + geoStringEnd
    }
    func setPrecision(x: CLLocationDegrees) -> Double {
        return Double(round(10000000*x)/10000000)
    }
    func drawHike() throws{
        if self.coordinates.coordinatesForTrail.count > 0 {
            let trailCoordinates = convertCoordinates(coordinatesArray: self.coordinates.coordinatesForTrail)
            //Set where map will focus on
            print("trailCoordinates \(trailCoordinates)")
            
            if trailSelected.publicTrail {
                do{
                    try setTrailRoute(coordinatesArray: trailCoordinates){
                        (route: Route?) in
        
                       
                            print("Entered not private assignment of route")
                           guard route!.coordinateCount > 0 else {return true}
                           var routeCoordinates = route!.coordinates! as [CLLocationCoordinate2D]
                        
                            // first fix recenter of map
                            let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
                        
                            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
                        
                            let layer = MGLLineStyleLayer(identifier: "route-style", source: source)
                            layer.lineDashPattern = NSExpression(forConstantValue: [2, 1.5])
                        
                            layer.lineColor = NSExpression(mglJSONObject: #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1))
                            layer.lineWidth = NSExpression(mglJSONObject: 3.0)
                        
                            self.mapView.style?.addSource(source)
                            self.mapView.style?.addLayer(layer)
                        
                        
                       print("Type of routeCoordinates PUBLIC: \(type(of: routeCoordinates))")
                        print("Count of routeCoordinates PUBLIC: \(routeCoordinates.count)")
                        //Array<CLLocationCoordinate2D>
                        //152

                        return false
                        
                  }
                }catch{
                    print("Error in Function setTrailRoute for public\(error)")
                }
                self.mapView.setVisibleCoordinates(
                    trailCoordinates,
                    count: UInt(self.coordinates.coordinatesForTrail.count),
                    edgePadding: UIEdgeInsets(top: 140, left: 140, bottom: 140, right: 140),
                    animated: true
                )
            }else {
              //PRIVATE
                do {
                    // Convert the file contents to a shape collection feature object
                    let geoCoor = formatGeoString(trailCoordinates)
                    let data = Data(geoCoor.utf8)
                    DispatchQueue.main.async {
                        self.drawPolyline(geoJson: data)
                    }
                    
                } catch {
                    print("GeoJSON parsing failed")
                }
               
                self.mapView.setCenter(self.coordinates.startLocation!, zoomLevel: 12, animated: false)
                print("Type of routeCoordinates PRIVATE: \(type(of: trailCoordinates))")
                print("Count of routeCoordinates PRIVATE: \(trailCoordinates.count)")
                
            }
            
            
            
        }else{
            throw TrailDescriptionError.noCoordinatesForTrailFound
        }
        
        DispatchQueue.main.async {
            do{
                try self.drawFixedPins()
            }catch{
                print("Error in function drawFixedPins() \(error)")
            }
        }
        
    }
    func drawPolyline(geoJson: Data) {
        // Add our GeoJSON data to the map as an MGLGeoJSONSource.
        // We can then reference this data from an MGLStyleLayer.
        
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = self.mapView.style else { return }
        
        guard let shapeFromGeoJSON = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) else {
            fatalError("Could not generate MGLShape")
        }
        
        let source = MGLShapeSource(identifier: "polyline", shape: shapeFromGeoJSON, options: nil)
        style.addSource(source)
        
        // Create new layer for the line.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        
        // Set the line join and cap to a rounded end.
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        
        // Set the line color to a constant blue color.
        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1))
        
        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18. The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 2, 18: 20])
        
        // We can also add a second layer that will draw a stroke around the original line.
        let casingLayer = MGLLineStyleLayer(identifier: "polyline-case", source: source)
        // Copy these attributes from the main line layer.
        casingLayer.lineJoin = layer.lineJoin
        casingLayer.lineCap = layer.lineCap
        // Line gap width represents the space before the outline begins, so should match the main line’s line width exactly.
        casingLayer.lineGapWidth = layer.lineWidth
        // Stroke color slightly darker than the line color.
        casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red: 41/255, green: 145/255, blue: 171/255, alpha: 1))
        // Use `NSExpression` to gradually increase the stroke width between zoom levels 14 and 18.
        casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])
        
        // Just for fun, let’s add another copy of the line with a dash pattern.
        let dashedLayer = MGLLineStyleLayer(identifier: "polyline-dash", source: source)
        dashedLayer.lineJoin = layer.lineJoin
        dashedLayer.lineCap = layer.lineCap
        dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.white)
        dashedLayer.lineOpacity = NSExpression(forConstantValue: 0.5)
        dashedLayer.lineWidth = layer.lineWidth
        // Dash pattern in the format [dash, gap, dash, gap, ...]. You’ll want to adjust these values based on the line cap style.
        dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
        
        style.addLayer(layer)
        style.addLayer(dashedLayer)
        style.insertLayer(casingLayer, below: layer)
    }
    
    func drawFixedPins() throws{
        
        guard let startLocation = coordinates.startLocation else {
            throw TrailDescriptionError.noStartLocationOfTrail
        }
        
        print("startLocation: \(startLocation.latitude) \(startLocation.longitude)")

        let start = CustomPointAnnotation(coordinate: startLocation,
                                          title: "Start",
                                          subtitle: nil)
        
        start.reuseIdentifier = "customAnnotation\(-1)"
        start.image = shapePin(size: 15, pos: 0)
        
        guard let endLocation = coordinates.endLocation else {
            throw TrailDescriptionError.noEndLocationOfTrail
        }
       
        let end = CustomPointAnnotation(coordinate: endLocation,
                                          title: "End",
                                          subtitle: nil)
        print("end location: \(endLocation.latitude) \(endLocation.longitude)")
        end.reuseIdentifier = "customAnnotation\(-2)"
        end.image = shapePin(size: 15, pos: -1)
        
        var pointAnnotations = [CustomPointAnnotation]()
        pointAnnotations.append(start)
        pointAnnotations.append(end)
        
        self.mapView.addAnnotations(pointAnnotations)
        
    }
    
    func setupNavigationCapabilityFromUserLocation() throws{
        // erase this line if nothing changes here: mapView.setUserTrackingMode(.none, animated: true)
        guard let startLocation = coordinates.startLocation else {
            throw TrailDescriptionError.noStartLocationOfTrail
        }
        print("Start location of Trail: \(startLocation)")
        print("User location: \(User.sharedInstance.userLocation)")
        calculateRoute(from: User.sharedInstance.userLocation, to: startLocation) { (route, error) in
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

    func  setTrailRoute(coordinatesArray: [CLLocationCoordinate2D], drawRoute: @escaping (Route?) -> Bool)throws -> Void{
         print("starting route")
              //Set navigation
        print("coordinates count array: \(coordinatesArray.count)")
        var noRouteFound: Bool = false
        if trailSelected.publicTrail {
            let options = NavigationRouteOptions(coordinates: coordinatesArray, profileIdentifier: MBDirectionsProfileIdentifier.walking)
           
                _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in
                    self.hikeRoute = routes?.first
                    self.coordinatesOfTrail = coordinatesArray
                    print("creating route")
                    //Draw route
                    if self.hikeRoute != nil{
                        noRouteFound = drawRoute(self.hikeRoute)
                    }else{
                        print("Route not found")
                    }
                })
            
        }
        
        if noRouteFound {
            throw TrailDescriptionError.noRouteFound
        }
 
    }

    func shapePin(size: Int, pos: Int) -> UIImage {
        let floatSize = CGFloat(size)
        let rect = CGRect(x: 0, y: 0, width: floatSize, height: floatSize)
        let strokeWidth: CGFloat = 1
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let ovalPath = UIBezierPath(ovalIn: rect.insetBy(dx: strokeWidth, dy: strokeWidth))
        if pos == 0 {
            #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).setFill()
        }else if pos == -1 {
            #colorLiteral(red: 0.9253688455, green: 0, blue: 0.05485691875, alpha: 1).setFill()
        }else {
            #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1).setFill()
        }
        
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
        for coor in coordinatesArray{
            
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
        //Show description + Pics view
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
            print("self.trailSelected in Map ctlr \(self.trailSelected.startLocation)")
            drawerViewController.initDrawerData(hike: self.trailSelected, userLocation: User.sharedInstance.userLocation)
            drawerViewController.tableView.isScrollEnabled = false
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
                    drawerViewController.tableView.isScrollEnabled = true
                    animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
                } else {
                    // From Full Height to Compressed
                    drawerViewController.expansionState = .compressed
                    drawerViewController.tableView.isScrollEnabled = false
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            } else if previousContainerViewTopConstraint == expandedTopConstraint {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                    // From Expanded to Full Height
                    drawerViewController.expansionState = .fullHeight
                    drawerViewController.tableView.isScrollEnabled = true
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } else {
                    // From Expanded to Compressed
                    drawerViewController.expansionState = .compressed
                    drawerViewController.tableView.isScrollEnabled = false
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            } else {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                    // From Compressed to Full Height
                    drawerViewController.expansionState = .fullHeight
                    drawerViewController.tableView.isScrollEnabled = true
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } else {
                    // From Compressed back to Compressed
                    drawerViewController.expansionState = .compressed
                    drawerViewController.tableView.isScrollEnabled = false
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
    
    func getCoordinatesFromString(coordinatesString: String) -> CLLocationCoordinate2D {
        let coodinatesStringArray = coordinatesString.components(separatedBy: ",")
        
       return CLLocationCoordinate2D(latitude: Double(coodinatesStringArray[0]) ?? 0.0, longitude: Double(coodinatesStringArray[1]) ?? 0.0)
    }
}

