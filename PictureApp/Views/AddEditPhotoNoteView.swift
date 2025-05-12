//
//  AddEditPhotoNoteView.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/9/25.
//
import SwiftUI

struct AddEditPhotoNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PhotoNoteViewModel
    @State private var caption = ""
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    @State private var isShowingSourceSelector = false
    
    var editingNote: PhotoNote?
    
    init(viewModel: PhotoNoteViewModel, editingNote: PhotoNote? = nil) {
        self.viewModel = viewModel
        self.editingNote = editingNote
        
        if let note = editingNote {
            _caption = State(initialValue: note.caption)
            _selectedImage = State(initialValue: note.image)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photo")) {
                    VStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .clipped()
                                .cornerRadius(8)
                                .padding()
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(
                                    VStack {
                                        Image(systemName: "photo")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("Tap to add photo")
                                            .foregroundColor(.gray)
                                            .padding(.top, 8)
                                    }
                                )
                                .padding()
                        }
                        
                        Button(action: {
                            isShowingSourceSelector = true
                        }) {
                            Text(selectedImage == nil ? "Add Photo" : "Change Photo")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                }
                
                Section(header: Text("Caption")) {
                    TextField("Enter a caption", text: $caption)
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle(editingNote == nil ? "Add New Note" : "Edit Note")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(selectedImage == nil || caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .actionSheet(isPresented: $isShowingSourceSelector) {
                ActionSheet(
                    title: Text("Select Photo Source"),
                    buttons: [
                        .default(Text("Camera")) {
                            source = .camera
                            isShowingImagePicker = true
                        },
                        .default(Text("Photo Library")) {
                            source = .photoLibrary
                            isShowingImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: source)
            }
        }
    }
}

extension AddEditPhotoNoteView {
    func saveNote() {
        guard let image = selectedImage else { return }
        
        // Save the image to the file system
        if let imagePath = PhotoNote.saveImage(image) {
            // If editing an existing note
            if let editingNote = editingNote, let index = viewModel.photoNotes.firstIndex(where: { $0.id == editingNote.id }) {
                // Delete the old image file if it's different
                if editingNote.imagePath != imagePath {
                    deleteImageFile(imagePath: editingNote.imagePath)
                }
                
                // Update the existing note
                var updatedNote = editingNote
                updatedNote.caption = caption
                updatedNote.imagePath = imagePath
                viewModel.photoNotes[index] = updatedNote
            } else {
                // Create a new note
                let newNote = PhotoNote(caption: caption, imagePath: imagePath)
                viewModel.photoNotes.append(newNote)
            }
            
            // Signal to the view model that data has changed
            viewModel.objectWillChange.send()
        }
    }
    
    private func deleteImageFile(imagePath: String) {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(imagePath)
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}
