import Foundation

actor M3UParser {
    enum ParserError: Error {
        case invalidResponse
    }

    func parse(from url: URL) async throws -> [PlaylistEntry] {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ParserError.invalidResponse
        }
        guard let body = String(data: data, encoding: .utf8) else { return [] }
        return parse(body: body, baseURL: url.deletingLastPathComponent())
    }

    func parse(body: String, baseURL: URL) -> [PlaylistEntry] {
        var entries: [PlaylistEntry] = []
        var currentTitle: String?
        var currentDetails: String?

        for line in body.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("#EXTINF:") {
                if let range = trimmed.range(of: ",") {
                    currentTitle = String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    currentDetails = String(trimmed[trimmed.index(after: trimmed.startIndex)..<range.lowerBound])
                }
                continue
            }

            if trimmed.hasPrefix("#") {
                continue
            }

            if let entryURL = URL(string: trimmed, relativeTo: baseURL) {
                let entry = PlaylistEntry(
                    title: currentTitle ?? entryURL.lastPathComponent,
                    url: entryURL,
                    details: currentDetails
                )
                entries.append(entry)
                currentTitle = nil
                currentDetails = nil
            }
        }

        return entries
    }
}
