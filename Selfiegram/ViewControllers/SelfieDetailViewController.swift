//
//  SelfieDetailViewController.swift
//  Selfiegram
//
//  Created by Alexander on 23.10.2019.
//  Copyright © 2019 Alexander Shigin. All rights reserved.
//

import UIKit

class SelfieDetailViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet var selfieNameField: UITextField!
    @IBOutlet var dateCreatedLabel: UILabel!
    @IBOutlet var selfieImageView: UIImageView!
    
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
            configureView()
        }
    }

    //MARK: - ViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    //MARK: - Methods
    func configureView() {
        
        guard let selfie = selfie else { return }
        guard let selfieNameField = selfieNameField else { return }
        guard let dateCreatedLabel = dateCreatedLabel else { return }
        guard let selfieImageView = selfieImageView else { return }
        
        selfieNameField.text = selfie.title
        dateCreatedLabel.text = dateFormatter.string(from: selfie.created)
        selfieImageView.image = selfie.image
    }
    
    //MARK: - Actions
    @IBAction func doneButtonTapped(_ sender: UITextField) {
        
        selfieNameField.resignFirstResponder()
        
        guard let selfie = selfie else { return }
        guard let text = selfieNameField.text else { return }
        
        selfie.title = text
        try? SelfieStore.shared.save(selfie: selfie)
    }
}

