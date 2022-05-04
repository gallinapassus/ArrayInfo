import Foundation
/// Concrete type storing trivial / statistical information about an array
///
/// - Complexity: O(n)
public struct ArrayInfo<T:AdditiveArithmetic&BinaryInteger> : Equatable {
    /// Available options for `ArrayInfo`
    public struct Options : OptionSet {
        public typealias RawValue = Int
        public let rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        /// Enable value histogram
        public static var histogram:Options { Options(rawValue: 1 << 0) }
    }
    /// Number of elements
    fileprivate (set) public var count:Int = 0
    /// Sum of elements
    fileprivate (set) public var sum:Int? = 0
    /// Indication of sum calculation overflow
    fileprivate (set) public var sumOverflow:Bool = false
    /// Indication of element overflow
    ///
    /// Set to `true` if given element can not be presented as an exact `Int` value
    fileprivate (set)public var elementOverflow:Bool = false
    /// Indicates if all elements are equal
    ///
    /// - Attention: This property will return `false` when `elementOverflow` is `true`
    ///  or when array/sequence is empty
    fileprivate (set) public var allElementsEqual:Bool = false
    /// Average (arithmetic mean) of the elements
    fileprivate (set) public var avg:Double? = 0
    /// Indication of average calculation overflow
    fileprivate (set) public var avgOverflow:Bool = false
    /// Minimum value
    fileprivate (set) public var minValue:T?
    /// Maximum value
    fileprivate (set) public var maxValue:T?
    /// First `Index` where `minValue` appears
    ///
    /// - Attention: Returned index is an index from the original array
    ///
    /// Example:
    ///
    ///     let a:[Int] = [1,2,4,8,16]
    ///     let s = a[1...3].info()
    ///     s.minValue // Optional(2)
    ///     s.maxValue // Optional(8)
    ///     s.minValueIndex // Optional(1)
    ///     s.maxValueIndex // Optional(3)
    ///
    fileprivate (set) public var minValueIndex:Array.Index?
    /// First `Index` where `maxValue` appears
    ///
    /// - Attention: Returned index is an index from the original array
    ///
    /// Example:
    ///
    ///     let a:[Int] = [1,2,4,8,16]
    ///     let s = a[1...3].info()
    ///     s.minValue // Optional(2)
    ///     s.maxValue // Optional(8)
    ///     s.minValueIndex // Optional(1)
    ///     s.maxValueIndex // Optional(3)
    ///
    fileprivate (set) public var maxValueIndex:Array.Index?
    /// Minimum distance between two consecutive values
    fileprivate (set) public var minDelta:UInt?
    /// Maximum distance between two consecutive values
    fileprivate (set) public var maxDelta:UInt?
    /// Average distance between consecutive values
    fileprivate (set) public var avgDelta:Double?
    /// Sum of deltas (between consecutive values)
    fileprivate (set) public var sumDelta:UInt?
    /// Indication of delta sum calculation overflow
    fileprivate (set) public var sumDeltaOverflow:Bool = false
    /// Indication of min/max delta calculation overflow
    fileprivate (set) public var minMaxDeltaOverflow:Bool = false
    /// Idicates if values in array are ascending order (previous value <= next value)
    ///
    /// Empty arrays and arrays with single element are always considered to be ordered
    /// (as sorting them wouldn't change the element order).
    fileprivate (set) public var isAscending:Bool = true
    /// Idicates if values in array are strictly ascending (previous value < next value)
    ///
    /// Empty arrays and arrays with single element are always considered to be ordered
    /// (as sorting them wouldn't change the element order).
    fileprivate (set) public var isStrictlyAscending:Bool = true
    /// Idicates if values in array are ascending (previous value >= next value)
    ///
    /// Empty arrays and arrays with single element are always considered to be ordered
    /// (as sorting them wouldn't change the element order).
    fileprivate (set) public var isDescending:Bool = true
    /// Idicates if values in array are strictly ascending (previous value > next value)
    ///
    /// Empty arrays and arrays with single element are always considered to be ordered
    /// (as sorting them wouldn't change the element order).
    fileprivate (set) public var isStrictlyDescending:Bool = true
    /// Indicates if elements are sorted (either ascending or descending)
    ///
    /// - Returns: A boolean value indicating if array elements are in sorted order (either ascending or descending)
    public var isSorted:Bool { isAscending || isDescending }
    /// Indicates if values in array have a constant delta (stride)
    public var hasConstantDelta:Bool { count >= 2 && minDelta == maxDelta }
    /// Constant stride value (if array has a constant stride)
    public var constantDelta:UInt? { hasConstantDelta ? minDelta : nil }
    /// Median value
    fileprivate (set) public var median:Double?
    /// Value histogram (if histogram option was defined)
    fileprivate (set) public var histogram:[T:Int]?
    /// Mode (value which appears most frequently in the data set)
    ///
    /// There is no mode when all observed values appear the same number of times in a data set.
    /// There is more than one mode when the highest frequency was observed for more than one
    /// value in a data set. In case of `elementOverflow`, mode is `nil`
    ///
    /// - Returns: An array of elements (as modes) or `nil` if mode
    /// doesn't exist for the given data set
    /// - Attention: `mode` is calculated only when `Option.histogram` is set.
    fileprivate (set) public var mode:[T]?
}
public extension Sequence where Element:AdditiveArithmetic&FixedWidthInteger {
    /// Calculate trivial / statistical info about the sequence and it's values
    ///
    /// See ``ArrayInfo`` for more details of calculated data.
    /// - Returns: ArrayInfo
    func info(_ options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
        ArraySlice(self).info(options)
    }
}
public extension ArraySlice where Element:AdditiveArithmetic&FixedWidthInteger {
    /// Calculate trivial / statistical info about the sequence and it's values
    ///
    /// See ``ArrayInfo`` for more details of calculated data.
    /// - Returns: ArrayInfo
    func info(_ options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
        guard self.isEmpty == false else {
            return ArrayInfo<Element>()
        }
        let r:Range<Index> = self.startIndex..<self.endIndex
        var stat = ArrayInfo<Element>()
        guard let firstValue = self.first,
              let fv = Int(exactly: firstValue) else {
            var s = ArrayInfo<Element>()
            s.elementOverflow = true
            return s
        }
        stat.sum = fv
        let doHistogram = options.contains(.histogram)
        if doHistogram {
            stat.histogram = [:]
            stat.histogram![firstValue, default: 0] += 1
        }
        stat.minValue = firstValue
        stat.maxValue = firstValue
        stat.minValueIndex = self.indices.first
        stat.maxValueIndex = self.indices.first
        stat.sumDeltaOverflow = false
        stat.count = count
        for (l,r) in zip(r.dropLast(),r.dropFirst()) {

            // MARK: min & max values
            if self[r] < stat.minValue! {
                stat.minValueIndex = r
            }
            if self[r] > stat.maxValue! {
                stat.maxValueIndex = r
            }
            stat.minValue = Swift.min(stat.minValue!, Swift.min(self[l], self[r]))
            stat.maxValue = Swift.max(stat.maxValue!, Swift.max(self[l], self[r]))
            
            // MARK: isAscending / isStrictlyAscending
            if count > 1, (stat.isAscending == true || stat.isStrictlyAscending == true),
               self[l] <= self[r] {
                if self[l] == self[r] {
                    stat.isStrictlyAscending = false
                }
            }
            else if count > 1 {
                stat.isAscending = false
                stat.isStrictlyAscending = false
            }
            // MARK: isDescending / isStrictlyDescending
            if count > 1, (stat.isDescending == true || stat.isStrictlyDescending == true),
               self[l] >= self[r] {
                if self[l] == self[r] {
                    stat.isStrictlyDescending = false
                }
            }
            else if count > 1 {
                stat.isDescending = false
                stat.isStrictlyDescending = false
            }
            
            guard let lint = Int(exactly: self[l]),
                  let rint = Int(exactly: self[r]) else {
                stat.elementOverflow = true
                break
            }

            // MARK: Sum
            if let ss = stat.sum {
                let (sum,sumOverflow) = ss.addingReportingOverflow(rint)
                if sumOverflow {
                    stat.sumOverflow = true
                    stat.sum = nil
                    stat.avg = nil
                }
                else {
                    stat.sum = sum
                }
            }

            // MARK: minDelta & maxDelta
            let (distance,deltaOverflow) = rint.subtractingReportingOverflow(lint)
            if deltaOverflow {
                stat.minMaxDeltaOverflow = true
                stat.sumDelta = nil
            }
            else {
                stat.minDelta = Swift.min(stat.minDelta ?? distance.magnitude, distance.magnitude)
                stat.maxDelta = Swift.max(stat.maxDelta ?? distance.magnitude, distance.magnitude)
            }

            // MARK: sumDelta
            let (sumDelta,sumDeltaOverflow) = (stat.sumDelta ?? 0).addingReportingOverflow(distance.magnitude)
            if sumDeltaOverflow {
                stat.sumDeltaOverflow = true
            }
            else {
                stat.sumDelta = sumDelta
            }
            if doHistogram {
                stat.histogram![self[r], default: 0] += 1
            }
        }

        // MARK: allElementsEqual
        stat.allElementsEqual = (stat.elementOverflow || stat.minValue != stat.maxValue) ? false : true
                
        // MARK: avg
        if let ss = stat.sum {
            let (avg,overflow) = ss.dividedReportingOverflow(by: count)
            let (_,rem) = ss.quotientAndRemainder(dividingBy: count)
            stat.avg = Double(avg) + (Double(rem) / Double(count))
            stat.avgOverflow = overflow
        }

        // MARK: avgDelta
        if let sumDelta = stat.sumDelta {
            stat.avgDelta = count >= 2 ? Double(sumDelta) / Double(count - 1) : nil
        }
        else {
            stat.avgDelta = nil
        }
        
        // MARK: median
        if stat.isAscending || stat.isDescending {
            if count == 1 {
                stat.median = Double(firstValue)
            }
            if count > 1 && count % 2 == 0 {
                let lidx = self.startIndex + (count / 2) - 1
                let ridx = self.startIndex + (count / 2)
                stat.median = (Double(self[lidx]) + Double(self[ridx])) / 2.0
            }
            else {
                let idx = count / 2
                stat.median = Double(self[idx])
            }
        }
        
        // MARK: mode
        if let hgram = stat.histogram,
           count > 1 // no elements -or- single elemnt => no mode
        {
            let sorted = hgram.sorted(by: { $0.value < $1.value })
            let first = sorted.first
            let last = sorted.last
            
            // Data set doesn't have a mode, if all number counts are equal
            if first?.value != last?.value {
                let modesSorted = sorted
                    .filter { $0.value == last?.value }
                    .sorted(by: <)
                stat.mode = modesSorted.map { $0.key }
            }
        }
        return stat
    }
}
