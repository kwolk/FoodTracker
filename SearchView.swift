//
//  SearchView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI
import SwiftData


private enum Route: Hashable {
    case add
    case food(Foodstuffs)
}


struct SearchView: View {
    @State private var path = NavigationPath()
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var showingSettings = false
    @State private var showAllFoodstuffs = false
    @Query(sort: \Foodstuffs.name) var foodstuffs: [Foodstuffs]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // show (specific/all) foodstuffs
    var displayedFoodstuffs: [Foodstuffs] {
        
        // display foodstuufs from name/brand
        if !searchText.isEmpty {
            return foodstuffs.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.brand.localizedCaseInsensitiveContains(searchText)
            }
        }

        // display all foodstuffs on record
        if showAllFoodstuffs {
            return foodstuffs
        }

        return []
    }


    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(displayedFoodstuffs) { foodstuff in
                        NavigationLink(value: Route.food(foodstuff)) {
                            SearchResultTile(foodstuff: foodstuff)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    foodstuff.enjoy ? Color.red :
                                    (foodstuff.health ? Color.green : Color.clear),
                                    lineWidth: 3
                                )
                        )
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .food(let foodstuff)   : SummaryView(foodstuffs: foodstuff, path: $path, searchText: $searchText)
                case .add                   : AddView(path: $path)
                }
            }

            .toolbar {
                // settings page (export/import)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                // reveal every brand
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showAllFoodstuffs.toggle()
                        }
                    } label: {
                        Image(systemName: showAllFoodstuffs == true ? "eye" : "eye.slash")
                    }
                }
                
                // add new foodstuffs
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        path.append(Route.add)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingAddSheet) {
                AddView(path: $path)
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search brands..."
            )
            // display messages to help user
            .overlay {
                // encourage user to search
                if !foodstuffs.isEmpty && searchText.isEmpty && !showAllFoodstuffs {
                    emptySearchField
                }

                // encourage user to input new data (empty)
                if foodstuffs.isEmpty {
                    emptyLarder
                }
            }
        }
    }
    
    // if no foodstuffs exist then display message : "The cupboard is bare"
    private var emptyLarder: some View {
        ContentUnavailableView(
            "The cupboard is bare",
            systemImage: "carrot",
            description: Text("not a carrot !")
        )
    }
    
    // when foodstuffs exist then present text : "Search for Foodstuffs"
    private var emptySearchField: some View {
        ContentUnavailableView(
            "Search for Foodstuffs",
            systemImage: "magnifyingglass",
            description: Text("Results will appear as you type.")
        )
    }
}



private struct SearchResultTile: View {
    let foodstuff: Foodstuffs
    
    var body: some View {
        VStack {
            FoodstuffTile(images: foodstuff.photos)
            
            Text(foodstuff.name)
                .font(.headline)
            
            Text(foodstuff.brand)
                .font(.headline)
        }
    }
}




private struct FoodstuffTile: View {
    let images: [Photo]

    var body: some View {
        Group {
            if let firstPhoto = images.first,
               let uiImage = loadImage(named: firstPhoto.filename) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()

            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(32)
                    .foregroundColor(.secondary)
                    .background(Color(.secondarySystemBackground))
            }
        }
        .frame(height: 120)
        .clipped()
        .cornerRadius(8)
    }

    // load UIImage from disk
    private func loadImage(named filename: String) -> UIImage? {
        let documentsURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)

        guard let data = try? Data(contentsOf: documentsURL) else {
            return nil
        }

        return UIImage(data: data)
    }
}
