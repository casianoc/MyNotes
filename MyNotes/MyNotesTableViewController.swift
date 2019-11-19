//
//  MyNotesTableViewController.swift
//  MyNotes
//
//  Created by Casiano, Cameron Joseph on 11/19/19.
//  Copyright © 2019 Casiano, Cameron Joseph. All rights reserved.
//

import UIKit
import CoreData

class MyNotesTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var notes = [Note] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadMyNotes()
        
        self.tableView.rowHeight = 84.0
    }
    
    // fetch shopping lists from core data
    func loadMyNotes(){
        
        // create an instance of a fetch request so that shopping lists can be fetched from core data
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        
        do {
            // use context to execute fetch request to fetch ShoppingLists from Core Data store the fethed ShoppingLists in our array
            notes = try context.fetch(request)
        } catch {
            print("Error fetching Notes from Core Data!")
        }
        
        //reloading the fetched data in the table view controller
        tableView.reloadData()
    }
    
    // saves lists to core data
    func saveMyNotes(){
        do {
            try context.save()
        } catch {
            print("Error saving Notes to Core Data")
        }
        
        // reload the data in the Table View Controller
        tableView.reloadData()
    }
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        // declare text fields variables for the input of the name store and date
        var titleTextField = UITextField()
        var typeTextField = UITextField()
        
        // create an Alert controller
        let alert = UIAlertController(title: "Add Note", message: "", preferredStyle: .alert)
        
        // define an aciton that will occur whrn the Add List button is pushed
        let action = UIAlertAction(title: "Add ", style: .default, handler: { (action) in
            
            // create an instance of a shoppingLists entity
            let newNote = Note(context: self.context)
            
            // get name, store, and date input by user and store them in ShoppingList entity
            newNote.title = titleTextField.text!
            newNote.type = typeTextField.text!
            
            // add shoppinglist entity to array
            self.notes.append(newNote)
            
            // save shoppingLists to CoreData
            self.saveMyNotes()
            })
            
            // disable the action that will let the user Add List
            action.isEnabled = false
            
            // define an aciton that will occur when the cancel button is pushed
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (cancelAction) in
                
            })
            
            // add actions into Alert Controller
            alert.addAction(action)
            alert.addAction(cancelAction)
            
            // add the text fields into the alert controller
            alert.addTextField(configurationHandler: { (field) in
                titleTextField = field
                titleTextField.placeholder = "Enter Title"
                titleTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
            })
            alert.addTextField(configurationHandler: { (field) in
                typeTextField = field
                typeTextField.placeholder = "Enter Type"
                typeTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
            })
            
            // display the AlertController
            present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath)

        // Configure the cell...
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title!
        cell.detailTextLabel!.numberOfLines = 0
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        note.date = formattedDate
        
        cell.detailTextLabel?.text = note.type! + "\n" + note.date!
        
        return cell
    }

    @objc func alertTextFieldDidChange (){
        
        // get reference to the Alert Controller
        let alertController = self.presentedViewController as! UIAlertController
        
        // get reference to the action that allows the user to add a shopping list
        let action = alertController.actions[0]
        
        // get references to the text in the textFields
        if let title = alertController.textFields![0].text, let type = alertController.textFields![1].text{
            
            // trim whitespace from the text
            let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
            let trimmedType = type.trimmingCharacters(in: .whitespaces)
            
            // check if the trimmed text isnt empty and if it isnt, we are going to enable the action that allows the user to add the shopping list
            if (!trimmedTitle.isEmpty && !trimmedType.isEmpty){
                action.isEnabled = true;
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
