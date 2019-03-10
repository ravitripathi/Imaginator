//
//  ScanListTableVC.swift
//  Imaginator
//
//  Created by Ravi Tripathi on 09/03/19.
//  Copyright © 2019 Ravi Tripathi. All rights reserved.
//

import UIKit

class ScanListTableVC: UITableViewController {

    var sceneList: [SceneModel] = [SceneModel]()
    var destinationUrl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        Utility.shared.retrieveScene { (sceneModel) in
            self.sceneList.append(sceneModel)
            self.tableView.reloadData()
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sceneList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = sceneList[indexPath.row].fileName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < sceneList.count {
            if let sceneUrl = sceneList[indexPath.row].url, let url = URL(string: sceneUrl) {
                self.view.lock()
                Utility.shared.downloadFile(withUrl: url) { (success, url) in
                    self.view.unlock()
                    if success, let url = url {
                        self.destinationUrl = url
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "showScreen", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showScreen", let vc = segue.destination as? ViewerController {
            vc.sceneURL = self.destinationUrl
        }
    }
}
