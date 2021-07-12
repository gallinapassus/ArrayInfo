# ArrayInfo

Extends Swift ArraySlice and Sequence with `info(with:)` method returning a concrete type ArrayInfo containing information about trivial statistical information about array and it's elements. 

    import ArrayInfo
    
    let array = [1,2,4,8,16]
    var info = array.info(with: .histogram)
    print(info) // ArrayInfo<Int>(options: ArrayInfo.ArrayInfo<Swift.Int>.Options(rawValue: 0), count: 5, sum: Optional(31), elementOverflow: false, sumOverflow: false, avg: Optional(6.2), avgOverflow: false, minValue: Optional(1), maxValue: Optional(16), minDelta: Optional(1), maxDelta: Optional(8), avgDelta: Optional(6.0), sumDelta: Optional(24), sumDeltaOverflow: false, deltaOverflow: false, isAscending: true, isStrictAscending: true, histogram: Optional([2: 1, 8: 1, 4: 1, 16: 1, 1: 1]))

