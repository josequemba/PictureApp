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
    @State private var isShowingDeleteConfirmation = false
    
    var editingNote: PhotoNote?
    
    // Initialize with the note being edited, if any
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
                    VStack(spacing: 0) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                                .shadow(radius: 3)
                                .padding(.vertical)
                                .transition(.opacity)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 200)
                                    .shadow(radius: 1)
                                
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue.opacity(0.8))
                                    
                                    Text("Tap to add photo")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical)
                            .onTapGesture {
                                isShowingSourceSelector = true
                            }
                        }
                        
                        Button(action: {
                            isShowingSourceSelector = true
                        }) {
                            HStack {
                                Image(systemName: selectedImage == nil ? "camera.fill" : "arrow.triangle.2.circlepath")
                                Text(selectedImage == nil ? "Add Photo" : "Change Photo")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .tint(.blue)
                        .padding(.bottom, 8)
                    }
                }
                
                Section(header: Text("Caption")) {
                    TextField("Enter a caption for your photo", text: $caption)
                        .padding(.vertical, 8)
                        .onChange(of: caption) {
                            // Trim whitespace as user types
                            if caption.trimmingCharacters(in: .whitespacesAndNewlines) != caption {
                                caption = caption.trimmingCharacters(in: .whitespacesAndNewlines)
                            }
                        }
                }
                
                if editingNote != nil {
                    Section {
                        Button(role: .destructive) {
                            isShowingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Photo Note")
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
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
                    .bold()
                }
            }
            .actionSheet(isPresented: $isShowingSourceSelector) {
                ActionSheet(
                    title: Text("Select Photo Source"),
                    message: Text("Choose where you want to get your photo from"),
                    buttons: [
                        .default(Text("Take Photo")) {
                            source = .camera
                            isShowingImagePicker = true
                        },
                        .default(Text("Choose from Library")) {
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
            .alert("Delete Photo Note", isPresented: $isShowingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let note = editingNote, let index = viewModel.photoNotes.firstIndex(where: { $0.id == note.id }) {
                        viewModel.deleteNote(at: IndexSet(integer: index))
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this photo note? This action cannot be undone.")
            }
            .animation(.default, value: selectedImage != nil)
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
