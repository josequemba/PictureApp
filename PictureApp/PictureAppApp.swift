//
//  PictureAppApp.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/7/25.
//

import SwiftUI
import SwiftData

@main
struct PictureAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = PhotoNoteViewModel()
    
    var body: some View {
        Text("PhotoNotes App")
            .padding()
            .onAppear {
                // Add sample data for testing
                viewModel.addSampleData()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
