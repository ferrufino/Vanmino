//
//  ImageController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2019-09-05.
//  Copyright © 2019 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class ImageController {
    

    /*
     Compose the search URL to hit based on the search string
     Fetch the JSON response for that URL and parse out the attribution & URL elements
     Fetch the image from the URL in those search results
     Return the attribution info and the image so we can display them

     */
    
     func getStaticImage(imgURL: String, completionHandler: @escaping (UIImage, Bool) -> Void) {
       
            //download
            let storage = Storage.storage()
            
            let httpsReference = storage.reference(forURL: imgURL)
            
            var imageRetrieved = UIImage(named: "loadingTrailMap")
            DispatchQueue.main.async {
                httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error getting image: \(error)")
                        completionHandler(UIImage(named: "emptyTrailMap")!, true)
                        
                    } else {
                        
                        imageRetrieved = UIImage(data: data!)!
                    }
                }
                let result = imageRetrieved!
                
                completionHandler(result, false)
            }
        
    }

}
