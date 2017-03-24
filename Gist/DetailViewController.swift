import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

	var content: String?
	@IBOutlet weak var textView: UITextView!

	override func viewDidLoad() {
		super.viewDidLoad()
		textView.text = content ?? ""
	}
}
