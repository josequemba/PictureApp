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
