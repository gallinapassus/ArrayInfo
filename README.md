# ArrayInfo

Extends Swift `ArraySlice` and `Sequence` with

    info(_ options:ArrayInfo.Options = []) -> ArrayInfo<Element>

for `Element` types conforming to `BinaryInteger&Codable` and `BinaryFloatingPoint&Codable`.

    
Concrete type ArrayInfo contains trivial/statistical information about array/sequence and it's elements.

    import ArrayInfo
    
    let array = [1,2,4,8,16]
    var info = array.info(.histogram)
    print(info) // ArrayInfo<Int>(issues: Set([]), count: 5, isEmpty: false, sum: Optional(31.0), exactSum: Optional(31), _exactSumOverflow: false, _elementOverflow: false, allElementsEqual: false, avg: Optional(6.2), minValue: Optional(1), maxValue: Optional(16), minValueIndex: Optional(0), maxValueIndex: Optional(4), exactMinDelta: Optional(1), exactMaxDelta: Optional(8), minDelta: Optional(1.0), maxDelta: Optional(8.0), avgDelta: Optional(3.75), exactSumDelta: Optional(15), sumDelta: Optional(15.0), _exactSumDeltaOverflow: false, _exactMinMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: false, isStrictlyDescending: false, hasConstantExactDelta: false, constantExactDelta: nil, median: Optional(4.0), histogram: Optional([4: 1, 8: 1, 2: 1, 16: 1, 1: 1]), mode: nil)
    
    print(array[3...].info().sum) // Optional(24)
    print(array.reversed().info().isAscending) // false

### Performance
O(n), all information is collected on a single pass through the elements. 
