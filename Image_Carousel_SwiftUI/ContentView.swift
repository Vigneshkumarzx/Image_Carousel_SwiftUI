//
//  ContentView.swift
//  Image_Carousel_SwiftUI
//
//  Created by vignesh kumar c on 18/09/24.
//

import SwiftUI

struct CarouselView: View {
    let images = ["image2", "image3", "image4", "image5", "image6", "image7", "image8", "image9", "image10"]
    let names = ["Image 2", "Image 3", "Image 4", "Image 5", "Image 6", "Image 7", "Image 8", "Image 9", "Image 10"]
    let subNames = ["Description 1", "Description 2", "Description 3", "Description 4", "Description 5", "Description 6", "Description 7", "Description 8", "Description 9", "Description 10"]

    @State private var currentIndex = 0
    @State private var searchText = ""
    @State private var isSearchBarPinned = false
    @State private var showBottomSheet = false

    var filteredIndices: [Int] {
        if searchText.isEmpty {
            return Array(0..<images.count)
        } else {
            return names.enumerated().compactMap { index, name in
                name.localizedCaseInsensitiveContains(searchText) ? index : nil
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 10) {
                    TabView(selection: $currentIndex) {
                        ForEach(filteredIndices.indices, id: \.self) { index in
                            Image(images[filteredIndices[index]])
                                .resizable()
                                .scaledToFit()
                                .tag(filteredIndices[index])
                                .cornerRadius(10)
                                .padding(30)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 300)
                    .onAppear {
                        currentIndex = filteredIndices.first ?? 0
                    }
                    .onChange(of: searchText) { _ in
                        currentIndex = filteredIndices.first ?? 0
                    }
                    .onChange(of: currentIndex) { newIndex in
                        if newIndex < filteredIndices.count {
                            currentIndex = filteredIndices[newIndex]
                        } else {
                            currentIndex = filteredIndices.last ?? 0
                        }
                    }

                    PageControl(numberOfPages: filteredIndices.count, currentPage: Binding(
                        get: { filteredIndices.firstIndex(of: currentIndex) ?? 0 },
                        set: { newIndex in
                            if newIndex < filteredIndices.count {
                                currentIndex = filteredIndices[newIndex]
                            }
                        }
                    ))
                    .frame(width: 100, height: 20)

                    GeometryReader { geometry in
                        let searchBarOffset = geometry.frame(in: .global).minY
                        Color.clear
                            .onChange(of: searchBarOffset) { newValue in
                                isSearchBarPinned = newValue <= 0
                            }
                            .frame(height: 0)
                    }
                    .frame(height: 0)

                    // Search view
                    if isSearchBarPinned {
                        SearchBar(text: $searchText)
                            .padding(.top, 10)
                            .zIndex(1)
                    } else {
                        SearchBar(text: $searchText)
                            .padding(.top, 10)
                    }

                    if let currentItemIndex = filteredIndices.firstIndex(of: currentIndex) {
                        HStack(spacing: 10) {
                            Image(images[filteredIndices[currentItemIndex]])
                                .resizable()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                                .padding([.top, .leading], 10)
                                .padding(.bottom, 10)
                            VStack {
                                Text(names[filteredIndices[currentItemIndex]])
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                                Text(subNames[filteredIndices[currentItemIndex]])
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(3)
                    }
                    
                    ForEach(0..<images.count, id: \.self) { index in
                        HStack(spacing: 10) {
                            Image(images[index])
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                                .padding([.leading, .top, .bottom], 10)

                            VStack(alignment: .leading) {
                                Text(names[index])
                                    .font(.system(size: 16))
                                Text(subNames[index])
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .padding(3)
                    }

                    Spacer()
                }
            }

            if isSearchBarPinned {
                SearchBar(text: $searchText)
                    .padding(.top, 10)
                    .background(Color.white)
                    .shadow(radius: 2)
                    .animation(.easeInOut, value: isSearchBarPinned)
                    .transition(.move(edge: .top))
            }
         
            
            VStack {
                   Spacer()

                   HStack {
                       Spacer()
                       Button(action: {
                           showBottomSheet.toggle()
                       }) {
                           Image(systemName: "ellipsis")
                               .font(.system(size: 24))
                               .foregroundColor(.white)
                               .padding()
                               .background(Color.blue)
                               .clipShape(Circle())
                               .shadow(radius: 5)
                               .rotationEffect(.degrees(90))
                       }
                       .padding()
                   }
               }
            
        }
        .sheet(isPresented: $showBottomSheet) {
            BottomSheetView(show: $showBottomSheet, itemCount: filteredIndices.count, topCharacters: topThreeCharacters())
        }
    }
    
    func topThreeCharacters() -> [(character: Character, count: Int)] {
        let text = names.joined()
        var characterCount = [Character: Int]()

        for char in text {
            characterCount[char, default: 0] += 1
        }

        let sortedCharacters = characterCount.sorted { $0.value > $1.value }
        return sortedCharacters.prefix(3).map { (character: $0.key, count: $0.value) }
    }
}

struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPage = currentPage
        control.pageIndicatorTintColor = UIColor.lightGray
        control.currentPageIndicatorTintColor = UIColor.black
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            TextField("Search...", text: $text)
                .padding(10)
                .padding(.leading, 30)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 22)
                .offset(y: 2)
        }
        .frame(height: 40)
        .padding(.vertical, 5)
    }
}

#Preview {
    CarouselView()
}

struct BottomSheetView: View {
    @Binding var show: Bool
    let itemCount: Int
    let topCharacters: [(character: Character, count: Int)]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Statistics")
                    .font(.headline)
                    .padding()

                Text("Total Items: \(itemCount)")
                    .font(.subheadline)

                Text("Top 3 Characters:")
                    .font(.subheadline)

                ForEach(topCharacters, id: \.character) { characterInfo in
                    Text("\(characterInfo.character): \(characterInfo.count)")
                }

                Spacer()

                Button("Close") {
                    show = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
    }
}

