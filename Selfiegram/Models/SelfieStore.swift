//
//  SelfieStore.swift
//  Selfiegram
//
//  Created by Alexander on 24.10.2019.
//  Copyright © 2019 Alexander Shigin. All rights reserved.
//

import Foundation
import UIKit.UIImage
import CoreLocation.CLLocation

class Selfie: Codable {
    
    struct Coordinate: Codable, Equatable {
        
        var latitude: Double
        var longitude: Double
        var location: CLLocation {
            get {
                return CLLocation(latitude: latitude, longitude: longitude)
            }
            
            set {
                latitude = newValue.coordinate.latitude
                longitude = newValue.coordinate.longitude
            }
        }
        
        init(location: CLLocation) {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
        
        public static func == (lhs: Selfie.Coordinate, rhs: Selfie.Coordinate) -> Bool {
            return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
        }
    }
    
    let created: Date
    let id: UUID
    var title = "New Selfie!"
    var image: UIImage? {
        get {
            return SelfieStore.shared.getImage(id: self.id)
        }
        set {
            try? SelfieStore.shared.setImage(id: self.id, image: newValue)
        }
    }
    var position: Coordinate?
    
    init(title: String) {
        self.title = title
        self.created = Date()
        self.id = UUID()
    }
}

enum SelfieStoreError: Error {
    case cannotSaveImage(UIImage?)
}

final class SelfieStore {
    
    //MARK: - Properties
    static let shared = SelfieStore()
    private var imageCashe: [UUID : UIImage] = [:]
    var documentsFolder: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    }
    
    //MARK: - Methods
    func getImage(id: UUID) -> UIImage? {
        
        if let image = imageCashe[id] {
            return image
        }
        
        let imageURL = documentsFolder.appendingPathComponent("\(id.uuidString)-image.jpg")
        
        guard let imageData = try? Data(contentsOf: imageURL) else { return nil }
        guard let image = UIImage(data: imageData) else { return nil }
        
        imageCashe[id] = image
        
        return image
    }
    
    func setImage(id: UUID, image: UIImage?) throws {
        
        let destinationURL = documentsFolder.appendingPathComponent("\(id.uuidString)-image.jpg")
        
        if let image = image {
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                throw SelfieStoreError.cannotSaveImage(image)
            }
            try data.write(to: destinationURL)
        } else {
            try FileManager.default.removeItem(at: destinationURL)
        }
        imageCashe[id] = image
    }
    
    func listSelfies() throws -> [Selfie] {
        
        let contents = try FileManager.default.contentsOfDirectory(at: documentsFolder, includingPropertiesForKeys: nil)
        
        return try contents.filter { $0.pathExtension == "json" }.map { try Data(contentsOf: $0) }.map { try JSONDecoder().decode(Selfie.self, from: $0) }
    }
    
    func delete(selfie: Selfie) throws {
        
        try delete(id: selfie.id)
    }
    
    func delete(id: UUID) throws {
        
        let selfieDataFileName = "\(id.uuidString).json"
        let imageFileName = "\(id.uuidString)-image.jpg"
        
        let selfieDataURL = documentsFolder.appendingPathComponent(selfieDataFileName)
        let imageURL = documentsFolder.appendingPathComponent(imageFileName)
        
        if FileManager.default.fileExists(atPath: selfieDataURL.path) {
            try FileManager.default.removeItem(at: selfieDataURL)
        }
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            try FileManager.default.removeItem(at: imageURL)
        }
        
        imageCashe[id] = nil
    }
    
    func load(id: UUID) -> Selfie? {
        
        let dataURL = documentsFolder.appendingPathComponent("\(id.uuidString).json")
        
        if let data = try? Data(contentsOf: dataURL),
           let selfie = try? JSONDecoder().decode(Selfie.self, from: data) {
            return selfie
        } else {
            return nil
        }
    }
    
    func save(selfie: Selfie) throws {
        
        let selfieData = try JSONEncoder().encode(selfie)
        let destinationURL = documentsFolder.appendingPathComponent("\(selfie.id.uuidString).json")
        try selfieData.write(to: destinationURL)
    }
}
