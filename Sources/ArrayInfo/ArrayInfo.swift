public struct ArrayInfo<T:AdditiveArithmetic&BinaryInteger> : Equatable {
    public struct Options : OptionSet {
        public typealias RawValue = Int
        public let rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        public static var histogram:Options { Options(rawValue: 1 << 0) }
    }
    fileprivate (set) public var options:Options = []
    fileprivate (set) public var count:Int = 0
    fileprivate (set) public var sum:Int? = 0
    fileprivate (set)public var elementOverflow:Bool = false
    fileprivate (set) public var sumOverflow:Bool = false
    fileprivate (set) public var avg:Double? = 0
    fileprivate (set) public var avgOverflow:Bool = false
    fileprivate (set) public var minValue:T?
    fileprivate (set) public var maxValue:T?
    fileprivate (set) public var minDelta:Int?
    fileprivate (set) public var maxDelta:Int?
    fileprivate (set) public var avgDelta:Double?
    fileprivate (set) public var sumDelta:Int?
    fileprivate (set) public var sumDeltaOverflow:Bool = false
    fileprivate (set) public var deltaOverflow:Bool = false
    fileprivate (set) public var isAscending:Bool = false
    fileprivate (set) public var isStrictAscending:Bool = false
    public var hasConstantStride:Bool { count >= 2 && minDelta == maxDelta }
    public var constantStride:Int? { hasConstantStride ? minDelta : nil }
    fileprivate (set) public var histogram:[T:Int]?
}
public extension Sequence where Element:AdditiveArithmetic&FixedWidthInteger {
    func info(with options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
        ArraySlice(self).info(with: options)
    }
}
public extension ArraySlice where Element:AdditiveArithmetic&FixedWidthInteger {
    func info(with options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
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
            stat.minValue = Swift.min(stat.minValue!, Swift.min(self[l], self[r]))
            stat.maxValue = Swift.max(stat.maxValue!, Swift.max(self[l], self[r]))

            // MARK: minDelta & maxDelta
            let (distance,deltaOverflow) = rint.subtractingReportingOverflow(lint)
            if deltaOverflow {
                stat.deltaOverflow = true
                stat.sumDelta = nil
            }
            else {
                stat.minDelta = Swift.min(stat.minDelta ?? distance, distance)
                stat.maxDelta = Swift.max(stat.maxDelta ?? distance, distance)
            }

            // MARK: sumDelta
            let (sumDelta,sumDeltaOverflow) = lint.addingReportingOverflow(rint)
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

        // MARK: isAscending
        stat.isAscending = stat.minDelta == nil ? false : stat.minDelta! >= 0

        // MARK: isStrictAscending
        stat.isStrictAscending = stat.minDelta == nil ? false : stat.minDelta! > 0

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
