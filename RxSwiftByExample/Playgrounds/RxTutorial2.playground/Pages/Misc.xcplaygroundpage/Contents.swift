//: [Previous](@previous)

import Foundation
import RxSwift
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

let startTime = Date()

let state = PublishSubject<Int>()

state
.do(onNext: {
    print(#line, $0)
})
.distinctUntilChanged()
.flatMapLatest { state -> Observable<Int> in
    print(#line, state)
    return Observable<Int>
        .interval(1.0, scheduler: MainScheduler.instance)
    .map { tick in state }
    .take(2)
    }
.subscribe(onNext: { state in
    print(#line, state)
})


state.onNext(0)
state.onNext(1)
state.onNext(2)
state.onNext(3)
state.onNext(4)
state.onNext(10)
Observable<Int>.timer(1.0, scheduler: MainScheduler.instance)
    .subscribe(onNext: { tick in 
        state.onNext(100)
    })






//let ticker = Observable<Int>
//    .interval(1.0, scheduler: MainScheduler.instance)
//
//ticker
//.take(2)
//.subscribe(onNext: { tick in
//    let currentTime = Date()
//    let interval = currentTime.timeIntervalSince(startTime)
////    print(interval)
//})
//
//Observable.just()
//.delay(1.0, scheduler: MainScheduler.instance)
//.do(onNext: {print("onNext:".pad(by: 10), Date().timeIntervalSince(startTime))})
//.delay(1.0, scheduler: MainScheduler.instance)
//.subscribe({ 
//    let msg : String
//    switch $0 {
//    case .next: msg = "next"
//    case .error:  msg = "error"
//    case .completed: msg = "completed"
//    }
//    print("subscribe: \(msg)".pad(by: 20), Date().timeIntervalSince(startTime))
//    })

