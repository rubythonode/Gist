import UIKit
import RxSwift
import RxCocoa

class GistsViewController: UIViewController, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	var viewModel = GistsViewModel()
	let bag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rx.setDelegate(self).disposed(by: bag)

		viewModel.gists.asObservable()
			.bindTo(tableView.rx.items(cellIdentifier: "GistCell", cellType: GistCell.self))
			{ (row, element, cell) in
				cell.viewModel = GistCellViewModel(gist: element)
			}.disposed(by: bag)

		tableView.rx.itemSelected.asObservable().subscribe(onNext: { item in
			self.viewModel.selectedIndexPath.value = item
		}).disposed(by: bag)
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.rowsPerSection[section]
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard let des = segue.destination as? DetailViewController else { return }
		guard let indexPath = tableView.indexPathForSelectedRow else { return }
		self.tableView.deselectRow(at: indexPath, animated: true)
		des.content = (viewModel.gists.value)[indexPath.row].content
	}
}

class GistsViewModel {
	let bag = DisposeBag()
	var userName: String?
	var gists: Variable<[Gist]> = Variable([])
	var selectedIndexPath: Variable<IndexPath> = Variable([])
	var numberOfSections: Int = 1
	var rowsPerSection: [Int] = [0]

	init() {
		let url = URL(string: "https://api.github.com/users/trilliwon/gists")!
		URLSession.shared.rx.json(url: url).subscribe(onNext: { json in
			print("content: \(json)")
			guard let gists = json as? [[String: Any]] else { return }
			self.rowsPerSection[0] = gists.count
			self.gists.value = gists.map({ Gist(json: $0) })
		}).disposed(by: bag)
	}
}

class GistCell: UITableViewCell {

	@IBOutlet weak var fileNameLabel: UILabel!
	@IBOutlet weak var languageLabel: UILabel!
	let bag = DisposeBag()

	var viewModel: GistCellViewModel? {
		didSet {
			self.viewModel?.fileName.bindTo(self.fileNameLabel.rx.text).disposed(by: self.bag)
			self.viewModel?.language.bindTo(self.languageLabel.rx.text).disposed(by: self.bag)
		}
	}
}

class GistCellViewModel {

	let bag = DisposeBag()
	var fileName = PublishSubject<String>()
	var language = PublishSubject<String>()
	let gist: Gist

	init(gist: Gist) {
		self.gist = gist
		DispatchQueue.main.async {
			self.fileName.onNext(gist.fileName)
			self.language.onNext(gist.language)

			URLSession.shared.rx.json(url: URL(string: "\(gist.rawUrl)")!)
				.subscribe(onNext: { json in
					guard let content = json as? String else { return }
					gist.content = content
				}).disposed(by: self.bag)
		}

		let request = URLRequest(url: URL(string: gist.rawUrl)!)
		URLSession.shared.rx.data(request: request)
			.subscribe(onNext: { data in
				guard let content = String(data: data, encoding: .utf8) else { return }
				gist.content = content
			}).disposed(by: self.bag)
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
