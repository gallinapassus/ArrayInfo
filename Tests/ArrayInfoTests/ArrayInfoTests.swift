import XCTest
@testable import ArrayInfo

final class StatsArrayPerfTests: XCTestCase {
    func testPerf1d() {
        let c = 60 * 60 * 24
        var a:[Int8] = []
        for _ in 0..<c {
            a.append(Int8.random(in: (Int8.min...Int8.max)))
        }
        measure {
            let _ = a.info()
        }
    }
    func testPerf6h() {
        let c = 60 * 60 * 6
        var a:[Int] = []
        for _ in 0..<c {
            a.append(Int.random(in: (Int.min...Int.max)))
        }

        measure {
            let _ = a.info()
        }
    }
    func testPerf1h() {
        let c = 60 * 60
        var a:[UInt] = []
        for _ in 0..<c {
            a.append(UInt.random(in: (UInt.min...UInt.max)))
        }

        measure {
            let _ = a.info()
        }
    }
    func testPerf15m() {
        let c = 60 * 15
        var a:[UInt16] = []
        for _ in 0..<c {
            a.append(UInt16.random(in: (UInt16.min...UInt16.max)))
        }

        measure {
            let _ = a.info()
        }
    }
}
final class StatsArrayTests: XCTestCase {
    func testExample() {
        let array = [1,2,4,8,16]
        var info = array.info(.histogram)
        print(info)
        print(array[3...].info().sum) // Optional(24)
        print(array.reversed().info().isAscending) // false
    }
    func testEmptyArray() {
        let a:[UInt64] = []
        let s1 = a.info()
        let s2 = a.info(.histogram)
        XCTAssertEqual(s1, ArrayInfo<UInt64>())
        XCTAssertEqual(s2, ArrayInfo<UInt64>())
        XCTAssertEqual(s1.constantDelta, nil)
        XCTAssertEqual(s1.hasConstantDelta, false)
        XCTAssertEqual(s2.constantDelta, nil)
        XCTAssertEqual(s2.hasConstantDelta, false)
    }
    func testArrayWithZeroAsOnlyElement() {
        let a:[UInt64] = [0]

        XCTAssertEqual(a.info(),
                       ArrayInfo(count: 1, sum: 0, sumOverflow: false, elementOverflow: false, allElementsEqual: true, avg: 0, avgOverflow: false, minValue: 0, maxValue: 0, minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: true, isStrictlyDescending: true, median: 0.0, histogram: nil, mode: nil))
        
        XCTAssertEqual(a.info(.histogram),
                       ArrayInfo(count: 1, sum: 0, sumOverflow: false, elementOverflow: false, allElementsEqual: true, avg: 0, avgOverflow: false, minValue: 0, maxValue: 0, minValueIndex: 0, maxValueIndex: 0,minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: true, isStrictlyDescending: true, median: 0.0, histogram: [0:1], mode: nil))
    }
    func testArrayWithSingleNegativeElement() {
        let a:[Int16] = [-1]
        let s1 = a.info()
        let s2 = a.info(.histogram)

        XCTAssertEqual(s1, ArrayInfo<Int16>(count: 1, sum: -1, sumOverflow: false, elementOverflow: false, allElementsEqual: true, avg: -1.0, avgOverflow: false, minValue: Optional(-1), maxValue: Optional(-1), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: true, isStrictlyDescending: true, median: -1.0, histogram: nil, mode: nil))
        XCTAssertEqual(s1.constantDelta, nil)
        XCTAssertEqual(s1.hasConstantDelta, false)
        XCTAssertEqual(s2, ArrayInfo<Int16>(count: 1, sum: -1, sumOverflow: false, elementOverflow: false, allElementsEqual: true, avg: -1.0, avgOverflow: false, minValue: Optional(-1), maxValue: Optional(-1), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: true, isStrictlyDescending: true, median: -1.0, histogram: [-1:1], mode: nil))
        XCTAssertEqual(s2.constantDelta, nil)
        XCTAssertEqual(s2.hasConstantDelta, false)
    }
    func testArrayWithSinglePositiveElement() {
        let a:[Int16] = [1]
        let s1 = a.info()
        let s2 = a.info(.histogram)

        XCTAssertEqual(s1, ArrayInfo<Int16>(count: 1, sum: 1, sumOverflow: false, elementOverflow: false, allElementsEqual: true, avg: 1.0, avgOverflow: false, minValue: Optional(1), maxValue: Optional(1), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: true, isStrictlyDescending: true, median: 1.0, histogram: nil, mode: nil))
        XCTAssertEqual(s1.constantDelta, nil)
        XCTAssertEqual(s1.hasConstantDelta, false)
        XCTAssertEqual(s2, ArrayInfo<Int16>(count: 1, sum: 1, sumOverflow: false, elementOverflow: false, allElementsEqual: true, avg: 1.0, avgOverflow: false, minValue: Optional(1), maxValue: Optional(1), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: true, isStrictlyDescending: true, median: 1.0, histogram: Optional([1: 1]), mode: nil))
        XCTAssertEqual(s2.constantDelta, nil)
        XCTAssertEqual(s2.hasConstantDelta, false)
    }
    func testElementOverflow() {
        let a:[UInt64] = [UInt64.max]
        XCTAssertEqual(a.info(),
                       ArrayInfo<UInt64>(count: 0, sum: 0, sumOverflow: false, elementOverflow: true, avg: 0.0, avgOverflow: false, minValue: nil, maxValue: nil, minValueIndex: nil, maxValueIndex: nil, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: true, isStrictlyDescending: true, median: nil, histogram: nil, mode: nil))
        XCTAssertEqual(a.info().constantDelta, nil)
        XCTAssertEqual(a.info().hasConstantDelta, false)
        let b:[UInt64] = [0, UInt64.max]
        XCTAssertEqual(b.info(),
                       ArrayInfo<UInt64>(count: 2, sum: 0, sumOverflow: false, elementOverflow: true, avg: 0.0, avgOverflow: false, minValue: Optional(0), maxValue: Optional(18446744073709551615), minValueIndex: 0, maxValueIndex: 1, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictlyAscending: true, isDescending: false, isStrictlyDescending: false, median: 9.223372036854776e+18, histogram: nil, mode: nil))
        XCTAssertEqual(b.info().constantDelta, nil)
        XCTAssertEqual(b.info().hasConstantDelta, true)
    }
    func testSumOverflow() {
        do {
            let a:[Int8] = []
            let s = a.info()
            XCTAssertFalse(s.sumOverflow)
            XCTAssertEqual(s.sum, 0)
        }
        do {
            let a:[Int64] = [Int64.max]
            let s = a.info()
            XCTAssertFalse(s.sumOverflow)
            XCTAssertEqual(s.sum, 9223372036854775807)
        }
        do {
            let a:[Int64] = [1,Int64.max]
            let s = a.info()
            XCTAssertTrue(s.sumOverflow)
            XCTAssertNil(s.sum)
        }
        do {
            let a:[Int] = [-1, Int.min]
            let s1 = a.info()
            XCTAssertEqual(s1,
                           ArrayInfo<Int>(count: 2, sum: nil, sumOverflow: true, elementOverflow: false, avg: nil, avgOverflow: false, minValue: Optional(-9223372036854775808), maxValue: Optional(-1), minValueIndex: 1, maxValueIndex: 0, minDelta: Optional(9223372036854775807), maxDelta: Optional(9223372036854775807), avgDelta: 9.223372036854776e+18, sumDelta: 9223372036854775807, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictlyAscending: false, isDescending: true, isStrictlyDescending: true, median: -4.611686018427388e+18, histogram: nil))
            XCTAssertEqual(s1.constantDelta, 9223372036854775807)
            XCTAssertEqual(s1.hasConstantDelta, true)
        }
    }
    func testMinMaxIndexes() {
        do {
            let a:[Int] = [0,1,2,3,4,5,6,7,8,9]
            let s = a.info()
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 9)
        }
        do {
            let a:[Int] = [1,1,0,1]
            let s = a.info()
            XCTAssertEqual(s.minValueIndex, 2)
            XCTAssertEqual(s.maxValueIndex, 0)
        }
        do {
            let a:[Int] = [1,2,0,3,3,0]
            let s = a.info()
            XCTAssertEqual(s.minValueIndex, 2)
            XCTAssertEqual(s.maxValueIndex, 3)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 0)
        }
        do {
            let a:[Int] = [0,0]
            let s = a.info()
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 0)
        }
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertNil(s.minValueIndex)
            XCTAssertNil(s.maxValueIndex)
        }
    }
    func testMinMaxDelta() {
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertNil(s.minDelta)
            XCTAssertNil(s.maxDelta)
        }
        do {
            let a:[Int] = [1,2]
            let s = a.info()
            XCTAssertEqual(s.minDelta, 1)
            XCTAssertEqual(s.maxDelta, 1)
        }
        do {
            let a:[Int] = [1,2,4]
            let s = a.info()
            XCTAssertEqual(s.minDelta, 1)
            XCTAssertEqual(s.maxDelta, 2)
        }
        do {
            let a:[Int] = [1,2,4,0,3]
            let s = a.info()
            XCTAssertEqual(s.minDelta, 1)
            XCTAssertEqual(s.maxDelta, 4)
        }
        do {
            let a:[Int] = [-1,1]
            let s = a.info()
            XCTAssertEqual(s.minDelta, 2)
            XCTAssertEqual(s.maxDelta, 2)
        }
        do {
            let a:[Int] = [-10,1,10]
            let s = a.info()
            XCTAssertEqual(s.minDelta, 9)
            XCTAssertEqual(s.maxDelta, 11)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertNil(s.minDelta)
            XCTAssertNil(s.maxDelta)
        }
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertNil(s.minDelta)
            XCTAssertNil(s.maxDelta)
        }
    }
    func testAvgDelta() {
        do {
            let a:[Int] = [0,2,4,8,16]
            let s = a.info()
            XCTAssertEqual(s.avgDelta, 16.0/4.0)
        }
        do {
            let a:[Int] = [-100,-50,-25,0,5]
            let s = a.info()
            XCTAssertEqual(s.avgDelta, 105.0/4.0)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertNil(s.avgDelta)
        }
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertNil(s.avgDelta)
        }
    }
    func testConstantStride() {
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertFalse(s.hasConstantDelta)
            XCTAssertNil(s.constantDelta)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertFalse(s.hasConstantDelta)
            XCTAssertNil(s.constantDelta)
        }
        do {
            let a:[Int] = [0,5]
            let s = a.info()
            XCTAssertTrue(s.hasConstantDelta)
            XCTAssertEqual(s.constantDelta, 5)
        }
        do {
            let a:[Int] = [-5,0,5]
            let s = a.info()
            XCTAssertTrue(s.hasConstantDelta)
            XCTAssertEqual(s.constantDelta, 5)
        }
        do {
            let a:[Int] = [-5,0,3,5]
            let s = a.info()
            XCTAssertFalse(s.hasConstantDelta)
            XCTAssertNil(s.constantDelta)
        }
    }
    func testHistogram() {
        do {
            let a:[Int] = []
            let s = a.info(.histogram)
            XCTAssertNil(s.histogram)
        }
        do {
            let a:[Int] = [0]
            let s = a.info(.histogram)
            XCTAssertNotNil(s.histogram)
            guard let hgram = s.histogram else {
                XCTFail()
                return
            }
            let expected:[(Int,Int)] = [(0,1)]
            for (kv,expected) in zip(hgram.sorted(by: <), expected) {
                XCTAssertEqual(kv.key, expected.0)
                XCTAssertEqual(kv.value, expected.1)
            }
        }
        do {
            let a:[Int] = [0,1,2,1,1,2,-4]
            let s = a.info(.histogram)
            XCTAssertNotNil(s.histogram)
            guard let hgram = s.histogram else {
                XCTFail()
                return
            }
            let expected:[(Int,Int)] = [(-4,1),(0,1), (1,3), (2,2)]
            for (kv,expected) in zip(hgram.sorted(by: <), expected) {
                XCTAssertEqual(kv.key, expected.0)
                XCTAssertEqual(kv.value, expected.1)
            }
        }
    }
    func testIsAscendingDescendingIsSorted() {
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertTrue(s.isAscending)
            XCTAssertTrue(s.isStrictlyAscending)
            XCTAssertTrue(s.isDescending)
            XCTAssertTrue(s.isStrictlyDescending)
            XCTAssertTrue(s.isSorted)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertTrue(s.isAscending)
            XCTAssertTrue(s.isStrictlyAscending)
            XCTAssertTrue(s.isDescending)
            XCTAssertTrue(s.isStrictlyDescending)
            XCTAssertTrue(s.isSorted)
        }
        do {
            let a:[Int] = [0,0]
            let s = a.info()
            XCTAssertTrue(s.isAscending)
            XCTAssertFalse(s.isStrictlyAscending)
            XCTAssertTrue(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertTrue(s.isSorted)
        }
        do {
            let a:[Int] = [0,1]
            let s = a.info()
            XCTAssertTrue(s.isAscending)
            XCTAssertTrue(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertTrue(s.isSorted)
        }
        do {
            let a:[Int] = [0,1,1]
            let s = a.info()
            XCTAssertTrue(s.isAscending)
            XCTAssertFalse(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertTrue(s.isSorted)
        }
        do {
            let a:[Int] = [0,1,1,0]
            let s = a.info()
            XCTAssertFalse(s.isAscending)
            XCTAssertFalse(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertFalse(s.isSorted)
        }
        do {
            let a:[Int] = [0,1,10,11,10]
            let s = a.info()
            XCTAssertFalse(s.isAscending)
            XCTAssertFalse(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertFalse(s.isSorted)
        }
    }
    func testAllElementsEqual() {
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertFalse(s.allElementsEqual)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertTrue(s.allElementsEqual)
        }
        do {
            let a:[Int] = [0,0]
            let s = a.info()
            XCTAssertTrue(s.allElementsEqual)
        }
        do {
            let a:[Int] = [0,1]
            let s = a.info()
            XCTAssertFalse(s.allElementsEqual)
        }
    }
    func testMedian() {
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertNil(s.median)
        }
        do {
            let a:[Int] = [1]
            let s = a.info()
            XCTAssertEqual(s.median, 1.0)
        }
        do {
            let a:[Int] = [0,1]
            let s = a.info()
            XCTAssertEqual(s.median, 0.5)
        }
        do {
            let a:[Int] = [0,1,10]
            let s = a.info()
            XCTAssertEqual(s.median, 1.0)
        }
        do {
            let a:[Int] = [0,1,10,11]
            let s = a.info()
            XCTAssertEqual(s.median, 5.5)
        }
        do {
            let a:[Int] = [0,1,10,11,10]
            let s = a.info()
            print(s.isAscending, s.isDescending)
            XCTAssertNil(s.median)
        }
    }
    func testMode() {
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertNil(s.mode)
        }
        do {
            let a:[Int] = []
            let s = a.info(.histogram)
            XCTAssertNil(s.mode)
        }
        do {
            let a:[Int] = [1]
            let s = a.info()
            XCTAssertNil(s.mode)
        }
        do {
            let a:[Int] = [10]
            let s = a.info(.histogram)
            XCTAssertNil(s.mode)
        }
        do {
            let a:[Int] = [0,1]
            let s = a.info(.histogram)
            XCTAssertNil(s.mode)
        }
        do {
            let a:[Int] = [1,1]
            let s = a.info(.histogram)
            XCTAssertNil(s.mode)
        }
        do {
            let a:[Int] = [1,1,1]
            let s = a.info(.histogram)
            XCTAssertNil(s.mode)
        }
        do {
            let a:[Int] = [1,1,1,0,0,0]
            let s = a.info(.histogram)
            XCTAssertNil(s.mode)
        }
        do {
            let a:[Int] = [0,1,1,0,2]
            let s = a.info(.histogram)
            XCTAssertEqual(s.mode, [0,1])
        }
        do {
            let a:[Int] = [-1,0,-1,1,1,1]
            let s = a.info(.histogram)
            XCTAssertEqual(s.mode, [1])
        }
        do {
            let a:[Int] = [1,2,3,1,2,3,1,2,3,0]
            let s = a.info(.histogram)
            XCTAssertEqual(s.mode, [1,2,3])
        }
        do {
            let a:[Int] = [1,2,3,1,2,3,1,2,3]
            let s = a.info(.histogram)
            XCTAssertNil(s.mode)
        }
        do {
            let a:[UInt64] = [0, 9223372036854775807, 9223372036854775807, UInt64.max]
            let s = a.info(.histogram)
            XCTAssertEqual(s.mode, [UInt64(9223372036854775807)])
            // UInt64.max causes an elementOverflow, yet we will be able to determine modes
            XCTAssertTrue(s.elementOverflow)
        }
    }
    func testSlices() {
        let a:[Int] = [1,2,4,8,16,12,10,8,6,4,2,1]
        do {
            let s = a[1...3].info()
            dump(s)
            XCTAssertEqual(s.count, 3)
            XCTAssertEqual(s.sum, 14)
            XCTAssertFalse(s.sumOverflow)
            
            XCTAssertFalse(s.elementOverflow)
            XCTAssertFalse(s.allElementsEqual)
            XCTAssertEqual(s.avg, Optional(4.666666666666667))
            XCTAssertFalse(s.avgOverflow)
            XCTAssertEqual(s.minValue, Optional(2))
            XCTAssertEqual(s.maxValue, Optional(8))
            XCTAssertEqual(s.minValueIndex, Optional(1))
            XCTAssertEqual(s.maxValueIndex, Optional(3))
            XCTAssertEqual(s.minDelta, Optional(2))
            XCTAssertEqual(s.maxDelta, Optional(4))
            XCTAssertEqual(s.avgDelta, Optional(3.0))
            XCTAssertEqual(s.sumDelta, Optional(6))
            XCTAssertFalse(s.sumDeltaOverflow)
            XCTAssertFalse(s.minMaxDeltaOverflow)
            XCTAssertTrue(s.isAscending)
            XCTAssertTrue(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertEqual(s.median, Optional(2.0))
            XCTAssertNil(s.histogram)
            XCTAssertNil(s.mode)
        }
        do {
            let s = a[4...].info() // [16,12,10,8,6,4,2,1]
            XCTAssertEqual(s.count, 8)
            XCTAssertEqual(s.sum, 59)
            XCTAssertFalse(s.sumOverflow)
            
            XCTAssertFalse(s.elementOverflow)
            XCTAssertFalse(s.allElementsEqual)
            XCTAssertEqual(s.avg, Optional(7.375))
            XCTAssertFalse(s.avgOverflow)
            XCTAssertEqual(s.minValue, Optional(1))
            XCTAssertEqual(s.maxValue, Optional(16))
            XCTAssertEqual(s.minValueIndex, Optional(11))
            XCTAssertEqual(s.maxValueIndex, Optional(4))
            XCTAssertEqual(s.minDelta, Optional(1))
            XCTAssertEqual(s.maxDelta, Optional(4))
            XCTAssertEqual(s.avgDelta, Optional(2.142857142857143))
            XCTAssertEqual(s.sumDelta, Optional(15))
            XCTAssertFalse(s.sumDeltaOverflow)
            XCTAssertFalse(s.minMaxDeltaOverflow)
            XCTAssertFalse(s.isAscending)
            XCTAssertFalse(s.isStrictlyAscending)
            XCTAssertTrue(s.isDescending)
            XCTAssertTrue(s.isStrictlyDescending)
            XCTAssertEqual(s.median, Optional(7.0))
            XCTAssertNil(s.histogram)
            XCTAssertNil(s.mode)

        }
    }
}
