//: Playground - noun: a place where people can play
// https://academy.realm.io/posts/altconf-scott-gardner-reactive-programming-with-rxswift/

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func exampleOf(_ description: String, action: () -> ()) {
    print("\n--- Example of:", description, "---")
    action()
}

// Creating and Subscribing to Observable Sequences
/*
This first example is using the just operator, which will create an observable sequence of a single value, just an integer in this case. Then I’m going to subscribe to events that are going to be emitted from this observable sequence using this subscribe operator. And as I receive each event as it’s emitted, I’ll just print it out, and I’m just using the $0 default argument name.
 */
exampleOf("just") {
    Observable.just(32)
        .subscribe(onNext: {
            print($0)
    })
}

/*
So first we get this next event containing the element, and then we get a completed event. And like with the error, once an observable sequence has emitted a completed event, it’s terminated. It can’t emit any more elements.
 */
exampleOf("just") {
    _ = Observable.just(32)
        .subscribe(onNext: {
            print($0)
    })
}


/*
So this of operator can take a variable number of values. I subscribe to it and print it out just like before, only this time, instead of explicitly ignoring the return value, I’m gonna call dispose on the subscription, and dispose cancels the subscription. So now we get a print out of each element from the observable sequence.
 */
exampleOf("of") {
    Observable.of(1, 2, 3, 4, 5)
        .subscribe(onNext: {
            print($0)
        })
        .dispose()
}

/*
 We can also create observable sequences from arrays of values. toObservable will convert an array` into an observable sequence. toObservable is now deprecated and now using Observable.from or Observable.just

 Elements of the array at the time that the from or just operator is called will be final set of emissions on the onNext events and will end with an onCompleted event. Changes to the array will not be recognized as new events for this observable sequence.

 So first I’ll just create a dispose bag, which remember will dispose of its contents on deinit, and then I’ll use toObservable to convert the array of integers to an observable sequence, and then I’ll subscribe next and print out the elements. Then I’ll add that subscription to the dispose bag.
 */

exampleOf("toObservable now known as, Observable.from"){
    let disposeBag = DisposeBag()
    Observable.from([1, 2, 3])
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
}

/*
 A BehaviorSubject is one way to do that. You can think of a BehaviorSubject is simply representing a value that is updated or changed over time.

 I’m gonna explain why that’s not exactly the case in just a moment, but first, I’m gonna just create a string BehaviorSubject here with an initial value of “Hello.” And then I’ll subscribe to it to receive updates and print them out. And notice that I didn’t use the subscribeNext this time. You’ll see why in a moment. Then I add this new value “World” onto the string BehaviorSubject.
 */

exampleOf("BehaviorSubject") {
    let disposeBag = DisposeBag()
    let string = BehaviorSubject(value: "Hello")
    string.subscribe {
        print($0)
    }.disposed(by: disposeBag)

    string.onNext("World!")
}

/*
 Like I said a moment ago, BehaviorSubject represents a value that can change over time, but I’m not actually changing the value. This is immutable. What I’m doing is I’m adding this “World” value onto the sequence, using this on operator, with a next case that wraps that new value. This will then cause the sequence to emit a next event to its observers. So this on and then case next is sort of the original way to use that operator to put these new values onto the sequence, but there’s also a convenience operator that I tend to use pretty much all the time, and that’s onNext. And it does the exact same thing, it’s just a little bit easier to write, and a little bit easier to read after the fact.

 As a result, I see both next events with the elements printed out, including the initial value, because when it was assigned before the subscription even existed. That’s because a BehaviorSubject will always emit the latest or the initial element when new subscribers subscribe to it, so you always get that replay of that last item. A BehaviorSubject does not automatically emit a completed event, though, when it’s about to be disposed of, and it also can emit an error event and terminate. We may not want that. Typically, you want the completed event to be automatically emitted when the subscription’s gonna be disposed of, but you want to prevent error events from being emitted, if we’re talking about UI integration, that kind of thing.

 So as an alternative, you can use a type called Variable. Variable is a wrapper around BehaviorSubject. It exposes its BehaviorSubject’s observable sequence via the asObservable operator. And what a Variable does that a regular BehaviorSubject will not, is a Variable is guaranteed to not emit error events, and it will automatically emit a completed event when it’s about to be disposed of. So use of Variable’s value property to get the current value or to set a new value onto the sequence. I like the syntax a little better than using that onNext so I tend to use Variables a lot. For some other reasons too.
 */

exampleOf("Variable") {
    let disposeBag = DisposeBag()
    let number = Variable(1)
    number.asObservable()
    .subscribe {
        print($0)
    }.disposed(by: disposeBag)
    number.value = 12
    number.value = 1_234_567
}

/*
 These are the basic building blocks of reactive programming in RxSwift, and there are a few more types, and of course lots more operators. I’ll go over some more in a moment. But once you get the basic gist of this, everything else is a variation. It should come pretty easy. Again, if you remember just one thing from this talk, everything is a sequence. You’re not changing a value. You’re putting new values onto the sequence, and then observers can react to those values as they’re emitted by the observable sequence.
 */


// Transform Observable Sequences
/*
 I’ve gone over some ways that you can create observable sequences, now I’m going to cover just a few ways that you can transform observable sequences. So you know about Swift’s map method, right?

 You can take an array and you can call map on an array, pass it closure that provides some sort of transformation, and then that will return an array of all those elements transformed. Rx has its own map operator that works very similarly.

 Here I’m gonna just create an observable sequence of integers using the of operator. Then I use map to transform them by multiplying each element by itself, and then I use subscribeNext to just print out each element.
 */

exampleOf("map") {
    let disposeBag = DisposeBag()
    Observable.of(1, 2, 3)
        .map { $0 * $0 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

/*
 Map will transform each element as it’s emitted from the source observable sequence. So what happens when you want to subscribe to an observable sequence that has observable sequence properties that you wanna listen to? So observable sequence that has observable sequence properties.

 Down the rabbit hole. RxSwift’s flatMap is also conceptually similar to Swift’s standard flatMap method, except that, of course, it works with observable sequences and it does so in an asynchronous manner. It will flatten an observable sequence of observable sequences into a single sequence. flatMap will also apply a transforming action to the elements that are emitted by that observable sequence.

 So I’m gonna walk step by step through an example here:

 First, we have this Person struct, and it has a name variable of type Variable of string. So name contains an observable sequence, but because I declared it as var, so it not only can have values added onto the sequence, but the sequence itself can be reassigned.
 */

exampleOf("flatMap") {
    let disposeBag = DisposeBag()
    struct Person {
        var name: Variable<String>
    }
    let scott = Person(name: Variable("Scott"))
    let lori = Person(name: Variable("Lori"))
    let person = Variable(scott)
    person.asObservable()
        .flatMap { // flatMap
            $0.name.asObservable()
        }
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    person.value = lori
    scott.name.value = "Eric"
}

/*
 This is a contrived example, just to kind of show you the inner workings here. So then I create a couple of instances of Person, Scott and Lori. And then I’ll use flatMap to reach into the Person observable and access its name observable sequence, and then only print out newly added values.

 Remember with Variables, you use the asObservable to access its underlying observable sequence. So Person starts out with Scott, and Scott is printed. But then I reassign Person’s value altogether to Lori, so Lori is printed. And then I’ll put a new value on Scott’s sequence.

 Because I used flatMap, both sequences are actually still active, so we will see Eric printed out.That could be a gotcha. This could be sort of like a memory leak, if you think you should be using flatMap when you should be using something else. That something else is flatMapLatest. So this flatMapLatest operator, if I use it here instead, will also flatMap, but then it will also switch the subscription to the latest sequence, and it’s gonna ignore emissions from the previous one.

 */

exampleOf("flatMapLatest") {
    let disposeBag = DisposeBag()
    struct Person {
        var name: Variable<String>
    }
    let scott = Person(name: Variable("Scott"))
    let lori = Person(name: Variable("Lori"))
    let person = Variable(scott)
    person.asObservable()
        .flatMapLatest({ // flatMapLatest
            $0.name.asObservable()
        })
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)

    person.value = lori
    scott.name.value = "Eric" // this is ignored because of flatMapLatest
}

/*
 So because Scott’s emissions will be ignored once I set person.value to Lori, Eric is not printed out when I set it on scott.name. So really, this is sort of like a synchronous example just to show you the inner workings of flatMapLatest, but this is really more often used asynchronously with things like networking operations, and I’m going to go over an example of that here shortly.

 */

// Debug
/*
RxSwift also includes a couple of really useful debugging operators. One of them is called debug. And you can add debug to a chain like this.
 */

exampleOf("flatMapLatest") {
    let disposeBag = DisposeBag()
    struct Person {
        var name: Variable<String>
    }
    let scott = Person(name: Variable("Scott"))
    let lori = Person(name: Variable("Lori"))
    let person = Variable(scott)
    person.asObservable()
        .debug("person")
        .flatMapLatest {
            $0.name.asObservable()
        }
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)
    person.value = lori
    scott.name.value = "Eric"
}

// Filtering
/*
Here’s an example of using distinctUntilChanged, which is going to be used to suppress consecutive duplicates, so if the value is the same as the previous value, the latest value on that sequence it’s going to ignore. searchString starts out with this value iOS, and then I’ll use map to transform the string to a lowercase string, and then I’ll use distinctUntilChanged to filter out and ignore new values that are added onto that sequence that are the same as the latest value. Then I just subscribe to print it out.

 */

exampleOf("distinctUntilChanged") {
    let disposeBag = DisposeBag()
    let searchString = Variable("iOS")
    searchString.asObservable()
        .map { $0.lowercased() }
        .distinctUntilChanged()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    searchString.value = "IOS"
    searchString.value = "Rx"
    searchString.value = "ios"
}

/*
 The sequence was created with an initial value of iOS, so that initial value was printed out upon subscription, and then I added the same value onto the sequence. And even though it’s differently cased, it will be ignored because of distinctUntilChanged. So then I add a new value of Rx onto the sequence, and that’s printed, and then I add ios back onto the sequence again, and this time, it is printed, because it’s not equal to the latest value.
*/

// Combining
/*
 Sometimes you want to observe multiple sequences at the same time. And for that we can use this combineLatest operator, which combines multiple sequences into a single sequence. You might be thinking back to the flatMapLatest operator I showed you a couple minutes ago. flatMapLatest is actually a combination of the map and the combineLatest operators. And switchLatest operators.

 Here’s another Rx subject type, it’s called PublishSubject, and it’s similar to a behavior subject, except for it doesn’t require an initial value, and it won’t replay the latest value to new subscribers. That’s the difference between PublishSubject and BehaviorSubject.

 Then I’ll use combineLatest, which will wait for each source observable sequence to emit an element before it produces any next event. But then once they both do emit a next event, then it’ll emit a next event whenever any of the source observable sequences emits an event. Because I’m at the point where I just had that circle show up, that we haven’t put a value on the number sequence yet, string does not have a value yet. So the subscription does not produce anything yet.

 And then just “Nothing yet” is printed out at this point. As soon as I do add a value onto the string sequence, the latest elements from both the string and the number sequences are printed out, and then from that point forward, whenever either of the source sequences emits a new element, the latest elements from both sequences will be printed out.
 */

exampleOf("combineLatest") {
    let disposeBag = DisposeBag()
    let number = PublishSubject<Int>()
    let string = PublishSubject<String>()
    Observable.combineLatest(number, string) { "\($0) \($1)" }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    number.onNext(1)
    print("Nothing yet")
    string.onNext("A")
    number.onNext(2)
    string.onNext("B")
    string.onNext("C")
}

// Conditional
/*
 Here’s an example of takeWhile, which takes emitted elements only as long as a specified condition is true.

 First, I’ll just convert an array of integers to observable, then I use takeWhile to conditionally only take elements as long as each element is less than five. Once an element is five or greater, then it stops and the sequence is terminated and emits a completed message.
 */
exampleOf("takeWhile") {

    Observable.from([1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1])
        .takeWhile { $0 < 5 }
        .subscribe(onNext: { print($0) })
        .dispose()
}

// Mathematical
/*
RxSwift has a reduce operator that works the same way as the reduce method in the Swift standard library, but sometimes you may want to work with the intermediate values along the way, and for that, RxSwift has the scan operator.
 */

exampleOf("scan") {
    Observable.of(1, 2, 3, 4, 5)
        .scan(10, accumulator: +)
        .subscribe(onNext: { print($0) })
        .dispose()
}

// Error handling
/*
 So remember that some observable sequences can emit an error event, so this is just a real simple example demonstrating how you can subscribe to handle an error event.

 I’ve created an observable sequence that terminates immediately with an error. Not very useful. But then I use the subscribeError operator so that I can handle the error, which in this example I just print out.

 */
exampleOf("error") {
    enum ErrorName: Error {
        typealias RawValue = Int
        case A
    }

    Observable<Int>.error(ErrorName.A)
    .subscribe(onError: {
        // Handle error
        print($0)
    }).dispose()
}

/*
So let me show you that networking example using Rx extensions. This is a basic single view app with a UITableView, and there’s a repository model that’s just a struct with a name and url string properties.

 */
struct Repository {
    let name: String
    let url: String
}

/*
And in the view controller, I’ve created a search controller and I’ve configured it and then added the search bar to the UITableView’s header.
*/

class ViewController: UIViewController {

    var tableView: UITableView!

    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }

    var viewModel = ViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSearchController()

        searchBar.rx.text
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        searchBar.rx.cancelButtonClicked
            .map{ "" }
            .bind(to: viewModel.searchText)
            .disposed(by: disposeBag)

        viewModel.data
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = repository.url
            }
            .disposed(by: disposeBag)
    }

    func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.showsCancelButton = true
        searchBar.text = "scotteg"
        searchBar.placeholder = "Enter GitHub Id, e.g., \"scotteg\""
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
}
/*
 I’m binding the search bar’s Rx text, which is an Rx wrapper around UISearchBar’s text property, to the ViewModel’s search text observable sequence.

 I’m also binding the search bar’s rx_cancelButtonTapped to the ViewModel’s search text sequence too. And I’m using map to put an empty string onto the sequence when the cancel button’s tapped. rx_cancelButtonTapped is an Rx wrapper around UISearchBarDelegate’s searchBarCancelButtonClicked callback. And finally, I’m binding the ViewModel’s data sequence to the UITableView, just like I did in my first example. So that’s it for the view controller. Let me look at the ViewModel now. In a production app, I’d probably compartmentalize this networking code into a separate API manager, but I thought it would be easier just to have it all on one screen to kind of go through it.

 There’s this search text variable, which remember, wraps an observable sequence. And then here’s the data observable sequence.

 And I’m using another type here called a driver, which also wraps an observable sequence, but it provides some other benefits that are useful when you’re working with binding UI. Drivers won’t error out, and they also ensure that they are on the main thread. The throttle operator helps you prevent rapid network requests, like if you’re in a type ahead searching type app like this, it’ll prevent firing off an API call every time they type in a new character. In this case I’m just throttling it by .3 seconds. Then I’m using distinctUntilChanged again, which, as I showed you earlier, will ignore the element if it’s the same as the previous value. And then I’m using flatMapLatest, which will switch to the latest observable sequence. And this is because when you’re receiving new search results because of additional text typed into the search field, you no longer care about the previous results sequence. flatMapLatest will take care of that for you, and it will just switch to the latest and ignore emissions from the previous.

 Then I’m calling getRepositories in the body of the flatMapLatest, and that takes the search text, and it’s gonna return an observable array of these repository objects that I bound to the UITableView in the view controller.

 */

struct ViewModel {

    let searchText = Variable<String?>("")
    let disposeBag = DisposeBag()

    var data: Driver<[Repository]> {
        return self.searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { text -> Observable<[Repository]> in
                return self.getRepositories(githubId: text)
            }.asDriver(onErrorJustReturn: [])
    }

    func getRepositories(githubId: String?) -> Observable<[Repository]> {
        guard let gitId = githubId, let url = URL(string: "https://api.github.com/users/" + gitId + "/repos")
            else { return Observable.just([]) }

        return URLSession.shared
            .rx.json(request: URLRequest(url: url))
            .retry(3)
            .map {
                var data = [Repository]()

                if let items = $0 as? [[String: AnyObject]] {
                    items.forEach {
                        guard let name = $0["name"] as? String,
                            let repoUrl = $0["url"] as? String
                            else { return }
                        data.append(Repository(name: name, url: repoUrl))
                    }
                }
                return data
        }
    }
}

/*
 Net blocker code does a lot, so lemme walk through it.

 First I create a URL that I’m gonna use in my NSURLRequest. Then I use NSURLSession’s sharedSession singleton with this rxjson extension. rxjson takes a URL and it returns an observable sequence of the JSON data already ready to parse. And because things can go wrong with networking, and they often do, I’m going to use this retry operator, that will allow me to just retry this request three times before giving up.

 And then finally, I’ll use the map operator to create an array of repository instances that return that data. It took me longer to explain that code than it did to write it.

 So really, for just a few dozen lines of code, I have a handy GitHub repo app, which I kind of think is like the new Hello World app these days, demonstrating internet networking, stuff like that.

 */
