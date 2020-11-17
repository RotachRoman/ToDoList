//
//  ToDoListTableViewController.swift
//  ToDoList
//
//  Created by Rotach Roman on 17.11.2020.
//

import UIKit
import CoreData

class ToDoListTableViewController: UIViewController, UITableViewDelegate {
    
    private let tableView = UITableView()
    private var tasks: [Tasks] = []
    
    override func loadView() {
        super.loadView()
        setupTable()
        setupConstraint()
        editNavigation()
        tableView.reloadData()
      }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        let context = getContext()
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - Setting Table View
    private func setupTable() {
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraint(){
        let safe = view.safeAreaLayoutGuide
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safe.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: safe.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: safe.rightAnchor).isActive = true
    }
    
    //MARK: - Setting Navigation
    private func editNavigation(){
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.title = "To-do list"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }
    
    @objc private func addItem(){
        let alertController = UIAlertController(title: "New task", message: "Add a new task", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Add", style: .default) { action in
            let textField = alertController.textFields?.first
            textField?.placeholder = "Add task"
            if let newTask = textField?.text {
                self.saveTask(withTitle: newTask)
                self.tableView.reloadData()
            }
        }
        alertController.addTextField{ _ in }
        let canacelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        
        alertController.addAction(saveAction)
        alertController.addAction(canacelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveTask(withTitle title: String){
        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context) else { return }
        
        let taskObject = Tasks(entity: entity, insertInto: context)
        taskObject.task = title
        
        do {
            try context.save()
            tasks.insert(taskObject, at: 0)
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Delete Element
    private func deleteElement(at index: Int){
        let context = getContext()
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        if let object = try? context.fetch(fetchRequest){
            context.delete(object[index])
        }
        do {
            try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Supporting funcs
    private func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}
    // MARK: - Table view data source

extension ToDoListTableViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.task
        return cell
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleteElement(at: indexPath.row)
            
        }
    }
}
