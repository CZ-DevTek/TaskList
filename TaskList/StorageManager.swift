//
//  StorageManager.swift
//  TaskList
//
//  Created by Carlos Garcia Perez on 30/3/24.
//

import UIKit
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private init() {}
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func fetchData() -> [ToDoTask] {
        let fetchRequest = ToDoTask.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error)
            return []
        }
    }
    func save(_ taskName: String) {
        let context = persistentContainer.viewContext
        let task = ToDoTask(context: context)
        task.title = taskName
        saveContext()
    }
    func editTask(_ task: ToDoTask, with newName: String) {
        task.title = newName
        saveContext()
    }
    func deleteTask(_ task: ToDoTask) {
        let context = persistentContainer.viewContext
        context.delete(task)
        saveContext()
    }
}
