//
//  PersistenceHelper.swift
//  Scheduler
//
//  Created by Alex Paul on 1/23/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

public enum DataPersistenceError: Error {
  case propertyListEncodingError(Error)
  case propertyListDecodingError(Error)
  case writingError(Error)
  case deletingError
  case noContentsAtPath(String)
}

//MARK: DataPersistence is not type constrained to only work with Codable types 01/24
//typealias Codable = Encodable & Decodable
typealias Writeable = Codable & Equatable
class DataPersistence<T: Writeable> {
  
  private let filename: String
  
  private var items: [T]
      
  public init(filename: String) {
    self.filename = filename
    self.items = []
  }
  
  private func saveItemsToDocumentsDirectory() throws {
    do {
      let url = FileManager.getPath(with: filename, for: .documentsDirectory)
      let data = try PropertyListEncoder().encode(items)
      try data.write(to: url, options: .atomic)
    } catch {
      throw DataPersistenceError.writingError(error)
    }
  }
  
  // Create
  public func createItem(_ item: T) throws {
    _ = try? loadItems()
    items.append(item)
    do {
      try saveItemsToDocumentsDirectory()
    } catch {
      throw DataPersistenceError.writingError(error)
    }
  }
  
  // Read
  public func loadItems() throws -> [T] {
    let path = FileManager.getPath(with: filename, for: .documentsDirectory).path
     if FileManager.default.fileExists(atPath: path) {
       if let data = FileManager.default.contents(atPath: path) {
         do {
           items = try PropertyListDecoder().decode([T].self, from: data)
         } catch {
          throw DataPersistenceError.propertyListDecodingError(error)
         }
       }
     }
    return items
  }
  
  // for re-ordering, and keeping date in sync
  public func synchronize(_ items: [T]) {
    self.items = items
    try? saveItemsToDocumentsDirectory()
  }
  
  //MARK: Update
    
    @discardableResult // silences the warning if the return value is not used by the caller
    // discardable result - its up the user to use or not use the return value
    public func update(_ oldItem: T, with newItem: T) -> Bool{
        if let index = items.firstIndex(of: oldItem) { // does the comparison is a = b is oldItem == currentItem
            // firstIndex and goes through it..
            // equatable allows for the comparison..
            let result = update(newItem, at: index)
            return result
        }
        return false
    }
    
    @discardableResult // silences the warning if the return value is not used
    public func update(_ item: T, at Index: Int) -> Bool{
        // arguements within differenciates should the name of the function be the same as another.
        items[Index] = item
        //save items to documents directory
        do {
            try saveItemsToDocumentsDirectory()
            return true
        }catch{
            return false
        }
    }
  
  // Delete
  public func deleteItem(at index: Int) throws {
    items.remove(at: index)
    do {
      try saveItemsToDocumentsDirectory()
    } catch {
      throw DataPersistenceError.deletingError
    }
  }
  
  public func hasItemBeenSaved(_ item: T) -> Bool {
    guard let items = try? loadItems() else {
      return false
    }
    self.items = items
    if let _ = self.items.firstIndex(of: item) {
      return true
    }
    return false
  }
  
  public func removeAll() {
    guard let loadedItems = try? loadItems() else {
      return
    }
    items = loadedItems
    items.removeAll()
    try? saveItemsToDocumentsDirectory()
  }
}
