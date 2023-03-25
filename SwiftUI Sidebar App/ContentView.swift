import SwiftUI
import QuickLookThumbnailing
import UniformTypeIdentifiers
import QuickLook

struct ContentView: View {
    let fileManager = FileManager.default
    @StateObject var directory = DirectoryModel()
    
    var body: some View {
        NavigationView {
            List {
                DisclosureGroup(isExpanded: .constant(true)) {
                    ForEach(getSubdirectories(in: directory.selectedDirectory!), id: \.self) { url in
                        NavigationLink(destination: ContentView()) {
                            Label(url.lastPathComponent, systemImage: "folder")
                        }
                    }
                } label: {
                    Label("Directories", systemImage: "folder")
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle(directory.selectedDirectory!.lastPathComponent)

            DirectoryView(images: directory.imageFiles)
        }.toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: { // 1
                    Image(systemName: "sidebar.leading")
                })
            }
        }
    }
    
    private func toggleSidebar() { // 2
        #if os(iOS)
        #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
