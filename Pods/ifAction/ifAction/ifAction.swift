import Foundation

extension Optional {

	func ifSome( _ closure: (Wrapped) -> Void) {
		switch self {
		case .some(let wrapped): return closure(wrapped)
		case .none: break
		}
	}

	@discardableResult
	func ifNone( _ closure: () -> Void) -> Optional {
		switch self {
		case .some: return self
		case .none(): closure(); return self
		}
	}
}

extension Bool {

	func ifTrue( _ closure: @autoclosure () -> Void) {
		if self { closure() }
	}

	func ifFalse( _ closure: @autoclosure () -> Void) {
		if !self { closure() }
	}
}
