//
//  PhotoNote.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/7/25.
//
import Foundation
import SwiftUI

struct PhotoNote: Identifiable, Codable, Equatable {
    var id: UUID
    var caption: String
    var imagePath: String
    var dateCreated: Date
    
    // Computed property to load the image from storage
    // Not included in Codable as it's computed
    var image: UIImage? {
        get {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let imageURL = documentsDirectory.appendingPathComponent(imagePath)
                if let imageData = try? Data(contentsOf: imageURL) {
                    return UIImage(data: imageData)
                }
            }
            return nil
        }
    }
    
    // Initializer with default values
    init(id: UUID = UUID(), caption: String = "", imagePath: String = "", dateCreated: Date = Date()) {
        self.id = id
        self.caption = caption
        self.imagePath = imagePath
        self.dateCreated = dateCreated
    }
    
    // Function to save an image to the file system and return the path
    static func saveImage(_ uiImage: UIImage) -> String? {
        guard let imageData = uiImage.jpegData(compressionQuality: 0.7) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imageURL = documentsDirectory.appendingPathComponent(filename)
            do {
                try imageData.write(to: imageURL)
                return filename
            } catch {
                print("Error saving image: \(error)")
                return nil
            }
        }
        return nil
    }
}

