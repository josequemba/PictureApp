//
//  PhotoNoteViewModel.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/7/25.
//
import Foundation
import SwiftUI

class PhotoNoteViewModel: ObservableObject {
    @Published var photoNotes: [PhotoNote] = [] {
        didSet {
            saveNotes()
        }
    }
    
    private let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("photoNotes.json")
    
    init() {
        loadNotes()
    }
    
    // Load notes from file system
    func loadNotes() {
        do {
            let data = try Data(contentsOf: savePath)
            photoNotes = try JSONDecoder().decode([PhotoNote].self, from: data)
        } catch {
            // If loading fails, we'll just start with an empty array
            photoNotes = []
            print("Error loading notes: \(error)")
        }
    }
    
    // Save notes to file system
    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(photoNotes)
            try data.write(to: savePath)
        } catch {
            print("Error saving notes: \(error)")
        }
    }
    
    // Add a method to delete a note
    func deleteNote(at offsets: IndexSet) {
        // Delete image files for the notes being removed
        for index in offsets {
            let note = photoNotes[index]
            deleteImageFile(imagePath: note.imagePath)
        }
        
        // Remove the notes from the array
        photoNotes.remove(atOffsets: offsets)
    }
    
    // Delete an image file from the file system
    private func deleteImageFile(imagePath: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(imagePath)
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    // For testing/preview purposes
    func addSampleData() {
        // Only add sample data if there are no existing notes
        if photoNotes.isEmpty {
            loadSampleImages()
        }
    }
}

extension PhotoNoteViewModel {
    func loadSampleImages() {
        // Create sample images
        let size = CGSize(width: 300, height: 200)
        
        // Create first sample image - blue gradient
        let renderer1 = UIGraphicsImageRenderer(size: size)
        let sampleImage1 = renderer1.image { ctx in
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor.blue.cgColor, UIColor.cyan.cgColor] as CFArray,
                locations: [0, 1]
            )!
            ctx.cgContext.drawLinearGradient(gradient,
               start: .zero,
               end: CGPoint(x: 0, y: size.height),
               options: [])
            UIColor.white.setFill()
            ctx.cgContext.fill(CGRect(x: 120, y: 80, width: 60, height: 40))
        }
        
        // Create second sample image - red gradient
        let renderer2 = UIGraphicsImageRenderer(size: size)
        let sampleImage2 = renderer2.image { ctx in
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [UIColor.red.cgColor, UIColor.orange.cgColor] as CFArray,
                locations: [0, 1]
            )!
            ctx.cgContext.drawLinearGradient(gradient,
               start: .zero,
               end: CGPoint(x: 0, y: size.height),
               options: [])
            UIColor.white.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 120, y: 80, width: 60, height: 40))
        }
        
        // Save images and create sample notes
        if let path1 = PhotoNote.saveImage(sampleImage1) {
            let note1 = PhotoNote(caption: "Blue gradient with rectangle", imagePath: path1, dateCreated: Date())
            photoNotes.append(note1)
        }
        
        if let path2 = PhotoNote.saveImage(sampleImage2) {
            let note2 = PhotoNote(caption: "Red gradient with circle", imagePath: path2, dateCreated: Date().addingTimeInterval(-86400))
            photoNotes.append(note2)
        }
    }
}

extension PhotoNoteViewModel {
    // Enhanced version of loadNotes with better error handling
    func loadNotesWithErrorHandling() {
        do {
            guard FileManager.default.fileExists(atPath: savePath.path) else {
                print("Notes file does not exist yet, starting with empty array")
                photoNotes = []
                return
            }
            
            let data = try Data(contentsOf: savePath)
            
            // Validate data before decoding
            guard !data.isEmpty else {
                print("Notes file is empty, starting with empty array")
                photoNotes = []
                return
            }
            
            // Try to decode the data
            do {
                photoNotes = try JSONDecoder().decode([PhotoNote].self, from: data)
            } catch {
                print("Error decoding notes: \(error)")
                // Try to recover corrupted data
                if let backupPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("photoNotes_backup.json"),
                   FileManager.default.fileExists(atPath: backupPath.path) {
                    // Try to load from backup
                    do {
                        let backupData = try Data(contentsOf: backupPath)
                        photoNotes = try JSONDecoder().decode([PhotoNote].self, from: backupData)
                        print("Recovered from backup")
                    } catch {
                        print("Could not recover from backup: \(error)")
                        photoNotes = []
                    }
                } else {
                    photoNotes = []
                }
            }
        } catch {
            print("Error loading notes: \(error)")
            photoNotes = []
        }
    }
    
    // Enhanced version of saveNotes with backup creation
    func saveNotesWithBackup() {
        do {
            let data = try JSONEncoder().encode(photoNotes)
            
            // First create a backup of the current file if it exists
            if FileManager.default.fileExists(atPath: savePath.path) {
                let backupPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("photoNotes_backup.json")
                try? FileManager.default.copyItem(at: savePath, to: backupPath)
            }
            
            // Now save the new data
            try data.write(to: savePath)
        } catch {
            print("Error saving notes: \(error)")
        }
    }
}
