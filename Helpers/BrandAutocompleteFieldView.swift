//
//  BrandAutocompleteFieldView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI
import SwiftData


// workaround : "ghosted-text" is not native to tap UI
// display existing brand names when typed in
struct BrandAutocompleteFieldView: View {
    @Binding var brand: String
    
    // fetch all Foodstuffs
    @Query private var allFoodstuffs: [Foodstuffs]

    @State private var filteredBrands: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            TextField("Brand", text: $brand)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                // return existing brand(s) if typed chars match database
                .onChange(of: brand) { newValue in
                    updateFilteredBrands(for: newValue)
                }

            // display brand suggestions box below textfield (if brands already exist)
            if !filteredBrands.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(filteredBrands, id: \.self) { suggestion in
                            Text(suggestion)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                                .italic()
                                .background(Color(.systemGray6))
                                .onTapGesture {
                                    brand = suggestion
                                    filteredBrands = []
                                }
                        }
                    }
                }
                .frame(maxHeight: 150)
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
        }
        .animation(.easeInOut, value: filteredBrands)
    }

    // return an array of brand(s) matching what chars are being typed in real time
    // basically auto-complete for company brands
    private func updateFilteredBrands(for input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)     // trim any white space at beginning and end of string value
        if trimmed.isEmpty {
            filteredBrands = []
        } else {
            // extract all brands
            let allBrands: [String] = allFoodstuffs.map { $0.brand }
            
            // convert array to a Set to automatically remove duplicates from available brands (keeping it in an Array)
            let uniqueBrands = Array(Set(allBrands))
            
            filteredBrands = uniqueBrands
                // make case insensitive ("A" and "a" are the same) and any conforms to locale diatrics (e.g., "é" in French)
                .filter { $0.localizedCaseInsensitiveContains(trimmed) }
                .sorted()   // sort alphabeticallt
        }
    }
}

