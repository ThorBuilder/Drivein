import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var drive: DriveMonitor
    @Environment(\.dismiss) private var dismiss
    @AppStorage("keepAudioWhileDriving") private var keepAudioWhileDriving = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $keepAudioWhileDriving) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Keep sound playing while driving")
                            Text("The picture is always hidden when the car moves. Turn this off to pause playback too.")
                                .font(.footnote)
                                .foregroundStyle(Color.muted)
                        }
                    }
                } header: {
                    Text("While driving")
                }

                Section {
                    HStack {
                        Text("Status")
                        Spacer()
                        DriveStatusPill()
                    }
                    Button("Location settings") { AppLauncher.openSettings() }
                } header: {
                    Text("Parked detection")
                } footer: {
                    Text("DriveIn reads your speed with GPS. Video unlocks after the car has been still for about 8 seconds.")
                }

                Section {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–")
                } header: {
                    Text("About")
                } footer: {
                    Text("DriveIn isn't affiliated with YouTube, Netflix or the other services listed. Their names belong to their owners.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.night)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
