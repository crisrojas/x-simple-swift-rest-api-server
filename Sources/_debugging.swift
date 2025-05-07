let debug = false
func dp(_ msg: Any, line: UInt = #line, function: String = #function) {
    if debug {
        _dp(line,function,msg)
    }
}

fileprivate func _dp(_ any: Any...) {
    let msg = any.map { "\($0)" }.reduce("") { first, second in first + "\(second) "} 
    print(msg)
}