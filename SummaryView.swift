//
//  SummaryView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI


struct SummaryView: View {
    @Bindable var foodstuffs: Foodstuffs
    @Binding var path: NavigationPath
    @Binding var searchText: String
    @State private var showEditView = false
    @State private var photoSelection = 0
    @State private var priceSelection = 0
    @State private var reviewSelection = 0
    
    
    private var priceHeader: Date {
        guard !foodstuffs.prices.isEmpty else { return .now }
        return foodstuffs.prices[priceSelection].date
    }
    
    private var photoHeader: Date {
        guard !foodstuffs.photos.isEmpty else { return .now }
        return foodstuffs.photos[photoSelection].date
    }
    
    private var reviewHeader: Date {
        guard !foodstuffs.reviews.isEmpty else { return .now }
        return foodstuffs.reviews[reviewSelection].date
    }
    
    @State private var isSimplifiedMode: Bool = true
    
    
    private var sortedPrices: [Price] {
        foodstuffs.prices.sorted { $0.date > $1.date }
    }
    
    // workaround : control UIPageControl pips colours (so they show in Light Mode)
    init(foodstuffs: Foodstuffs, path: Binding<NavigationPath>, searchText: Binding<String>) {
        self._foodstuffs = Bindable(wrappedValue: foodstuffs)
        self._searchText = searchText
        self._path = path
        // pip colours (sliding between photos)
        UIPageControl.appearance().currentPageIndicatorTintColor = .systemPink
        UIPageControl.appearance().pageIndicatorTintColor = .gray
    }
    
    
    var body: some View {
        Form {
            
            Section("Details") {
                Text(foodstuffs.name)
                
                if !foodstuffs.brand.isEmpty {
                    Text(foodstuffs.brand)
                }
                
                // some foods I like, but they disagree with my tummy
                if foodstuffs.health == true {
                    Text("This upset my tummy :(")
                        .foregroundStyle(.green)
                        .italic()
                }
                
                // some food I don't like and should be marked for future avoidance
                if foodstuffs.enjoy == true {
                    Text("Not a fan")
                        .foregroundStyle(.red)
                        .italic()
                }
            }
            
            if (foodstuffs.weight != 0) && !isSimplifiedMode {
                Section("Weight") {
                    Text(foodstuffs.weight.description)
                }
            }
            
            // TODO: SORT BY NEWEST ('.tag' is the issue)
            // prices often change and so a historical records are kept (when recorded)
            if !foodstuffs.prices.isEmpty && !isSimplifiedMode {
                Section {
                    TabView(selection: $priceSelection) {
                        // uniquely enumerate over all prices
                        ForEach(Array(foodstuffs.prices.enumerated()), id: \.element.id) { index, price in
                            VStack {
                                ScrollView(.horizontal) {
                                    // display historical pricing
                                    historicalPriceView(price)
                                }
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(height: 120)
                } header: {
                    // extract date price was commited (for header use)
                    Text(Helper.shared.sectionHeaderInfo(for: priceHeader))
                        .padding(.vertical, 6)
                }
            }
            
            // TODO: SORT BY NEWEST ('.tag' is the issue)
            // display photos in carousel (ordered by most recent)
            if !foodstuffs.photos.isEmpty {
                Section {
                    TabView(selection: $photoSelection) {
                        ForEach(Array(foodstuffs.photos.indices), id: \.self) { index in
                            // check photos exist (out of bounds)
                            if index < foodstuffs.photos.count {
                                let photo = foodstuffs.photos[index]

                                if let uiImage = loadImage(named: photo.filename) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 220)
                                        .clipped()
                                        .tag(index)
                                } else {
                                    // pip (denote which photo is in view in slideshow)
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 220)
                                        .clipped()
                                        .tag(index)
                                }
                            }
                        }
                    }
                    .tabViewStyle(.page)            // behave as a carousel
                    .frame(height: 220)
                    .listRowInsets(EdgeInsets())    // remove margins
                    .listRowBackground(Color.clear)
                    
                    // keep carousel and page indicator (pips) synchronised
                    .onChange(of: foodstuffs.photos) { newPhotos in
                        // ensure UI never tries to show a non-existent photo
                        if newPhotos.isEmpty {
                            photoSelection = 0      // reset selection if no photos
                        } else if photoSelection >= newPhotos.count {
                            photoSelection = newPhotos.count - 1    // clamp selection to last valid index
                        }
                    }
                } header: {
                    // extract date photo was commited (for header use)
                    Text(Helper.shared.sectionHeaderInfo(for: photoHeader))
                }
            }

            // TODO: SORT BY NEWEST ('.tag' is the issue)
            // display reviews in carousel (ordered by most recent)
            if !foodstuffs.sortedReviews.isEmpty {
                Section {
                    TabView(selection: $reviewSelection) {
                        ForEach(Array(foodstuffs.sortedReviews.enumerated()), id: \.element.id) { index, review in
                            VStack {
                                // swipe review into view (should more than one exist)
                                ScrollView {
                                    Text(review.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.bottom, 10)
                                .frame(height: 140) // adjust as needed
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(height: 200)
                    
                } header: {
                    // extract date review was commited (for header use)
                    Text(Helper.shared.sectionHeaderInfo(for: reviewHeader))
                }
            }
            
            // display scannable barcode (visual and numerical)
            // nb. one never knows when such things could come in handy...
            if !foodstuffs.barcode.isEmpty && !isSimplifiedMode {
                Section {
                    SummaryBarcodeView(numberString: foodstuffs.barcode)
                }
                .listRowInsets(EdgeInsets())    // remove Section padding
                .background(Color.clear)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isSimplifiedMode) // gracefully reveal animation
        .navigationTitle("Summary")
        .toolbar {
            // toggle all fields into view (default to simplified view)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isSimplifiedMode.toggle()
                    }
                } label: {
                    Image(systemName: isSimplifiedMode == true ? "eye" : "eye.slash")
                }
            }
            // edit foodstuffs
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showEditView = true
                }
            }
        }
        .navigationDestination(isPresented: $showEditView) {
            EditView(foodstuffs: foodstuffs, path: $path, searchText: $searchText)
        }
    }
    
    
    // load stored image from disk into memory
    private func loadImage(named filename: String) -> UIImage? {
        // locate the file in app documents directory
        let documentsURL = FileManager.default
            // return array of URLs to app documents directories
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            // append filename to create full path to the image file
            .appendingPathComponent(filename)

        // load the file into memory as Data
        guard let data = try? Data(contentsOf: documentsURL) else {
            return nil
        }

        // convert the data into a UIImage
        return UIImage(data: data)
    }
    
    
    // historical price of a foodstuffs
    private func historicalPriceView(_ price: Price) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            // display the regular price
            Text("\(price.regularPrice, format: .currency(code: "GBP")) (rrp)")
            
            // display the special price (in red) ~if it exists
            if let special = price.specialPrice {
                Text("\(special, format: .currency(code: "GBP")) (special)")
                    .foregroundColor(.red)
            }
        }
    }
}
