import SwiftUI
import QuickLookThumbnailing
import UniformTypeIdentifiers
import QuickLook

struct ContentView: View {
    let fileManager = FileManager.default
    @State var currentDirectory = FileManager.default.urls(for: .userDirectory, in: .allDomainsMask)[0]
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        NavigationView {
            List {
                DisclosureGroup(isExpanded: .constant(true)) {
                    ForEach(getSubdirectories(in: currentDirectory), id: \.self) { url in
                        NavigationLink(destination: ContentView(currentDirectory: url)) {
                            Label(url.lastPathComponent, systemImage: "folder")
                        }
                    }
                } label: {
                    Label("Directories", systemImage: "folder")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(currentDirectory.lastPathComponent)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(getDirectoryContents(in: currentDirectory), id: \.self) { item in
                        VStack {
                            getThumbnail(for: item, in: currentDirectory)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 80, maxHeight: 80)
                                .foregroundColor(.accentColor)
                            Text(item)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .onTapGesture {
                            let fileURL = currentDirectory.appendingPathComponent(item)
                            if fileManager.isReadableFile(atPath: fileURL.path) {
                                NSWorkspace.shared.open(fileURL) // Open the file with the default app
                            }
                        }
                    }
                }
                .padding()
            }
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

    func getThumbnail(for item: String, in directory: URL) -> Image {
        let fileURL = directory.appendingPathComponent(item)
        let generator = QLThumbnailGenerator.shared
        let size = CGSize(width: 80, height: 80)
        let scale = NSScreen.main?.backingScaleFactor ?? 1.0
        let request = QLThumbnailGenerator.Request(fileAt: fileURL, size: size, scale: scale, representationTypes: .lowQualityThumbnail)

        var thumbnailImage: NSImage?
        let semaphore = DispatchSemaphore(value: 0)

        generator.generateRepresentations(for: request) { thumbnail, _, error in
            if let thumbnail = thumbnail {
                thumbnailImage = thumbnail.nsImage
            } else if let error = error {
                print("Error while generating thumbnail for \(item): \(error.localizedDescription)")
            } else {
                print("Error while generating thumbnail for \(item): Unknown error")
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

    func getSubdirectories(in directory: URL) -> [URL] {
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            let subdirectories = directoryContents.filter { (url: URL) -> Bool in
                var isDirectory: ObjCBool = false
                fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
                return isDirectory.boolValue
            }
            return subdirectories
        } catch {
            print("Error while enumerating directories \(directory.path): \(error.localizedDescription)")
            return []
        }
    }
}
