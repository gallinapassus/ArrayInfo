import Foundation

/// Concrete type storing trivial / statistical information about an array
///
/// - Complexity: O(n)
public struct ArrayInfo<T:Hashable&Comparable&Codable> : Codable {
    /// Concrete type representing various calculation/element related issues
    public enum Issue : Equatable, Hashable, Codable {
        /// Issue in calculating the sum
        case sum       // Calculating the intSum overflowed
        /// Issue in calculating the average
        case avg       // Calculating the average overflowed
        /// Issue with element
        ///
        /// Element conversion to `Int` failed or Element conversion to `Double` failed when `.exact` option was set.
        /// - Attention: See also ``ArrayInfo.Options.exact``
        case element(T) // Element can not be represented exactly as an BinaryInteger -or- BinaryFloatingPoint
        public var description:String {
            switch self {
            case .sum: return "Exact sum calculation overflow"
            case .avg: return "Accurate average calculation was not possible"
            case .element(let v): return "Element \(v) can not be represented exactly as '\(Int.self)' (\(MemoryLayout<Int>.size * 8)-bit integer)"
            }
        }
    }
    /// Available options for `ArrayInfo`
    public struct Options : OptionSet, Codable {
        public typealias RawValue = Int
        public let rawValue: RawValue
        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }
        /// Enable value histogram
        /// - Attention: `mode` is calculated only when `Option.histogram` is set.
        public static var histogram:Options { Options(rawValue: 1 << 0) }
        /// Require exact conversion of floating point numbers to Double (no rounding allowed)
        ///
        /// BinaryFloatingPoint elements are converted to Doubles for some calculations. If `exact`
        /// option is set the conversion is done with `Double(exactly: elementValue)`. Default conversion
        /// is done with `Double(elementValue)` which will result the closest representation of the elementValue
        /// (when it can not be represented exactly).
        public static var exact:Options { Options(rawValue: 1 << 1) }
    }
    /// Issues encountered while calculating the `ArrayInfo` values
    fileprivate (set) public var issues:Set<Issue> = []
    /// Number of elements
    fileprivate (set) public var count:Int = 0
    /// Number of elements
    fileprivate (set) public var isEmpty:Bool = true
    /// Sum of elements
    fileprivate (set) public var sum:Double?
    /// Exact sum of elements
    fileprivate (set) public var exactSum:Int?
    private var _exactSumOverflow:Bool = false
    /// Indication of `exactSum` calculation overflow
    fileprivate (set) public var exactSumOverflow:Bool {
        get {
            _exactSumOverflow
        }
        set {
            _exactSumOverflow = newValue
            guard newValue == true else {
                return
            }
            exactSum = nil
        }
    }
    private var _elementOverflow:Bool = false
    /// Indication of element overflow
    ///
    /// Set to `true` if given element can not be presented as an exact `Int` value
    fileprivate (set) public var elementOverflow:Bool {
        get {
            _elementOverflow
        }
        set {
            _elementOverflow = newValue
        }
    }
    /// Indicates if all elements are equal
    ///
    /// - Attention: This property will return `false` when `elementOverflow` is `true`
    ///  or when array/sequence is empty.
    fileprivate (set) public var allElementsEqual:Bool = false
    /// Average (arithmetic mean) of the elements
    fileprivate (set) public var avg:Double?
    /*
    /// Indication of average calculation overflow
    fileprivate (set) public var avgOverflow:Bool = false
     */
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
    fileprivate (set) public var exactMinDelta:UInt?
    /// Maximum distance between two consecutive values
    fileprivate (set) public var exactMaxDelta:UInt?
    /// Minimum distance between two consecutive values
    fileprivate (set) public var minDelta:Double?
    /// Maximum distance between two consecutive values
    fileprivate (set) public var maxDelta:Double?
    /// Average distance between consecutive values
    fileprivate (set) public var avgDelta:Double?
//    fileprivate (set) public var exactSumDelta:UInt?
    /// Sum of deltas (delta = distance between two consecutive values)
    fileprivate (set) public var exactSumDelta:UInt?
    /// Sum of deltas (delta = distance between two consecutive values)
    fileprivate (set) public var sumDelta:Double?
    private var _exactSumDeltaOverflow:Bool = false
    /// Indication of `exactSumDelta` calculation overflow
    fileprivate (set) public var exactSumDeltaOverflow:Bool {
        get {
            _exactSumDeltaOverflow
        }
        set {
            _exactSumDeltaOverflow = newValue
            guard newValue == true else {
                return
            }
            exactSumDelta = nil
        }
    }
    private var _exactMinMaxDeltaOverflow:Bool = false
    /// Indication of `exactMinDelta` and/or `exactMaxDelta` calculation overflow
    fileprivate (set) public var exactMinMaxDeltaOverflow:Bool {
        get {
            _exactMinMaxDeltaOverflow
        }
        set {
            _exactMinMaxDeltaOverflow = newValue
            guard newValue == true else {
                return
            }
            exactMinDelta = nil
            exactMaxDelta = nil
            exactSumDeltaOverflow = true
        }
    }
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
    /// Indicates if values in array have a constant delta (delta = distance between two consecutive values)
    public var hasConstantExactDelta:Bool = false
    /// Constant delta value (delta = distance between two consecutive values)
    public var constantExactDelta:UInt?
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
    @inline(__always)
    fileprivate mutating func _preLoop(rawValue:T, rawValueAsDouble:Double?, firstValueAsInt:Int?, firstIndex:Int, options:Options, elementCount:Int, _ isBinaryInteger:Bool) {
        
        if options.contains(.histogram) {
            histogram = [:]
            histogram![rawValue, default: 0] = 1
        }
        minValue = rawValue
        maxValue = rawValue
        minValueIndex = firstIndex
        maxValueIndex = firstIndex
        count = elementCount
        isEmpty = elementCount == 0

        if let intVal = firstValueAsInt {
            exactSum = intVal
            sum = options.contains(.exact) ? Double(exactly: intVal) : Double(intVal)
        }
        else {
            if isBinaryInteger {
                elementOverflow = true
                exactSumOverflow = true
                issues.insert(.element(rawValue))
            }
            else {
                exactSumOverflow = true
            }
        }
        if let rdbl = rawValueAsDouble {
            sum = rdbl
        }
    }
    @inline(__always)
    fileprivate mutating func _inLoop(_ rindex:Int, _ lval:T, _ rval:T, _ lint:Int?, _ rint:Int?, _ ldbl:Double?, _ rdbl:Double?, _ options:Options, _ isBinaryInteger:Bool) {
        // MARK: minValue, maxValue, minValueIndex, maxValueIndex
        do {
            if rval < minValue! {
                minValueIndex = rindex
            }
            if rval > maxValue! {
                maxValueIndex = rindex
            }
            minValue = Swift.min(minValue!, Swift.min(lval, rval))
            maxValue = Swift.max(maxValue!, Swift.max(lval, rval))
        }
        // MARK: isAscending, isStrictlyAscending, isDescending, isStrictlyDescending
        do {
            if count > 1, (isAscending == true || isStrictlyAscending == true),
               lval <= rval {
                if lval == rval {
                    isStrictlyAscending = false
                }
            }
            else if count > 1 {
                isAscending = false
                isStrictlyAscending = false
            }
            if count > 1, (isDescending == true || isStrictlyDescending == true),
               lval >= rval {
                if lval == rval {
                    isStrictlyDescending = false
                }
            }
            else if count > 1 {
                isDescending = false
                isStrictlyDescending = false
            }
        }
        // MARK: exactMinDelta, exactMaxDelta, exactMinMaxDeltaOverflow, exactSumDelta, exactSumOverflow, minDelta, maxDelta
        do {
            if let lint = lint, let rint = rint {
                let (distance,deltaOverflow) = rint.subtractingReportingOverflow(lint)
                if deltaOverflow {
                    exactMinMaxDeltaOverflow = true
                    exactSumDelta = nil
                }
                else {
                    exactMinDelta = Swift.min(exactMinDelta ?? distance.magnitude, distance.magnitude)
                    exactMaxDelta = Swift.max(exactMaxDelta ?? distance.magnitude, distance.magnitude)
                    minDelta = Double(exactMinDelta!)
                    maxDelta = Double(exactMaxDelta!)
                }
            }
            else {
                exactSumOverflow = isBinaryInteger ? true : false
                if lint == nil, isBinaryInteger {
                    issues.insert(.element(lval))
                }
                if rint == nil, isBinaryInteger {
                    issues.insert(.element(rval))
                }
                if let luint = lval as? UInt, let ruint = rval as? UInt {
                    let (magnitude,overflow) = ruint > luint ? ruint.subtractingReportingOverflow(luint) : luint.subtractingReportingOverflow(ruint)
                    if overflow == false, let uintMagnitude = UInt(exactly: magnitude) {
                        exactMinDelta = Swift.min(exactMinDelta ?? uintMagnitude, uintMagnitude)
                        exactMaxDelta = Swift.max(exactMaxDelta ?? uintMagnitude, uintMagnitude)
                        minDelta = Swift.min(minDelta ?? Double(uintMagnitude), Double(uintMagnitude))
                        maxDelta = Swift.max(maxDelta ?? Double(uintMagnitude), Double(uintMagnitude))
                    }
                }
                else if let ldbl = ldbl, let rdbl = rdbl {
                    let distance = rdbl > ldbl ? rdbl - ldbl : ldbl - rdbl
                    if distance != .nan && distance != .infinity {
                        minDelta = Swift.min(minDelta ?? distance.magnitude, distance.magnitude)
                        maxDelta = Swift.max(maxDelta ?? distance.magnitude, distance.magnitude)
                    }
                }
            }
        }
        // MARK: exactSum, exactSumOverflow, sum, histogram, elementOverflow
        do {
            if let r = rint {
                if let s = exactSum {
                    let (newSum, overflow) = s.addingReportingOverflow(r)
                    if overflow == false {
                        exactSum = newSum
                    }
                    else {
                        if isBinaryInteger {
                            exactSum = nil
                            exactSumOverflow = true
                        }
                        else {
                            exactSum = nil
                            exactSumOverflow = false
                        }
                    }
                }
                if let v = histogram?[rval] {
                    histogram![rval] = v + 1
                }
                else {
                    histogram?[rval, default: 0] = 1
                }
            }
            else if let _ = rdbl {
                if isBinaryInteger {
                    elementOverflow = true
                    issues.insert(.element(rval))
                }
                if let v = histogram?[rval] {
                    histogram![rval] = v + 1
                }
                else {
                    histogram?[rval, default: 0] = 1
                }
            }
            else {
                issues.insert(.element(rval))
                elementOverflow = true
            }
            if let s = sum {
                if let rdbl = rdbl {
                    sum = s + rdbl
                }
                else {
                    issues.insert(.element(rval))
                    sum = nil
                }
            }
        }
        // MARK: exactSumDelta, exactSumDeltaOverflow, sumDelta, elementOverflow
        do {
            if let l = lint, let r = rint {
                if let s = exactSumDelta {
                    let (magnitude,overflow) = r > l ? r.subtractingReportingOverflow(l) : l.subtractingReportingOverflow(r)
                    if overflow {
                        exactSumDeltaOverflow = true
                        exactSumDelta = nil
                    }
                    else {
                        let (newSumDelta,overflow) = s.addingReportingOverflow(UInt(magnitude))
                        if overflow {
                            exactSumDelta = nil
                            exactSumDeltaOverflow = true
                        }
                        else {
                            exactSumDelta = newSumDelta
                            sumDelta = Double(newSumDelta)
                        }
                    }
                }
                else {
                    let (magnitude,overflow) = r > l ? r.subtractingReportingOverflow(l) : l.subtractingReportingOverflow(r)
                    if overflow {
                        exactSumDeltaOverflow = true
                        exactSumDelta = nil
                    }
                    else {
                        exactSumDelta = UInt(magnitude)
                    }
                }
            }
            else if let ldbl = ldbl, let rdbl = rdbl {
                let distance = rdbl > ldbl ? rdbl - ldbl : ldbl - rdbl
                if let s = sumDelta {
                    sumDelta = s + distance
                }
                else {
                    sumDelta = distance
                }
            }
            else {
                if lint == nil {
                    issues.insert(.element(lval))
                    elementOverflow = true
                }
                if rint == nil {
                    issues.insert(.element(rval))
                    elementOverflow = true
                }
            }
        }
    }
    @inline(__always)
    fileprivate mutating func _postLoop() {
        // MARK: allElementsEqual
        allElementsEqual = (/*elementOverflow ||*/ minValue != maxValue) ? false : true
                
        // MARK: avg
        if let s = exactSum {
            // First, try to calculate avg from exact intSum
            let (avg,overflow) = s.dividedReportingOverflow(by: count)
            let (_,rem) = s.quotientAndRemainder(dividingBy: count)
            self.avg = Double(avg) + (Double(rem) / Double(count))
            if overflow {
                issues.insert(.avg)
                self.avg = nil
                //avgOverflow = true
            }
        }
        else if let s = sum {
            let dblavg = s / Double(count)
            if dblavg.isNaN || dblavg.isSignalingNaN || dblavg.isInfinite {
                self.avg = nil
                //avgOverflow = true
                issues.insert(.avg)
            }
            else {
                self.avg = dblavg
            }
        }

        // MARK: avgDelta
        if let sumDelta = exactSumDelta {
            avgDelta = count >= 2 ? Double(sumDelta) / Double(count - 1) : nil
        }
        else if let sumDelta = sumDelta {
            avgDelta = count >= 2 ? sumDelta / Double(count - 1) : nil
        }
        else {
            avgDelta = nil
        }
                
        // MARK: constantDelta
        if let minDelta = exactMinDelta,
           let maxDelta = exactMaxDelta,
           minDelta == maxDelta {
            hasConstantExactDelta = count >= 2
            constantExactDelta = minDelta
        }
        // MARK: mode
        if let hgram = histogram,
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
                mode = modesSorted.map { $0.key }
            }
        }
    }
}
public extension Sequence where Element:BinaryInteger&Codable {
    /// Calculate trivial / statistical info about the sequence and it's values
    ///
    /// See ``ArrayInfo`` for more details of calculated data.
    /// - Returns: ArrayInfo
    func info(_ options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
        ArraySlice(self).info(options)
    }
}
public extension ArraySlice where Element:BinaryInteger&Codable {
    /// Calculate trivial / statistical info about ArraySlice and it's values
    ///
    /// See ``ArrayInfo`` for more details of calculated data.
    /// - Returns: ArrayInfo
    func info(_ options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
        // Fail fast with default values
        guard self.isEmpty == false else {
            return ArrayInfo<Element>()
        }
        // Slice range
        let r:Range<Index> = self.startIndex..<self.endIndex
        var stat = ArrayInfo<Element>()
        let firstValue = first!
        stat._preLoop(rawValue: firstValue,
                      rawValueAsDouble: Double(exactly: firstValue),
                      firstValueAsInt: Int(exactly: firstValue),
                      firstIndex: self.indices.startIndex,
                      options: options,
                      elementCount: count,
                      true)
        for (l,r) in zip(r.dropLast(),r.dropFirst()) {
            if options.contains(.exact) {
                stat._inLoop(r, self[l], self[r],
                             Int(exactly: self[l]), Int(exactly: self[r]),
                             Double(exactly: self[l]), Double(exactly: self[r]),
                             options, true)
            }
            else {
                stat._inLoop(r, self[l], self[r],
                             Int(exactly: self[l]), Int(exactly: self[r]),
                             Double(self[l]), Double(self[r]),
                             options, true)
            }
        }
        stat._postLoop()
        // MARK: median
        if stat.isAscending || stat.isDescending {
            if count == 1 {
                stat.median = options.contains(.exact) ? Double(exactly: firstValue) : Double(firstValue)
            }
            else if count > 1 && count % 2 == 0 {
                let lidx = self.startIndex + (count / 2) - 1
                let ridx = self.startIndex + (count / 2)
                if options.contains(.exact) {
                    if let l = Double(exactly: self[lidx]), let r = Double(exactly: self[ridx]) {
                        stat.median = (l + r) / 2.0
                    }
                    else {
                        stat.median = nil
                    }
                }
                else {
                    stat.median = (Double(self[lidx]) + Double(self[ridx])) / 2.0
                }
            }
            else {
                let idx = count / 2
                stat.median = Double(self[idx])
            }
        }
        return stat
    }
}
public extension Sequence where Element:BinaryFloatingPoint&Codable {
    /// Calculate trivial / statistical info about the sequence and it's values
    ///
    /// See ``ArrayInfo`` for more details of calculated data.
    /// - Returns: ArrayInfo
    func info(_ options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
        ArraySlice(self).info(options)
    }
}
public extension ArraySlice where ArraySlice.Element:BinaryFloatingPoint&Codable {
    /// Calculate trivial / statistical info about the ArraySlice and it's values
    ///
    /// See ``ArrayInfo`` for more details of calculated data.
    /// - Returns: ArrayInfo
    func info(_ options:ArrayInfo<Element>.Options = []) -> ArrayInfo<Element> {
        // Fail fast with default values
        guard self.isEmpty == false else {
            return ArrayInfo<Element>()
        }
        // Slice range
        let r:Range<Index> = self.startIndex..<self.endIndex
        var stat = ArrayInfo<Element>()
        let firstValue = first!
        stat._preLoop(rawValue: firstValue,
                      rawValueAsDouble: Double(firstValue),
                      firstValueAsInt: Int(exactly: firstValue),
                      firstIndex: self.indices.startIndex,
                      options: options,
                      elementCount: count,
                      false)
        stat.exactSumOverflow = false
        stat.exactSum = nil
        for (l,r) in zip(r.dropLast(),r.dropFirst()) {
            if options.contains(.exact) {
                stat._inLoop(r, self[l], self[r],
                             Int(exactly: self[l]), Int(exactly: self[r]),
                             Double(exactly: self[l]), Double(exactly: self[r]),
                             options, false)
            }
            else {
                stat._inLoop(r, self[l], self[r],
                             Int(exactly: self[l]), Int(exactly: self[r]),
                             Double(self[l]), Double(self[r]),
                             options, false)
            }
        }
        stat._postLoop()
        // MARK: median
        if stat.isAscending || stat.isDescending {
            if count == 1 {
                stat.median = Double(firstValue)
            }
            else if count > 1 && count % 2 == 0 {
                let lidx = self.startIndex + (count / 2) - 1
                let ridx = self.startIndex + (count / 2)
                if options.contains(.exact) {
                    if let l = Double(exactly: self[lidx]), let r = Double(exactly: self[ridx]) {
                        stat.median = (l + r) / 2.0
                    }
                    else {
                        stat.median = nil
                    }
                }
                else {
                    stat.median = (Double(self[lidx]) + Double(self[ridx])) / 2.0
                }
            }
            else {
                let idx = self.startIndex + (count / 2)
                if options.contains(.exact) {
                    stat.median = Double(exactly: self[idx])
                }
                else {
                    stat.median = Double(self[idx])
                }
            }
        }
        return stat
    }
}

