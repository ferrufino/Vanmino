//
//  ViewController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-02.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase


let appDelegate = UIApplication.shared.delegate as? AppDelegate


class TrailsVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    
    var trails: [Trail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        
        self.readTrailsFromFirebase()
        //self.deleteAllData("Trail")
         fetchCoreDataObjects()
         tableView.reloadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func fetchCoreDataObjects(){
        self.fetch { (complete) in
            if complete {
                if trails.count >= 1 {
                    print("Data read into obj from model")
                } else {
                    print("Data NOT read into obj from model")
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      //  let root = Database.database().reference()
       // let childRef = Database.database().referen
        
        
    }

    
   
}

extension TrailsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "trailCell") as? TrailCell else {return UITableViewCell()}
        
        // set the text from the data model
        //cell.textLabel?.text = self.animals[indexPath.row]
        let trail = trails[indexPath.row]
        cell.configCell(trail: trail)
        return cell
    }


}

    //USE CORE DATA
extension TrailsVC {

    func fetch(completion: (_ complete:Bool) -> ()){
        guard let manageContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let fetchRequest = NSFetchRequest<Trail>(entityName: "Trail")
        
        do{
            trails = try manageContext.fetch(fetchRequest)
            completion(true)
        } catch{
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
    
    func deleteAllData(_ entity:String) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        let fetchRequest = NSFetchRequest<Trail>(entityName: "Trail")
        fetchRequest.includesPropertyValues = false
        
        do{
            let items = try managedContext.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>) as! [NSManagedObject]
            
            for item in items {
                managedContext.delete(item)
            }
            
            print("Model \(entity) successfully delted")
        } catch {
            debugPrint("Could not delete entry: \(error.localizedDescription)")
        }
        
    }
    
    

//    func loadData(completion: (_ finished: Bool)->()){
//        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
//
//        let trail = Trail(context: managedContext)
//
//        do{
//            try managedContext.save()//persistant storage
//            print("Successfully build data")
//            completion(true)
//        } catch {
//            debugPrint("Could not save: \(error.localizedDescription)")
//            completion(false)
//        }
//    }
}

extension TrailsVC {
    
    func readTrailsFromFirebase(){
        let trailsReference = Database.database().reference()
        let itemsRef = trailsReference.child("trails")
        itemsRef.observe(DataEventType.value, with: { (snapshot) in
            let value = snapshot.value as! [String: AnyObject]
            
            for (nameOfHike,infoOfHike) in value {
                self.save(nameOfHike: nameOfHike, descriptionOfHike: infoOfHike)
            }
        }){ (error) in
            print(error.localizedDescription)
        }
    }
    
    func save(nameOfHike: String, descriptionOfHike: AnyObject) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let trail = Trail(context: managedContext)
        
        trail.name = nameOfHike
        trail.difficulty = descriptionOfHike["difficulty"] as? String ?? ""
        trail.distance = descriptionOfHike["distance"] as? String ?? ""
        trail.elevation = descriptionOfHike["elevation"] as? String ?? ""
        trail.season = descriptionOfHike["season"] as? String ?? ""
        trail.time = descriptionOfHike["time"] as? String ?? "" 
        
        do{
            try managedContext.save()//persistant storage
            print("Successfully build data")
            
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            
        }
        
    }

    
}


