//
//  StudentController.swift
//  Students
//
//  Created by Ben Gohlke on 6/17/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation

enum TrackType: Int {
    case none
    case iOS
    case Web
    case UX
}

enum SortOptions: Int {
    case firstName
    case lastName
}
class StudentController {
    
    private var students: [Student] = []
    
    private var persistentFileURL: URL? {
        guard let filePath = Bundle.main.path(forResource: "students", ofType: "json") else { return nil }
        return URL(fileURLWithPath: filePath)
    }
    
    // this is the closure, anoynmous function load date from the json data file
    func loadFromPersistentStore(completion: @escaping ([Student]?, Error?) -> Void) {
        let bgQueue = DispatchQueue(label: "studentQueue", attributes: .concurrent) // this makes function on background queue, lots of work for the computer to read data
       
        bgQueue.async {
        let fm = FileManager.default
        guard let url = self.persistentFileURL,
            fm.fileExists(atPath: url.path) else { return }
        do {
       let data = try Data(contentsOf: url)
            // convert data to Students objects
            let decoder = JSONDecoder()
            let students = try decoder.decode([Student].self, from: data)
            // store students objects in students array
            self.students = students
        } catch {
            print("Error loading student data: \(error)")
            completion(nil, error)
        }  // do catch to try the data if there is, or not catch the error
        }
}

    func filter(with trackType: TrackType, sortedBy sorter: SortOptions, completion: @escaping ([Student]) -> Void) {
        var updatedStudents: [Student]
        
        switch trackType {
        case .iOS:
            updatedStudents = students.filter { $0.course == "iOS"}
        case .Web:
                 updatedStudents = students.filter { $0.course == "Web"}
            case .UX:
                 updatedStudents = students.filter { $0.course == "UX"}
        default:
            //filter for none, or any other course
            updatedStudents = students
        }
        if sorter == .firstName {
            updatedStudents = updatedStudents.sorted { $0.firstName < $1.firstName }
        } else{
             updatedStudents = updatedStudents.sorted { $0.lastName < $1.lastName }
             }
            completion(updatedStudents)
        }

}
