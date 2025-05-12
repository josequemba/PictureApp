//
//  PhotoNoteListView.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/8/25.
//
import SwiftUI

struct PhotoNoteListView: View {
    @ObservedObject var viewModel: PhotoNoteViewModel
    @State private var isAddingNewNote = false
    @State private var editingNote: PhotoNote?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.photoNotes) { note in
                    PhotoNoteRow(note: note)
                        .onTapGesture {
                            editingNote = note
                        }
                }
            }
            .navigationTitle("Photo Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingNewNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                if viewModel.photoNotes.isEmpty {
                    viewModel.loadSampleImages()
                }
            }
            .sheet(isPresented: $isAddingNewNote) {
                AddEditPhotoNoteView(viewModel: viewModel)
            }
            .sheet(item: $editingNote) { note in
                AddEditPhotoNoteView(viewModel: viewModel, editingNote: note)
            }
        }
    }
}

struct PhotoNoteRow: View {
    let note: PhotoNote
    
    var body: some View {
        HStack {
            if let image = note.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading) {
                Text(note.caption)
                    .font(.headline)
                
                Text(note.dateCreated, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 4)
    }
}
