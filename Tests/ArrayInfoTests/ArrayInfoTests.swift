import XCTest
@testable import ArrayInfo

final class StatsArrayTests: XCTestCase {
//    func testExample() {
//        let array = [1,2,4,8,16]
//        var info = array.info(.histogram)
//        print(info)
//    }
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
    func testEmptyArray() {
        let a:[UInt64] = []
        let s1 = a.info()
        let s2 = a.info(.histogram)
        XCTAssertEqual(s1, ArrayInfo<UInt64>())
        XCTAssertEqual(s2, ArrayInfo<UInt64>())
        XCTAssertEqual(s1.constantStride, nil)
        XCTAssertEqual(s1.hasConstantStride, false)
        XCTAssertEqual(s2.constantStride, nil)
        XCTAssertEqual(s2.hasConstantStride, false)
    }
    func testArrayWithZeroAsOnlyElement() {
        let a:[UInt64] = [0]

        XCTAssertEqual(a.info(),
                       ArrayInfo(count: 1, sum: 0, elementOverflow: false, sumOverflow: false, avg: 0, avgOverflow: false, minValue: 0, maxValue: 0, minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        
        XCTAssertEqual(a.info(.histogram),
                       ArrayInfo(count: 1, sum: 0, elementOverflow: false, sumOverflow: false, avg: 0, avgOverflow: false, minValue: 0, maxValue: 0, minValueIndex: 0, maxValueIndex: 0,minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: [0:1]))
    }
    func testArrayWithSingleNegativeElement() {
        let a:[Int16] = [-1]
        let s1 = a.info()
        let s2 = a.info(.histogram)

        XCTAssertEqual(s1, ArrayInfo<Int16>(count: 1, sum: -1, elementOverflow: false, sumOverflow: false, avg: -1.0, avgOverflow: false, minValue: Optional(-1), maxValue: Optional(-1), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(s1.constantStride, nil)
        XCTAssertEqual(s1.hasConstantStride, false)
        XCTAssertEqual(s2, ArrayInfo<Int16>(count: 1, sum: -1, elementOverflow: false, sumOverflow: false, avg: -1.0, avgOverflow: false, minValue: Optional(-1), maxValue: Optional(-1), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: [-1:1]))
        XCTAssertEqual(s2.constantStride, nil)
        XCTAssertEqual(s2.hasConstantStride, false)
    }
    func testArrayWithSinglePositiveElement() {
        let a:[Int16] = [1]
        let s1 = a.info()
        let s2 = a.info(.histogram)

        XCTAssertEqual(s1, ArrayInfo<Int16>(count: 1, sum: 1, elementOverflow: false, sumOverflow: false, avg: 1.0, avgOverflow: false, minValue: Optional(1), maxValue: Optional(1), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(s1.constantStride, nil)
        XCTAssertEqual(s1.hasConstantStride, false)
        XCTAssertEqual(s2, ArrayInfo<Int16>(count: 1, sum: 1, elementOverflow: false, sumOverflow: false, avg: 1.0, avgOverflow: false, minValue: Optional(1), maxValue: Optional(1), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: Optional([1: 1])))
        XCTAssertEqual(s2.constantStride, nil)
        XCTAssertEqual(s2.hasConstantStride, false)
    }
    func testElementOverflow() {
        let a:[UInt64] = [UInt64.max]
        XCTAssertEqual(a.info(),
                       ArrayInfo<UInt64>(count: 0, sum: 0, elementOverflow: true, sumOverflow: false, avg: 0.0, avgOverflow: false, minValue: nil, maxValue: nil, minValueIndex: nil, maxValueIndex: nil, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(a.info().constantStride, nil)
        XCTAssertEqual(a.info().hasConstantStride, false)
        let b:[UInt64] = [0, UInt64.max]
        XCTAssertEqual(b.info(),
                       ArrayInfo<UInt64>(count: 2, sum: 0, elementOverflow: true, sumOverflow: false, avg: 0.0, avgOverflow: false, minValue: Optional(0), maxValue: Optional(0), minValueIndex: 0, maxValueIndex: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: true, isStrictAscending: true, histogram: nil))
        XCTAssertEqual(b.info().constantStride, nil)
        XCTAssertEqual(b.info().hasConstantStride, true)
    }
    func testSumOverflow() {
        let a:[Int] = [-1, Int.min]
        let s1 = a.info()
        XCTAssertEqual(s1,
                       ArrayInfo<Int>(count: 2, sum: nil, elementOverflow: false, sumOverflow: true, avg: nil, avgOverflow: false, minValue: Optional(-9223372036854775808), maxValue: Optional(-1), minValueIndex: 1, maxValueIndex: 0, minDelta: Optional(9223372036854775807), maxDelta: Optional(9223372036854775807), avgDelta: 9.223372036854776e+18, sumDelta: 9223372036854775807, sumDeltaOverflow: false, minMaxDeltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(s1.constantStride, 9223372036854775807)
        XCTAssertEqual(s1.hasConstantStride, true)
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
            //XCTAssertEqual(s.maxDelta, 11)
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
            XCTAssertFalse(s.hasConstantStride)
            XCTAssertNil(s.constantStride)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertFalse(s.hasConstantStride)
            XCTAssertNil(s.constantStride)
        }
        do {
            let a:[Int] = [0,5]
            let s = a.info()
            XCTAssertTrue(s.hasConstantStride)
            XCTAssertEqual(s.constantStride, 5)
        }
        do {
            let a:[Int] = [-5,0,5]
            let s = a.info()
            XCTAssertTrue(s.hasConstantStride)
            XCTAssertEqual(s.constantStride, 5)
        }
        do {
            let a:[Int] = [-5,0,3,5]
            let s = a.info()
            XCTAssertFalse(s.hasConstantStride)
            XCTAssertNil(s.constantStride)
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
}
