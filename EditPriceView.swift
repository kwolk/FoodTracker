//
//  EditPriceView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 17/01/2026.
//

import SwiftUI


// display historical prices and allow for them to be amended
struct EditPriceView: View {

    @Bindable var foodstuffs: Foodstuffs
    @Environment(\.dismiss) private var dismiss

    @State private var regularPriceInput: String = ""
    @State private var specialPriceInput: String = ""

    var body: some View {
        Section() {
            TextField("Regular Price", text: $regularPriceInput)
                .keyboardType(.decimalPad)
                .onChange(of: regularPriceInput) { newValue in
                    regularPriceInput = Helper.shared.filterNumericInput(newValue)
                }
            
            TextField("Special Price", text: $specialPriceInput)
                .keyboardType(.decimalPad)
                .onChange(of: specialPriceInput) { newValue in
                    specialPriceInput = Helper.shared.filterNumericInput(newValue)
                }

            // either add new price or overwrite existing (update)
            Button("Commit New Price") {
                guard let regular = Decimal(string: regularPriceInput) else { return }
                let special = Decimal(string: specialPriceInput)

                if let sp = special, sp >= regular { return } // validation

                // append new price entry with current date
                foodstuffs.addPrice(regular: regular, special: special, on: .now)

                // Clear input fields
                regularPriceInput = ""
                specialPriceInput = ""
            }
            // disable 'Commit New Price' button if regular price is empty, or the special price is greater than it
            .disabled(regularPriceInput.trimmingCharacters(in: .whitespaces).isEmpty ||
                      (Decimal(string: specialPriceInput) ?? 0) >= (Decimal(string: regularPriceInput) ?? 0))
        }

        // display historical pricing records
        Section("Price History") {
            ForEach($foodstuffs.prices) { $entry in
                VStack(alignment: .leading) {
                    HStack {
                        TextField(
                            "Regular Price",
                            value: $entry.regularPrice,
                            // conform to GBP format
                            format: .currency(code: Locale.current.currency?.identifier ?? "GBP")
                        )
                        .keyboardType(.decimalPad)  // numerical keypad only
                        .frame(width: 120)

                        // SwiftUI cannot bind optional numeric values, so a custom Binding bridges the model and the view
                        TextField(
                            "Special Price",
                            value: Binding(
                                get: { entry.specialPrice ?? 0 },
                                set: { entry.specialPrice = $0 }
                            ),
                            format: .currency(code: Locale.current.currency?.identifier ?? "GBP")
                        )
                        .keyboardType(.decimalPad)

                        // update existing price record with new price data
                        Button("Update") {
                            // searches prices array to match unique ID
                            guard let index = foodstuffs.prices.firstIndex(where: { $0.id == entry.id }) else { return }
                            var updated = foodstuffs.prices[index]
                            
                            // update prices
                            updated.regularPrice = Decimal(string: regularPriceInput) ?? updated.regularPrice
                            updated.specialPrice = Decimal(string: specialPriceInput)
                            
                            // update date stamp
                            updated.date = .now
                            
                            // commit changes to the prices array
                            foodstuffs.prices[index] = updated
                        }
                    }
                    // display date price was committed
                    Text(Helper.shared.prettyDate(entry.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(4)
            }
        }
        .navigationTitle("Edit Foodstuff")
    }
}

