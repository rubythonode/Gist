import UIKit

struct UserInfo {
	static var userName: String {
		return UserDefaults.standard.string(forKey: "gist_user_name") ?? ""
	}

	static func saveUserName(with userName: String) {
		UserDefaults.standard.set(userName, forKey: "gist_user_name")
		UserDefaults.standard.synchronize()
	}
}
