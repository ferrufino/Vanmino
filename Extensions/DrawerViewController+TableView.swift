//
//  DrawerViewController+TableView.swift
//  ShortcutsDrawer
//
//  Created by Phill Farrugia on 10/17/18.
//  Copyright © 2018 Phill Farrugia. All rights reserved.
//

import UIKit

/// An extension on DrawerViewController that handles all of the
/// tableView related configuration and functionality.
extension DrawerViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Configuration
    
    internal func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        //Register cells with identifier
        tableView.register(UINib(nibName: "LiveInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "LiveInfoTableViewCell")
        tableView.register(UINib(nibName: "FactInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "FactInfoTableViewCell")
        tableView.register(UINib(nibName: "SecLiveInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "SecLiveInfoTableViewCell")
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LiveInfoTableViewCell", for: indexPath) as? LiveInfoTableViewCell {
                
                cell.selectionStyle = .none

                if(hikeModel.temperature != nil){
                    cell.temperature.text = hikeModel.temperature! + " C"
                    cell.weather.text = hikeModel.weather
                    cell.weatherIcon.image = UIImage(named:hikeModel.weatherIcon!)
                    cell.tempMax.text = hikeModel.tempMax! + " C"
                    cell.tempMin.text = hikeModel.tempMin! + " C"
                    cell.sunrise.text = hikeModel.sunrise
                    cell.sunset.text = hikeModel.sunset
                  
                }
                
                
                return cell
            }
        } else if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FactInfoTableViewCell", for: indexPath) as? FactInfoTableViewCell {
                cell.selectionStyle = .none
                cell.hikeDifficulty.text = hikeModel.difficulty
                cell.hikeDistance.text = hikeModel.distance! + " km"
                cell.hikeElevation.text = hikeModel.elevation
                cell.hikeTime.text = hikeModel.time
               
                if hikeModel.dogFriendly {
                    cell.dogIcon.image = UIImage(named:"dog")
                }
                
                if hikeModel.camping {
                    cell.campingIcon.image = UIImage(named:"camping")
                }

                return cell
            }
        } else if indexPath.row == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SecLiveInfoTableViewCell", for: indexPath) as? SecLiveInfoTableViewCell {
              
                cell.selectionStyle = .none
                
                if(hikeModel.temperature != nil){
                  cell.visibility.text = hikeModel.visibility! + " m"
                  cell.cloudsPercentage.text = hikeModel.clouds! + " %"
                  cell.windSpeed.text = hikeModel.windSpeed! + " m/s"
                  cell.windDirection.text = hikeModel.windDirection
                  cell.barometer.text = hikeModel.barometer! + " hPa"
                  cell.humidity.text = hikeModel.humidity! + " %"
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LiveInfoTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row in Drawer: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
