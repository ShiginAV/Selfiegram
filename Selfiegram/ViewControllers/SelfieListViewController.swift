//
//  SelfieListViewController.swift
//  Selfiegram
//
//  Created by Alexander on 23.10.2019.
//  Copyright © 2019 Alexander Shigin. All rights reserved.
//

import UIKit
import CoreLocation

class SelfieListViewController: UITableViewController {

    //MARK: - Properties
    var detailViewController: SelfieDetailViewController? = nil
    var selfies = [Selfie]()
    var lastLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    let timeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    lazy var addSelfieBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewSelfie))
    }()

    //MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationItem()
        loadSelfies()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? SelfieDetailViewController
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "showDetail" else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let navigationController = segue.destination as? UINavigationController else { return }
        guard let detailController = navigationController.topViewController as? SelfieDetailViewController else { return }
        
        detailController.selfie = selfies[indexPath.row]
        detailController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        detailController.navigationItem.leftItemsSupplementBackButton = true
    }
    
    //MARK: - Methods
    func setupNavigationItem() {
        navigationItem.rightBarButtonItem = addSelfieBarButtonItem
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadSelfies() {
        do {
            selfies = try SelfieStore.shared.listSelfies().sorted(by: { $0.created > $1.created })
        } catch let error {
            showError(message: "Failed to load selfies: \(error.localizedDescription)")
        }
    }
    
    private func getLocation() {
        let shouldGetLocation = UserDefaults.standard.bool(forKey: SettingsKey.saveLocation.rawValue)
        
        if shouldGetLocation {
            switch CLLocationManager.authorizationStatus() {
            case .denied, .restricted:
                return
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                break
            }
            locationManager.requestLocation()
        }
    }
    
    @objc func createNewSelfie() {
        
        lastLocation = nil
        
        getLocation()
        
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .front
            }
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func newSelfieTaken(image: UIImage) {
        
        let newSelfie = Selfie(title: "New Selfie")
        newSelfie.image = image
        
        if let location = lastLocation {
            newSelfie.position = Selfie.Coordinate(location: location)
        }
        
        do {
            try SelfieStore.shared.save(selfie: newSelfie)
        } catch let error {
            showError(message: "Can't save photo: \(error)")
            return
        }
        
        selfies.insert(newSelfie, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selfies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let selfie = selfies[indexPath.row]
        
        //configure cell
        cell.textLabel!.text = selfie.title
        if let interval = timeIntervalFormatter.string(from: selfie.created, to: Date()) {
            cell.detailTextLabel?.text = "\(interval) ago"
        } else {
            cell.detailTextLabel?.text = nil
        }
        cell.imageView?.image = selfie.image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let selfieToRemove = selfies[indexPath.row]
            
            do {
                try SelfieStore.shared.delete(selfie: selfieToRemove)
                selfies.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                showError(message: "Failed to delete \(selfieToRemove.title).")
            }
        }
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SelfieListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage ?? info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            showError(message: "Couldn't get a picture from the image picker!")
            return
        }
        newSelfieTaken(image: image)
        
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - CLLocationManagerDelegate
extension SelfieListViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lastLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        showError(message: error.localizedDescription)
    }
}
