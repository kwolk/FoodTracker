//
//  PhotoCarouselView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI
import PhotosUI



struct PhotoCarouselView: View {
    @Binding var photos: [Photo]
    @Binding var selection: Int
    @Binding var pickedItems: [PhotosPickerItem]
    var showHeader: Bool = false
    var onHeaderUpdate: ((Photo) -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            
            // if no photos exist display display message : "Add Photos" with a sun illustration
            if photos.isEmpty {
                // photo picker for selecting new photos
                PhotosPicker(
                    selection: $pickedItems,
                    maxSelectionCount: 10,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack {
                        Image(systemName: "sun.max")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .foregroundColor(.secondary)
                        Text("Add Photos")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                // handle newly picked photos
                .onChange(of: pickedItems) { newItems in
                    addPickedPhotos(newItems)
                }
            } else {
                // display photo(s) in carousel
                TabView(selection: $selection) {
                    ForEach(photos.indices, id: \.self) { index in
                        if let uiImage = PhotoStorageManager.loadImage(named: photos[index].filename) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .tag(index)
                                .clipped()
                                .cornerRadius(10)
                        } else {
                            // placeholder if the image cannot be loaded
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(height: 220)
                .tabViewStyle(.page)
                // update header details from new photo in focus
                .onChange(of: selection) { newSelection in
                    if photos.indices.contains(newSelection), showHeader {
                        onHeaderUpdate?(photos[newSelection])
                    }
                }

                // add photo (button)
                HStack(spacing: 40) {
                    PhotosPicker(
                        selection: $pickedItems,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .onChange(of: pickedItems) { newItems in
                        guard !newItems.isEmpty else { return }
                        addPickedPhotos(newItems)
                    }

                    Spacer()

                    // delete photo (button)
                    Button(action: deleteCurrentPhoto) {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color(.systemGray5).opacity(0.7))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(photos.isEmpty)   // disable delete button if no photos exist
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
        }
    }

    // add photos
    private func addPickedPhotos(_ items: [PhotosPickerItem]) {
        Task {  // runs the following code asynchronously (as it can take time to load photo data from the picker)
            for item in items {
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let photo = PhotoStorageManager.savePhoto(data: data) else { continue }
                
                // update UI state safely on the main thread
                // await pauses this task until the photo data is loaded
                await MainActor.run {
                    // adds the new photo to the front of the array so it appears first in any carousel
                    photos.insert(photo, at: 0)
                    // resets carousel/selection index to show the newly added photo immediately
                    selection = 0
                    // update a header if needed
                    if showHeader {
                        onHeaderUpdate?(photo)
                    }
                }
            }
            // clears the pickedItems array after processing all selected photos
            await MainActor.run { pickedItems.removeAll() }
        }
    }

    // delete the currently selected photo
    private func deleteCurrentPhoto() {
        // ensure the selection is valid before attempting deletion
        guard photos.indices.contains(selection) else { return }
        
        // remove photo from disk and from the photos array
        PhotoStorageManager.deletePhoto(photos[selection])
        photos.remove(at: selection)
        
        // adjust selection so it remains a valid index after removal
        if selection >= photos.count {
            selection = max(0, photos.count - 1)
        }
        
        // update header info if a header is shown and a valid photo remains
        if showHeader, photos.indices.contains(selection) {
            onHeaderUpdate?(photos[selection])
        }
    }
}



// ensures photo is deleted from disk and not just the reference in the array
private struct PhotoStorageManager {
    // load an image from disk if it exists
    static func loadImage(named filename: String) -> UIImage? {
        let documentsURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: documentsURL) else { return nil }
        return UIImage(data: data)
    }

    // save photo data to disk and return a Photo object
    static func savePhoto(data: Data) -> Photo? {
        let documentsURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]

        // generate unique file name
        let filename = UUID().uuidString + ".jpg"
        
        // writes the data to the documents directory
        let fileURL = documentsURL.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL, options: [.atomic])
            return Photo(date: .now, filename: filename)
        } catch {
            print("Failed to save image:", error)
            return nil
        }
    }

    // delete a photo file from disk
    static func deletePhoto(_ photo: Photo) {
        let fileURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(photo.filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
