//
//  PhotoPickerView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI
import PhotosUI


// display a carousel of photos
struct PhotoPickerView: View {
    @Binding var photos: [Photo]
    @State private var selection = 0
    @State private var pickedItems: [PhotosPickerItem] = []

    var body: some View {
        PhotoCarouselView(
            photos      : $photos,
            selection   : $selection,
            pickedItems : $pickedItems,
            showHeader  : false
        )
        .padding()
    }
}
