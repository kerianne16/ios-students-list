//
//  MainViewController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import UIKit

class StudentsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var sortSelector: UISegmentedControl!
    @IBOutlet weak var filterSelector: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let studentController = StudentController() // private bc this is the only view controller that needs access to this constant no one else should be able to modify this 
    private var filteredAndSortedStudents: [Student] = [] { // anything changes, the table view is told to reload data
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
    
        studentController.loadFromPersistentStore { (students, error) in
            if let error = error {
                NSLog("Error loading students: \(error)")
                return 
            } // this is running in the background queue async
            DispatchQueue.main.async {
                if let students = students {
                    self.filteredAndSortedStudents = students // triggers code to update UI
                }
            }
        }
    }
    
    // MARK: - Action Handlers
    
    @IBAction func sort(_ sender: UISegmentedControl) {
        updateDataSource()
    }
    
    @IBAction func filter(_ sender: UISegmentedControl) {
        updateDataSource()
    }
    
    // MARK: - Private
    private func updateDataSource() {
            let filter = TrackType(rawValue: filterSelector.selectedSegmentIndex) ?? .none
            let sort = SortOptions(rawValue: sortSelector.selectedSegmentIndex) ?? .firstName
            studentController.filter(with: filter, sortedBy: sort) { (students) in
                self.filteredAndSortedStudents = students
            }
        }
    }

extension StudentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAndSortedStudents.count // however many rows that are in student array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        
        // Configure cell
        let aStudent = filteredAndSortedStudents[indexPath.row]
        cell.textLabel?.text = aStudent.name
        cell.detailTextLabel?.text = aStudent.course
        return cell
    }
}
