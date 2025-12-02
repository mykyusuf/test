import Combine
import Foundation
#if canImport(GoogleCast)
import GoogleCast
#endif

struct CastDiscovery {
    let chromecast: [String]
    let dlna: [String]
}

final class CastManager {
    private let discoverySubject = PassthroughSubject<CastDiscovery, Never>()
    var devicePublisher: AnyPublisher<CastDiscovery, Never> { discoverySubject.eraseToAnyPublisher() }

    private var discoveryTimer: Timer?

    func startDiscovery() {
        #if canImport(GoogleCast)
        configureCastContext()
        #endif
        startMockDiscovery()
    }

    func cast(url: URL, toChromecast device: String, title: String?) {
        #if canImport(GoogleCast)
        let metadata = GCKMediaMetadata()
        metadata.setString(title ?? url.lastPathComponent, forKey: kGCKMetadataKeyTitle)
        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: url)
        mediaInfoBuilder.streamType = .buffered
        mediaInfoBuilder.contentType = "application/x-mpegURL"
        mediaInfoBuilder.metadata = metadata

        let request = GCKSessionManager.shared().currentSession?.remoteMediaClient?
            .loadMedia(mediaInfoBuilder.build())
        request?.delegate = nil
        #else
        print("Chromecast cast requested for \(device): \(url)")
        #endif
    }

    func cast(url: URL, toDLNA device: String, title: String?) {
        // Stub for DLNA casting. In production, integrate a DLNA library such as UPnAtom or MRDLNA
        // and replace this diagnostic log with the renderer playback request.
        print("DLNA cast requested for \(device): \(url), title: \(title ?? url.lastPathComponent)")
    }

    private func startMockDiscovery() {
        discoveryTimer?.invalidate()
        discoveryTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            let chromecastDevices = ["Living Room TV", "Bedroom Chromecast"].shuffled().prefix(1)
            let dlnaDevices = ["Android TV", "Smart TV"]
            let payload = CastDiscovery(chromecast: Array(chromecastDevices), dlna: dlnaDevices)
            self?.discoverySubject.send(payload)
        }
        RunLoop.main.add(discoveryTimer!, forMode: .common)
    }

    #if canImport(GoogleCast)
    private func configureCastContext() {
        if GCKCastContext.sharedInstance().sessionManager.currentCastSession == nil {
            let options = GCKCastOptions(discoveryCriteria: .init(applicationID: kGCKDefaultMediaReceiverApplicationID))
            GCKCastContext.setSharedInstanceWith(options)
            GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        }
    }
    #endif
}
