import Foundation
import UIKit
import RxSwift
import RxCocoa

public class SimpleViewController: UIViewController {

    public func alert(title: String, text: String?) -> Completable {
        return Completable.create { [weak self] completable in
            let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)

            alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
                completable(.completed)
            }))

            self?.present(alertVC, animated: true, completion: nil)
            return Disposables.create()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
