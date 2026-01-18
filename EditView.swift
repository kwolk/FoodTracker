//
//  EditView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI


// edit foodstuff record
struct EditView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var foodstuffs: Foodstuffs
    @Binding var path: NavigationPath
    @Binding var searchText: String // workaround : needed to clear if deleting record and reset the search field (pop to root)
    
    @State private var showDeleteConfirmation = false
    @State var isDraftEmpty: Bool = false

    // local state for editing (avoids commiting through Binding value)
    @State private var name: String
    @State private var brand: String
    @State private var weight: Double
    @State private var barcode: String
    @State private var reviews: [Review]
    @State private var draftReviews: [Review]
    @State private var enjoy: Bool
    @State private var health: Bool
    @State private var photos: [Photo]
    @State private var selectedReviewID: UUID?
    
    @State private var weightText: String = ""
    @State var photoDateHeader: String = ""
    @State var reviewDateHeader: String = ""
    
    
    // workaround : local changes only comitted on 'save' request
    init(foodstuffs: Foodstuffs, path: Binding<NavigationPath>, searchText: Binding<String>) {
        self.foodstuffs = foodstuffs
        _name = State(initialValue: foodstuffs.name)
        _brand = State(initialValue: foodstuffs.brand)
        _weight = State(initialValue: foodstuffs.weight)
        _barcode = State(initialValue: foodstuffs.barcode)
        _reviews = State(initialValue: foodstuffs.reviews)
        _enjoy = State(initialValue: foodstuffs.enjoy)
        _health = State(initialValue: foodstuffs.health)
        _draftReviews = State(initialValue: foodstuffs.sortedReviews)
        _photos = State(initialValue: foodstuffs.photos)
        _selectedReviewID = State(initialValue: foodstuffs.reviews.first?.id)
        self._path = path
        self._searchText = searchText
    }

    var body: some View {
        VStack(spacing: 16) {

            Form {
                nameSection
                brandSection
                weightSection
                
                Section("PRICING") {
                    EditPriceView(foodstuffs: foodstuffs)
                }
                
                barcodeSection
                
                // photos
                Section(photoDateHeader) {
                    EditPhotoCarouselView(photos: $photos, photoDateHeader: $photoDateHeader)
                }
                                
                Section(reviewDateHeader) {
                    EditReviewView(foodstuffs: foodstuffs,
                                             isDraftEmpty: $isDraftEmpty,
                                             reviewDateHeader: $reviewDateHeader,
                                             draftReviews: $draftReviews)
                }
                
                enjoySection
                healthSection
            }
        }
        .navigationTitle("Edit")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                saveButton
                .disabled(foodstuffs.name.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            ToolbarItem(placement: .cancellationAction) {
                cancelButton
            }
        }
        deleteButton
    }

    private var nameSection: some View {
        Section("Name") {
            TextField("Foodstuff", text: $name)
        }
    }
    
    private var brandSection: some View {
        Section("Brand") {
            TextField("Brand", text: $brand)
        }
    }

    private var weightSection: some View {
        Section("Weight") {
            weightInput
                .keyboardType(.numberPad)
        }
    }
            
    private var barcodeSection: some View {
        Section("Barcode") {
            barcodeInput
                .keyboardType(.numberPad)
        }
    }
    
    // is the foodstuff worth buying again ?
    private var enjoySection: some View {
        Section("Awful ?") {
            Toggle("Awful ?", isOn: $enjoy)
                .toggleStyle(SwitchToggleStyle(tint: .red))
        }
    }
    
    // did the fodstuff upset my tummy ?
    private var healthSection: some View {
        Section("Dicky tummy ?") {
            Toggle("Dicky tummy ?", isOn: $health)
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
    }
    
    
    // workaround : work with text field to ensure limiting constraits are applied in real time
    /// SwiftUI uses a TextField bound to a Double through a Binding<String>, which doesn’t prevent typing invalid characters in real time.
    /// The TextField updates the string first, then the set closure runs.
    /// Thus, non-numeric characters briefly appear in the field before being “redacted”
    private var weightInput: some View {
        TextField("Weight", text: $weightText)
            .keyboardType(.numberPad)
            .onChange(of: weightText) { newValue in
                let filtered = newValue.filter(\.isNumber)
                let limited = String(filtered.prefix(4))
                
                // Update the text field if needed
                if limited != newValue {
                    weightText = limited
                }
                
                // Update the model
                foodstuffs.weight = Double(limited) ?? 0
            }
            .onAppear {
                // Initialise the text field from the model
                weightText = foodstuffs.weight == 0 ? "" : String(Int(foodstuffs.weight))
            }
    }
    
    private var barcodeInput: some View {
        TextField("Barcode", text: $barcode)
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .onChange(of: barcode) { newValue in
                let filtered = newValue.filter(\.isNumber)
                let limited = String(filtered.prefix(12))

                if limited != newValue {
                    barcode = limited
                }
            }
    }


    func commit() {
        // Filter out empty reviews
        let validReviews = reviews.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        foodstuffs.name     = name
        foodstuffs.brand    = brand
        foodstuffs.barcode  = barcode
        foodstuffs.reviews  = validReviews.sorted { $0.date > $1.date } // organise valid reviews by date
        foodstuffs.photos   = photos
        foodstuffs.reviews  = draftReviews
        foodstuffs.enjoy    = enjoy
        foodstuffs.health   = health
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save after delete: \(error)")
        }

        dismiss()
    }

    
    private func addReview() {
        let newReview = Review(text: "", date: .now)
        reviews.append(newReview)

        // make the new review visible
        withAnimation {
            selectedReviewID = newReview.id
        }
    }

    
    private var saveButton: some View {
        Button {
            commit()
        } label: {
            Text("Save")
        }
    }

    private var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
        }
    }
    
    // delete record (with confirmation)
    private var deleteButton: some View {
        Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Text("Delete '\(foodstuffs.name)'")
            }
            .confirmationDialog(
                "Are you sure terribly sure ?!",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Destroy", role: .destructive) {
                    deleteFoodstuff()
                }

                Button("Actually, no", role: .cancel) {
                    showDeleteConfirmation = false
                }
            }
    }
    
    private func deleteFoodstuff() {
            modelContext.delete(foodstuffs)
            do { try modelContext.save() } catch { print(error) }

        dismiss()
        path.removeLast(path.count) // pop to root
        searchText = ""             // clear search (for return)
    }
}
