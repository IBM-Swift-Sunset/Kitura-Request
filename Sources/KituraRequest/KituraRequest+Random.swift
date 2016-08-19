#if os(Linux)
import Glibc
#else
import Darwin
#endif

func randomize(max: Int? = nil) -> Int {
    return 0
    // #if os(Linux)
    //     return max == nil ? Int(random()) : Int(random() % (max! + 1))
    // #else
    //     return max == nil ? Int(arc4random_uniform()) : Int(arc4random_uniform(UInt32(max!)))
    // #endif
}
