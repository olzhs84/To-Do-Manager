//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by olzhs on 30.01.2022.
//

import UIKit

class TaskListController: UITableViewController {

    var tasksStorage: TasksStorageProtocol = TaskStorage()
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
        didSet {
            for (taskGroupPriority, taskGroup) in tasks {
                tasks[taskGroupPriority] = taskGroup.sorted { task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            if tasks.count > 0 {
                var savingArray: [TaskProtocol] = []
                tasks.forEach { _, value in
                    savingArray += value
                }
                tasksStorage.saveTasks(savingArray)
            }

        }
    }
    var sectionsTypesPosition: [TaskPriority] = [.impotant, .normal]
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadTasks()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }

        tasksCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    private func loadTasks() {
        sectionsTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        tasksStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let taskType = sectionsTypesPosition[section]
        
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        
        return currentTasksType.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)

        // Configure the cell...

        return getConfiguredTaskCell_constraints(for: indexPath)
    }
    
    
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let taskType = sectionsTypesPosition[indexPath.section]
        
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        textLabel?.text = currentTask.title
        
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
            
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let taskType = sectionsTypesPosition[section]
        if taskType == .impotant {
            title = "????????????"
        } else if taskType == .normal {
            title = "??????????????"
        }

        return title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let taskType = sectionsTypesPosition[indexPath.section]
        
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        guard tasks[taskType]![indexPath.row].status == .planned else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        tasks[taskType]![indexPath.row].status = .completed
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskType = sectionsTypesPosition[indexPath.section]
        
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }

        
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "???? ??????????????????") {
            _,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        let actionEditInstance = UIContextualAction(style: .normal, title: "????????????????") {
            _,_,_ in
            
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                
                if type != taskType {
                    tasks[taskType]!.remove(at: indexPath.row)
                    tasks[type]?.append(editedTask)
                } else {
                    tasks[taskType]![indexPath.row] = editedTask
                }
                
                
                tableView.reloadData()
            }
            
            self.navigationController?.pushViewController(editScreen, animated: true)
//            self.tasks[taskType]![indexPath.row].status = .planned
//            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        actionEditInstance.backgroundColor = .darkGray
        
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance, actionSwipeInstance])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
        }
        
        
        return actionsConfiguration
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let taskType = sectionsTypesPosition[indexPath.section]
            
            tasks[taskType]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let taskTypeFrom = sectionsTypesPosition[sourceIndexPath.section]
        let taskTypeTo = sectionsTypesPosition[destinationIndexPath.section]
        
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        
        tableView.reloadData()
    }
    

    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }


   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
