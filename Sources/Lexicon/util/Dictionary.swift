//
// github.com/screensailor 2022
//

public extension Dictionary {
    
    subscript(key: Key, inserting defaultValue: @autoclosure () -> (Value)) -> Value {
        mutating get {
            guard let value = self[key] else {
                let value = defaultValue()
                self[key] = value
                return value
            }
            return value
        }
    }
}
