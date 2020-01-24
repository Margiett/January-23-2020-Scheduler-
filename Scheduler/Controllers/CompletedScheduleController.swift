//
//  CompletedScheduleController.swift
//  Scheduler
//
//  Created by Alex Paul on 1/18/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class CompletedScheduleController: UIViewController {
    
  private var completedEvents = [Event]() {
    didSet {
        guard let tableView = tableView else { return }
        tableView.reloadData()
    }
  }
    private let completedEventPersistence = DataPersistence<Event>(filename: "completedEvents.plist")
    public var dataPersistence: DataPersistence<Event>! // "schedule.plist"
    
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    loadCompletedItems()
  }
  
  private func loadCompletedItems() {
    // we need to write code here this is connected with the didDeleteItem extention delegate
    do {
        completedEvents = try completedEventPersistence.loadItems()
    } catch {
        print("error loading completed events \(error)")
    }
  }
}

extension CompletedScheduleController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return completedEvents.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
    let event = completedEvents[indexPath.row]
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = event.date.description
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      // remove from data soruce
      completedEvents.remove(at: indexPath.row)
      
      // TODO: persist change
        //MARK: this is making sure when you delete something from the completed tab it stays deleted forever !!
        do {
            try completedEventPersistence.deleteItem(at: indexPath.row)
        } catch {
            print("error delete completed task: \(error)")
            print("deleted forever")
        }
    }
  }
}
// site for delegations 
//https://gist.github.com/alexpaul/978c561846b0c619ba7b01b1cfb0d9e7
extension CompletedScheduleController: DataPersistenceDelegate {
    func didDeleteItem<T>(_ persistenceHelper: DataPersistence<T>, item: T) where T : Decodable, T : Encodable, T : Equatable {
        print("item was deleted")
        
        
        //MARK: Persist item to completed event persistence
        do{
            let event = item as! Event
         try completedEventPersistence.createItem(event)
        } catch {
            print("error creating item: \(error)")
        }
        //MARK: reload completed items array
        loadCompletedItems()
    }
}

