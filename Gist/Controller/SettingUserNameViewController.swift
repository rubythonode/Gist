import UIKit
import RxSwift
import RxCocoa

class SettingUserNameViewController: UIViewController {

	@IBOutlet weak var saveBarButton: UIBarButtonItem!
	@IBOutlet weak var userNameTextField: UITextField!

	let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()

		saveBarButton.rx.tap
			.subscribe(onNext: {
				UserInfo.saveUserName(with: self.userNameTextField.text ?? "")
				self.dismiss(animated: true, completion: nil)
			}).disposed(by: disposeBag)
	}
}
