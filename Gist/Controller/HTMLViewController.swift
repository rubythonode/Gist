import UIKit
import WebKit

class HTMLViewController: UIViewController {

	var content: String?
	let webView = WKWebView()

	override func loadView() {
		self.view = UIView()
		self.view.backgroundColor = .gray
		guard let content = content else { return }
		webView.loadHTMLString("<html><body><p>Hello!</p></body></html>", baseURL: nil)
		self.view.addSubview(webView)
		print(content)
	}
}
