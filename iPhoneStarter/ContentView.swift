import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import UIKit

private enum ShareDropTab: Hashable {
    case send
    case activity
    case settings
}

private struct PreparedFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let kind: String

    var extensionLabel: String {
        let value = url.pathExtension.uppercased()
        return value.isEmpty ? kind.uppercased() : value
    }

    var sizeLabel: String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? NSNumber else {
            return "Ready to share"
        }
        return ByteCountFormatter.string(fromByteCount: size.int64Value, countStyle: .file)
    }

    var symbol: String {
        let ext = url.pathExtension.lowercased()
        if ["jpg", "jpeg", "png", "heic", "gif", "webp", "tif", "tiff"].contains(ext) {
            return "photo.fill"
        }
        if ["mov", "mp4", "m4v", "avi"].contains(ext) {
            return "film.fill"
        }
        if ext == "pdf" {
            return "doc.richtext.fill"
        }
        if ["zip", "rar", "7z", "tar", "gz"].contains(ext) {
            return "archivebox.fill"
        }
        return "doc.fill"
    }
}

struct ContentView: View {
    @State private var selectedTab: ShareDropTab = .send
    @State private var selectedFiles: [PreparedFile] = []
    @State private var recentFiles: [PreparedFile] = []
    @State private var photoSelection: [PhotosPickerItem] = []
    @State private var showingFileImporter = false
    @State private var showingPhotoPicker = false
    @State private var showingShareSheet = false
    @State private var isImportingPhotos = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            ShareDropPalette.background.ignoresSafeArea()
            LinearGradient(
                colors: [ShareDropPalette.glow.opacity(0.17), .clear, ShareDropPalette.blue.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                NavigationStack {
                    sendScreen
                }
                .tabItem { Label("Send", systemImage: "paperplane.fill") }
                .tag(ShareDropTab.send)

                NavigationStack {
                    activityScreen
                }
                .tabItem { Label("Activity", systemImage: "clock.arrow.circlepath") }
                .tag(ShareDropTab.activity)

                NavigationStack {
                    settingsScreen
                }
                .tabItem { Label("Settings", systemImage: "slider.horizontal.3") }
                .tag(ShareDropTab.settings)
            }
            .tint(ShareDropPalette.accent)
        }
        .preferredColorScheme(.dark)
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true,
            onCompletion: handleFileImport
        )
        .photosPicker(
            isPresented: $showingPhotoPicker,
            selection: $photoSelection,
            maxSelectionCount: 12,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: photoSelection) { _, items in
            guard !items.isEmpty else { return }
            Task { await importPhotos(items) }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: selectedFiles.map(\.url))
                .presentationDetents([.medium, .large])
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Please try again.")
        }
    }

    private var sendScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 25) {
                brandHeader
                heroCard
                sourcePickerSection
                if !selectedFiles.isEmpty {
                    selectedFilesSection
                }
                recentSection
                privacyNote
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(Color.clear)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var brandHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(LinearGradient(
                        colors: [ShareDropPalette.accent, ShareDropPalette.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 49, height: 49)
            .glassEffect(.regular.tint(ShareDropPalette.accent.opacity(0.18)), in: RoundedRectangle(cornerRadius: 17, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text("ShareDrop")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .tracking(-0.7)
                    .foregroundStyle(.white)
                Text("MOVE WITHOUT FRICTION")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(ShareDropPalette.secondaryText)
            }

            Spacer()

            Button {
                selectedTab = .settings
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }
            .buttonStyle(.glass)
            .accessibilityLabel("Settings")
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 7) {
                Circle()
                    .fill(ShareDropPalette.accent)
                    .frame(width: 6, height: 6)
                Text("A FRESH WAY TO SHARE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(Color.white.opacity(0.84))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(.white.opacity(0.08), in: Capsule())
            .glassEffect(.clear, in: Capsule())

            Text("Your files.\nReady to move.")
                .font(.system(size: 35, weight: .bold, design: .rounded))
                .tracking(-1.25)
                .lineSpacing(-1)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)

            Text("Choose photos or documents to get started. Simple, focused, and built for iPhone.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.70))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)

            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 10, weight: .bold))
                Text("YOU CHOOSE WHERE TO SHARE")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(1.1)
            }
            .foregroundStyle(Color.white.opacity(0.85))
            .padding(.top, 23)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(LinearGradient(
                        colors: [ShareDropPalette.heroTop, ShareDropPalette.heroBottom, ShareDropPalette.blue.opacity(0.65)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                Circle()
                    .stroke(.white.opacity(0.075), lineWidth: 1)
                    .frame(width: 215, height: 215)
                    .offset(x: 75, y: -84)
                Circle()
                    .stroke(ShareDropPalette.accent.opacity(0.18), lineWidth: 1)
                    .frame(width: 155, height: 155)
                    .offset(x: 45, y: -52)
                Circle()
                    .fill(ShareDropPalette.accent.opacity(0.10))
                    .frame(width: 110, height: 110)
                    .blur(radius: 2)
                    .offset(x: 18, y: -26)
            }
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.11), lineWidth: 1)
        }
        .shadow(color: ShareDropPalette.blue.opacity(0.18), radius: 28, x: 0, y: 12)
    }

    private var sourcePickerSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeading("Start with a file", detail: "Choose what you want to share")

            HStack(spacing: 12) {
                Button {
                    showingFileImporter = true
                } label: {
                    VStack(alignment: .leading, spacing: 15) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundStyle(ShareDropPalette.accent)
                            .frame(width: 43, height: 43)
                            .background(ShareDropPalette.accent.opacity(0.13), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Browse files")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("PDFs, videos and more")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(ShareDropPalette.secondaryText)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
                    .padding(15)
                    .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                    .glassEffect(.regular.tint(ShareDropPalette.accent.opacity(0.08)), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 23, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    showingPhotoPicker = true
                } label: {
                    VStack(alignment: .leading, spacing: 15) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 21, weight: .semibold))
                            .foregroundStyle(ShareDropPalette.violet)
                            .frame(width: 43, height: 43)
                            .background(ShareDropPalette.violet.opacity(0.13), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Photos")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("Choose images")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(ShareDropPalette.secondaryText)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
                    .padding(15)
                    .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                    .glassEffect(.regular.tint(ShareDropPalette.violet.opacity(0.09)), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 23, style: .continuous)
                            .stroke(.white.opacity(0.08), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
            .disabled(isImportingPhotos)
            .opacity(isImportingPhotos ? 0.6 : 1)

            if isImportingPhotos {
                HStack(spacing: 10) {
                    ProgressView().tint(ShareDropPalette.accent)
                    Text("Preparing your photos…")
                        .font(.subheadline)
                        .foregroundStyle(ShareDropPalette.secondaryText)
                }
                .padding(.top, 2)
            }
        }
    }

    private var selectedFilesSection: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .firstTextBaseline) {
                sectionHeading("Ready to share", detail: "\(selectedFiles.count) \(selectedFiles.count == 1 ? "item" : "items") selected")
                Spacer(minLength: 8)
                Button("Clear") {
                    selectedFiles.removeAll()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ShareDropPalette.secondaryText)
            }

            VStack(spacing: 0) {
                ForEach(Array(selectedFiles.prefix(4))) { file in
                    PreparedFileRow(file: file) {
                        selectedFiles.removeAll { $0.id == file.id }
                    }
                    if file.id != selectedFiles.prefix(4).last?.id {
                        Divider().overlay(.white.opacity(0.06)).padding(.leading, 60)
                    }
                }
                if selectedFiles.count > 4 {
                    Text("+ \(selectedFiles.count - 4) more items")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(ShareDropPalette.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 17)
                        .padding(.vertical, 12)
                }
            }
            .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 23, style: .continuous))
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 23, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 23, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            }

            Button {
                showingShareSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .bold))
                    Text("Open sharing options")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 18)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .tint(ShareDropPalette.accent)
            .disabled(selectedFiles.isEmpty)
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading("Recently prepared", detail: "On this iPhone")

            if recentFiles.isEmpty {
                HStack(spacing: 13) {
                    Image(systemName: "clock")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ShareDropPalette.secondaryText)
                        .frame(width: 43, height: 43)
                        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nothing here yet")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.92))
                        Text("Files you prepare will show up here.")
                            .font(.system(size: 12))
                            .foregroundStyle(ShareDropPalette.secondaryText)
                    }
                    Spacer(minLength: 0)
                }
                .padding(15)
                .background(.white.opacity(0.025), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 21, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recentFiles.prefix(3))) { file in
                        PreparedFileRow(file: file, onRemove: nil)
                        if file.id != recentFiles.prefix(3).last?.id {
                            Divider().overlay(.white.opacity(0.06)).padding(.leading, 60)
                        }
                    }
                }
                .background(.white.opacity(0.025), in: RoundedRectangle(cornerRadius: 21, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 21, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                }
            }
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: 11) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ShareDropPalette.accent)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text("You stay in control")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                Text("ShareDrop prepares files on your device. The iPhone sharing menu lets you choose the destination.")
                    .font(.system(size: 11))
                    .foregroundStyle(ShareDropPalette.secondaryText)
                    .lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
        .padding(.top, 1)
    }

    private var activityScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                screenHeading("Activity", subtitle: "Your recently prepared files")
                if recentFiles.isEmpty {
                    emptyState(
                        symbol: "clock.arrow.circlepath",
                        title: "Your activity starts here",
                        subtitle: "When you choose files or photos, they’ll appear in this list."
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(recentFiles) { file in
                            PreparedFileRow(file: file, onRemove: nil)
                            if file.id != recentFiles.last?.id {
                                Divider().overlay(.white.opacity(0.06)).padding(.leading, 60)
                            }
                        }
                    }
                    .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                Text("This list shows files prepared in the current app session. It does not claim that a transfer has completed.")
                    .font(.system(size: 12))
                    .foregroundStyle(ShareDropPalette.secondaryText)
                    .lineSpacing(3)
            }
            .padding(20)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(Color.clear)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var settingsScreen: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                screenHeading("Settings", subtitle: "A quieter, more considered way to share")

                VStack(spacing: 0) {
                    SettingsRow(
                        symbol: "hand.raised.fill",
                        title: "Privacy first",
                        subtitle: "Files are prepared locally before you choose a share destination.",
                        tint: ShareDropPalette.accent
                    )
                    Divider().overlay(.white.opacity(0.06)).padding(.leading, 62)
                    SettingsRow(
                        symbol: "iphone.gen3",
                        title: "Made for iPhone",
                        subtitle: "Native SwiftUI controls and the system sharing experience.",
                        tint: ShareDropPalette.violet
                    )
                    Divider().overlay(.white.opacity(0.06)).padding(.leading, 62)
                    SettingsRow(
                        symbol: "info.circle.fill",
                        title: "About ShareDrop",
                        subtitle: "Version 0.2 · Early development build",
                        tint: ShareDropPalette.blue
                    )
                }
                .background(.white.opacity(0.035), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.07), lineWidth: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("IN DEVELOPMENT")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .tracking(1.4)
                        .foregroundStyle(ShareDropPalette.accent)
                    Text("Direct device discovery and ShareDrop-to-ShareDrop transfers are the next milestone. This build currently uses the native iPhone sharing menu after you select files.")
                        .font(.system(size: 13))
                        .foregroundStyle(ShareDropPalette.secondaryText)
                        .lineSpacing(3)
                }
                .padding(17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ShareDropPalette.accent.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(ShareDropPalette.accent.opacity(0.12), lineWidth: 1)
                }
            }
            .padding(20)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(Color.clear)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func sectionHeading(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .tracking(-0.35)
                .foregroundStyle(.white)
            Text(detail)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ShareDropPalette.secondaryText)
        }
    }

    private func screenHeading(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ShareDrop")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(ShareDropPalette.accent)
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .tracking(-1)
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(ShareDropPalette.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }

    private func emptyState(symbol: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(ShareDropPalette.accent)
                .frame(width: 68, height: 68)
                .background(ShareDropPalette.accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .glassEffect(.regular.tint(ShareDropPalette.accent.opacity(0.08)), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(ShareDropPalette.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 38)
        .padding(.horizontal, 22)
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.03), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.07), lineWidth: 1)
        }
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            do {
                let imported = try urls.map { try copyExternalFile($0) }
                addPreparedFiles(imported)
            } catch {
                errorMessage = "Some files could not be imported. \(error.localizedDescription)"
            }
        case .failure(let error):
            if (error as NSError).code != NSUserCancelledError {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func copyExternalFile(_ source: URL) throws -> PreparedFile {
        let didStartAccessing = source.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing { source.stopAccessingSecurityScopedResource() }
        }

        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ShareDropImports", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let destination = folder.appendingPathComponent(UUID().uuidString + "-" + source.lastPathComponent)
        try FileManager.default.copyItem(at: source, to: destination)
        return PreparedFile(url: destination, name: source.lastPathComponent, kind: "file")
    }

    @MainActor
    private func importPhotos(_ items: [PhotosPickerItem]) async {
        isImportingPhotos = true
        defer {
            isImportingPhotos = false
            photoSelection = []
        }

        do {
            let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ShareDropImports", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            var imported: [PreparedFile] = []

            for item in items {
                guard let data = try await item.loadTransferable(type: Data.self) else { continue }
                let fileExtension = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
                let fileURL = folder.appendingPathComponent(UUID().uuidString + "." + fileExtension)
                try data.write(to: fileURL, options: .atomic)
                imported.append(PreparedFile(url: fileURL, name: "Photo \(imported.count + 1).\(fileExtension)", kind: "photo"))
            }

            guard !imported.isEmpty else {
                errorMessage = "The selected photos could not be prepared. Please try selecting them again."
                return
            }
            addPreparedFiles(imported)
        } catch {
            errorMessage = "The selected photos could not be imported. \(error.localizedDescription)"
        }
    }

    private func addPreparedFiles(_ files: [PreparedFile]) {
        guard !files.isEmpty else { return }
        selectedFiles.append(contentsOf: files)
        recentFiles = Array((files.reversed() + recentFiles).prefix(12))
    }
}

private struct PreparedFileRow: View {
    let file: PreparedFile
    let onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(ShareDropPalette.accent)
                .frame(width: 42, height: 42)
                .background(ShareDropPalette.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 13, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(1)
                Text("\(file.extensionLabel) · \(file.sizeLabel)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ShareDropPalette.secondaryText)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(ShareDropPalette.secondaryText)
                        .frame(width: 30, height: 30)
                        .background(.white.opacity(0.05), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(file.name)")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(ShareDropPalette.accent.opacity(0.9))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct SettingsRow: View {
    let symbol: String
    let title: String
    let subtitle: String
    let tint: Color
    var showsChevron = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.11), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(ShareDropPalette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            Spacer(minLength: 4)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(ShareDropPalette.secondaryText)
            }
        }
        .padding(15)
        .contentShape(Rectangle())
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [URL]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

private enum ShareDropPalette {
    static let background = Color(red: 0.025, green: 0.035, blue: 0.065)
    static let heroTop = Color(red: 0.075, green: 0.13, blue: 0.23)
    static let heroBottom = Color(red: 0.04, green: 0.075, blue: 0.14)
    static let accent = Color(red: 0.27, green: 0.82, blue: 0.98)
    static let blue = Color(red: 0.18, green: 0.39, blue: 0.90)
    static let glow = Color(red: 0.12, green: 0.55, blue: 0.92)
    static let violet = Color(red: 0.66, green: 0.52, blue: 1.0)
    static let secondaryText = Color(red: 0.60, green: 0.66, blue: 0.76)
}
