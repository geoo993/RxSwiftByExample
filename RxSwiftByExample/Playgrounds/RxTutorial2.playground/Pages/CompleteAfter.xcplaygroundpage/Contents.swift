//: [Previous](@previous)

import Foundation
import RxSwift
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let startTime = Date()

Observable<Int>
.interval(1.0, scheduler: MainScheduler.instance)
.completeAfter({ $0 == 3})
.subscribe{ print($0) }


let totalCount = 1000
let arr = (0 ... totalCount).map { $0 }
let obs = Observable.from(arr) //
Observable.of(
    obs.takeWhile { $0 != 3 }, 
    obs.skipWhile { $0 != 3 }.take(1))
.merge()
.subscribe(onNext: { x in 
    print(x) //, x == totalCount)
})








//: [Next](@next)
