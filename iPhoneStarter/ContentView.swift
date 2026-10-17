import SwiftUI

struct ContentView: View {
    @State private var showingAbout = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your next idea.")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .tracking(-0.8)

                        Text("A native iPhone app, ready to become something uniquely yours.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)

                    Button {
                        showingAbout = true
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "iphone.gen3")
                                .font(.system(size: 30, weight: .medium))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.primary)
                                .frame(width: 56, height: 56)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Made for iPhone")
                                    .font(.headline)
                                Text("Built with native SwiftUI")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.glass)
                    .accessibilityHint("Opens information about the starter app")

                    VStack(alignment: .leading, spacing: 14) {
                        Text("The foundation")
                            .font(.title2.weight(.semibold))

                        FeatureRow(
                            symbol: "moon.stars.fill",
                            title: "Dark by default",
                            subtitle: "A comfortable, low-glare interface"
                        )

                        FeatureRow(
                            symbol: "water.waves",
                            title: "Liquid Glass ready",
                            subtitle: "Native system controls plus a subtle glass surface"
                        )

                        FeatureRow(
                            symbol: "shippingbox.fill",
                            title: "Cloud IPA build",
                            subtitle: "A GitHub Actions workflow builds the iOS app package"
                        )
                    }
                    .padding(.top, 4)

                    Button {
                        showingAbout = true
                    } label: {
                        Label("About this starter app", systemImage: "info.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 36)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("iPhone Starter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAbout = true
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("About this app")
                }
            }
            .alert("Your app starts here", isPresented: $showingAbout) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This is the starter project. We can replace this screen with the features you choose next.")
            }
        }
    }
}

private struct FeatureRow: View {
    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}
