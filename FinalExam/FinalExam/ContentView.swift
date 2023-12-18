import SwiftUI

struct ContentView: View {
    @State private var publicIP: String?
    @State private var isDateTimeViewPresented = false
    @State private var isIPViewPresented = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Useful Information")

                RectangleButton(title: "Date and Time") {
                    isDateTimeViewPresented.toggle()
                }
                .sheet(isPresented: $isDateTimeViewPresented) {
                    DateTimeView()
                }

                RectangleButton(title: "My Public IP") {
                    fetchPublicIP()
                    isIPViewPresented.toggle()
                }
                .sheet(isPresented: $isIPViewPresented) {
                    IPView(publicIP: publicIP ?? "")
                }

                if isIPViewPresented, let publicIP = publicIP {
                    Text("Public IP: \(publicIP)")
                        .foregroundColor(.black)
                }
            }
            .padding(4)
            .navigationBarHidden(true)
        }
    }

    private func fetchPublicIP() {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let ipAddress = try decoder.decode(IPAddress.self, from: data)
                DispatchQueue.main.async {
                    self.publicIP = ipAddress.ip
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        .resume()
    }
}

struct RectangleButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Rectangle()
            .frame(width: 200, height: 50)
            .foregroundColor(.white)
            .border(Color.black, width: 1)
            .overlay(
                Button(action: action) {
                    Text(title)
                        .foregroundColor(.black)
                }
            )
    }
}

struct IPAddress: Codable {
    let ip: String
}

struct DateTimeView: View {
    var body: some View {
        Text((formattedCurrentDateTime()))
            .foregroundColor(.black)
            .padding()
    }

    private func formattedCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm MM/dd/yyyy"
        return formatter.string(from: Date())
    }
}

struct IPView: View {
    let publicIP: String

    var body: some View {
        Text((publicIP))
            .foregroundColor(.black)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
