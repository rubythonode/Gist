import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

	enum ThemeApplied: Int {
		case tomorrow = 0
		case tomorrowBright = 1
	}

	fileprivate var scrollView: UIScrollView?

	fileprivate var contentView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize.zero))

	fileprivate var codeLabel: UILabel?

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
		setUpScrollView()
		updateViews(for: .tomorrow)
	}

	@IBAction func themeChanged(_ sender: UISegmentedControl) {
		guard let theme = ThemeApplied(rawValue: sender.selectedSegmentIndex) else { return }

		updateViews(for: theme)
	}

	fileprivate func setUpScrollView() {
		scrollView = UIScrollView()
		guard let scrollView = self.scrollView else { fatalError() }
		let views: [String: UIView] = ["scrollView": scrollView, "segmented": themeSegmentedControl]
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		var constraints = [NSLayoutConstraint]()
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: views)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[segmented]-[scrollView]|", options: [], metrics: nil, views: views)

		NSLayoutConstraint.activate(constraints)
	}

	fileprivate func updateViews(`for` theme: ThemeApplied) {
		switch theme {
		case .tomorrow:
			scrollView?.backgroundColor = .white
		case .tomorrowBright:
			scrollView?.backgroundColor = .black
		}
		setUpCodeLabel(with: theme)
	}

	fileprivate func setUpCodeLabel(with theme: ThemeApplied) {
		let codeString = generateCodeString(styledWith: theme)

		self.codeLabel?.removeFromSuperview()
		let codeLabel = UILabel()
		codeLabel.attributedText = codeString
		codeLabel.frame.size = codeString.size()
		codeLabel.frame.origin = CGPoint(x: 5, y: 5)
		codeLabel.numberOfLines = 0
		self.codeLabel = codeLabel
		scrollView?.contentSize = CGSize(width: codeString.size().width + 10, height: codeString.size().height + 10)
		scrollView?.addSubview(codeLabel)
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
