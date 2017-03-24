import UIKit
import RxSwift
import RxCocoa

class GistsTableViewController: UITableViewController {

	var viewModel = GistsViewModel()

	let bag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		print(#function)

//		viewModel.gists.asObservable().bindTo(tableView.rx.items(cellIdentifier: "GistCell", cellType: GistCell.self)) { (row, element, cell) in
//			cell.viewModel = GistCellViewModel(gist: element)
//			print("\(row) : \(element) : \(cell)")
//			}.disposed(by: bag)

		self.navigationItem.rightBarButtonItem = self.editButtonItem
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.rowsPerSection[section]
	}
}

class GistsViewModel {

	let bag = DisposeBag()
	var userName: String?
	var gists: BehaviorSubject<[Gist]> = BehaviorSubject(value: [])
	var numberOfSections: Int = 1
	var rowsPerSection: [Int] = [0]

	init() {
		print(#function)
		let url = URL(string: "https://api.github.com/users/trilliwon/gists")!
		URLSession.shared.rx.json(url: url).subscribe(onNext: { json in
			print("gists: \(json)")
			guard let gists = json as? [[String: Any]] else { return }
			self.rowsPerSection[0] = gists.count
			self.gists.onNext(gists.map({ Gist(json: $0) }))
		}).disposed(by: bag)

	}
}

class GistCell: UITableViewCell {

	@IBOutlet weak var fileNameLabel: UILabel!
	@IBOutlet weak var languageLabel: UILabel!
	let bag = DisposeBag()

	var viewModel: GistCellViewModel? {
		didSet {
			DispatchQueue.main.async {
				guard let viewModel = self.viewModel else { return }
				viewModel.fileName
					.bindTo(self.fileNameLabel.rx.text)
					.disposed(by: self.bag)
				viewModel.language
					.bindTo(self.languageLabel.rx.text)
					.disposed(by: self.bag)
			}
		}
	}
}

class GistCellViewModel {

	let disposeBag = DisposeBag()
	var fileName = PublishSubject<String>()
	var language = PublishSubject<String>()

	var gist: Gist? {
		didSet {
			guard let gist = gist else { return }
			URLSession.shared.rx.json(url: URL(string: "\(gist.rawUrl)")!)
				.subscribe(onNext: { json in
					guard let content = json as? String else { return }
					gist.content = content
					DispatchQueue.main.async {
						self.fileName.onNext(gist.fileName)
						self.language.onNext(gist.language)
					}
				}).disposed(by: self.disposeBag)
		}
	}

	init(gist: Gist) {
		self.gist = gist
	}
}

class Gist {
	var url: String = ""
	var htmlUrl: String = ""
	var rawUrl: String = ""
	var id: String = ""
	var language: String = ""
	var fileName: String = ""
	var content: String = ""
	var size: Int = 0
	var files: [String: Any]?

	init(json: [String: Any]) {
		self.url = json["url"] as? String ?? ""
		self.id = json["id"] as? String ?? ""
		self.htmlUrl = json["html_url"] as? String ?? ""

		guard
			let files = json["files"] as? [String: Any],
			let file = files.first,
			let value = file.value as? [String: Any] else { return }

		self.files = files
		self.language = value["language"] as? String ?? ""
		self.fileName = value["filename"] as? String ?? ""
		self.rawUrl = value["raw_url"] as? String ?? ""
		self.size = value["size"] as? Int ?? 0
	}
}
