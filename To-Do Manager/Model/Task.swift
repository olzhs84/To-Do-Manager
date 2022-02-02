//
//  Task.swift
//  To-Do Manager
//
//  Created by olzhs on 30.01.2022.
//

import Foundation


enum TaskPriority {
    case normal
    case impotant
}

enum TaskStatus: Int{
    case planned
    case completed
}

protocol TaskProtocol {
    var title: String { get set }
    var type: TaskPriority { get set }
    var status: TaskStatus { get set }
}

struct Task: TaskProtocol {
    var title: String
    var type: TaskPriority
    var status: TaskStatus
    
}


