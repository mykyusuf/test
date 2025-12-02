import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @State private var presentCastSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("M3U or HLS URL", text: $viewModel.playlistURL)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                HStack {
                    Button(action: { viewModel.loadAndPlay() }) {
                        Label("Play Stream", systemImage: "play.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: { presentCastSheet = true }) {
                        Label("Cast", systemImage: "tv.and.mediabox")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!viewModel.hasPlayableURL)
                }

                if let nowPlaying = viewModel.nowPlayingTitle {
                    Text("Now Playing: \(nowPlaying)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VideoPlayer(player: viewModel.player)
                    .frame(height: 240)
                    .cornerRadius(16)
                    .padding(.top, 8)

                List(viewModel.playlistEntries) { entry in
                    Button(action: {
                        viewModel.play(entry)
                    }) {
                        VStack(alignment: .leading) {
                            Text(entry.title)
                                .font(.headline)
                            if let details = entry.details {
                                Text(details)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("M3U Cast Player")
            .sheet(isPresented: $presentCastSheet) {
                CastDestinationView(presented: $presentCastSheet)
                    .environmentObject(viewModel)
            }
            .onAppear {
                viewModel.prepareCastServices()
            }
        }
    }
}

struct CastDestinationView: View {
    @EnvironmentObject var viewModel: PlayerViewModel
    @Binding var presented: Bool

    var body: some View {
        NavigationStack {
            List {
                Section("Chromecast") {
                    if viewModel.chromecastDevices.isEmpty {
                        Text("Searching for Cast devices...")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(viewModel.chromecastDevices, id: \.self) { device in
                        Button(device) {
                            viewModel.cast(toChromecast: device)
                            presented = false
                        }
                    }
                }

                Section("DLNA / UPnP") {
                    if viewModel.dlnaDevices.isEmpty {
                        Text("Searching for DLNA renderers...")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(viewModel.dlnaDevices, id: \.self) { device in
                        Button(device) {
                            viewModel.cast(toDLNA: device)
                            presented = false
                        }
                    }
                }
            }
            .navigationTitle("Cast target")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { presented = false }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PlayerViewModel())
}
