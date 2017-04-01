import UIKit
import RxSwift
import RxCocoa

class GistsViewController: UIViewController, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var setUserNameButton: UIBarButtonItem!
	var viewModel: GistsViewModel!
	let bag = DisposeBag()

	override func viewWillAppear(_ animated: Bool) {

		if UserInfo.userName != "" {
			viewModel = GistsViewModel(userName: UserInfo.userName)
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

	init(userName: String) {
		let url = URL(string: "https://api.github.com/users/\(userName)/gists")!
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

