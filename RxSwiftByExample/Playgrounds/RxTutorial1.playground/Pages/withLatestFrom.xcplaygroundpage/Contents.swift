//: [Previous](@previous)

import Foundation
import RxSwift
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let timer1 = Observable<Int64>
    .interval(3.0, scheduler: MainScheduler.instance)
    //.subscribeNext { print($0) }
let timer2 = Observable<Int64>
    .interval(1.0, scheduler: MainScheduler.instance)
    
timer1
.withLatestFrom(timer2) { ($0, $1) }
.subscribeNext { print(($0, $1)) }
var str = "Hello, playground"

//: [Next](@next)
