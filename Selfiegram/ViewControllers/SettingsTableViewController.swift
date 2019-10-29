//
//  SettingsTableViewController.swift
//  Selfiegram
//
//  Created by Alexander on 28.10.2019.
//  Copyright © 2019 Alexander Shigin. All rights reserved.
//

import UIKit
import UserNotifications

enum SettingsKey: String {
    case saveLocation
}

class SettingsTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet var locationSwitch: UISwitch!
    @IBOutlet var reminderSwitch: UISwitch!
    
    //MARK: - Properties
    private let notificationId = "SelfiegramReminder"
    
    //MARK: - ViewController methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationSwitch.isOn = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        updateReminderSwitch()
    }
    
    //MARK: - Methods
    func addNotificationRequest() {
        
        let current = UNUserNotificationCenter.current()
        
        current.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Take a selfie!"
        
        var components = DateComponents()
        components.setValue(10, for: .hour)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: notificationId, content: content, trigger: trigger)
        
        current.add(request) { error in
            self.updateReminderSwitch()
        }
    }
    
    func updateReminderSwitch() {
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                    let active = requests.filter({ $0.identifier == self.notificationId }).count > 0
                    self.updateReminderUI(enabled: true, active: active)
                }
                
            case .notDetermined:
                self.updateReminderUI(enabled: true, active: false)
                
            case .denied:
                self.updateReminderUI(enabled: false, active: false)
                
            case .provisional:
                self.updateReminderUI(enabled: true, active: false)
                
            @unknown default:
                self.updateReminderUI(enabled: false, active: false)
            }
        }
    }
    
    private func updateReminderUI(enabled: Bool, active: Bool) {
        
        OperationQueue.main.addOperation {
            self.reminderSwitch.isEnabled = enabled
            self.reminderSwitch.isOn = active
        }
    }
    
    //MARK: - Actions
    @IBAction func locationSwitchToggled(_ sender: UISwitch) {
        
        UserDefaults.standard.set(locationSwitch.isOn, forKey: SettingsKey.saveLocation.rawValue)
    }
    
    @IBAction func reminderSwitchToggled(_ sender: UISwitch) {
        
        let current = UNUserNotificationCenter.current()
        
        switch reminderSwitch.isOn {
        case true:
            let notificationOptions: UNAuthorizationOptions = [.alert]
            current.requestAuthorization(options: notificationOptions) { (granted, error) in
                if granted {
                    self.addNotificationRequest()
                }
                self.updateReminderSwitch()
            }
            
        case false:
            current.removeAllPendingNotificationRequests()
        }
    }
    
}
