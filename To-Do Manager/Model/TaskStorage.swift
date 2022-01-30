//
//  TaskStorage.swift
//  To-Do Manager
//
//  Created by olzhs on 30.01.2022.
//

import Foundation

protocol TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks:[TaskProtocol])
}

class TaskStorage: TasksStorageProtocol {
    func loadTasks() -> [TaskProtocol] {
        let testTasks: [TaskProtocol] = [
        Task(title: "Купить хлеб", type: .normal, status: .planned),
        Task(title: "Помыть кота", type: .impotant, status: .planned),
        Task(title: "Отдать долг Арнольду", type: .impotant, status: .completed),
        Task(title: "Купить новый пылесос", type: .normal, status: .completed),
        Task(title: "Подарить цветы супруге", type: .impotant, status: .planned),
        Task(title: "Позвонить родителям", type: .impotant, status: .planned)]
        return testTasks
    }
    func saveTasks(_ tasks: [TaskProtocol]) {
        
    }
}


