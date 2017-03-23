import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var fetchButton: UIButton!

	let viewModel = ViewModel()
	let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		fetchButton.rx.tap.asObservable().bindTo(viewModel.fetchButton).disposed(by: disposeBag)
		viewModel.result.bindTo(textView.rx.text).disposed(by: disposeBag)
	}
}

class Gist {
	var type: String? // type
	var content: String? // content
	var language: String? // language
	var url: String? // raw_url
	var size: Int? // size
	var file: [String: Any]?

	init(json: [String: Any]) {
		guard let files = json["files"] as? [String: Any] else { return }
		self.file = files
	}
}

class ViewModel {

	private struct Constants {
		static let URLPrefix = "https://api.github.com/gists/"
		static let URLSuffix = "96252a53a6e6f44a14f3f891e202f049"
	}

	let disposeBag = DisposeBag()

	var fetchButton = PublishSubject<Void>()
	var result = PublishSubject<String>()

	var gist: Gist? {
		didSet {
			if let file = gist?.file {
				DispatchQueue.main.async {
					guard let file = file.first else { return }
					guard let value = file.value as? [String: Any] else { return }
					guard let content = value["content"] as? String else { return }
					self.result.onNext(content)
					print("didSet gist")
				}
			}
		}
	}

	init() {
		fetchButton.bindNext {
			URLSession.shared.rx.json(url: URL(string: "\(Constants.URLPrefix)\(Constants.URLSuffix)")!).subscribe(onNext: { json in
				guard let json = json as? [String: Any] else { return }
				self.gist = Gist(json: json)
			}).disposed(by: self.disposeBag)
		}.disposed(by: disposeBag)
	}
}
