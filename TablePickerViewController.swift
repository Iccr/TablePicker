//
//  TablePickerViewController.swift
//  Sipradi
//
//  Created by shishir sapkota on 7/25/17.
//  Copyright © 2017 Ekbana. All rights reserved.
//

import UIKit

enum SearchListingTypes: String {
    case airlinesFromLocation = "origin"
    case airlinesToLocation = "destination"
}

class TablePickerViewController: UIViewController {
    
    struct Constants {
//        static let defaultEmptyResultText = "No matching place found for "
    }
    
    
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noResultFoundLabel: UILabel!
    
    var data: [String] = []
    var filteredPlaces: [String] = [] {
        didSet {
            self.tableVIew.reloadData()
            self.setNoResultText()
            self.filteredPlaces.isEmpty ? (self.noResultFoundLabel.isHidden = false) : (self.noResultFoundLabel.isHidden = true)
        }
    }
    var allowMultipleSelection = false
    var allowSelection = true
    var doneAction: (([String]) -> ())?
    var defaultSelectedData: [String] = []
//    var titleString = "Choose Location"
    var searchText = ""
    var type: SearchListingTypes?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.addGradientView()
        self.setupSearchService()
        self.setupSearchTextFieldUi()
        self.setupPlaces()
        setTitle()
    }
    
    
    private func setNoResultText() {
        var text = ""
        if let type = self.type  {
            text = "No matching \(type.rawValue) found for "
        } else {
            text = "No matching result found for "
        }
        self.noResultFoundLabel.text = text + "'\(searchText)'"
    }
    
    
    private func setTitle() {
        self.titleLabel.text = "Choose " + (self.type?.rawValue ?? "Location").capitalized
    }
    
    private func setupTableView() {
        self.tableVIew.delegate = self
        self.tableVIew.dataSource = self
        self.tableVIew.separatorColor = UIColor.init(hex: "#DFDFDF")
        self.tableVIew.allowsMultipleSelection = self.allowMultipleSelection
        self.tableVIew.allowsSelection = self.allowSelection
        self.noResultFoundLabel.isHidden = true
    }
    
    private func setupPlaces() {
        self.filteredPlaces = self.data
    }
    
    private func setupSearchTextFieldUi() {
        let searchIconImageView = UIImageView(image: #imageLiteral(resourceName: "search"))
        searchIconImageView.tintColor = IMEColors.red
        self.searchTextField.leftView = searchIconImageView
        self.searchTextField.leftViewMode = .always
    }
    
    
    private func setupSearchService() {
        self.searchTextField.addTarget(self, action: #selector(self.search(sender:)), for: UIControlEvents.editingChanged)
    }
    
    private func addGradientView() {
        let gradientview = IMEGradientView()
        gradientview.leftColor = UIColor.init(hex: "#FF0000")
        gradientview.rightColor = UIColor.init(hex: "#9C272D")
        if let navbarFrame = self.navigationController?.navigationBar.frame {
            gradientview.frame = navbarFrame
        }
        self.navigationController?.navigationBar.addSubview(gradientview)
    }
    
    @objc private func search(sender: UITextField) {
        let searchString = sender.text!
        self.searchText = searchString
        if searchString.isEmpty {
            self.filteredPlaces = self.data
            return
        }
        self.filteredPlaces = self.data.filter({
            return searchString.isEmpty ||
            $0.lowercased().contains(searchString.lowercased())
        }).sorted(by: { (a, _) -> Bool in
            return a.lowercased().hasPrefix(searchString.lowercased())
        })
    }
    
    private func getNotificationName() -> Notification.Name {
        return Notification.Name.init(NotificationNames.from)
    }
    
    // MARK: IBActions
    
    @IBAction func close(_ sender: Any?) {
        let selectedIndexPaths = self.tableVIew.indexPathsForSelectedRows ?? self.tableVIew.indexPathForSelectedRow.map({[$0]})
        let selectedData = selectedIndexPaths?.flatMap { indexPath -> String? in
            let value = filteredPlaces.elementAt(index: indexPath.row)
            return value
        }
        self.doneAction?(selectedData ?? [])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clear(_ sender: Any) {
        self.tableVIew.indexPathsForSelectedRows?.forEach({self.tableVIew.deselectRow(at: $0, animated: true)})
        self.tableVIew.indexPathForSelectedRow.map({self.tableVIew.deselectRow(at: $0, animated: true)})
        self.defaultSelectedData = []
        self.tableVIew.reloadData()
    }
    
    
     @IBAction func dismiss(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
     }
}

extension TablePickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! TablePickerTableViewCell
        cell.selectedPlace = self.filteredPlaces.elementAt(index: indexPath.row)
        cell.setup()
        if !self.allowMultipleSelection {
            self.close(nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TablePickerTableViewCell {
            cell.selectedPlace = nil
            cell.setup()
        } else {
            print("wtf happened here??")
        }
//        cell?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let onlyIndex = (filteredPlaces.elementAt(index: indexPath.row) ?? "").components(separatedBy: " ").first ?? ""
        if defaultSelectedData.contains(onlyIndex) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}



extension TablePickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableVIew.dequeueReusableCell(withIdentifier: "TablePickerTableViewCell", for: indexPath) as! TablePickerTableViewCell
        

        cell.title = filteredPlaces.elementAt(index: indexPath.row)

        let onlyIndex = filteredPlaces[indexPath.row].components(separatedBy: " ").first ?? ""
        cell.selectedPlace = self.defaultSelectedData.first
//        if defaultSelectedData.contains(onlyIndex) {
//            cell.
//            cell.accessoryType = .checkmark
//        }else {
//            cell.accessoryType = .none
//        }
        cell.setup()

        return cell
    }
}
