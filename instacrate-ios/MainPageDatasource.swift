//
//  MainPageDatasource.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/8/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Moya

// Featured boxes
// Advertisement
// New and noteworthy
// Advertisement
// Today's Staff Pics

protocol NibLoadable: class {
    
    static var identifier: String { get }
    
    static func load<T: UIView>() -> T
}

extension NibLoadable {
    
    static var identifier: String {
        return "\(self)"
    }
    
    static func nib() -> UINib {
        return UINib(nibName: self.identifier, bundle: nil)
    }
}

extension UIView: NibLoadable {
    
    static func load<T : NibLoadable>() -> T {
        guard let nib = Bundle.main.loadNibNamed(T.identifier, owner: nil, options: nil) else {
            fatalError("Tried to load nib with identifier \(T.identifier) but no such nib was found.")
        }
        
        if nib.count > 1 {
            print("WARNING: Loaded nib with identifier \(T.identifier) and it has more than 1 top level object.")
        }
        
        guard let view = nib.first as? T else {
            fatalError("Could not cast \(type(of: nib.first)) to \(T.self)")
        }
        
        return view
    }
}

extension UITableView {
    
    func register<T: UITableViewCell>(cell: T.Type) where T: NibLoadable {
        register(T.nib(), forCellReuseIdentifier: T.identifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(headerFooterView: T.Type) where T: NibLoadable {
        register(T.nib(), forHeaderFooterViewReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: NibLoadable {
        guard let cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell: \(T.self) with identifier: \(T.identifier)")
        }
        
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: NibLoadable {
        if let cell = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T {
            return cell
        }
        
        return T.load()
    }
}

extension Realm {
    
    func curatedBoxes() -> Results<Box> {
        return boxes.filter("type IN %@", [Curated.featured.string, Curated.new.string, Curated.staffpicks.string])
    }
}

class MainPageDatasource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    static let curatedSections: [Curated] = [.featured, .new, .staffpicks]
    
    let curatedBoxes: Results<Box>
    let token: NotificationToken
    let advertisedBoxes: Results<Box>
    
    deinit {
        token.stop()
    }
    
    init(tableView: UITableView) {
        
        tableView.register(cell: BoxTableViewCell.self)
        tableView.register(headerFooterView: BoxAdvertisingBannerTableViewCell.self)
        
        let endpoint = Boxes.boxes(format: .long, curated: .all)
        
        MoyaProvider<Boxes>().request(endpoint) { response in
            switch response {
            case let .success(result):
                try! result.updateRealmAsRequest(from: endpoint)
                
            case let .failure(error):
                print("error on box category \(error)")
            }
        }
        
        curatedBoxes = try! Realm().curatedBoxes()
        
        token = curatedBoxes.addNotificationBlock { changes in
            tableView.reloadData()
        }
        
        advertisedBoxes = try! Realm().boxes
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MainPageDatasource.curatedSections.count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view: BoxAdvertisingBannerTableViewCell = tableView.dequeueReusableHeaderFooterView()
        let box = advertisedBoxes[section]
        view.configure(with: box)
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return MainPageDatasource.curatedSections[section].string
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects(in: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(BoxTableViewCell.self)", for: indexPath) as! BoxTableViewCell
        let object = objects(in: indexPath.section)[indexPath.row]
        
        cell.configure(with: object)
        
        return cell
    }
    
    func objects(in section: Int) -> Results<Box> {
        let sectionType = MainPageDatasource.curatedSections[section]
        return curatedBoxes.filter("type = %i", sectionType.string)
    }
    
    func object(for indexPath: IndexPath) -> Box {
        return objects(in: indexPath.section)[indexPath.row]
    }
}
