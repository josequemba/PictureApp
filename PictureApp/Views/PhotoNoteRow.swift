//
//  PhotoNoteRow.swift
//  PictureApp
//
//  Created by Jose Quemba on 5/14/25.
//
import SwiftUI

struct PhotoNoteRow: View {
    let note: PhotoNote
    
    var body: some View {
        HStack(spacing: 12) {
            if let image = note.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    )
                    .shadow(radius: 1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(note.caption)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(formattedDate(note.dateCreated))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.5))
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
