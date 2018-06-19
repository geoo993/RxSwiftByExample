//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift
import Foundation

func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

func print(label: String, event: Event<String>) {
    if let element = event.element {
        print(label, element)
    }

    if let error = event.error {
        print(label, error)
    }
}

let episodeI = "The Phantom Menace"
let episodeII = "Attack of the Clones"
let theCloneWars = "The Clone Wars"
let episodeIII = "Revenge of the Sith"
let solo = "Solo"
let rogueOne = "Rogue One"
let episodeIV = "A New Hope"
let episodeV = "The Empire Strikes Back"
let episodeVI = "Return Of The Jedi"
let episodeVII = "The Force Awakens"
let episodeVIII = "The Last Jedi"
let episodeIX = "Episode IX"
let noLuck = "In my experience there is no such thing as luck"
let doOrDoNot = "Do. Or do not. There is no try."
let lackOfFaith = "I find your lack of faith disturbing"
let eyesCanDeceive = "Your eyes can deceive you. Don't trust them"
let stayOnTarget = "Stay on Target, Stay on Target!"
let noMercy = "Do what must be done. Do not hesitate. Show no mercy!"
let yourReality = "Your focus determines your reality"
let wayOfTheForce = "I can show you the ways of the Force."
let theOdds = "Never tell me the odds"
let letGo = "Train yourself to let go of everything you fear to lose"
let iAmYourFather = "Luke, I am your father."
let useTheForce = "Use the Force, Luke."
let theForceIsStrong = "The Force is strong with this one."
let mayTheForceBeWithYou = "May the Force be with you!"
let mayThe4thBeWithYou = "May the 4th be with you!"

example(of: "sequences") {
    let observableJust = Observable.just(episodeI)
    let observableOf = Observable.of(episodeIV, episodeV, episodeVI)
    let observableOfArray = Observable.of([episodeIV, episodeV, episodeVI])
    let observableFrom = Observable.from([episodeIV, episodeV, episodeVI])

}

example(of: "subscribe") {
    let observable = Observable.of(episodeIV, episodeV, episodeVI)
    observable.subscribe { element in
        print(element)
    }

    observable.subscribe(onNext: { element in
        print(element)
    })

    observable
        .subscribe(onCompleted: { () in
        print("completed")
    })
}

// empty emits a completed event
example(of: "empty") {
    let observable = Observable<Void>.empty()
    observable.subscribe(onNext: { element in
        print(element)
    }, onCompleted: { () in
        print("Completed")
    })
}

// never observable does not return anything at all
// the never operator can be used to represent an infinite duration
example(of: "never") {
    let observable = Observable<Any>.never()
    observable.subscribe(onNext: { element in
        print(element)
    }, onCompleted: { () in
        print("Completed")
    })
}

// disposable to cancel an observable sequence
example(of: "dispose") {
    let mostPopular = Observable.of(episodeV, episodeVI, episodeVII)
    let subscription = mostPopular.subscribe(onNext: { element in
        print(element)
    })

    subscription.dispose() // call dispose to cancel it
    // your going to have to cancel subsscriptuons in order to avoid leaking memory

}


// managing each subscription like this, using dispose() will quickly become tedious.
// so thats why RxSwift has a thing called DisposeBag. basically you add subscriptions to a disposebag,
// and when its owner is about to be deallocated, it will call dispose on its content for you
example(of: "DisposeBag") {
    let disposeBag = DisposeBag()
    Observable.of(episodeV, episodeVI, episodeVII)
        .subscribe(onNext: { element in
        print(element)
    }).disposed(by: disposeBag)
}




// create an observable
example(of: "create") {

    let disposeBag = DisposeBag()

    // creating a disposable that does nothing on disposal
    let observable = Observable<String>.create({ (observer) -> Disposable in

        // the observable will emit these next events, and then the completed to its subscriber
        observer.onNext("R2-D2")
        observer.onNext("C-3PO")
        observer.onNext("K-2SO")
        observer.onCompleted()

        return Disposables.create()
    })

    // handling all the events and the dispose handler and add to disposebag
    observable.subscribe(onNext: { (element) in
        print(element)
    }, onError: { (error) in
        print("Error:", error)
    }, onCompleted: {
        print("Completed")
    }, onDisposed: {
        print("Disposed")
    }).disposed(by: disposeBag)

}


// create an observable and emit an error
example(of: "create and error") {

    // creating enum to represent an error
    enum Droid: Error {
        case OU812
    }

    let disposeBag = DisposeBag()

    // creating a disposable that does nothing on disposal
    let observable = Observable<String>.create({ (observer) -> Disposable in

        // the observable will emit these next events, and then the completed to its subscriber
        observer.onNext("R2-D2")
        observer.onNext("C-3PO")
        observer.onError(Droid.OU812)
        observer.onNext("K-2SO")
        observer.onCompleted()

        return Disposables.create()
    })

    // handling all the events and the dispose handler and add to disposebag
    observable.subscribe(onNext: { (element) in
        print(element)
    }, onError: { (error) in
        print("Error:", error)
    }, onCompleted: {
        print("Completed")
    }, onDisposed: {
        print("Disposed")
    }).disposed(by: disposeBag)

}

// KEYNOTE: - TRAITS
// Traits are designed to introduce more context to your code. These Traits are totally optional,
// using them can really be useful to convey your intensions to readers of your code.
// there are 3 Traits (Single, Completable, Maybe)
// Single will only either emit a single Next event containing an element or will emit an Error event containing an error.
// Completable will only either emit a Completed event or will emit an Error event containing an error, but cannot emit Next events.
// Maybe is sort of a match between Single and Completable, it will only emit one event,
// which can be a Next event, or a Completed event or an Error event.


// using single to load text
example(of: "Single") {

    let disposeBag = DisposeBag()

    enum FileReadError: Error {
        case fileNotFound, unreadable, encodingFailed
    }

    func loadText(from filename: String) -> Single<String> {
        return Single.create(subscribe: { (single) -> Disposable in
            let disposable = Disposables.create()

            // single takes success or error
            guard let path = Bundle.main.path(forResource: filename, ofType: "txt") else {
                single(.error(FileReadError.fileNotFound)) // using single error
                return disposable
            }

            guard let data = FileManager.default.contents(atPath: path) else {
                single(.error(FileReadError.unreadable)) // using single error
                return disposable
            }

            guard let contents = String(data: data, encoding: .utf8) else {
                single(.error(FileReadError.encodingFailed)) // using single error
                return disposable
            }

            single(.success(contents)) // using single success as we successfully read text from file

            return disposable
        })
    }

    loadText(from: "traits")
        .subscribe({ (element) in
            switch element {
            case .success(let text):
                print(text)
            case .error(let error):
                print(error)
            }
    }).disposed(by: disposeBag)
}


// do operator allows you to do some side work that does not have any effect on the observable that you are working with.
// the do operator allows you to do side effects, that is handlers that will do things tat will not change
// the emitted event in any way. do also includes on subscribe handler to allow it to do side effects before subscriptions.
example(of: "do") {
    let disposeBag = DisposeBag()

    Observable.of(episodeV, episodeVI, episodeVII)
        .do(onNext: { (element) in
            print("do with:", element)
        }, onError: { (error) in
            print(error)
        }, onCompleted: {
            print("do completed")
        }, onSubscribe: {
            print("about to subscribe")
        }, onSubscribed: {
            print("when subscribed")
        }, onDispose: {
            print("dispose")
        }).subscribe(onNext: { element in
            print("subcribe with:", element)
        }, onCompleted: {
            print("subcribe completed")
        }, onDisposed: {
            print("disposed")
        })
        .disposed(by: disposeBag)
}


// subjects are comprised of two parts, an observable that can be subscribed to,
// and an observer that can receive new events, which it then emits to its subscribers.
// this provides us with observables that are not finite sequences.
// New elemnt will be added to subjects at run time and will be emit to subscribers.
// There are three types of Subjects (BehaviorSubject, PublishSubject, ReplaySubject),
// and one type called a Variable that wraps a subject.

// A PublishSubject starts as an empty sequence and emits only new Next events to its subsribers.
example(of: "PublishSubject") {

    let quotes = PublishSubject<String>()

    quotes.onNext(noLuck)

    let subscriptionOne = quotes
        .subscribe({
            print(label: "1)", event: $0)
    })

    // because this is added after the subcriber subscribe, the subscriber sees the next event
    quotes.onNext(doOrDoNot)

    let subscriptionTwo = quotes
        .subscribe ({
            print(label: "2)", event: $0)
    })

    quotes.onNext(lackOfFaith)

    subscriptionOne.dispose()

    quotes.onNext(eyesCanDeceive)

    quotes.onCompleted()

    // return completed as the observable is completed
    let subscriptionTree = quotes
        .subscribe ({
            print(label: "3)", event: $0)
        })

    // subscription three does emit an event, which is the completed event,
    // this is because all subject types will re-emit or replay stop events to new subscribers
    quotes.onNext(stayOnTarget)

    subscriptionTwo.dispose()
    subscriptionTree.dispose()

}

// sometimes you want subscribers to always receive the most recent next events,
// event if they subscribed after that event was emitted, for this you sue BehaviorSubject
// BehaviorSubject start with an initial value, and will replay the latest value or
// the initial value if no other values have been added on yet to new subscribers.
example(of: "BehaviorSubject") {

    enum Quotes: Error {
        case neverSaidThat
    }
    let disposebag = DisposeBag()

    let quotes = BehaviorSubject<String>(value: iAmYourFather)

    let subscriptionOne = quotes
        .subscribe({
            print(label: "1)", event: $0)
        })

    quotes.onError(Quotes.neverSaidThat)

    quotes
        .subscribe({
            print(label: "2)", event: $0)
        }).disposed(by: disposebag)

    subscriptionOne.disposed(by: disposebag)
}


// ReplaySubject starts empty, but its initialised with a buffer size.
// It will replay up to that buffer size to new subscribers.
// so if the buffer size was 3, and there are only 2 elements added to it.
// Only 2 will be replayed to new subscribers.
// you may want to avoid making that buffer too large,
// this is because the buffer will be held in memory for the life of this subject.
// so if it is holding large or a lot of objects, you could be creating memory pressure.
example(of: "ReplaySubject") {
    let disposebag = DisposeBag()

    let subject = ReplaySubject<String>.create(bufferSize: 2)

    subject.onNext(useTheForce)

    subject
        .subscribe({
            print(label: "1)", event: $0)
        }).disposed(by: disposebag)

    // notice the replaysubject does not replay the buffer every time.
    // it just replays it to new subscribers and from then on it emits just like a regular observable
    subject.onNext(theForceIsStrong)

    subject
        .subscribe({
            print(label: "2)", event: $0)
        }).disposed(by: disposebag)
}

// Variable is a wrapper around a BehaviorSubject.
// So it starts with an initial value and replays the latest or initial value to subscribers.
// what makes Variable unique is that it is guaranteed not to fail, it will not and cannot emit an error.
// and it will automatically complete, meaning you do not add a completed event like other subjects.
// and Variable is stateful, it stores the latest value, which you can access at any time, using .value.
example(of: "Variable") {
    let disposebag = DisposeBag()

    let variable = Variable<String>(mayTheForceBeWithYou)
    print(variable.value)

    // need to use asObservble to access or call its BehaviorSubject
    variable.asObservable()
        .subscribe({
            print(label: "1)", event: $0)
        }).disposed(by: disposebag)

    // emit new values to subscribers
    variable.value = mayThe4thBeWithYou

}


// BlackJack 21
example(of: "BlackJack") {

    func cardString(for hand: [(String, Int)]) -> String {
        return hand.map { $0.0 }.joined(separator: "")
    }

    func points(for hand: [(String, Int)]) -> Int {
        return hand.map { $0.1 }.reduce(0, +)
    }

    enum HandError: Error {
        case busted
    }

    let disposeBag = DisposeBag()

    let dealtHand = PublishSubject<[(String, Int)]>()

    func deal(_ cardCount: UInt) {
        var deck = cards
        var cardsRemaining: UInt32 = 52
        var hand = [(String, Int)]()

        for _ in 0..<cardCount {
            let randomIndex = Int(arc4random_uniform(cardsRemaining))
            hand.append(deck[randomIndex])
            deck.remove(at: randomIndex)
            cardsRemaining -= 1
        }

        // Add code to update dealtHand here
        if points(for: hand) > 21 {
            dealtHand.onError(HandError.busted)
        } else {
            dealtHand.onNext(hand)
        }
    }

    // Add subscription to dealtHand here
    dealtHand
        .subscribe(
            onNext: { hand in
                print(cardString(for: hand), "for", points(for: hand), "points")
        },
            onError: { error in
                print(String(describing: error))
        })
        .disposed(by: disposeBag)

    deal(3)

}

