/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation

class DirectoryModel: ObservableObject {
    
    @Published var selectedDirectory: URL? {
        didSet {
            loadImages()
        }
    }
    @Published var imageFiles: [ImageFile] = []

    init() {
        self.selectedDirectory = FileManager.default.homeDirectoryForCurrentUser
        self.loadImages()
    }

    func loadImages() {
        if let directory = selectedDirectory {
            let urls = FileManager.default.getContentsOfDirectory(directory).filter { $0.isImage }
            for url in urls {
                let item = ImageFile(url: url)
                imageFiles.append(item)
            }
        }
    }
}

extension URL {
    /// Indicates whether the URL has a file extension corresponding to a common image format.
    var isImage: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic", "ARW", "CR2", "DNG"]
        return imageExtensions.contains(self.pathExtension)
    }
}

