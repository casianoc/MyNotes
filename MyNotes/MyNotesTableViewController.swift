//
//  MyNotesTableViewController.swift
//  MyNotes
//
//  Created by Casiano, Cameron Joseph on 11/19/19.
//  Copyright © 2019 Casiano, Cameron Joseph. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _ = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath)

        var dateTextField = UITextField()
        
        let alert = UIAlertController(title: notes[indexPath.row].title, message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Change", style: .default, handler: { (action) in
            
            let note = self.notes[indexPath.row]
            
            note.date = dateTextField.text
            
            self.saveMyNotes()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default
            , handler: {(cancelAction) in
        })
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        alert.addTextField(configurationHandler: { (field) in
            dateTextField = field
            dateTextField.text = self.notes[indexPath.row].date
        })
        
        present(alert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func notesDoneNotification(){
        
        var done = true
        
            if notes.count > 0{
                done = false
            }
        
        if done == true{
            
            // create content object that controls the content and sound of the notification
            let content = UNMutableNotificationContent()
            content.title = "MyNotes"
            content.body = "All Notes Deleted"
            content.sound = UNNotificationSound.default
            
            // create trigger object that defines when notification will be sent and if it should be sent repeatedly
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            // create a rewuest object that is responsible for creating the notification
            let request = UNNotificationRequest(identifier: "notesIdentifier", content: content, trigger: trigger)
            
            // post the notification
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
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
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            let formattedDate = format.string(from: date)
            newNote.date = formattedDate
            
            
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
    
    func deleteNote (item: Note){
        context.delete(item)
        
        do {
            // use context to delete ShoppingList Item from Core Data
            try context.save()
        } catch {
            print("Error deleting Note from Core Data")
        }
        loadMyNotes()
        notesDoneNotification()
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
            let item = notes[indexPath.row]
            deleteNote(item: item)
    }


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
}
