import Foundation
import RxSwift
import RxCocoa

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
