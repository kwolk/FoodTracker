//
//  EditReviewView.swift
//  FoodTracker
//
//  Created by Samuel Corke on 17/01/2026.
//

import SwiftUI


// edit review(s)
struct EditReviewView: View {
    @State var foodstuffs: Foodstuffs
    @Binding var isDraftEmpty: Bool
    @Binding var reviewDateHeader: String
    
    @Binding var draftReviews: [Review]
    @State private var selectedIndex: Int = 0

    
    var body: some View {
        // check if any reviews exist
        if draftReviews.isEmpty {
            emptyState
        } else {
            Section {
                reviewPager
            }
        }
    }

    private var reviewPager: some View {
        TabView(selection: $selectedIndex) {
            ForEach(draftReviews.indices, id: \.self) { index in
                reviewEditor(for: index)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 280)
    }

    // edit single review (at a given index)
    private func reviewEditor(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            TextEditor(text: $draftReviews[index].text)
                .frame(height: 190)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(0)
                // retrieve updated date to present in Section header
                .onChange(of: draftReviews[index].text) { oldValue, newValue in
                    reviewDateHeader = Helper.shared.sectionHeaderInfo(for: draftReviews[index].date)
                    //TODO: TEST
                    isDraftEmpty = draftReviews.allSatisfy { $0.text.isEmpty }
//                    isDraftEmpty.toggle()
                }
                // retrieve review date to present in Section header
                .onAppear {
                    reviewDateHeader = Helper.shared.sectionHeaderInfo(for: draftReviews[index].date)
                }

            HStack {
                // add review
                Button {
                    addReview()
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
                // no new reviews may be created until at least a single char is present in an empty review
                .disabled(draftReviews[index].text.isEmpty)

                Spacer()

                // delete review
                Button(role: .destructive) {
                    deleteReview(at: index)
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .padding(.vertical)
    }
    

    // imagery displayed when no reviews are available
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.bubble")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)

            Text("No Reviews")
                .font(.title3)
                .foregroundStyle(.secondary)

            Text("Tap here to add your first review.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle()) // makes the whole area tappable
        .onTapGesture {
            addReview()
        }
    }

    private func addReview() {
        let newReview = Review(text: "")
        draftReviews.insert(newReview, at: 0)
        selectedIndex = 0
    }

    private func deleteReview(at index: Int) {
        guard draftReviews.indices.contains(index) else { return }
        draftReviews.remove(at: index)
        selectedIndex = max(0, min(selectedIndex, draftReviews.count - 1))
    }
}
