//
//  GistsViewModel.swift
//  Gist
//
//  Created by Won on 22/05/2017.
//  Copyright © 2017 Won. All rights reserved.
//

import RxSwift
import RxCocoa

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
