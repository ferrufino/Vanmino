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

class TrailDescriptionVC: UIViewController, MGLMapViewDelegate {
    
    var mapView: NavigationMapView!
    var navigateButton: UIButton!
    var directionsRoute: Route?
    
    var startOfHike: CLLocationCoordinate2D!
    var userLocation: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = NavigationMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        //mapView.setUserTrackingMode(.follow, animated: true)
        // Do any additional setup after loading the view.
        pinRoute()
        addButton()
    }
    
    func initData(trail: Trail, userLocation: CLLocationCoordinate2D){
       
        //print(trail.startLocation)
        let location = trail.startLocation!.components(separatedBy: ",")
        self.startOfHike = CLLocationCoordinate2D(latitude: Double(location[0])!, longitude: Double(location[1])!)
        self.userLocation = userLocation
    }
    func pinRoute(){
        mapView.setUserTrackingMode(.none, animated: true)
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = startOfHike
        annotation.title = "Start Navigation"
        
        mapView.addAnnotation(annotation)
        //print("User location \(userLocation) vs \(mapView.userLocation!.coordinate)")
        calculateRoute(from: userLocation, to: startOfHike) { (route, error) in
            if error != nil {
                print("Error getting route")
            }
            
        }
    }
    func addButton() {
        navigateButton = UIButton(frame: CGRect(x: (view.frame.width/2) - 100, y: view.frame.height - 75, width: 200, height: 50))
        navigateButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navigateButton.setTitle("Directions to Start of Hike", for: .normal)
        navigateButton.setTitleColor(UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1), for: .normal)
        navigateButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 15)
        navigateButton.layer.cornerRadius = 25
        navigateButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        navigateButton.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        navigateButton.layer.shadowRadius = 5
        navigateButton.layer.shadowOpacity = 0.3
        navigateButton.addTarget(self, action: #selector(navigateButtonWasPressed(_:)), for: .touchUpInside)
        view.addSubview(navigateButton)
       
    }
    @objc func navigateButtonWasPressed(_ sender: UIButton){
        let navigationVC = NavigationViewController(for: directionsRoute!)
        present(navigationVC, animated: true, completion: nil)
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
