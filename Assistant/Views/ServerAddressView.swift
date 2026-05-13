import AuthenticationServices
import Rainmaker
import SwiftUI

struct ServerAddressView: View {
    @Environment(Store.self) private var store
    @Environment(\.webAuthenticationSession) var webAuthenticationSession

    @FocusState var isServerAddressFocused: Bool

    @State var enteredServerAddress = ""

    @State var error: String?

    @State var isPolling = false

    var body: some View {
        VStack {
            Text("Enter Nextcloud Server Address")
            TextField("Enter Nextcloud Server Address", text: $enteredServerAddress, prompt: Text("https://"))
                .focused($isServerAddressFocused)
                .onSubmit {
                    dispatchLoginInformationRetrieval()
                }

            Button {
                dispatchLoginInformationRetrieval()
            } label: {
                Text("Login")
            }
        }
        .padding()
        .onAppear {
            isServerAddressFocused = true
        }
        .disabled(isPolling)
    }

    var sanitizedServerAddress: URL? {
        URL(string: enteredServerAddress.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func dispatchLoginInformationRetrieval() {
        guard let sanitizedServerAddress else {
            return
        }

        error = nil
        isPolling = true

        Task {
            do {
                let server = Server(address: sanitizedServerAddress, userAgent: Bundle.main.displayName)
                let loginFlow = try await server.login()

                // Present the login page for the user to authenticate
                _ = try? await webAuthenticationSession.authenticate(using: loginFlow.entry, callbackURLScheme: "nc")

                // Retrieve login credentials after the user completes authentication
                let loginResult = try await server.poll(loginFlow.endpoint, token: loginFlow.token)
                store.name = loginResult.name
                store.password = loginResult.password
                store.server = loginResult.server
            } catch {
                self.error = error.localizedDescription
            }

            isPolling = false
        }
    }
}

#Preview {
    ServerAddressView()
}
