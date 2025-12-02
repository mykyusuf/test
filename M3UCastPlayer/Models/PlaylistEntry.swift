import Foundation

struct PlaylistEntry: Identifiable, Hashable {
    var id: String { url.absoluteString }
    let title: String
    let url: URL
    let details: String?
}
