// 'RxSwift Filters'
import RxSwift
import RxSwiftExt
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

let theCloneWars = "The Clone Wars"
let solo = "Solo"
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
let mayThe4thBeWithYou = "May the 4th be with you!"

let landOfDroids = "Land of Droids"
let wookieWorld = "Wookie World"
let detours = "Detours"

let mayTheOdds = "And may the odds be ever in your favor"
let liveLongAndProsper = "Live long and prosper"
let mayTheForce = "May the Force be with you"

let episodeI = (title: "The Phantom Menace", rating: 55)
let episodeII = (title: "Attack of the Clones", rating: 66)
let episodeIII = (title: "Revenge of the Sith", rating: 79)
let rogueOne = (title: "Rogue One", rating: 85)
let episodeIV = (title: "A New Hope", rating: 93)
let episodeV = (title: "The Empire Strikes Back", rating: 94)
let episodeVI = (title: "Return Of The Jedi", rating: 80)
let episodeVII = (title: "The Force Awakens", rating: 93)
let episodeVIII = (title: "The Last Jedi", rating: 91)
let tomatometerRatings = [episodeI, episodeII, episodeIII, rogueOne, episodeIV, episodeV, episodeVI, episodeVII, episodeVIII]

enum Droid { case C3PO, R2D2 }


// RxSwift filtering operators allows to apply conditional constraints to next events,
// to only pass through to subscribers the elements you want


// IgnoreElements will ignore Next events, however it will allow through Completed or Error events
example(of: "ignoreElements") {
    let disposeBag = DisposeBag()

    let cannedProjects = PublishSubject<String>()

    cannedProjects
        .ignoreElements()
        .subscribe {
        print($0)
    }.disposed(by: disposeBag)

    cannedProjects.onNext(landOfDroids)
    cannedProjects.onNext(wookieWorld)
    cannedProjects.onNext(detours)

    cannedProjects.onCompleted()

}

// ElementAt Operator will filter out all Next events out excepts the one at a specific index
example(of: "elementAt") {
    let disposeBag = DisposeBag()
    let quotes = PublishSubject<String>()

    quotes
        .elementAt(2)
        .subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)

    quotes.onNext(mayTheOdds)
    quotes.onNext(liveLongAndProsper)
    quotes.onNext(mayTheForce)

    quotes.onCompleted()
}

// the Filter operator works similarly to swift filter function,
// it takes a predicate that will apply each element to determine if it allows through or not.
example(of: "filter") {
    let disposeBag = DisposeBag()

    Observable.from(tomatometerRatings)
        .filter({ movie in
            movie.rating >= 90
        }).subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
}

// there are operators in RxSwift for taking and skiping elements based on certain conditions. These are Skip, Take, TakeWhile

//Skip will skip the kind of element that you pass through its parameter, and then allow all forth coming elemnets through,
// where as SkipWhile will apply a predicate and skip the elemets up-to the predicate fails and then let through all future elements.
// In other words it stops skipping once the predicate fails.
// Take works in opposite of skip, it takes the kind of elements up-to and including the number you provide for its parameter and stop taking additional elements.
// TakeWhile will only take elements while a conditions resolves to true and then stop taking any more elements.
// There are also filtering operators that let you dynamically filter elements based on some other observable.

example(of: "takeWhile") {
    let disposeBag = DisposeBag()

    Observable<Int>
        .interval(1.0, scheduler: MainScheduler.instance)
        .takeWhile({ $0 <= 3})
        .subscribe{ print($0) }
        .disposed(by: disposeBag)

    let totalCount = 1000
    let arr = (0 ... totalCount).map { $0 }
    let obs = Observable.from(arr) //
    Observable.of(
        obs.takeWhile { $0 != 3 },
        obs.skipWhile { $0 >= 3 }.take(1))
        .merge()
        .subscribe(onNext: { x in
            print(x) //, x == totalCount)
        }).disposed(by: disposeBag)

}

// SkipUntil will skip elements until a second Observable triggers the skip until the operator stops skipping and conversly TakeUntil will keep taking elements, until a second Observable triggers it to stop taking.

example(of: "skipWhile") {

    let disposeBag = DisposeBag()

    Observable.from(tomatometerRatings)
        .skipWhile { movie in
            movie.rating < 90
        }
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)
}

example(of: "skipUntil") {

    let disposeBag = DisposeBag()

    let subject = PublishSubject<String>()
    let trigger = PublishSubject<Void>()

    subject
        .skipUntil(trigger)
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)

    subject.onNext(episodeI.title)
    subject.onNext(episodeII.title)
    subject.onNext(episodeIII.title)

    trigger.onNext(())

    subject.onNext(episodeIV.title)
}


// DistinctUnitlChanged prevents contiguous duplicates to get through,
// it waits for the non similar changes
example(of: "distinctUntilChanged") {

    let disposeBag = DisposeBag()

    Observable<Droid>.of(.R2D2, .C3PO, .C3PO, .R2D2, .R2D2, .R2D2, .C3PO)
        .distinctUntilChanged()
        .subscribe(onNext: {
            print($0)
        })
        .disposed(by: disposeBag)


    Observable.from([1,1,1,2,3,nil, nil, 3, 3])
        .distinctUntilChanged(==)
        .unwrap()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}


// Phone look-up utility using filter operators
example(of: "Challenge 1") {

    let disposeBag = DisposeBag()

    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]

    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()

        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )

        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )

        return phone
    }

    let input = PublishSubject<Int>()
    
    input.asObservable()
        .skipWhile { $0 <= 0 }
        .filter { $0 < 10 }
        .take(10)
        .toArray()
        .subscribe(onNext: {
            let phone = phoneNumber(from: $0)
            if let contact = contacts[phone] {
                print("Dialing \(contact) (\(phone)...")
            } else {
                print("Contact not found")
            }

        }).disposed(by: disposeBag)

    input.onNext(0)
    input.onNext(603)

    input.onNext(2)
    input.onNext(1)

    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
    input.onNext(7)

    "5551212".forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }

    input.onNext(9)
}

example(of: "single vs take") {
    let disposebag = DisposeBag()

    enum State { case Inactive, Listening }
    let state = PublishSubject<State>()

    let switchLatest = PublishSubject<Observable<State>>()
    switchLatest.asObservable()
        .switchLatest()
        .debug("switchLatest")
        .subscribe(onNext: {
            print("switchLatest: ob \($0)")
    }).disposed(by: disposebag)

    let listenWithSingle =
        state.asObservable()
            .single()
            .debug("single")
            .do(onNext: {
                state.onNext(.Listening)
                print("single: do \($0)")
    })

    let listenWithTake1 =
        state.asObservable()
            .take(1)
            .debug("take(1)")
            .do(onNext: {
                state.onNext(.Listening)
                print("take(1): do \($0)")
            })

    //switchLatest.onNext(listenWithTake1) // `listenWithTake1` works as expected
    switchLatest.onNext(listenWithSingle)  // `listenWithSingle` causes hundred of .Next(.Listening) events
    state.onNext(.Inactive)
}
