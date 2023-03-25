/*
See the License.txt file for this sample’s licensing information.
*/

import Foundation

extension FileManager {
    /// Returns the contents of the specified directory as an array of URLs.
    func getContentsOfDirectory(_ url: URL) -> [URL] {
        var isDirectory: ObjCBool = false
        // The URL must be a directory.
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue else { return [] }
        do {
            return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        } catch let error {
            print("Unable to get directory contents: \(error.localizedDescription)")
        }
        return []
    }
}
