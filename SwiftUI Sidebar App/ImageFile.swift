/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct ImageFile: Identifiable {

    let id = UUID()
    let url: URL

}

extension ImageFile: Equatable {
    static func ==(lhs: ImageFile, rhs: ImageFile) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
}
