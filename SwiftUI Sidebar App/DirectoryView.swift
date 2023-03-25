//
//  DirectoryView.swift
//  SwiftUI Sidebar App
//
//  Created by Joshua Germon on 25/3/2023.
//

import SwiftUI
import QuickLookThumbnailing

struct DirectoryView: View {
    let fileManager = FileManager.default
    @State var images: [ImageFile]
    let columns = [
        GridItem(.adaptive(minimum: 120))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(images) { item in
                    VStack {
                        getThumbnail(itemUrl: item.url)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 120, maxHeight: 120)
                            .foregroundColor(.accentColor)
                            .fontWeight(.light)
                        Text(item.url.lastPathComponent)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding()
                    .cornerRadius(8.0)
                }
            }
            .padding()
        }
    }
    
    func getDirectoryContents(in directory: URL) -> [String] {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return fileURLs.map { $0.lastPathComponent }
        } catch {
            print("Error while enumerating files \(directory.path): \(error.localizedDescription)")
            return []
        }
    }
    
    func getThumbnail(itemUrl: URL) -> Image {
        let generator = QLThumbnailGenerator.shared
        let size = CGSize(width: 80, height: 80)
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0
        let request = QLThumbnailGenerator.Request(fileAt: itemUrl, size: size, scale: scale, representationTypes: .lowQualityThumbnail)

        var thumbnailImage: NSImage?
        let semaphore = DispatchSemaphore(value: 0)

        generator.generateRepresentations(for: request) { thumbnail, _, error in
            if let thumbnail = thumbnail {
                thumbnailImage = thumbnail.nsImage
            } else if let error = error {
                print("Error while generating thumbnail for \(itemUrl): \(error.localizedDescription)")
            } else {
                print("Error while generating thumbnail for \(itemUrl): Unknown error")
            }
            semaphore.signal()
        }

        semaphore.wait()

        if let thumbnailImage = thumbnailImage {
            return Image(nsImage: thumbnailImage)
        } else {
            return Image(systemName: "doc")
        }
    }
}

//struct DirectoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        DirectoryView(imageListModel: ImageListModel(directory: FileManager.default.homeDirectoryForCurrentUser))
//    }
//}
