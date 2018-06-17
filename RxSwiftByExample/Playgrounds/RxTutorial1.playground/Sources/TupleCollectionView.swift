
import Foundation

//public struct TupleCollectionView<T>: Collection {
//    public typealias Index = Int 
//    private let _mirror: Mirror
//    public init(_ tuple: T) {
//        _mirror = Mirror(reflecting: tuple)
//    }
// 
//    public var startIndex: Int { return Int(0) }
// 
//    public var endIndex: Int {
//        guard case .tuple = _mirror.displayStyle!
//          else { return Int(1) }
// 
//        return Int(_mirror.children.count)
//    }
// 
//    public subscript(idx: Int) -> Any? {
//        guard case .tuple = _mirror.displayStyle!
//          else { return _mirror.children.first }
//        guard Int64(idx) < _mirror.children.count else {
//            return EMPTY
//        }
//        return _mirror.children.dropFirst(idx).first!.1 
//    }
//    public subscript(idx: IntMax) -> Any? {
//        return self[Int(idx)]
//    }
//    
//}

