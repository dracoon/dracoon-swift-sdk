//
//  NodeTableViewController.swift
//  oauth2.example
//
//  Created by Mathias Schreiner on 08.11.18.
//  Copyright © 2018 Dracoon. All rights reserved.
//

import UIKit
import dracoon_sdk

class NodeTableViewController: UITableViewController {
    
    let client: DracoonClient
    var nodes: [Node]?
    
    let cellIdentifier = "NodeCellIdentifier"
    
    init(client: DracoonClient) {
        self.client = client
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.requestNodes()
    }
    
    func requestNodes() {
        self.client.nodes.getNodes(parentNodeId: 0, limit: nil, offset: nil, completion: { result in
            switch result {
            case .error(let error):
                print(error)
            case .value(let nodeList):
                self.reloadNodes(nodes: nodeList.items)
                break
            }
        })
    }
    
    func reloadNodes(nodes: [Node]) {
        self.nodes = nodes
        self.tableView.reloadData()
    }
    
    // MARK: - Table View DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let nodes = self.nodes else {
            return 0
        }
        return nodes.count
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let item = self.getItemForIndexPath(indexPath) else {
            return cell
        }
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.size != nil ? String(item.size!) : ""
        return cell
    }
    
    func getItemForIndexPath(_ indexPath: IndexPath) -> Node? {
        guard let nodes = self.nodes else {
            return nil
        }
        
        guard nodes.count > indexPath.row else {
            return nil
        }
        return nodes[indexPath.row]
    }
}
