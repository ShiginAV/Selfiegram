//
//  SelfieDetailViewController.swift
//  Selfiegram
//
//  Created by Alexander on 23.10.2019.
//  Copyright © 2019 Alexander Shigin. All rights reserved.
//

import UIKit
import MapKit

class SelfieDetailViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet var selfieNameField: UITextField!
    @IBOutlet var dateCreatedLabel: UILabel!
    @IBOutlet var selfieImageView: UIImageView!
    @IBOutlet var mapView: MKMapView!
    
    //MARK: - Properties
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var selfie: Selfie? {
        didSet {
            configureViews()
        }
    }

    //MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    //MARK: - Methods
    func configureViews() {
        
        guard let selfie = selfie else { return }
        guard let selfieNameField = selfieNameField else { return }
        guard let dateCreatedLabel = dateCreatedLabel else { return }
        guard let selfieImageView = selfieImageView else { return }
        
        selfieNameField.text = selfie.title
        dateCreatedLabel.text = dateFormatter.string(from: selfie.created)
        selfieImageView.image = selfie.image
        
        if let position = selfie.position {
            mapView.setCenter(position.location.coordinate, animated: false)
            mapView.isHidden = false
        }
    }
    
    //MARK: - Actions
    @IBAction func doneButtonTapped(_ sender: UITextField) {
        
        selfieNameField.resignFirstResponder()
        
        guard let selfie = selfie else { return }
        guard let text = selfieNameField.text else { return }
        
        selfie.title = text
        try? SelfieStore.shared.save(selfie: selfie)
    }
    
    @IBAction func expandMap(_ sender: UITapGestureRecognizer) {
        
        if let coordinate = selfie?.position?.location {
            let options = [
                MKLaunchOptionsMapCenterKey : NSValue(mkCoordinate: coordinate.coordinate),
                MKLaunchOptionsMapTypeKey : NSNumber(value: MKMapType.mutedStandard.rawValue)
            ]
            let placemark = MKPlacemark(coordinate: coordinate.coordinate, addressDictionary: nil)
            let item = MKMapItem(placemark: placemark)
            item.name = selfie?.title
            item.openInMaps(launchOptions: options)
        }
    }
    
    @IBAction func sharedSelfie(_ sender: UIBarButtonItem) {
        
        guard let image = selfie?.image else {
            
            let alert = UIAlertController(title: "Error", message: "Unable to share selfie without an image", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
}

