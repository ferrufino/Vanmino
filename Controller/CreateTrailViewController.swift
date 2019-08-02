//
//  CreateTrailViewController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-07-21.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import MapKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class CreateTrailViewController: UIViewController, MGLMapViewDelegate {

    // MARK: - Properties
    var mapView: MGLMapView!
    var backButton : UIButton!
    var undoButton : UIButton!
    var saveButton : UIButton!
    var discardButton : UIButton!
    var drawRouteButton : UIButton!
    var createTrailButton : UIButton!
    var textField : UITextField!
    var distanceLabel : UILabel!
    var elevationGainLabel : UILabel!
    var timeLabel : UILabel!
    var sourceLine: MGLShapeSource!
    var layerLine: MGLLineStyleLayer!
    var imageView: UIImageView!
    let loadingAlert = UIAlertController(title: nil, message: "loading...", preferredStyle: .alert)
    var formView: UIView!
    
    var centerMap: CLLocationCoordinate2D!
    let regionRadius: CLLocationDistance = 1000
    var tileRenderer: MKTileOverlayRenderer!
    var shimmerRenderer: ShimmerRenderer!
    var pointAnnotations = [CustomPointAnnotation]()
    var routeLine: Route!
    var elevationGain: String!
    var distanceNewTrail: String!
    var timeNewTrail: String!
    var formViewFront: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initProperties()
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(centerMap, zoomLevel: 9, animated: false)
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        mapView.styleURL = MGLStyle.outdoorsStyleURL
        
        // Set the map view's delegate
        mapView.delegate = self
        //Add Buttons to UI
        addBackButton()
        addUndoButton()
        addDiscardButton()
        addGetCoordinatesUserTapped()
        addDrawRouteButton()
        addSaveButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Format Buttons visibility
        undoButton.isHidden = true
        discardButton.isHidden = true
        saveButton.isHidden = true
        drawRouteButton.isHidden = true
       
    }
    
   
    
    func initProperties() {
        //TODO add defualt values to all properties
        formView = UIView(frame: CGRect(x: 0, y: view.frame.height * 0.5, width: view.frame.width , height: view.frame.height * 0.5))
        
        distanceLabel = UILabel(frame: CGRect(x: formView.frame.width * 0.05, y: formView.frame.height * 0.3, width: 300, height: 21))
        
        timeLabel = UILabel(frame: CGRect(x: formView.frame.width * 0.05, y: formView.frame.height * 0.4, width: 300, height: 21))
        
        elevationGainLabel = UILabel(frame: CGRect(x: formView.frame.width * 0.05, y: formView.frame.height * 0.5, width: 300, height: 21))
        
        createTrailButton = UIButton(frame: CGRect(x: view.frame.width * 0.70, y: view.frame.height * 0.85, width: 100, height: 50))
        
        
        formView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        //text field
        textField =  UITextField(frame: CGRect(x: formView.frame.width * 0.05, y: formView.frame.height * 0.10, width: 300, height: 50))
        textField.placeholder = "Enter Name of the hike here"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.delegate = self
        
        textField.layer.cornerRadius = 15
     
        
        
        //button
        
        createTrailButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        createTrailButton.layer.cornerRadius = 15
        createTrailButton.tintColor = #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1)
        createTrailButton.setTitle("Create trail", for: .normal)
        createTrailButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        createTrailButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        
        createTrailButton.addTarget(self, action: #selector(confirmSave), for: .touchUpInside)
       
       
    }
    
    func refreshView() {
        view.insertSubview(backButton, aboveSubview: mapView)
        view.insertSubview(undoButton, aboveSubview: mapView)
        view.insertSubview(discardButton, aboveSubview: mapView)
        view.insertSubview(saveButton, aboveSubview: mapView)
        view.insertSubview(drawRouteButton, aboveSubview: mapView)
        distanceLabel.text = ""
        timeLabel.text = ""
        elevationGainLabel.text = ""
        
        discardButton.layer.cornerRadius = 25
        discardButton.layer.shadowOpacity = 0.3
       
    }
    
    func initCreateTrail(with userCoordinate: CLLocationCoordinate2D){
        
      centerMap = userCoordinate
        
    }
   

     // MARK: - Functions
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
        dismissDetail()
    }
    
    func addUndoButton() {
       
        undoButton = UIButton(frame: CGRect(x: view.frame.width * 0.75, y: view.frame.height * 0.3, width: 100, height: 50))
        undoButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        undoButton.layer.cornerRadius = 25
        undoButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        undoButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        undoButton.layer.shadowRadius = 5
        undoButton.layer.shadowOpacity = 0.3
        
        undoButton.tintColor = #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1)
        undoButton.setTitle("Undo", for: .normal)
        undoButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        undoButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        undoButton.addTarget(self, action: #selector(removeAnnotation(_:)), for: .touchUpInside)
        
        view.insertSubview(undoButton, aboveSubview: mapView)
        
        
    }
    
    @objc func removeAnnotation(_ sender: UIButton){

        mapView.removeAnnotation(pointAnnotations.last!)
        pointAnnotations.removeLast()
        
        //format buttons
        if pointAnnotations.count == 0 {
            undoButton.isHidden = true
            discardButton.isHidden = true
            saveButton.isHidden = true
            drawRouteButton.isHidden = true
        } else if pointAnnotations.count == 1 {
            drawRouteButton.isHidden = true
        }
        
    }
  
    func addDiscardButton() {
        
        discardButton = UIButton(frame: CGRect(x: view.frame.width * 0.75, y: view.frame.height * 0.40, width: 100, height: 50))

        discardButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        discardButton.layer.cornerRadius = 25
        discardButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        discardButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        discardButton.layer.shadowRadius = 5
        discardButton.layer.shadowOpacity = 0.3
        
        discardButton.tintColor = #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1)
        discardButton.setTitle("Discard", for: .normal)
        discardButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        discardButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        discardButton.addTarget(self, action: #selector(removeAllAnnotation(_:)), for: .touchUpInside)
        
        view.insertSubview(discardButton, aboveSubview: mapView)
        
        
    }
    @objc func removeAllAnnotation(_ sender: UIButton){
        mapView.removeAnnotations(pointAnnotations)
        pointAnnotations.removeAll()
        
        if layerLine != nil {
            mapView.style?.removeLayer(layerLine)
        }
        
        if sourceLine != nil {
            mapView.style?.removeSource(sourceLine)
        }
        
        //format buttons
        undoButton.isHidden = true
        discardButton.isHidden = true
        saveButton.isHidden = true
        drawRouteButton.isHidden = true
        if formViewFront {
            UIView.transition(with: mapView, duration: 1, options: .transitionCurlDown, animations: {
                self.view.bringSubviewToFront(self.mapView)
                self.view.insertSubview(self.backButton, aboveSubview: self.mapView)
                self.refreshView()
            })
            formViewFront = false
            
        }
        discardButton.frame.origin = CGPoint(x: view.frame.width * 0.75, y: view.frame.height * 0.40)
        discardButton.layer.cornerRadius = 25
        discardButton.layer.shadowOpacity = 0.3
        
    }
  
    
    func addDrawRouteButton() {
        
        drawRouteButton = UIButton(frame: CGRect(x: view.frame.width * 0.75, y: view.frame.height * 0.50, width: 100, height: 50))
        drawRouteButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        drawRouteButton.layer.cornerRadius = 25
        drawRouteButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        drawRouteButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        drawRouteButton.layer.shadowRadius = 5
        drawRouteButton.layer.shadowOpacity = 0.3
        
        drawRouteButton.tintColor = #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1)
        drawRouteButton.setTitle("Draw route", for: .normal)
        drawRouteButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        drawRouteButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        drawRouteButton.addTarget(self, action: #selector(drawRoute(_:)), for: .touchUpInside)
        view.insertSubview(drawRouteButton, aboveSubview: mapView)
 
    }

    @objc func drawRoute(_ sender: UIButton){
       startLoadingAlert()
 
        
        //Set navigation
        let coor = pointAnnotations.map{ $0.coordinate }

        let options = NavigationRouteOptions(coordinates: coor, profileIdentifier: MBDirectionsProfileIdentifier.walking)
        //var noRouteFound: Bool = false
        _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in
            
            if error == nil && routes != nil{
                let route = routes?.first!
                guard route!.coordinateCount > 0 else {return}
                let routeCoordinates = route!.coordinates!
                print("Amount of coordinates: \(route!.coordinateCount)")
                let polyline = MGLPolylineFeature(coordinates: routeCoordinates, count: route!.coordinateCount)
                
                let source = MGLShapeSource(identifier: "route-line", features: [polyline], options: nil)
                
                let layer = MGLLineStyleLayer(identifier: "line-layer", source: source)
                layer.lineDashPattern = NSExpression(forConstantValue: [2, 1.5])
                
                layer.lineColor = NSExpression(mglJSONObject: #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1))
                layer.lineWidth = NSExpression(mglJSONObject: 3.0)
                self.sourceLine = source
                self.layerLine = layer
                self.mapView.style?.addSource(source)
                self.mapView.style?.addLayer(layer)
               
                self.routeLine = route
                self.stopLoadingAlert()
            }else if error != nil {
                 print("error")
            }

        })
      
        //format buttons
        discardButton.isHidden = false
        saveButton.isHidden = false
        
    }
    
    func addSaveButton() {
        
        saveButton = UIButton(frame: CGRect(x: view.frame.width * 0.75, y: view.frame.height * 0.05, width: 100, height: 50))
        saveButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        saveButton.layer.cornerRadius = 25
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        saveButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        saveButton.layer.shadowRadius = 5
        saveButton.layer.shadowOpacity = 0.3
        
        saveButton.tintColor = #colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1)
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        saveButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        saveButton.addTarget(self, action: #selector(saveTrail(_:)), for: .touchUpInside)
        
        view.insertSubview(saveButton, aboveSubview: mapView)
        
        
    }
    
    @objc func saveTrail(_ sender: UIButton){
        startLoadingAlert()
        //Set navigation
        let coor = pointAnnotations.map{ $0.coordinate }
        
        //Distance and Time
        let distanceFormatter = LengthFormatter()
        let formattedDistance = distanceFormatter.string(fromMeters: routeLine!.distance)
        
        let travelTimeFormatter = DateComponentsFormatter()
        travelTimeFormatter.unitsStyle = .short
        let formattedTravelTime = travelTimeFormatter.string(from: routeLine!.expectedTravelTime)
        
        print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
        distanceNewTrail = formattedDistance
        var time:String = formattedTravelTime!
        if let range = time.range(of: "min") {
            
            timeNewTrail = String(time[...range.upperBound]).replacingOccurrences(of: "[\\.,]", with: "", options: .regularExpression, range: nil)
        }
        
        //Elevation
        var setCoordinatesURLFormat = ""
        let pipeline = "\u{007C}"
        for coordinate in coor {
            setCoordinatesURLFormat.append(contentsOf: String(coordinate.latitude)+","+String(coordinate.longitude)+"\(pipeline)")
            
        }
        
        var coordinatesURL = String(setCoordinatesURLFormat.dropLast())
        
        print(coordinatesURL)
        
        getElevation(with: coordinatesURL){
            DispatchQueue.main.async { // Dispatch call in the maint thread to avoid error
                self.stopLoadingAlert()
                _ = self.createForm()
            }
           
        }
        
        //format buttons
        undoButton.isHidden = true
        discardButton.isHidden = false
        saveButton.isHidden = true
        drawRouteButton.isHidden = true
        
        
        
    }
    
    func getElevation(with coordinates: String?, action: @escaping () -> Void){
       var minElevation = Float(INT_MAX)
       var maxElevation = Float(INT8_MIN)
       
        if let cor = coordinates {
            var url = "https://maps.googleapis.com/maps/api/elevation/json?locations=" + cor + "&key=AIzaSyCLy4dVl0_yAQGizcIcQkA5p1-1h6uIwu8"
            url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            print("Coordinates added to URL \(url)")
            dataRequest(with: url, objectType: elevationResponse.self) { (result: Result) in //TODO change keys
                switch result {
                case .success(let object):
                    if object.coordinates.count > 0 {
                        for obj in object.coordinates {
                            if obj.elevation < minElevation {
                                minElevation = obj.elevation
                            }
                            if obj.elevation > maxElevation {
                                maxElevation = obj.elevation
                            }
                        }
                        print("maxElevation \(maxElevation)")
                        print("minElevation \(minElevation)")
                        self.elevationGain = String(format: "%.2f", abs(maxElevation - minElevation)) + " m"
                        print("Elevation Gain: \(self.elevationGain!)")
                        action()
                    }
                case .failure(let error):
                    print(error)
                     self.stopLoadingAlert()
                }
            }
            
        }else{
            print("There was a problem with data request.")
        }
    }
    
    func createForm(){

        distanceLabel.textAlignment = .left
        distanceLabel.text = "Distance: \(distanceNewTrail ?? "Distance Error")"
        
     
        
        timeLabel.textAlignment = .left
        timeLabel.text = "Time: \(timeNewTrail ?? "Time Error")"
        
        
        elevationGainLabel.textAlignment = .left
        elevationGainLabel.text = "Elevation Gain: \(elevationGain ?? "Elevation error")"
        
        
        formView.addSubview(textField)
        formView.addSubview(distanceLabel)
        formView.addSubview(timeLabel)
        formView.addSubview(elevationGainLabel)
     
        self.view.insertSubview(formView, aboveSubview: self.mapView)
        self.view.insertSubview(createTrailButton, aboveSubview: self.formView)

        self.formViewFront = true
      
        discardButton.frame.origin = CGPoint(x: view.frame.width * 0.025, y: view.frame.height * 0.85)
        discardButton.layer.shadowOpacity = 0.0
    }
    
    @objc func confirmSave(_ sender: UIButton){
        createStaticImage()
        
        //Save this to firebase storage
            //show progress
        //Save url to firebase storage and static information and send it as an update to firestore
    }
    func createStaticImage(){
        // Create a UIImageView that will store the map snapshot.
        imageView = UIImageView(frame: CGRect(x: 0, y: view.bounds.height / 2, width: view.bounds.width, height: view.bounds.height / 2))
        imageView.backgroundColor = .black
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Use the map's style, camera, size, and zoom level to set the snapshot's options.
        let options = MGLMapSnapshotOptions(styleURL: mapView.styleURL, camera: mapView.camera, size: mapView.bounds.size)
        options.zoomLevel = mapView.zoomLevel
        startLoadingAlert()
        // Create the map snapshot.
        var snapshotter: MGLMapSnapshotter? = MGLMapSnapshotter(options: options)
        snapshotter?.start { (snapshot, error) in
            if error != nil {
                print("Unable to create a map snapshot.")
            } else if let snapshot = snapshot {
                // Add the map snapshot's image to the image view.
                self.stopLoadingAlert()
                self.imageView.image = snapshot.image
                print("Static image created!")
                self.view.insertSubview(self.imageView, aboveSubview: self.mapView)
                
            }
            
            snapshotter = nil
        }
        
    }
    
}


// MARK: - Extensions

// Get user coordinates where it long pressed on the map
extension CreateTrailViewController: UIGestureRecognizerDelegate{
    
    func addGetCoordinatesUserTapped() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.mapView.addGestureRecognizer(lpgr)
    }
    
    @IBAction func revealRegionDetailsWithLongPressOnMap(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.began { return }
        let touchLocation = gestureReconizer.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        
       
        
        let point = CustomPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude),
                                        title: "End",
                                        subtitle: nil)
       
        point.reuseIdentifier = "customAnnotation\(-2)"
        
        pointAnnotations.append(point)
        
        mapView.addAnnotations(pointAnnotations)
        
        //format button
        undoButton.isHidden = false
        discardButton.isHidden = false
        
        if pointAnnotations.count > 1 {
            drawRouteButton.isHidden = false
        }
    
    }
  
}


//Draw Route Extensions
extension CreateTrailViewController {
    //APPError enum which shows all possible errors
    enum APPError: Error {
        case networkError(Error)
        case dataNotFound
        case jsonParsingError(Error)
        case invalidStatusCode(Int)
    }
    
    //Result enum to show success or failure
    enum Result<T> {
        case success(T)
        case failure(APPError)
    }
    
    //dataRequest which sends request to given URL and convert to Decodable Object
    func dataRequest<T: Decodable>(with url: String, objectType: T.Type, completion: @escaping (Result<T>) -> Void) {
        
        //create the url with NSURL
        let dataURL = URL(string: url) //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        let request = URLRequest(url: dataURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                completion(Result.failure(APPError.networkError(error!)))
                return
            }
            
            guard let data = data else {
                completion(Result.failure(APPError.dataNotFound))
                return
            }
            
            do {
                //create decodable object from data
                let decodedObject = try JSONDecoder().decode(objectType.self, from: data)
                completion(Result.success(decodedObject))
                
            } catch let error {
                completion(Result.failure(APPError.jsonParsingError(error as! DecodingError)))
            }
        })
        
        task.resume()
    }
    
    
    struct elevationDetails: Decodable {
        
        let elevation: Float
        let location : Dictionary<String, Float>
        let resolution: Float
        
        
    }
    struct elevationResponse: Decodable {
        
        let coordinates: [elevationDetails]
        let status: String
        enum CodingKeys : String, CodingKey {
            case coordinates = "results"
            case status
        }
        
    }
}

// MARK: - Loading options
extension CreateTrailViewController {

    
    func startLoadingAlert(){
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        loadingAlert.view.addSubview(loadingIndicator)
        present(loadingAlert, animated: true, completion: nil)
    }
    
    func stopLoadingAlert(){
        loadingAlert.dismiss(animated: true, completion: nil)
    }
    
}


// MARK:- ---> UITextFieldDelegate

extension CreateTrailViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // return NO to disallow editing.
        print("TextField should begin editing method called")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // became first responder
        print("TextField did begin editing method called")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
        print("TextField should end editing method called")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
        print("TextField did end editing method called")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        // if implemented, called in place of textFieldDidEndEditing:
        print("TextField did end editing with reason method called")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        print("While entering the characters this method gets called")
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // called when clear button pressed. return NO to ignore (no notifications)
        print("TextField should clear method called")
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        print("TextField should return method called")
        // may be useful: textField.resignFirstResponder()
        textField.resignFirstResponder()
        return true
    }
    
}





