//
//  DetailViewController.swift
//  Gist
//
//  Created by Won on 22/05/2017.
//  Copyright © 2017 Won. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

class DetailViewController: UIViewController {

	@IBOutlet weak var loadHTML: UIBarButtonItem!
	@IBOutlet weak var codeTextView: UITextView!

	var content = ""

	var gist: Gist? {
		didSet {
			self.content = gist?.content ?? ""
		}
	}

	let bag = DisposeBag()

	fileprivate var manager = BundleManager {
		(identifier, isLanguage) -> (URL?) in typealias TmTypeGenerator = (String) -> TmType?
		let languageGen: TmTypeGenerator = { id in return TmLanguage(rawValue: id) }
		let themeGen: TmTypeGenerator = { id in return TmTheme(rawValue: id) }

		guard let type: TmType = isLanguage ? languageGen(identifier) : themeGen(identifier) else { return nil }
		return Bundle.main.url(forResource: type.fileName, withExtension: type.extensionType)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpCodeTextView()

		loadHTML.rx.tap
			.subscribe(onNext: {
				print(#function)
				guard let gist = self.gist else { return }
				let htmlView: SFSafariViewController = SFSafariViewController(url: URL(string: gist.htmlUrl)!)
				self.present(htmlView, animated: true, completion: nil)
			}).disposed(by: bag)
	}

	fileprivate func setUpCodeTextView() {
		let codeString = generateCodeString(with: content)
		codeTextView.backgroundColor = .black
		codeTextView.attributedText = codeString
		self.view.addSubview(codeTextView)
	}

	fileprivate func generateCodeString(with content: String) -> NSAttributedString {

		let themeString: String = "Tomorrow-Night-Bright"

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
