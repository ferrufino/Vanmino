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
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LiveInfoTableViewCell", for: indexPath) as? LiveInfoTableViewCell {
                
                cell.selectionStyle = .none
                ///get data and assign it to hike
                //assign hike to respective labels in cell and return cell
                //hike = DrawerViewController.hike
                // cell.descriptionLabel.text = subtitleText
                return cell
            }
        } else if indexPath.row == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FactInfoTableViewCell", for: indexPath) as? FactInfoTableViewCell {
                cell.selectionStyle = .none
                cell.hikeDifficulty.text = hikeModel.difficulty
                cell.hikeDistance.text = hikeModel.distance
                cell.hikeElevation.text = hikeModel.elevation
                cell.hikeTime.text = hikeModel.time
                ///get data and assign it to hike
                //assign hike to respective labels in cell and return cell
                //hike = DrawerViewController.hike
                // cell.descriptionLabel.text = subtitleText
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