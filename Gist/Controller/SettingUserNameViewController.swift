//
//  SettingUserNameViewController.swift
//  Gist
//
//  Created by Won on 22/05/2017.
//  Copyright © 2017 Won. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingUserNameViewController: UIViewController {

	@IBOutlet weak var saveBarButton: UIBarButtonItem!
	@IBOutlet weak var userNameTextField: UITextField!

	let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		userNameTextField.rx.text.orEmpty
			.bind {
				UserInfo.userName = $0
		}.disposed(by: disposeBag)
	}
}
