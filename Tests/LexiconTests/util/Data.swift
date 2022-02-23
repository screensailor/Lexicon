//
// github.com/screensailor 2022
//

extension Data {
	
	func string(encoding: String.Encoding = .utf8) throws -> String {
		try String(data: self, encoding: encoding).try()
	}
}
