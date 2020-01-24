//
//  CreateEventController.swift
//  Scheduler
//
//  Created by Alex Paul on 11/20/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

enum EventState {
  case newEvent
  case existingEvent
}

class CreateEventController: UIViewController {
  
  @IBOutlet weak var eventNameTextField: UITextField!
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var eventButton: UIButton!
  
  public var event: Event? 
  
  // private for setting
  // public for getting
     //MARK: the event is public for reading but you can not change it outside the createeventcontroller // public = you can see it private = you can not change it  01/23
  public private(set) var eventState = EventState.newEvent
   
  
  override func viewDidLoad() { // this gets called once on the initial load of ciew controller
    super.viewDidLoad()
    
    // set the view controller as the delegate for the text field
    eventNameTextField.delegate = self
    updateUI()
  }
    
    override func viewWillAppear(_ animated: Bool) { // everytime vc is on screen
        super.viewWillAppear(true)
    }
    override func viewWillDisappear(_ animated: Bool) { // everytime you exist the vc
        super.viewWillDisappear(true)
    }
   
  private func updateUI() {
    if let event = event { //MARK: Coming from didSelectRowAt (existing event) 01/23
      self.event = event
      datePicker.date = event.date
      eventNameTextField.text = event.name
      eventButton.setTitle("Update Event", for: .normal)
      eventState = .existingEvent
    } else {
      // instantiate a default value for event
      event = Event(date: Date(), name: "") // Date()
      eventState = .newEvent
    }
  }
  
  @IBAction func datePickerChanged(sender: UIDatePicker) {
    // update date of event
    event?.date = sender.date
  }
}

extension CreateEventController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    // dismiss the keyboard
    textField.resignFirstResponder()
    
    // update name of event
    event?.name = textField.text ?? "no event name"
    
    return true
  }
}
