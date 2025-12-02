import AVFoundation
import Combine
import Foundation
import SwiftUI

final class PlayerViewModel: ObservableObject {
    @Published var playlistURL: String = ""
    @Published var playlistEntries: [PlaylistEntry] = []
    @Published var chromecastDevices: [String] = []
    @Published var dlnaDevices: [String] = []

    private(set) var player: AVPlayer = AVPlayer()
    private let parser = M3UParser()
    private let castManager = CastManager()
    private var cancellables = Set<AnyCancellable>()

    var hasPlayableURL: Bool {
        URL(string: playlistURL) != nil || !playlistEntries.isEmpty
    }

    var nowPlayingTitle: String? {
        guard let currentItem = player.currentItem?.asset as? AVURLAsset else { return nil }
        if let match = playlistEntries.first(where: { $0.url == currentItem.url }) {
            return match.title
        }
        return currentItem.url.lastPathComponent
    }

    func loadAndPlay() {
        guard let url = URL(string: playlistURL) else { return }
        Task {
            await loadPlaylist(from: url)
            if let first = playlistEntries.first {
                play(first)
            } else {
                play(PlaylistEntry(title: url.lastPathComponent, url: url, details: "Direct stream"))
            }
        }
    }

    func loadPlaylist(from url: URL) async {
        do {
            let entries = try await parser.parse(from: url)
            await MainActor.run {
                playlistEntries = entries
            }
        } catch {
            await MainActor.run {
                playlistEntries = []
            }
        }
    }

    func play(_ entry: PlaylistEntry) {
        let item = AVPlayerItem(url: entry.url)
        player.replaceCurrentItem(with: item)
        player.play()
    }

    func prepareCastServices() {
        castManager.devicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] discovery in
                self?.chromecastDevices = discovery.chromecast
                self?.dlnaDevices = discovery.dlna
            }
            .store(in: &cancellables)

        castManager.startDiscovery()
    }

    func cast(toChromecast device: String) {
        guard let currentItem = player.currentItem as? AVPlayerItem, let urlAsset = currentItem.asset as? AVURLAsset else { return }
        castManager.cast(url: urlAsset.url, toChromecast: device, title: nowPlayingTitle)
    }

    func cast(toDLNA device: String) {
        guard let currentItem = player.currentItem as? AVPlayerItem, let urlAsset = currentItem.asset as? AVURLAsset else { return }
        castManager.cast(url: urlAsset.url, toDLNA: device, title: nowPlayingTitle)
    }
}
