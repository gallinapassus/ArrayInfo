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
    /// Indication of element overflow
    ///
    /// Set to `true` if given element can not be presented as an exact `Int` value
    fileprivate (set)public var elementOverflow:Bool = false
    /// Indication of sum calculation overflow
    fileprivate (set) public var sumOverflow:Bool = false
    /// Average of the elements
    fileprivate (set) public var avg:Double? = 0
    /// Indication of average calculation overflow
    fileprivate (set) public var avgOverflow:Bool = false
    /// Minimum value
    fileprivate (set) public var minValue:T?
    /// Maximum value
    fileprivate (set) public var maxValue:T?
    /// First `Index` where `minValue` appears
    fileprivate (set) public var minValueIndex:Array.Index?
    /// First `Index` where `maxValue` appears
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
    /// Idicates if values in array are ascending (previous value <= next value)
    fileprivate (set) public var isAscending:Bool = false
    /// Idicates if values in array are strictly ascending (previous value < next value)
    fileprivate (set) public var isStrictAscending:Bool = false
    /// Indicates if values in array have a constant stride (constant delta)
    public var hasConstantStride:Bool { count >= 2 && minDelta == maxDelta }
    /// Constant stride value (if array has a constant stride)
    public var constantStride:UInt? { hasConstantStride ? minDelta : nil }
    /// Value histogram (if histogram option was defined)
    fileprivate (set) public var histogram:[T:Int]?
}
public extension Sequence where Element:AdditiveArithmetic&FixedWidthInteger {
    /// Get trivial / statistical info about the sequence and it's values
    func info(_ options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
        ArraySlice(self).info(options)
    }
}
public extension ArraySlice where Element:AdditiveArithmetic&FixedWidthInteger {
    /// Get trivial / statistical info about the ArraySlice and it's values
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
        stat.isAscending = true
        stat.isStrictAscending = true
        for (l,r) in zip(r.dropLast(),r.dropFirst()) {

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

            // MARK: min & max values
            if self[r] < stat.minValue! {
                stat.minValueIndex = r
            }
            if self[r] > stat.maxValue! {
                stat.maxValueIndex = r
            }
            stat.minValue = Swift.min(stat.minValue!, Swift.min(self[l], self[r]))
            stat.maxValue = Swift.max(stat.maxValue!, Swift.max(self[l], self[r]))

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
            // MARK: isAscending / isStrictlyAscending
            if lint <= rint {
                if lint == rint {
                    stat.isStrictAscending = false
                }
            }
            else {
                stat.isAscending = false
                stat.isStrictAscending = false
            }
        }

        // MARK: isAscending
        stat.isAscending = count < 2 ? false : stat.isAscending
        //stat.isAscending = stat.minDelta == nil ? false : stat.minDelta! >= 0

        // MARK: isStrictAscending
        stat.isStrictAscending = count < 2 ? false : stat.isStrictAscending
        //stat.isStrictAscending = stat.minDelta == nil ? false : stat.minDelta! > 0

        // MARK: avg
        if let ss = stat.sum {
            let (avg,overflow) = ss.dividedReportingOverflow(by: count)
            let (_,rem) = ss.quotientAndRemainder(dividingBy: count)
            stat.avg = Double(avg) + (Double(rem) / Double(count))
            stat.avgOverflow = overflow
        }
        else {

        }

        // MARK: avgDelta
        if let sumDelta = stat.sumDelta {
            stat.avgDelta = count >= 2 ? Double(sumDelta) / Double(count - 1) : nil
        }
        else {
            stat.avgDelta = nil
        }

        return stat
    }
}
