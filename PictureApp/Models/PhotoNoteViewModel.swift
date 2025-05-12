//
//  PhotoNoteViewModel.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/7/25.
//
import Foundation
import SwiftUI

class PhotoNoteViewModel: ObservableObject {
    @Published var photoNotes: [PhotoNote] = []
    
    // For testing/preview purposes
    func addSampleData() {
        // This would typically include some sample photos,
        // but we're just adding placeholder data for now
        let note1 = PhotoNote(caption: "Beautiful sunset", imagePath: "", dateCreated: Date())
        let note2 = PhotoNote(caption: "My favorite coffee shop", imagePath: "", dateCreated: Date().addingTimeInterval(-86400)) // 1 day ago
        
        photoNotes.append(note1)
        photoNotes.append(note2)
    }
    
    // Further methods for CRUD operations and persistence will be added later
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
