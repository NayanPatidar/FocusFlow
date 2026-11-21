
import SwiftUI
import UserNotifications

struct SettingsView: View {

    @AppStorage("appAppearance") private var appearance = "system"

    @State private var notificationStatus = "Checking..."
    @State private var showingPermissionAlert = false

    var body: some View {
        Form {

            // Appearance
            Section("Appearance") {
                Picker("Theme", selection: $appearance) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.segmented)
            }

            // Notifications
            Section("Notifications") {
                HStack {
                    Text("Permission Status")
                    Spacer()
                    Text(notificationStatus)
                        .foregroundStyle(.secondary)
                }

                Button("Request Notification Permission") {
                    requestNotificationPermission()
                }
            }

            // About
            Section("About") {
                HStack {
                    Text("App")
                    Spacer()
                    Text("FocusFlow")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkNotificationStatus()
        }
        .alert("Notification Permission", isPresented: $showingPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Notification permission request completed. If permission was denied previously, enable it from iOS Settings.")
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    notificationStatus = "Enabled"
                case .denied:
                    notificationStatus = "Denied"
                case .notDetermined:
                    notificationStatus = "Not Requested"
                @unknown default:
                    notificationStatus = "Unknown"
                }
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in
            checkNotificationStatus()

            DispatchQueue.main.async {
                showingPermissionAlert = true
            }
        }
    }
}
