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
import MapboxStatic
import FirebaseStorage
import CoreData

class CreateTrailViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    var backButton : floatingButton!
    var undoButton : UIButton!
    var saveButton : UIButton!
    var discardButton : UIButton!
    var drawRouteButton : UIButton!
    var createTrailButton : UIButton!
    var toggleButton: UIButton!
    var textField : UITextField!
    var distanceLabel : UILabel!
    var elevationGainLabel : UILabel!
    var timeLabel : UILabel!
    var toggleDescriptionLabel : UILabel!
    var staticImageView: UIImageView!
    let loadingAlert = UIAlertController(title: nil, message: "loading...", preferredStyle: .alert)
    var confirmationView: UIView!
    
    var sourceLine: MGLShapeSource!
    var layerLine: MGLLineStyleLayer!
    var centerMap: CLLocationCoordinate2D!
    var routeCoordinates = [CLLocationCoordinate2D]()
    let regionRadius: CLLocationDistance = 1000
    var tileRenderer: MKTileOverlayRenderer!
    var pointAnnotations = [CustomPointAnnotation]()
    var routeLine: Route!
    var elevationGain: String!
    var distanceNewTrail: String!
    var timeNewTrail: String!
    var coordinatesOfNewTrail = [String]()
    var isConfirmationViewAtTheFront: Bool = false
    var trailTypePublic = true // 1 public, 0 private
    var downloadUrlString: String!
    
    var trailStartLocation = CLLocation()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    
    
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
        addFloatingButton()
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
        loadIntroAlert()
        
    }
    
    
    func loadIntroAlert(){
       let introAlert = UIAlertController(title: "Create a Trail", message: "Press and hold to pin a coordinate. The more pins the better!", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Cool", style: .default) { (action:UIAlertAction) in
            print("You've pressed default");
        }
        introAlert.addAction(action)
        
        present(introAlert, animated: true, completion: nil)
    }
    func initProperties() {
       
        // Confirmation properoties
        confirmationView = UIView(frame: CGRect(x: 0, y: view.frame.height * 0.5, width: view.frame.width , height: view.frame.height * 0.5))
        
        distanceLabel = UILabel(frame: CGRect(x: confirmationView.frame.width * 0.05, y: confirmationView.frame.height * 0.3, width: 300, height: 21))
        
        timeLabel = UILabel(frame: CGRect(x: confirmationView.frame.width * 0.05, y: confirmationView.frame.height * 0.4, width: 300, height: 21))
        
        elevationGainLabel = UILabel(frame: CGRect(x: confirmationView.frame.width * 0.05, y: confirmationView.frame.height * 0.5, width: 300, height: 21))
        
        createTrailButton = UIButton(frame: CGRect(x: view.frame.width * 0.70, y: view.frame.height * 0.85, width: 100, height: 50))
        
        toggleDescriptionLabel = UILabel(frame: CGRect(x: confirmationView.frame.width *  0.05, y: confirmationView.frame.height * 0.6, width: 300, height: 21))
        
        toggleButton = UIButton(frame: CGRect(x: confirmationView.frame.width * 0.55, y: confirmationView.frame.height * 0.60, width: 100, height: 30))
        
        confirmationView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        //text field
        textField =  UITextField(frame: CGRect(x: confirmationView.frame.width * 0.05, y: confirmationView.frame.height * 0.10, width: 300, height: 50))
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
        
        
        
        //create trail button
        
        createTrailButton.setTitle("Create trail", for: .normal)
        createTrailButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        createTrailButton.setTitleColor(#colorLiteral(red: 0.134868294, green: 0.3168562651, blue: 0.5150131583, alpha: 1), for: .normal)
        
        createTrailButton.addTarget(self, action: #selector(createAndSaveTrail), for: .touchUpInside)
        
        //toggle description
        toggleDescriptionLabel.textAlignment = .left
        toggleDescriptionLabel.text = "Personal or Public Trail:"
        // toggle Button
        // TODO property definitions goes somewhere else.
        toggleButton.backgroundColor = #colorLiteral(red: 0.9769582152, green: 0.7567471862, blue: 0, alpha: 1)
        toggleButton.layer.cornerRadius = 15
        toggleButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        toggleButton.setTitle("Public", for: .normal)
        toggleButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        toggleButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        
        toggleButton.addTarget(self, action: #selector(toggleTrailStateButton), for: .touchUpInside)
        
        distanceLabel.textAlignment = .left
        
        
        timeLabel.textAlignment = .left
        
        elevationGainLabel.textAlignment = .left
        
        downloadUrlString = ""
        
    }
    
    func refreshView() {
        view.insertSubview(backButton.btn, aboveSubview: mapView)
        view.insertSubview(undoButton, aboveSubview: mapView)
        view.insertSubview(discardButton, aboveSubview: mapView)
        view.insertSubview(saveButton, aboveSubview: mapView)
        view.insertSubview(drawRouteButton, aboveSubview: mapView)
        
        distanceLabel.text = ""
        timeLabel.text = ""
        elevationGainLabel.text = ""
        textField.text = ""
        discardButton.layer.cornerRadius = 25
        discardButton.layer.shadowOpacity = 0.3
        routeLine = nil
        mapView.isUserInteractionEnabled = true
    }
    
    func initCreateTrail(with userCoordinate: CLLocationCoordinate2D){
        
        centerMap = userCoordinate
        
    }
    
    
    // MARK: - Functions
    func addFloatingButton() {
        backButton = floatingButton(btnLabel: " Back", imgLabel: "back", xPos: view.frame.width * 0.025, yPos: view.frame.height * 0.05)
        backButton.btn.addTarget(self, action: #selector( backButtonWasPressed(_:)), for: .touchUpInside)
        view.insertSubview(backButton.btn, aboveSubview: mapView)
 
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
            routeLine = nil
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
        if isConfirmationViewAtTheFront {
            UIView.transition(with: mapView, duration: 1, options: .transitionCurlDown, animations: {
                self.view.bringSubviewToFront(self.mapView)
                self.view.insertSubview(self.backButton.btn, aboveSubview: self.mapView)
                self.refreshView()
            })
            isConfirmationViewAtTheFront = false
            
        }
        discardButton.frame.origin = CGPoint(x: view.frame.width * 0.75, y: view.frame.height * 0.40)
        discardButton.layer.cornerRadius = 25
        discardButton.layer.shadowOpacity = 0.3
        routeLine = nil
        
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
        if routeLine == nil {
            //Set navigation
            let coordinateArray = pointAnnotations.map{ $0.coordinate }
            
            // Center map
            self.mapView?.setVisibleCoordinates(
                coordinateArray,
                count: UInt(coordinateArray.count),
                edgePadding: UIEdgeInsets(top: 150, left: 150, bottom: 150, right: 150),
                animated: true
            )
            //TODO - remove this? mapView.isUserInteractionEnabled = false
            let options = NavigationRouteOptions(coordinates: coordinateArray, profileIdentifier: MBDirectionsProfileIdentifier.walking)
            //var noRouteFound: Bool = false
            _ = Directions.shared.calculate(options, completionHandler: { (waypoints, routes, error) in
                
                if error == nil && routes != nil{
                    let route = routes?.first!
                    guard route!.coordinateCount > 0 else {return}
                    self.routeCoordinates = route!.coordinates!
                    print("Amount of coordinates: \(route!.coordinateCount)")
                    let polyline = MGLPolylineFeature(coordinates: self.routeCoordinates, count: route!.coordinateCount)
                    
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
            
        }else{
              self.stopLoadingAlert()
        }
        
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
        saveButton.addTarget(self, action: #selector(saveButtonPressed(_:)), for: .touchUpInside)
        
        view.insertSubview(saveButton, aboveSubview: mapView)
        
        
    }
    
    @objc func saveButtonPressed(_ sender: UIButton){
        startLoadingAlert()
        //Set navigation
        let coordinateArray = pointAnnotations.map{ $0.coordinate }
        
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
            
            timeNewTrail = String(time[...range.upperBound]).replacingOccurrences(of: "[\\rsin.,]", with: "", options: .regularExpression, range: nil)
        }
        
        //Elevation
        var setCoordinatesURLFormat = ""
        let pipeline = "\u{007C}"
        for coordinate in coordinateArray {
            setCoordinatesURLFormat.append(contentsOf: String(coordinate.latitude)+","+String(coordinate.longitude)+"\(pipeline)")
            
        }
        
        let coordinatesURL = String(setCoordinatesURLFormat.dropLast())

        getElevation(with: coordinatesURL){
            DispatchQueue.main.async { // Dispatch call in the main thread to avoid error
                self.stopLoadingAlert()
                _ = self.showConfirmationTrailView()
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
    
    func showConfirmationTrailView(){
        
        distanceLabel.text = "Distance: \(distanceNewTrail ?? "Distance Error")"
        timeLabel.text = "Time: \(timeNewTrail ?? "Time Error")"
        elevationGainLabel.text = "Elevation Gain: \(elevationGain ?? "Elevation error")"
        
        confirmationView.addSubview(textField)
        confirmationView.addSubview(distanceLabel)
        confirmationView.addSubview(timeLabel)
        confirmationView.addSubview(elevationGainLabel)
        confirmationView.addSubview(toggleButton)
        confirmationView.addSubview(toggleDescriptionLabel)
        self.view.insertSubview(confirmationView, aboveSubview: self.mapView)
        self.view.insertSubview(createTrailButton, aboveSubview: self.confirmationView)
        
        self.isConfirmationViewAtTheFront = true
        
        discardButton.frame.origin = CGPoint(x: view.frame.width * 0.025, y: view.frame.height * 0.85)
        discardButton.layer.shadowOpacity = 0.0
    }
    
    @objc func createAndSaveTrail(_ sender: UIButton){
        
        //Check if name is not empty
        if textField.text?.isEmpty ?? true {
            let missingNameAlert = UIAlertController(title: nil, message: "Please name the trail created", preferredStyle: .alert)
            missingNameAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(missingNameAlert, animated: true, completion: nil)
        } else {
            startLoadingAlert()
            createStaticImage()//Separate in part this.
            stopLoadingAlert()
            //Check if it is private or public
            if trailTypePublic {
                //show next card.
            }else {
                savePrivateTrailToCoreData()
                //save coordinates of private trail to firestore - check function works
            }
            
    
        }
        
    }
    

    func createStaticImage(){
        // MARK: Create a UIImageView that will store the map snapshot
        staticImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 500, height: 200))
        staticImageView.backgroundColor = .black
        staticImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
        let camera = SnapshotCamera(
            lookingAtCenter: CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude),
            zoomLevel: CGFloat(mapView.zoomLevel - 2))
        camera.pitch = 50
        // Use the map's style, camera, size, and zoom level to set the snapshot's options.
        let options = SnapshotOptions(
            styleURL: mapView.styleURL,
            camera: camera,
           size: CGSize(width: 500, height: 200))
       // options.overlays
        let geoJSONString = formatGeoString()
        options.overlays = [GeoJSON(objectString: geoJSONString)]
        let snapshot = Snapshot(options: options)
        
        if let snapshoptImage = snapshot.image{
            self.staticImageView.image = snapshoptImage
            // MARK: Save to firebase
            let storageRef = Storage.storage().reference().child("staticImages/\(textField.text!).png")
            let imgData = self.staticImageView.image?.pngData()
            let metaData = StorageMetadata()
            metaData.contentType = "image/png"
            
            storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
                guard let metadata = metadata else {
                    print("Error ocurred with meta data")
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                print("Size of img: \(size)")
                // You can also access to download URL after upload.
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error ocurred with download url")
                        return
                    }
                    self.downloadUrlString = downloadURL.absoluteString
                    
                }
                
                self.finalAlert()
            }
        } else {
            stopLoadingAlert()
            print("Error with setting snapshot image.")
            let confirmationAlertPublicTrail = UIAlertController(title: "There was an error creating this trail.", message: "Please try again later", preferredStyle: .alert)
            confirmationAlertPublicTrail.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(confirmationAlertPublicTrail, animated: true, completion: nil)
        }
        
    }
    @objc func toggleTrailStateButton (_ sender: UIButton) {
        trailTypePublic = !trailTypePublic
        if trailTypePublic {
            sender.setTitle("Public", for: .normal)
            sender.setTitleColor(.white, for: .normal)
             sender.backgroundColor = #colorLiteral(red: 0.9769582152, green: 0.7567471862, blue: 0, alpha: 1)
        } else {
            sender.setTitle("Private", for: .normal)
            sender.setTitleColor(.white, for: .normal)
             sender.backgroundColor = #colorLiteral(red: 0.2813360691, green: 0.5927771926, blue: 0.2168164253, alpha: 1)
            
        }
    }
    func setPrecision(x: CLLocationDegrees) -> Double {
        return Double(round(10000000*x)/10000000)
    }
    
    func formatGeoString() -> String {
        let geoStringStart =  """
            {
            "type": "FeatureCollection",
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
        let pinsCoordinates = pointAnnotations.map{ $0.coordinate }
        let coordinates = routeCoordinates.count < 500 ? routeCoordinates : pinsCoordinates
        trailStartLocation = CLLocation(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude)
        for coordinate in coordinates {
       
            coordinatesBody.append(contentsOf: "["+String(setPrecision(x: coordinate.longitude))+","+String(setPrecision(x: coordinate.latitude))+"],")
            //latitude first then longitude
            coordinatesOfNewTrail.append(String(setPrecision(x: coordinate.latitude))+","+String(setPrecision(x: coordinate.longitude)))
            
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
    
    func finalAlert(){
        discardButton.sendActions(for: .touchUpInside)
        if trailTypePublic {
            let confirmationAlertPublicTrail = UIAlertController(title: "Public trail created!", message: "Thank you for making Outdoorsy grow! It will be verified and added soon!", preferredStyle: .alert)
            confirmationAlertPublicTrail.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(confirmationAlertPublicTrail, animated: true, completion: nil)
        } else {
            let confirmationAlertPrivateTrail = UIAlertController(title: "Trail Successfully added", message: "Your new trail can be found under your Saved tab! Go check it out 🙌🏼", preferredStyle: .alert)
            confirmationAlertPrivateTrail.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(confirmationAlertPrivateTrail, animated: true, completion: nil)
        }
    }
    
    func savePrivateTrailToCoreData(){
        var sublocality = "not loaded"
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let trailCoreData = Trail(context: managedContext)
        trailCoreData.name = textField.text
        trailCoreData.distance = distanceNewTrail
        trailCoreData.elevationGain = elevationGain
        trailCoreData.time = timeNewTrail
        trailCoreData.trailId = UUID().uuidString
        
        trailCoreData.coordinates = coordinatesOfNewTrail
        trailCoreData.staticImage =  self.staticImageView.image!.jpegData(compressionQuality: 1.0)
        //Breaks here if I do it fast, make a loading while from saving to create trail?
        trailStartLocation.geocode{ placemark, error in
            if let error = error as? CLError {
                print("CLError:", error)
                return
            } else if let placemark = placemark?.first {
                sublocality = placemark.subLocality ?? "unknown"
                trailCoreData.region = sublocality
            }
            
        }
        // save to Core data
        do{
            try managedContext.save()//persistant storage
            
            
        } catch {
            debugPrint("Could not save coredata private trail - in Create new Trail: \(error.localizedDescription)")
            
        }
        
    }
    
    func saveDataToFirestore() {
        //creat new trailid
        //check form of trail public or personal
        //
        
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


// MARK:- UITextFieldDelegate

extension CreateTrailViewController: UITextFieldDelegate {

    
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





