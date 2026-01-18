//
//  EditPhotoCarouselView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 17/01/2026.
//

import SwiftUI
import PhotosUI


// display a carousel of photos (for editing)
struct EditPhotoCarouselView: View {
    @Binding var photos: [Photo]
    @Binding var photoDateHeader: String
    @State private var selection = 0
    @State private var pickedItems: [PhotosPickerItem] = []

    var body: some View {
        PhotoCarouselView(
            photos: $photos,
            selection: $selection,
            pickedItems: $pickedItems,
            showHeader: true,
            onHeaderUpdate: { photo in
                // extract date photo was submitted (header info)
                photoDateHeader = Helper.shared.sectionHeaderInfo(for: photo.date)
            }
        )
        .listRowInsets(EdgeInsets())
    }
}

