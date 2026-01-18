//
//  SummaryBarcodeView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 16/01/2026.
//

import SwiftUI
import CoreImage.CIFilterBuiltins


// generate barcode illustration
struct SummaryBarcodeView: View {
    let numberString: String
    let context = CIContext()
    let barcodeFilter = CIFilter.code128BarcodeGenerator()
    let invertFilter = CIFilter.colorInvert()
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 4) {
            // Barcode image
            if let image = generateBarcode(from: numberString, inverted: colorScheme == .dark) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: .infinity, minHeight: 140) // tweak : slightly taller
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .offset(y: -8) // tweak : nudge upward for appearences
            } else {
                // if no illustration can be drawn then display dashed line where numbers would exist
                Text("_ _ _ _ _ _") // tweak : underscore looks better
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            }
            
            // Number text (beneath illustration)
            Text(numberString)
                .frame(maxWidth: .infinity)
                .font(.system(size: 17, weight: .regular, design: .default)) // immitate TextField text
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.bottom, 8)
        }
        .padding(.top, 0) // remove extra top padding
    }
    
    // generates a barcode image from a given string, optionally inverting its colors.
    func generateBarcode(from string: String, inverted: Bool) -> UIImage? {
        // convert input string to UTF-8 data
        let data = Data(string.utf8)
        barcodeFilter.message = data
        
        // generate the barcode image from the filter
        guard let outputImage = barcodeFilter.outputImage else { return nil }
        
        if inverted {
            // apply color inversion if requested
            invertFilter.inputImage = outputImage
            guard let invertedImage = invertFilter.outputImage,
                  let cgImage = context.createCGImage(invertedImage, from: invertedImage.extent) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        } else {
            // convert CIImage to CGImage and return as UIImage
            guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
            return UIImage(cgImage: cgImage)
        }
    }
}
