// 'RxSwift Timers'
import RxSwift
import UIKit
import Foundation
import PlaygroundSupport

func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

let simpleVC = SimpleViewController()
let navigator = UINavigationController(rootViewController: simpleVC)
simpleVC.title = "SimpleViewController"
simpleVC.view.backgroundColor = .red
PlaygroundPage.current.liveView = navigator


example(of: "Timer") {

    let disposeBag = DisposeBag()

    let startTime = Date()

    let ticker = Observable<Int>
        .interval(1.0, scheduler: MainScheduler.instance)
        .take(2)

    ticker
        .flatMap { tick in
            return Observable<Int>.interval(0.25, scheduler: MainScheduler.instance)
                .take(2) }
        .subscribe(onNext: { tick in
            let currentTime = Date()
            let interval = currentTime.timeIntervalSince(startTime)
            print(interval)
        },  onCompleted: {
            print("Completed")
        }).disposed(by: disposeBag)

}

example(of: "Interval") {

    let disposeBag = DisposeBag()
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
        }).disposed(by: disposeBag)

}

example(of: "Delay") {

    let disposeBag = DisposeBag()
    let oneTick = Observable<Void>.create { observer in
        print("💸 Creating / Subscribing.")

        return Observable<Int64>
            .timer(1.0, scheduler: MainScheduler.instance)
            .delaySubscription(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: { tick in
                print("🗞 Observing in timer.")
                observer.onNext(())
                observer.onCompleted()
            })
    }

    print("🏁 Before subscription.")

    oneTick
        .delaySubscription(1.0, scheduler: MainScheduler.instance)
        .subscribe(onNext: {
            print("🗞 Observing in oneTick subscription.")
        }).disposed(by: disposeBag)

}



// throttle will only forward an event once the source observable has stopped sending events for the specified period of time. This does not work well with regular event delivery
example(of: "Throttle") {
    let disposeBag = DisposeBag()
    /*
     Observable<Int64>
     .interval(0.2, scheduler: MainScheduler.instance)
     .debug("timer")
     .throttle(0.1, scheduler: MainScheduler.instance)
     //    .sample(sampler)
     .take(5)
     .subscribe(onNext: { x in
     print("result:", x)
     }).disposed(by: disposeBag)
     */

    simpleVC.title = "Throttle"
    simpleVC.view.backgroundColor = .cyan


    let mainView = UIButton(type: .system)
    mainView.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300) )
    mainView.backgroundColor = .white
    mainView.center = simpleVC.view.center
    mainView.setTitle("Trottle", for: .normal)
    mainView.titleLabel?.font = UIFont.systemFont(ofSize: 30)
    simpleVC.view.addSubview(mainView)


    //Throttle will only emit the last item in particular timespan.
    //It's useful when you want to filter multiple events like tapping on the button
    mainView.rx.tap
        .asDriver()
        .throttle(2)
        .drive(onNext: { (tap) in
            print("tap!")
        }).disposed(by: disposeBag)

    // so, Throttle means that the original function be called at most once per specified period.
}


// debounce will only emit item from an Observable if a particular timespan has passed without it emitting another item.
example(of: "Debounce") {
    simpleVC.title = "Debounce"
    simpleVC.view.backgroundColor = .yellow


    let mainView = UIButton(type: .system)
    mainView.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 300) )
    mainView.backgroundColor = .white
    mainView.center = simpleVC.view.center
    mainView.setTitle("Debounce", for: .normal)
    mainView.titleLabel?.font = UIFont.systemFont(ofSize: 30)
    simpleVC.view.addSubview(mainView)


    // With debounce, it will reset the timer immediately if I press the button.
    // After 2 seconds I don’t press it, “Tap!” is printed.
    let disposeBag = DisposeBag()
    mainView.rx.tap
        .asDriver()
        .debounce(2)
        .drive(onNext: { (tap) in
            print("tap!")
        }).disposed(by: disposeBag)

    // so Debounce means that the original function be called after the caller stops calling the decorated function after a specified period.
}

example(of: "delay") {
    let a = Variable(0)

    a.value = 1

    let b =
        a.asObservable()
            .do(onNext: { _ in print("b before delay") })
            .delay(3.0, scheduler: MainScheduler.instance)
            .do(onNext: { _ in print("b after delay") })
            .delay(3.0, scheduler: MainScheduler.instance)

    a.asObservable()
        .take(1)
        .subscribe { evt in
            print("a:", evt, NSDate())
    }

    b.asObservable()
        .take(1)
        .subscribe { evt in
            print("b:", evt, NSDate())
    }

}


let timings = [0.1, 0.2, 0.3, 0.4, 0.3, 0.2, 0.1]

func reduceConcat() {
    [0.1, 0.2, 0.3, 0.4, 0.3, 0.2, 0.1]
        .reduce(Observable.just(0.0)) { acc, delay in
            let timer = Observable.timer(delay, scheduler: MainScheduler.instance).map { (tick: Int64) in delay }
            return acc.concat(timer)
        }
        .subscribe(onNext: {
            print(#function, $0)
    })
}

func reduceConcatTuple() {
    let start = (delay: 0.0, date: NSDate())

    [0.1, 0.2, 0.3, 0.4, 0.3, 0.2, 0.1]
        .reduce(Observable.just(start)) { chain, delay in
            let timer =
                Observable<Int64>
                    .timer(delay, scheduler: MainScheduler.instance)
                    .map { _ in (delay, NSDate()) }
            return chain.concat(timer)
        }
        .subscribe(onNext: {
            print(#function, $0.delay, formatter.string(from: $0.date))
    })
}

func reduceFlatmap() {
    timings
        .reduce(Observable<Double>.just(0.0)) { chain, delay in
            let timer =
                Observable<Int64>
                    .timer(delay, scheduler: MainScheduler.instance)
                    .map { _ in delay }
                    .do(onNext: { print(#function, $0) })
            return chain.flatMap { _ in timer }
        }
        .subscribe(onCompleted: {
            print(#function, "Completed")
    })
}

func scanFlatmapFlatmap() {
    let start = (delay: 0.0, date: Date())
    Observable.from([0.1, 0.2, 0.3, 0.4, 0.3, 0.2, 0.1])
        .scan(Observable.just(start)) { acc, delay in
            let timer = Observable<Int64>
                .timer(delay, scheduler: MainScheduler.instance)
                //.timer(delay, scheduler: SerialDispatchQueueScheduler(internalSerialQueueName: "DISPATCH_QUEUE_PRIORITY_DEFAULT"))
                .map { _ in (delay: delay, date: Date()) }
            return acc.flatMap { x in timer }.asObservable()

        }
        .flatMap { $0 }
        .subscribe {
            switch $0 {
            case .next(let elm):
                print(#function, elm.delay, formatter.string(from: elm.date))
            case .completed:
                let totalRequested = timings.reduce(0.0, +)
                let completedDate = Date()
                let timeInterval = completedDate.timeIntervalSince(start.date)
                print(#function, "Requested delay of \(totalRequested) completed at",
                    formatter.string(from: completedDate))
                print(#function, "Execution realtime delay of \(timeInterval)")
            default: break
            }
    }
}
//reduceConcatFlatmap()
//reduceConcat()
//reduceConcatTuple()
reduceFlatmap()
//scanFlatmapFlatmap()

