//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 28.03.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private var taskList: [ToDoTask] = []
    private let cellID = "task"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchData()
    }
    @objc private func AddNewTaskButton() {
        addEditTask()
    }
    @objc private func addEditTask(taskToEdit: ToDoTask? = nil) {
        let title = taskToEdit == nil ? "New Task" : "Edit Task"
        showAlert(withTitle: title, andMessage: "What do you want to do?", taskToEdit: taskToEdit)
    }
    
    private func fetchData() {
        taskList = StorageManager.shared.fetchData()
        tableView.reloadData()
    }
    private func showAlert(withTitle title: String, andMessage message: String, taskToEdit: ToDoTask?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            if let taskToEdit = taskToEdit {
                textField.text = taskToEdit.title
            }
            textField.placeholder = "Task Name"
        }
        let okAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let inputText = alert.textFields?.first?.text, !inputText.isEmpty else { return }
            if let taskToEdit = taskToEdit {
                StorageManager.shared.editTask(taskToEdit, with: inputText)
            } else {
                StorageManager.shared.save(inputText)
            }
            fetchData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
}


// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskToEdit = taskList[indexPath.row]
        addEditTask(taskToEdit: taskToEdit)
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (_, _, completion) in
            let taskToDelete = taskList[indexPath.row]
            StorageManager.shared.deleteTask(taskToDelete)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completion(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = .milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(AddNewTaskButton)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}
