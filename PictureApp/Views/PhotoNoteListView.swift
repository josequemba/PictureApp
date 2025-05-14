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
    @State private var showEmptyState = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main list view
                List {
                    ForEach(viewModel.photoNotes) { note in
                        PhotoNoteRow(note: note)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingNote = note
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let index = viewModel.photoNotes.firstIndex(where: { $0.id == note.id }) {
                                        viewModel.deleteNote(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete(perform: deleteNotes)
                }
                .listStyle(InsetGroupedListStyle())
                .animation(.default, value: viewModel.photoNotes)
                
                // Empty state view
                if viewModel.photoNotes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Text("No Photo Notes Yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Tap + to add your first photo note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            isAddingNewNote = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Photo Note")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
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
                // We'll show sample data only if there are no existing notes
                if viewModel.photoNotes.isEmpty {
                    // Check if it's the first launch
                    let defaults = UserDefaults.standard
                    if !defaults.bool(forKey: "didLaunchBefore") {
                        viewModel.loadSampleImages()
                        defaults.set(true, forKey: "didLaunchBefore")
                    }
                    
                    // Show empty state after a brief delay if still empty
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showEmptyState = viewModel.photoNotes.isEmpty
                    }
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
    
    private func deleteNotes(at offsets: IndexSet) {
        withAnimation {
            viewModel.deleteNote(at: offsets)
        }
    }
}
