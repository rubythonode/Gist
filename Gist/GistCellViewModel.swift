//
//  GistCellViewModel.swift
//  Gist
//
//  Created by Won on 22/05/2017.
//  Copyright © 2017 Won. All rights reserved.
//

import RxSwift
import RxCocoa

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
