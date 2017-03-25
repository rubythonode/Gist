import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

	enum ThemeApplied: Int {
		case tomorrow = 0
		case tomorrowBright = 1
	}

	fileprivate var contentView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize.zero))

	@IBOutlet weak var codeTextView: UITextView!

	fileprivate var manager = BundleManager {
		(identifier, isLanguage) -> (URL?) in
		typealias TmTypeGenerator = (String) -> TmType?

		let languageGen: TmTypeGenerator = { id in return TmLanguage(rawValue: id) }
		let themeGen: TmTypeGenerator = { id in return TmTheme(rawValue: id) }

		guard let type: TmType = isLanguage ? languageGen(identifier) : themeGen(identifier)
			else { return nil }

		return Bundle.main.url(forResource: type.fileName,
		                       withExtension: type.extensionType)
	}

	var content = ""

	@IBOutlet weak var themeSegmentedControl: UISegmentedControl!

	override func viewDidLoad() {
		super.viewDidLoad()
		updateViews(for: .tomorrow)
	}

	@IBAction func themeChanged(_ sender: UISegmentedControl) {
		guard let theme = ThemeApplied(rawValue: sender.selectedSegmentIndex) else { return }

		updateViews(for: theme)
	}

	fileprivate func updateViews(`for` theme: ThemeApplied) {
//		switch theme {
//		case .tomorrow:
////			scrollView?.backgroundColor = .white
//		case .tomorrowBright:
////			scrollView?.backgroundColor = .black
//		}
		setUpCodeTextView(with: theme)
	}

	fileprivate func setUpCodeTextView(with theme: ThemeApplied) {
		let codeString = generateCodeString(styledWith: theme)

		let frame = CGRect(x: 0, y: 10, width: codeString.size().width, height: view.frame.height - 10)
//		codeTextView.contentSize = codeTextView.frame.size
		codeTextView.attributedText = codeString
//		codeTextView.showsHorizontalScrollIndicator = true
//		codeTextView.isScrollEnabled = true
		self.view.addSubview(codeTextView)
	}

	fileprivate func generateCodeString(styledWith theme: ThemeApplied) -> NSAttributedString {
		let themeString: String

		switch theme {
		case .tomorrow: themeString = "Tomorrow"
		case .tomorrowBright: themeString = "Tomorrow-Night-Bright"
		}

		guard let font = UIFont(name: "Menlo-Regular", size: 14.0),
			let yaml = manager.language(withIdentifier: "Swift"),
			let themeToApply = manager.theme(withIdentifier: themeString) else { fatalError("Developer Error") }

		let layoutHandler = StringLayoutHandler(tabLength: .regular, font: font)
		let deserializedCode = layoutHandler.deserializedString(input: content)
		let attributedParser = AttributedParser(language: yaml, theme: themeToApply)
		let attributedCodeString = attributedParser.attributedString(for: deserializedCode)
		return layoutHandler.applyFont(to: attributedCodeString)
	}
}
