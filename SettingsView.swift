//
//  SwiftUIView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 17/01/2026.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData
import ZIPFoundation


// plain data container for moving data safely
// mirroring Foodstuffs for safe Codable export/import
struct FoodstuffsExportDTO: Codable {
    let id: UUID
    let name: String
    let brand: String
    let weight: Double
    let barcode: String
    let date: Date
    let prices: [Price]
    let photos: [Photo]
    let reviews: [Review]
    let enjoy: Bool
    let health: Bool
}




struct SettingsView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var exportFileURL: URL?

    var body: some View {
        NavigationStack {
            Form {
                Section("Data") {

                    // export JSON and photos
                    Button("Export") {
                        export()
                    }

                    // import JSON and photos
                    Button("Import") {
                        showingImporter = true
                    }
                }
            }
            .navigationTitle("Settings")

            // export
            .fileExporter(
                isPresented: $showingExporter,
                document: URLDocument(fileURL: exportFileURL),
                contentType: .zip,
                defaultFilename: "FoodstuffsBackup"
            ) { _ in }

            // import
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.zip],
                allowsMultipleSelection: false
            ) { result in
                if case .success(let urls) = result, let zipURL = urls.first {
                    importZip(from: zipURL)
                }
                dismiss()
            }
        }
    }
}



extension Foodstuffs {

    // fetch all Foodstuffs objects (sorted alphabetically by name)
    static var all: FetchDescriptor<Foodstuffs> {
        FetchDescriptor(
            sortBy: [SortDescriptor(\.name)]
        )
    }

    // fetch a Foodstuffs object by UUID
    // e.g. let food = try modelContext.fetch(Foodstuffs.byID(someUUID))
    static func byID(_ id: UUID) -> FetchDescriptor<Foodstuffs> {
        FetchDescriptor(
            predicate: #Predicate { $0.id == id }
        )
    }
}



private extension SettingsView {

    func export() {
        do {
            let foods: [Foodstuffs] = try modelContext.fetch(Foodstuffs.all)

            // dedicated temporary folder for export
            let exportRoot = FileManager.default.temporaryDirectory
                .appendingPathComponent("FoodstuffsExport", isDirectory: true)

            try? FileManager.default.removeItem(at: exportRoot)
            try FileManager.default.createDirectory(at: exportRoot, withIntermediateDirectories: true)

            try exportFoodstuffs(foods, to: exportRoot)

            // zip all files
            let zipURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("FoodstuffsBackup.zip")

            try? FileManager.default.removeItem(at: zipURL)
            try FileManager.default.zipItem(at: exportRoot, to: zipURL)

            exportFileURL = zipURL
            showingExporter = true

        } catch {
            print("Export failed:", error)
        }
    }

    func exportFoodstuffs(_ foods: [Foodstuffs], to folder: URL) throws {

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let dto = foods.map {
            FoodstuffsExportDTO(
                id: $0.id,
                name: $0.name,
                brand: $0.brand,
                weight: $0.weight,
                barcode: $0.barcode,
                date: $0.date,
                prices: $0.prices,
                photos: $0.photos,
                reviews: $0.reviews,
                enjoy: $0.enjoy,
                health: $0.health
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]    // humanly readable JSON
        encoder.dateEncodingStrategy = .iso8601                     // standardised date format for serialisation

        try encoder.encode(dto)
            .write(to: folder.appendingPathComponent("Foodstuffs.json"), options: .atomic)

        
        for food in dto {
            for photo in food.photos {
                let source = documentsURL.appendingPathComponent(photo.filename)        // original photo in app's Documents folder
                let destination = folder.appendingPathComponent(photo.filename)         // temporary export folder
                if FileManager.default.fileExists(atPath: source.path) {                // only copy file if it exists
                    try? FileManager.default.copyItem(at: source, to: destination)      // copy photo from Documents to export folder
                }
            }
        }
    }
}



private extension SettingsView {

    func importZip(from zipURL: URL) {
        do {
            // generate unique temporary folder in the system temp directory (where the ZIP contents will be unzipped)
            let tempFolder = FileManager.default.temporaryDirectory
                // ensures no naming collisions (if multiple imports happen simultaneously)
                .appendingPathComponent(UUID().uuidString, isDirectory: true)

            // ensures the full path is created even if the parent directories don’t exist
            try FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true)
            
            // expand the ZIP file into folder to access exported JSON and photos
            try FileManager.default.unzipItem(at: zipURL, to: tempFolder)

            // finds folder containing Foodstuffs.json inside unzipped ZIP folder
            let exportRoot = try locateExportRoot(in: tempFolder)
            
            // reads JSON, then reconstructs SwiftData objects and copies images into Documents
            try importFoodstuffs(from: exportRoot)

        } catch {
            print("Import failed:", error)
        }
    }

    func locateExportRoot(in folder: URL) throws -> URL {
        
        // read all files and subfolders inside the given folder
        let contents = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)

        // export file named "Foodstuffs.json" directly in this folder (if it exists)
        if contents.contains(where: { $0.lastPathComponent == "Foodstuffs.json" }) {
            return folder
        }

        // if "Foodstuffs.json" wasn’t found at the top level, this assumes it might be
        // inside a single subfolder (common when zipping folders)
        if let dir = contents.first(where: { $0.hasDirectoryPath }) {
            return dir
        }

        throw CocoaError(.fileReadNoSuchFile)
    }

    // imports Foodstuffs data and associated photos from folder
    func importFoodstuffs(from folder: URL) throws {

        let data = try Data(contentsOf: folder.appendingPathComponent("Foodstuffs.json"))

        // Decode JSON into Data Transfer Objects
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let imported = try decoder.decode([FoodstuffsExportDTO].self, from: data)

        // Documents folder for storing images
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        for dto in imported {

            // check if Foodstuffs already exists
            let existing: [Foodstuffs] = try modelContext.fetch(Foodstuffs.byID(dto.id))
            let food: Foodstuffs

            if let existingFood = existing.first {
                food = existingFood     // reuse existing object
            } else {
                
                // create new object and insert into SwiftData context
                food = Foodstuffs(
                    id      : dto.id,
                    name    : dto.name,
                    brand   : dto.brand,
                    weight  : dto.weight,
                    barcode : dto.barcode,
                    date    : dto.date,
                    prices  : dto.prices,
                    photos  : dto.photos,
                    reviews : dto.reviews,
                    enjoy   : dto.enjoy,
                    health  : dto.health
                )
                modelContext.insert(food)
            }

            // copy associated photos into app Documents folder
            for photo in dto.photos {
                let source = folder.appendingPathComponent(photo.filename)              // exported photo
                let destination = documentsURL.appendingPathComponent(photo.filename)   // destination in Documents

                if FileManager.default.fileExists(atPath: source.path),
                   !FileManager.default.fileExists(atPath: destination.path) {
                    try? FileManager.default.copyItem(at: source, to: destination)
                }
            }
        }
    }
}


// a simple FileDocument wrapper for a single ZIP file (used with SwiftUI fileImporter and fileExporter)
struct URLDocument: FileDocument {

    // specify that this document handles ZIP files
    static var readableContentTypes: [UTType] { [.zip] }
    
    // the URL of the file on disk
    let fileURL: URL?

    // initialise with a file URL (used for exporting)
    init(fileURL: URL?) { self.fileURL = fileURL }
    
    // initialise from a SwiftUI `ReadConfiguration` (required by FileDocument protocol)
    init(configuration: ReadConfiguration) throws { fileURL = nil }

    // return a FileWrapper for SwiftUI to read/write
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        
        // if no file URL exists, return an empty file
        guard let fileURL else {
            return FileWrapper(regularFileWithContents: Data())
        }
        // otherwise, wrap the file at the given URL
        return try FileWrapper(url: fileURL)
    }
}
