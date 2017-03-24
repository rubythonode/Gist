import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
//	@IBOutlet weak var fetchButton: UIButton!

//	let viewModel = GistViewModel()
//	let disposeBag = DisposeBag()

	override func viewDidLoad() {
		super.viewDidLoad()
//		fetchButton.rx.tap.asObservable().bindTo(viewModel.fetchButton).disposed(by: disposeBag)
//		viewModel.result.bindTo(textView.rx.text).disposed(by: disposeBag)
	}
}
