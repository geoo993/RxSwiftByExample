// 'RxSwift Transforming Operators'
import RxSwift
import RxSwiftExt
import RxCocoa
import UIKit
import PlaygroundSupport

func example(of description: String, action: () -> Void) {
  print("\n--- Example of:", description, "---")
  action()
}

let episodeI = "Episode I - The Phantom Menace"
let episodeII = "Episode II - Attack of the Clones"
let episodeIII = "Episode III - Revenge of the Sith"
let episodeIV = "Episode IV - A New Hope"
let episodeV = "Episode V - The Empire Strikes Back"
let episodeVI = "Episode VI - Return Of The Jedi"
let episodeVII = "Episode VII - The Force Awakens"
let episodeVIII = "Episode VIII - The Last Jedi"
let episodeIX = "Episode IX"

let episodes = [episodeI, episodeII, episodeIII, episodeIV, episodeV, episodeVI, episodeVII, episodeVIII, episodeIX]

extension String {

    /// https://stackoverflow.com/a/36949832/616764
    func romanNumeralIntValue() throws -> Int  {
        if range(of: "^(?=[MDCLXVI])M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$", options: .regularExpression) == nil  {
            throw NSError(domain: "NotValidRomanNumber", code: -1, userInfo: nil)
        }

        var result = 0
        var maxValue = 0

        uppercased().reversed().forEach {
            let value: Int
            switch $0 {
            case "M":
                value = 1000
            case "D":
                value = 500
            case "C":
                value = 100
            case "L":
                value = 50
            case "X":
                value = 10
            case "V":
                value = 5
            case "I":
                value = 1
            default:
                value = 0
            }

            maxValue = max(value, maxValue)
            result += value == maxValue ? value : -value
        }

        return result
    }
}

struct Jedi {

    public var rank: BehaviorSubject<JediRank>

    public init(rank: BehaviorSubject<JediRank>) {
        self.rank = rank
    }
}

enum JediRank: String {
    case youngling = "Youngling"
    case padawan = "Padawan"
    case jediKnight = "Jedi Knight"
    case jediMaster = "Jedi Master"
    case jediGrandMaster = "Jedi Grand Master"
}



// RxSwift Map operator works just like swift standard Map except it operates on observables.
// map takes a closure that transforms each element of the observable to some other type
example(of: "Map") {
    let disposeBag = DisposeBag()

    Observable.from(episodes)
    .map({ episode -> String in
        var components =  episode.components(separatedBy: " ")
        let number = NSNumber(value: try! components[1].romanNumeralIntValue())
        let numberString = String(describing: number)
        components[1] = numberString
        return components.joined(separator: " ")
    }).subscribe(onNext: {
        print($0)
    }).disposed(by: disposeBag)
    
}

// FlatMap projects each element of an observable sequence to an observable sequence and
// merges the resulting observable sequences into one observable sequence.
// to summarise, flatMap projects and transforms an
// observable value of an observable and then flatten it down to a target observable.
// another way to look at it is this, flatMap lets you reach into an observable that has an observable property
// and works directly with that inner observable

example(of: "FlatMap") {
    let disposeBag = DisposeBag()

    let ryan = Jedi(rank: BehaviorSubject(value: .youngling))
    let charlotte = Jedi(rank: BehaviorSubject(value: .youngling))

    let student = PublishSubject<Jedi>()

    // flatMap is letting you reach into the Jedi Observable and work with his inner rank value
    student
        .flatMap {
            $0.rank
        }
        .subscribe(onNext: {
            print($0.rawValue)
        })
        .disposed(by: disposeBag)

    student.onNext(ryan)

    ryan.rank.onNext(.padawan)

    student.onNext(charlotte)

    ryan.rank.onNext(.jediKnight)

    charlotte.rank.onNext(.jediMaster)

}

// when you only want to keep up with the latest element in the source observable you use FlatMapLatest.
// FlatMapLatest projects each element of an observable sequence into a new sequence of observable sequences and then transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.
// essentially, FlatMapLatest it only produces values from the most recent observable sequence.
// it is actually a combination of two operators, Map and SwitchLatest
// SwitchLatest will produce values from the most recent observable and unsubscribe from the previous observables.
example(of: "FlatMapLatest") {

    let disposeBag = DisposeBag()

    let ryan = Jedi(rank: BehaviorSubject(value: .youngling))
    let charlotte = Jedi(rank: BehaviorSubject(value: .youngling))

    let student = PublishSubject<Jedi>()

    student
        .flatMapLatest {
            $0.rank
        }
        .subscribe(onNext: {
            print($0.rawValue)
        })
        .disposed(by: disposeBag)

    student.onNext(ryan)

    ryan.rank.onNext(.padawan)

    student.onNext(charlotte)

    ryan.rank.onNext(.jediKnight)

    charlotte.rank.onNext(.jediMaster)
}

// you would use flatmap or flatMapLatest when doing networking operations.
// imagine you are implementing a type ahead search, as a user types each letter such as 's' 'w' 'i' 'f' 't'.
// you would want to excecute a new search and ignore the results of the previous ones. flatMapLatest is how you do that.

// Phone look-up utility using filter and flatMap operators
example(of: "Challenge 2") {

    let disposeBag = DisposeBag()

    let contacts = [
        "603-555-1212": "Florent",
        "212-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]

    let convert: (String) -> UInt? = { value in
        if let number = UInt(value),
            number < 10 {
            return number
        }

        let keyMap: [String: UInt] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
        ]

        let converted = keyMap
            .filter { $0.key.contains(value.lowercased()) }
            .map { $0.value }
            .first

        return converted
    }

    let format: ([UInt]) -> String = {
        var phone = $0.map(String.init).joined()

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

    let dial: (String) -> String = {
        if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
        } else {
            return "Contact not found"
        }
    }


    let input = PublishSubject<String>()

    input.asObservable()
        .map( convert )
        .unwrap()
        .skipWhile { $0 <= 0 }
        .filter { $0 < 10 }
        .take(10)
        .toArray()
        .map( format )
        .map( dial )
        .subscribe(onNext: {
            print($0)
        }).disposed(by: disposeBag)

    input.onNext("0")
    input.onNext("408")

    input.onNext("2")
    input.onNext("1")

    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
    input.onNext("2")

    "5551212".forEach {
        input.onNext("\($0)")
    }

    input.onNext("9")
}


public func cachedFileURL(_ fileName: String) -> URL {

    return FileManager.default
        .urls(for: .cachesDirectory, in: .allDomainsMask)
        .first!
        .appendingPathComponent(fileName)
}

public class SimpleViewController: UITableViewController {

    typealias AnyDict = [String: Any]

    public class Event {
        let repo: String
        let name: String
        let imageUrl: URL
        let action: String

        // MARK: - JSON -> Event
        init?(dictionary: AnyDict) {
            guard let repoDict = dictionary["repo"] as? AnyDict,
                let actor = dictionary["actor"] as? AnyDict,
                let repoName = repoDict["name"] as? String,
                let actorName = actor["display_login"] as? String,
                let actorUrlString = actor["avatar_url"] as? String,
                let actorUrl  = URL(string: actorUrlString),
                let actionType = dictionary["type"] as? String
                else {
                    return nil
            }

            repo = repoName
            name = actorName
            imageUrl = actorUrl
            action = actionType
        }

        // MARK: - Event -> JSON
        var dictionary: AnyDict {
            return [
                "repo" : ["name": repo],
                "actor": ["display_login": name, "avatar_url": imageUrl.absoluteString],
                "type" : action
            ]
        }
    }
    

    private let repo = "ReactiveX/RxSwift"

    private let events = Variable<[Event]>([])
    private let bag = DisposeBag()

    private let eventsFileURL = cachedFileURL("events.plist")
    private let modifiedFileURL = cachedFileURL("modified.txt")
    private let lastModified = Variable<NSString?>(nil)

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = repo

        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!

        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        let eventsArray = (NSArray(contentsOf: eventsFileURL) as? [[String: Any]]) ?? []
        events.value = eventsArray.compactMap(Event.init)

        lastModified.value = try? NSString(contentsOf: modifiedFileURL, usedEncoding: nil)

        refresh()
    }

    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fetchEvents(repo: strongSelf.repo)
        }
    }

    func fetchEvents(repo: String) {
        let topReposUrlString = "https://api.github.com/search/repositories?q=language:swift&per_page=5"

        let response = Observable.from([topReposUrlString])
            .map { urlString -> URLRequest in
                let url = URL(string: urlString)!
                return URLRequest(url: url)
            }
            .flatMap { request in
                return URLSession.shared.rx.json(request: request)
            }
            .flatMap { response -> Observable<String> in
                guard let response = response as? [String: Any],
                    let items = response["items"] as? [[String: Any]] else {
                        return Observable.empty()
                }

                return Observable.from(items.map { $0["full_name"] as! String })
            }
            .map { [weak self] repo in
                let url = URL(string: "https://api.github.com/repos/\(repo)/events")!
                var request = URLRequest(url: url)

                if let modifiedHeader = self?.lastModified.value {
                    request.addValue(modifiedHeader as String,
                                     forHTTPHeaderField: "Last-Modified")
                }

                return request
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                URLSession.shared.rx.response(request: request)
            }
            .share(replay: 1, scope: .whileConnected)

        response
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [[String: Any]] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                    let result = jsonObject as? [[String: Any]] else {
                        return []
                }

                return result
            }
            .filter { objects in
                objects.count > 0
            }
            .map { objects in
                objects.flatMap(Event.init)
            }
            .subscribe(onNext: { [weak self] newEvents in
                self?.processEvents(newEvents)
            })
            .disposed(by: bag)

        response
            .filter { response, _ in
                return 200..<400 ~= response.statusCode
            }
            .flatMap { response, _ -> Observable<NSString> in
                guard let value = response.allHeaderFields["Last-Modified"]  as? NSString else {
                    return Observable.empty()
                }

                return Observable.just(value)
            }
            .subscribe(onNext: { [weak self] modifiedHeader in
                guard let `self` = self else { return }
                self.lastModified.value = modifiedHeader
                try? modifiedHeader.write(to: self.modifiedFileURL, atomically: true,
                                          encoding: String.Encoding.utf8.rawValue)
            })
            .disposed(by: bag)
    }

    func processEvents(_ newEvents: [Event]) {
        var updatedEvents = newEvents + events.value

        if updatedEvents.count > 50 {
            updatedEvents = Array<Event>(updatedEvents.prefix(upTo: 50))
        }

        events.value = updatedEvents

        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }

        let eventsArray = updatedEvents.map { $0.dictionary } as NSArray
        eventsArray.write(to: eventsFileURL, atomically: true)
    }

    // MARK: - Table Data Source
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.value.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events.value[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        //cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
        return cell
    }

}

let simpleVC = SimpleViewController()
let navigator = UINavigationController(rootViewController: simpleVC)
simpleVC.title = "SimpleViewController"
simpleVC.view.backgroundColor = .red
PlaygroundPage.current.liveView = navigator


