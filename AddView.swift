//
//  AddView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI


struct AddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State var foodstuffs = Foodstuffs()
    @Binding var path: NavigationPath
    
    @State private var isPickerPresented = false
    @State private var reviewText: String = ""
    @State private var weightText: String = ""
    @State private var regularPriceInput: String = ""
    @State private var specialPriceInput: String = ""

    var body: some View {
        Form {
            Section("Details") {
                TextField("Foodstuff", text: $foodstuffs.name)
//                TextField("Brand", text: $foodstuffs.brand)
                
                BrandAutocompleteFieldView(brand: $foodstuffs.brand)
                
                priceInput
                
                weightInput
                    .keyboardType(.numberPad)
                
                barcodeInput
                    .keyboardType(.numberPad)
            }
                        
            Section("Photos") {
                PhotoPickerView(photos: $foodstuffs.photos)
                   .listRowInsets(.init())
            }

            Section("Review") {
                TextEditor(text: $reviewText)
                    .frame(height: 120)
            }
            
            enjoyInput
            
            healthInput
        }
        .navigationTitle("Add Foodstuff")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    commit()
                }
                .disabled(foodstuffs.name.trimmingCharacters(in: .whitespaces).isEmpty)
                .disabled(foodstuffs.name.isEmpty || foodstuffs.brand.isEmpty)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    // is it worth buying the foodstuff again (if checked the search result will have a red border)
    private var enjoyInput: some View {
        Toggle("Awful ?", isOn: $foodstuffs.enjoy)
            .toggleStyle(SwitchToggleStyle(tint: .red))
    }
    
    // did it leave me feeling ill (if checked the search result will have a green border)
    // nb. if 'enjoyInput' is checked then it will override the green border in the search results
    private var healthInput: some View {
        Toggle("Dicky tummy ?", isOn: $foodstuffs.health)
            .toggleStyle(SwitchToggleStyle(tint: .green))
    }
    
    // pricing history of product (inflation && price fixing)
    private var priceInput: some View {
        HStack {
            // standard price
            TextField("Regular Price", text: $regularPriceInput)
                .keyboardType(.decimalPad)
                .onChange(of: regularPriceInput) {
                    regularPriceInput = Helper.shared.filterNumericInput($0)
                }
            
            // special offer
            TextField("Special Price !", text: $specialPriceInput)
                .keyboardType(.decimalPad)
                .onChange(of: specialPriceInput) {
                    specialPriceInput = Helper.shared.filterNumericInput($0)
                }
            
            priceValidationView
        }
    }
    
    
    @ViewBuilder    // return multiple views conditionally rather than a single view
    // returns error messages if special price equates, or exceeds the rrp
    var priceValidationView: some View {
        // safely convert String inputs to Decimal (proceeds only if both conversions succeed)
        if let regular = Decimal(string: regularPriceInput),
           let special = Decimal(string: specialPriceInput) {

            // since when was a special offer more expensice than the rrp ?!
            if special > regular {
                Text("Special price cannot exceed the regular price")
                    .foregroundColor(.red)
                    .font(.caption)
            }

            // since when was a special offer the same price as the rrp ?!
            if special == regular {
                Text("A special price must be lower than the regular price")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    // barcode data
    private var barcodeInput: some View {
        TextField("Barcode", text: $foodstuffs.barcode)
            .keyboardType(.numberPad)   // numbers only
            .onChange(of: foodstuffs.barcode) { newValue in
                let filtered = newValue.filter(\.isNumber)
                let limited = String(filtered.prefix(12))

                if limited != newValue {
                    foodstuffs.barcode = limited
                }
            }
    }

    
    // workaround : work with text field to ensure limiting constraits are applied in real time
    // SwiftUI uses a TextField bound to a Double through a Binding<String>, which doesn’t prevent typing invalid characters in real time.
    // the TextField updates the string first, then the set closure runs.
    // thus, non-numeric characters briefly appear in the field before being “redacted”
    private var weightInput: some View {
        TextField("Weight", text: $weightText)
            .keyboardType(.numberPad)
            .onChange(of: weightText) { newValue in
                let filtered = newValue.filter(\.isNumber)
                let limited = String(filtered.prefix(4))
                
                // update the text field if needed
                if limited != newValue {
                    weightText = limited
                }
                
                // update the model
                foodstuffs.weight = Double(limited) ?? 0
            }
            .onAppear {
                // initialise the text field from the model
                weightText = foodstuffs.weight == 0 ? "" : String(Int(foodstuffs.weight))
            }
    }
    
    // add price
    func commitPrice() {
        // check if string can be converted to a decimal number
        guard let regular = Decimal(string: regularPriceInput) else { return }

        // special price will not always be available
        var special: Decimal? = nil
        
        // trim chars from beginning and end
        let trimmed = specialPriceInput.trimmingCharacters(in: .whitespaces)
        
        // check if string text can be converted to decimal
        if !trimmed.isEmpty {
            guard let parsed = Decimal(string: trimmed) else {
                // invalid input
                return
            }
            special = parsed
        }

        // commit initial price history
        foodstuffs.addPrice(regular: regular, special: special, on: foodstuffs.date)
    }


    // save changes
    private func commit() {
        if !reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            foodstuffs.addReview(reviewText)
        }

        commitPrice()
        
        modelContext.insert(foodstuffs)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save new paint: \(error)")
        }
    
        dismiss()
    }
    
    

}
