//
//  MasterViewController.swift
//  BWSwipeTableCellExample
//
//  Created by Kyle Newsome on 2015-11-12.
//  Copyright © 2015 Kyle Newsome. All rights reserved.
//

import UIKit
import CoreData
import BWSwipeRevealCell

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, SwipeRevealCellDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func insertNewObject(_ sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        
        //Create one of each type
        for i in 0..<3 {
            let newManagedObject = NSEntityDescription.insertNewObject(forEntityName: entity.name!, into: context)
            newManagedObject.setValue(i, forKey: "type")
        }
        
        do {
            try context.save()
        } catch {
            abort()
        }
    }
    
    func removeObjectAtIndexPath(_ indexPath:IndexPath) {
        let context = self.fetchedResultsController.managedObjectContext
        //Deleting objects regardless of done/delete for the purpose of this example
        context.delete(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
        do {
            try context.save()
        } catch {
            abort()
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let object = self.fetchedResultsController.object(at: indexPath)
        let swipeCell:SwipeRevealCell = cell as! SwipeRevealCell
        
        swipeCell.bgViewLeftImage = UIImage(named:"Done")!.withRenderingMode(.alwaysTemplate)
        swipeCell.bgViewLeftColor = UIColor.green()
        
        swipeCell.bgViewRightImage = UIImage(named:"Delete")!.withRenderingMode(.alwaysTemplate)
        swipeCell.bgViewRightColor = UIColor.red()
        
        let type = object.value(forKey: "type") as! Int
        
        let swipeConfig: SwipeHandlerConfiguration
        switch type {
        case 0:
            swipeCell.textLabel?.text = "Swipe Through"
            swipeConfig = .swipeThrough()
        case 1:
            swipeCell.textLabel?.text = "Spring Release"
            swipeConfig = .springRelease()
        case 2:
            swipeCell.textLabel?.text = "Sliding Door"
            swipeConfig = .slidingDoor()
        default:
            return
            
        }
        
        swipeCell.swipeHandler.config = swipeConfig
        swipeCell.delegate = self
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<NSManagedObject> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest:NSFetchRequest<NSManagedObject> = NSFetchRequest()
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: self.managedObjectContext!)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        let sortDescriptor = SortDescriptor(key: "type", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<NSManagedObject>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            self.configureCell(tableView.cellForRow(at: indexPath!)!, atIndexPath: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Reveal Cell Delegate
    
    func swipeCellWillRelease(_ cell: SwipeCell) {
        print("Swipe Cell Will Release")
        if cell.swipeHandler.state != .normal && cell.swipeHandler.config.name != "SlidingDoor" {
            let indexPath: IndexPath = tableView.indexPath(for: cell)!
            self.removeObjectAtIndexPath(indexPath)
        }
    }
    
    func swipeRevealCell(_ cell: SwipeCell, activatedAction isActionLeft: Bool) {
        print("Swipe Cell Activated Action")
        let indexPath: IndexPath = tableView.indexPath(for: cell)!
        self.removeObjectAtIndexPath(indexPath)
    }
    
    func swipeCellDidChangeState(_ cell: SwipeCell) {
        print("Swipe Cell Did Change State")
        if cell.swipeHandler.state != .normal {
            print("-> Cell Passed Threshold")
        } else {
            print("-> Cell Returned to Normal")
        }
    }
    
    func swipeCellDidCompleteRelease(_ cell: SwipeCell) {
        print("Swipe Cell Did Complete Release")
    }
    
    func swipeCellDidSwipe(_ cell: SwipeCell) {
        print("Swipe Cell Did Swipe")
    }
    
    func swipeCellDidStartSwiping(_ cell: SwipeCell) {
        print("Swipe Cell Did Start Swiping")
    }
    
}

