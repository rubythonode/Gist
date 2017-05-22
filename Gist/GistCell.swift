//
//  GistCell.swift
//  Gist
//
//  Created by Won on 22/05/2017.
//  Copyright © 2017 Won. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GistCell: UITableViewCell {

	@IBOutlet weak var fileNameLabel: UILabel!
	@IBOutlet weak var languageLabel: UILabel!

	let bag = DisposeBag()

	var viewModel: GistCellViewModel? {
		didSet {
			self.viewModel?.fileName.bind(to: self.fileNameLabel.rx.text).disposed(by: self.bag)
			self.viewModel?.language.bind(to: self.languageLabel.rx.text).disposed(by: self.bag)
		}
	}
}
