# ArrayInfo

Extends Swift `ArraySlice` and `Sequence` with

    info(_ options:ArrayInfo.Options = []) -> ArrayInfo<Element>
    
Concrete type ArrayInfo contains trivial/statistical information about the array/sequence and it's elements. Extensions are valid for element types `Element:AdditiveArithmetic&FixedWidthInteger`.

    import ArrayInfo
    
    let array = [1,2,4,8,16]
    var info = array.info(.histogram)
    print(info) // ArrayInfo<Int>(count: 5, sum: Optional(31), sumOverflow: false, elementOverflow: false, allElementsEqual: false, avg: Optional(6.2), avgOverflow: false, minValue: Optional(1), maxValue: Optional(16), minValueIndex: Optional(0), maxValueIndex: Optional(4), minDelta: Optional(1), maxDelta: Optional(8), avgDelta: Optional(3.75), sumDelta: Optional(15), sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: false, isStrictlyDescending: false, median: Optional(4.0), histogram: Optional([4: 1, 2: 1, 8: 1, 1: 1, 16: 1]), mode: nil)
    
    print(array[3...].info().sum) // Optional(24)
    print(array.reversed().info().isAscending) // false

### Performance
O(n), all information is collected on a single pass through elements. 

### Other
`ArrayInfo` will update the overflow properties (and set the respective property to nil) when overflows occurs. 
