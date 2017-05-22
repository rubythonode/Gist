//
//  GistsViewController.swift
//  Gist
//
//  Created by Won on 22/05/2017.
//  Copyright © 2017 Won. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GistsViewController: UIViewController, UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!

	var viewModel: GistsViewModel!
	let bag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.rx
			.setDelegate(self)
			.disposed(by: bag)

		if UserInfo.userName != "" {

			viewModel = GistsViewModel(userName: UserInfo.userName)

			viewModel.gists.asObservable()
				.bind(to: tableView.rx.items(cellIdentifier: "GistCell", cellType: GistCell.self))
				{ (row, element, cell) in
					cell.viewModel = GistCellViewModel(gist: element)
				}.disposed(by: bag)

			tableView.rx.itemSelected.asObservable()
				.subscribe(onNext: { item in
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
		des.gist = (viewModel.gists.value)[indexPath.row]
	}
}
