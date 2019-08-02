//
//  GeneralExtensions.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-02-23.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import CoreLocation

import MapboxStatic
import Mapbox
let imageCache = NSCache<NSString, UIImage>()


extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(self, completionHandler: completion)
    }
}

extension UIAlertController {
    func addImage(image: UIImage){
        let maxSize = CGSize(width: 245, height: 300)
        let imgSize = image.size
        
        var ratio: CGFloat!
        if(imgSize.width > imgSize.height){
            ratio = maxSize.width / imgSize.width
        }else {
            ratio = maxSize.height / imgSize.height
        }
        
        let scaledSize = CGSize(width: imgSize.width * ratio, height: imgSize.height * ratio)
        let resizedimage = image.imageWithSize(scaledSize)
        let imageAction = UIAlertAction(title: "", style: .default, handler: nil)
        imageAction.isEnabled = false
        imageAction.setValue(resizedimage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imageAction)
        
    }
}

extension UIImage {
    func imageWithSize(_ size:CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}


extension UIImageView {
    
    func loadImageUsingCacheWithGeoJSONURLString(urlString: String, coor: CLLocationCoordinate2D?){
        
        var geoJSONOverlay: GeoJSON!
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            print("CACHED IMAGE FOUND")
            return
        }
        
        
        do {
            //  let geoJSONString = try String(contentsOf: URL(string: urlString)!, encoding: .utf8)
            //  geoJSONOverlay = GeoJSON(objectString: geoJSONString)
            
            
            let camera = SnapshotCamera(
                lookingAtCenter: CLLocationCoordinate2D(latitude: coor?.latitude ?? 50.1748, longitude: coor?.longitude ?? -123.1162),
                zoomLevel: 12)
            //camera.heading = 45
            camera.pitch = 60
            let options = SnapshotOptions(
                styleURL: URL(string: "mapbox://styles/mapbox/outdoors-v11")!,
                camera: camera,
                size: CGSize(width: 500, height: 200))
            
            // options.overlays = [geoJSONOverlay] Have to add the trails?
            let snapshot = Snapshot(
                options: options,
                accessToken: "pk.eyJ1IjoiZmVycnVmaW5vIiwiYSI6ImNqcHlvNnNjdzAzYXM0M3M3cmN1amxpeWoifQ.mrGA90UjJN7HufE5IG3u4w")
            
            
            if let downloadedImage = snapshot.image {
                imageCache.setObject(snapshot.image!, forKey: urlString as NSString)
                self.image = downloadedImage
            }
            
        }catch {
            print("ERROR: geo string")
        }
        
    }
}


extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Avenir Black", size: 25)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
    
    
}

extension UITableViewCell {
    func assignDiff(diff: Int) -> String{
        switch diff {
        case 0:
            return "Easy"
        case 1:
            return "Intermediate"
        case 2:
            return "Hard"
        default:
            return "Not defined"
        }
    }
}

