//
//  ViewController.swift
//  Vanmino
//
//  Created by Gustavo Ferrufino on 2018-12-02.
//  Copyright © 2018 Gustavo Ferrufino. All rights reserved.
//

import UIKit

import Firebase
import FirebaseFirestore
import CoreLocation
import MapKit
import OnboardKit
import StoreKit

class HikesVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView! // Table of Hikes
    @IBOutlet var sideMenuConstraint: NSLayoutConstraint!
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var  locationManager = CLLocationManager()
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var sideMenuOpen = false
    var hikes: [Hike] = []
    var filteredHikes = [Hike]()
    var coordinatesOfTrails: [String: Coordinates] = [:]
    let searchController = UISearchController(searchResultsController: nil)
    let date = Date().addingTimeInterval(10)
    let gettingTrailsAlert = UIAlertController(title: nil, message: "Getting hikes...", preferredStyle: .alert)
    var db : Firestore! //firestore migration
    
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        refreshControl.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        introSetUp()
        initLocationManager()
        configureTableView()
        db = Firestore.firestore()
        self.getTrailFromFirestore()
        
        setSearchController()
        
        tableView.refreshControl = refreshControl
        self.getUserIdAndSavedTrailsData()
 
    }
    func setSearchController() {
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Hikes"
        
        searchController.searchBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        searchController.searchBar.barTintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        searchController.searchBar.barStyle = .blackOpaque
        
        searchController.searchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Easy", "Inter.", "Hard"]
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    internal func configureTableView() {
        //Table Services
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = false
        //Register cells with identifier
        tableView.register(UINib(nibName: "MainTrailTableViewCell", bundle: nil), forCellReuseIdentifier: "MainTrailTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if tableView.numberOfRows(inSection: 1) > 5 {
            stopGettingIntroTrailsAlert()
        }else {
            startGettingTrailsAlert()
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func startGettingTrailsAlert(){
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        gettingTrailsAlert.view.addSubview(loadingIndicator)
        present(gettingTrailsAlert, animated: true, completion: nil)
    }
    
    func stopGettingIntroTrailsAlert(){
        tableView.reloadData()
        gettingTrailsAlert.dismiss(animated: true, completion: nil)
        
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SideBarController,
            segue.identifier == "mainFeedToSideBar" {
            vc.delegate = self
        }
    }
    
    
    @IBAction func sideBarMenuTapped() {
        //print("Toggle Menu")
        if sideMenuOpen {
            
            sideMenuConstraint.constant = -240
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }else{
            sideMenuConstraint.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
        sideMenuOpen = !sideMenuOpen
    }
    //////////////////////
    // Navigation bar FUNCTIONS
    /////////////////////
    @IBAction func infoIconPressed(_ sender: Any) {
        guard let createTrailVC = storyboard?.instantiateViewController(withIdentifier: "CreateTrailViewController") as? CreateTrailViewController else {return}
        createTrailVC.initCreateTrail(with: User.sharedInstance.userLocation)
        presentDescription(createTrailVC)
        
    }

    func introSetUp(){
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {
            
            print("First launch, setting UserDefault.")
            
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            let page1 = OnboardPage(title: "Welcome to Outdoorsy 🤯",
                                    imageName: "onBoarding1",
                                    description: "Keep track of live conditions of hikes!")
            
            let page2 = OnboardPage(title: "Live conditions of Hikes",
                                    imageName: "onBoarding2",
                                    description: "Swip up the drawer! \n See Weather conditions of a hike, Pet friendly or Camping areas.")
            
            let page3 = OnboardPage(title: "Navigate, Save, Recenter",
                                    imageName: "onBoarding3",
                                    description: "Get directions by Car to the start of a hike. \n \n Save your fav hikes. \n \n Recenter the map!")
            
            let page4 = OnboardPage(title: "Where are you?",
                                    imageName: "onBoarding4",
                                    description: "We show your location during a Hike and how far away are you from it 🙃")
            
            let appearance = OnboardViewController.AppearanceConfiguration(tintColor: #colorLiteral(red: 0.9604964852, green: 0.7453318238, blue: 0, alpha: 1),
                                                                           titleColor: #colorLiteral(red: 0.9907949567, green: 0.9909603, blue: 0.9907731414, alpha: 1),
                                                                           textColor: .white,
                                                                           backgroundColor: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
                                                                           imageContentMode: .scaleAspectFit,
                                                                           titleFont: UIFont.boldSystemFont(ofSize: 27.0),
                                                                           textFont: UIFont.boldSystemFont(ofSize: 21.0))
            let onBoardPages : [OnboardPage] = [page1,page2,page3,page4]
            let onboardingViewController = OnboardViewController(pageItems: onBoardPages, appearanceConfiguration: appearance)
            onboardingViewController.presentFrom(self, animated: true)
            
        }else {
            startGettingTrailsAlert()
        }
    }
    
    //////////////////////
    // User Location SERVICES
    /////////////////////
    
    
    func checkLocationServices(handleComplete:(()->())) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            }
        } else {
            notifyUser(title: "By the way.. 🙄", message: "Features from Outdoorsy won't work if we don't have access to your location. \n Please enable it at Settings>Outdoorsy>Location>While Using the App.",imageName: "", rate: false, extraOption: "", handleComplete: {})
        }
        
        handleComplete()
    }
    
    
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Location Manager Delegate stuff
    // If failed
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            if (seenError == false) {
                seenError = true
                print("Location Manager error: \(error)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if (locationFixAchieved == false) {
            locationFixAchieved = true
            var locationArray = locations as NSArray
            var locationObj = locationArray.lastObject as! CLLocation
            var coord = locationObj.coordinate
            guard let locValue: CLLocationCoordinate2D = locationObj.coordinate else { return }
            User.sharedInstance.userLocation = locValue
            _ = triggerOnceSaveUserInformation
        }
        
    }
    
    // authorization status
    func locationManager(manager: CLLocationManager!,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        
        if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
            locationManager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
    
    
    
    private lazy var triggerOnceSaveUserInformation: Void = {
        saveUserData()
    }()
    
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredHikes = hikes.filter({( hike : Hike) -> Bool in
            let doesCategoryMatch = (scope == "All") || (hike.difficulty == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && hike.name!.lowercased().contains(searchText.lowercased())
            }
            
        })
        
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    
}

extension HikesVC{
    
    
    
    // Get User Phone Specs
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
}


extension HikesVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering() {
            return filteredHikes.count
        }
        return hikes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainTrailTableViewCell") as? MainTrailTableViewCell else {return UITableViewCell()}
        
        // set the text from the data model
        cell.selectionStyle = .none
        let hike : Hike
        if isFiltering() {
            hike = filteredHikes[indexPath.row]
        } else {
            hike = hikes[indexPath.row]
        }
        
        
        cell.configCell(trail: hike){
            self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        }

        //Calculate distance from User to Start of trail
        // TODO Try catch needed here //
        if hike.distanceFromUser == nil && User.sharedInstance.userLocation != CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0){
            let hikeLocations =
                hikes[indexPath.row].distanceFromUser = setDistanceFromTwoLocations(hikeLocation: hike.startLocation!)
            cell.distanceFromUser.text = hikes[indexPath.row].distanceFromUser ?? "Calc Distance"
            
            
        }else{
            cell.distanceFromUser.text = hikes[indexPath.row].distanceFromUser
            
        }
        
        return cell
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 300
    }
    
    
    
    func setDistanceFromTwoLocations(hikeLocation: CLLocationCoordinate2D) -> String {
        let coordinate₀ = User.sharedInstance.userLocation // Throw something if empty
        let coordinate₁ = hikeLocation
        let distanceInKms = Int(coordinate₀.distance(to: coordinate₁)/1000) // result is in kms
        
        return distanceInKms > 999 ? "You're too far" : String(distanceInKms) + " km away";
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkLocationServices { () -> () in
            if sideMenuOpen {
                sideBarMenuTapped()
            } else if User.sharedInstance.userLocation != CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) {
                guard let trailDescriptionVC = storyboard?.instantiateViewController(withIdentifier: "TrailDescriptionVC") as? HikeMapVC else {return}
                let hikeSelected = isFiltering() ? filteredHikes[indexPath.row] : hikes[indexPath.row]
                
                //check if its private or public then get from coredata and pass or not
                
                trailDescriptionVC.initTrailDescriptionData(hike: hikeSelected)
               
                
                
                presentDescription(trailDescriptionVC)
                
                
            }
        }
    }
    
}



extension HikesVC {
    
    @objc func saveUserData(){
        if User.sharedInstance.userLocation.latitude != 0.0 && User.sharedInstance.userLocation.longitude != 0.0 {
            let systemVersion = UIDevice.current.systemVersion
            //https://www.theiphonewiki.com/wiki/Models
            let phoneModel = modelIdentifier()
            let location:CLLocationCoordinate2D = User.sharedInstance.userLocation
            let longitude :CLLocationDegrees = location.longitude
            let latitude :CLLocationDegrees = location.latitude
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            var locality = "not loaded"
            var sublocality = "not loaded"
            var administrativeArea = "not loaded"
            var country = "not loaded"
            userLocation.geocode{ placemark, error in
                if let error = error as? CLError {
                    print("CLError:", error)
                    return
                } else if let placemark = placemark?.first {
                    // you should always update your UI in the main thread
                    DispatchQueue.main.async {
                        
                        locality = placemark.locality ?? "unknown"
                        sublocality = placemark.subLocality ?? "unknown"
                        administrativeArea = placemark.administrativeArea ?? "unknown"
                        country = placemark.country ?? "unknown"
                        
                        let dateFormatter : DateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
                        let date = Date()
                        let dateString = dateFormatter.string(from: date)
                        let outdoorsyVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
                        let post = [
                            "locality":  locality,
                            "sublocality": sublocality,
                            "administrativeArea":  administrativeArea,
                            "country": country,
                            "iOSversion": systemVersion,
                            "phoneModel": phoneModel,
                            "dateStamp": dateString,
                            "uid": User.sharedInstance.userId,
                            "appVersion": outdoorsyVersion
                        ]
                        
                        print("Locality: \(post)")
                        if(User.sharedInstance.locality != locality){
                            User.sharedInstance.locality = locality
                            
                            self.db.collection("users").document(User.sharedInstance.userId).setData(["userInfo": post], merge: true) { err in
                                if let err = err {
                                    print("Error writing userInfo: \(err)")
                                } else {
                                    print("userInfo successfully written!")
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func getTrailFromFirestore(){
        self.db.collection("trails").addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retreiving Trail snapshot: \(error!)")
                return
            }
            
            for diff in snapshot.documentChanges {
                if diff.type == .added {
                    print("Document changes found: \(diff.document.data())")
                }
            }
            
            let source = snapshot.metadata.isFromCache ? "local cache" : "server"
            print("Metadata: Data fetched from \(source)")
            
            
            
            for document in querySnapshot!.documents {
                //Get coordinate of Start Location
                let hike = Hike()
                hike.initVariables(trailId: document.documentID, hikeDetails: document.data() as AnyObject)
                self.hikes.removeAll(where: { hike.id == $0.id })
                self.hikes.append(hike)
                
            }
            
            //Order hikes by name
            self.hikes.sort(by: { $0.name! < $1.name! })
            self.tableView.reloadData()
            
            if User.sharedInstance.userLocation != CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) && self.hikes.count != 0{
                let count = 0...(self.hikes.count-1)
                for index in count {
                    self.hikes[index].distanceFromUser = self.setDistanceFromTwoLocations(hikeLocation: self.hikes[index].startLocation!)
                }
            }
            
        }
        
        
        
    }
    
    
    func getUserIdAndSavedTrailsData(){
        Auth.auth().signInAnonymously() { (authResult, error) in
            
            let user = authResult!.user
            User.sharedInstance.userId = user.uid
            self.db.collection("users").document(User.sharedInstance.userId).collection("savedTrails").getDocuments()
                {
                    (querySnapshot, err) in
                    
                    if let err = err
                    {
                        print("Documents dont exist: \(err)");
                        //make empty object
                    }
                    else
                    {
                        
                        for document in querySnapshot!.documents {
                            
                            print("Saved Trails \(document.data())");
                            let trail = Hike()
                            trail.initVariables(trailId: document.documentID, hikeDetails: document.data() as AnyObject)
                            User.sharedInstance.savedTrails.append(trail)
                        }
                        User.sharedInstance.createSavedTrailStatus()
                        
                        
                        
                    }
            }
        }
    }
    
    
    
    
}

extension HikesVC: ChildToParentProtocol {
    
    func OrderHikeListBy(Order: String){
        print(Order)
        switch Order {
        case "region":
            regionOrder()
        case "name":
            hikeOrder()
        case "distance":
            distanceOrder()
        case "closest":
            closestOrder()
        case "difficulty":
            difficultyOrder()
        default:
            hikeOrder()
            
        }
    }
    
    func closestOrder() {
        if User.sharedInstance.userLocation != CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) {
            self.hikes.sort(by: { $0.distanceFromUser ?? "--" < $1.distanceFromUser ?? "--" })
            sideBarMenuTapped()
            self.tableView.reloadData()
        }
        
    }
    
    func difficultyOrder() {
        self.hikes.sort(by: {
            switch ($0.difficulty, $1.difficulty){
            case ("Easy", "Hard"):
                return true //"Easy" < "Expert"
                
            case ("Easy", "Inter."):
                return true //"Easy" < "Intermediate"
                
            case ("Inter.", "Hard"):
                return true ///"Intermediate" < "Expert"
                
            case ("Inter.", "Easy"):
                return false //"Intermediate" > "Easy"
                
            case ("Easy", "Easy"):
                return $0.distance! < $1.distance!
                
            case ("Inter.", "Inter."):
                return $0.distance! < $1.distance!
                
            case ("Hard", "Hard"):
                return $0.distance! < $1.distance!
                
            case ("Hard", "Easy"):
                return false//"Expert" > "Easy"
                
            case ("Hard", "Inter."):
                return false//"Expert" > "Intermediate"
                
            default:
                return $0.distance! < $1.distance!
            }
            
        })
        sideBarMenuTapped()
        self.tableView.reloadData()
    }
    
    func hikeOrder() {
        self.hikes.sort(by: { $0.name! < $1.name! })
        sideBarMenuTapped()
        self.tableView.reloadData()
        
    }
    
    func regionOrder() {
        
        self.hikes.sort(by: { $0.region! < $1.region! })
        sideBarMenuTapped()
        self.tableView.reloadData()
    }
    
    func distanceOrder() {
        self.hikes.sort(by: { Float($0.distance!)! < Float($1.distance!)! })
        sideBarMenuTapped()
        self.tableView.reloadData()
    }
}

// MARK: - Search functionality
extension HikesVC : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
    
    
}

extension HikesVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


