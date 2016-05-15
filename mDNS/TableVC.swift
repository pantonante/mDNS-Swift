//
//  TableVC.swift
//  mDNS
//
//  Created by Pasquale Antonante on 15/05/16.
//  Copyright © 2016 Pasquale Antonante. All rights reserved.
//

import UIKit

class TableVC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var beacubeBrowser = mDNSBrowser()
    @IBOutlet weak var beacubeServicesTable: UITableView!
    
    let data:[String] = ["A","B","C","D","E","F"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beacubeBrowser.searchForServices()
        
        beacubeServicesTable.delegate = self
        beacubeServicesTable.dataSource = self
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TableVC.reloadServicesTable), name: "newBeacubeServiceDiscovered", object: beacubeBrowser)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacubeBrowser.beacubeList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("beacubeServiceCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = beacubeBrowser.beacubeList[indexPath.row].getAddress()
        return cell
    }
    
    func reloadServicesTable() {
        print("Should reload")
        self.beacubeServicesTable.reloadData()
    }
    
}