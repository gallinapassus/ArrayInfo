import XCTest
@testable import ArrayInfo

final class StatsArrayTests: XCTestCase {
    func testExample() {
        XCTAssertTrue(true)
    }
    func testPerf1d() {
        let c = 60 * 60 * 24
        var a:[Int8] = []
        for _ in 0..<c {
            a.append(Int8.random(in: (Int8.min...Int8.max)))
        }
        measure {
            let _ = a.info(with: [])
        }
    }
    func testPerf6h() {
        let c = 60 * 60 * 6
        var a:[Int] = []
        for _ in 0..<c {
            a.append(Int.random(in: (Int.min...Int.max)))
        }

        measure {
            let _ = a.info(with: [])
        }
    }
    func testPerf1h() {
        let c = 60 * 60
        var a:[UInt] = []
        for _ in 0..<c {
            a.append(UInt.random(in: (UInt.min...UInt.max)))
        }

        measure {
            let _ = a.info(with: [])
        }
    }
    func testPerf15m() {
        let c = 60 * 15
        var a:[UInt16] = []
        for _ in 0..<c {
            a.append(UInt16.random(in: (UInt16.min...UInt16.max)))
        }

        measure {
            let _ = a.info(with: [])
        }
    }
    func testEmptyArray() {
        let a:[UInt64] = []
        let s1 = a.info()
        let s2 = a.info(with: .histogram)
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
                       ArrayInfo(options: ArrayInfo.Options(rawValue: 0), count: 1, sum: 0, elementOverflow: false, sumOverflow: false, avg: 0, avgOverflow: false, minValue: 0, maxValue: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(a.info(with: .histogram),
                       ArrayInfo(options: ArrayInfo.Options(rawValue: 0), count: 1, sum: 0, elementOverflow: false, sumOverflow: false, avg: 0, avgOverflow: false, minValue: 0, maxValue: 0, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: [0:1]))
    }
    func testArrayWithSingleNegativeElement() {
        let a:[Int16] = [-1]
        let s1 = a.info()
        let s2 = a.info(with: .histogram)

        XCTAssertEqual(s1, ArrayInfo<Int16>(options: ArrayInfo.Options(rawValue: 0), count: 1, sum: -1, elementOverflow: false, sumOverflow: false, avg: -1.0, avgOverflow: false, minValue: Optional(-1), maxValue: Optional(-1), minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(s1.constantStride, nil)
        XCTAssertEqual(s1.hasConstantStride, false)
        XCTAssertEqual(s2, ArrayInfo<Int16>(options: ArrayInfo.Options(rawValue: 0), count: 1, sum: -1, elementOverflow: false, sumOverflow: false, avg: -1.0, avgOverflow: false, minValue: Optional(-1), maxValue: Optional(-1), minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: [-1:1]))
        XCTAssertEqual(s2.constantStride, nil)
        XCTAssertEqual(s2.hasConstantStride, false)
    }
    func testArrayWithSinglePositiveElement() {
        let a:[Int16] = [1]
        let s1 = a.info()
        let s2 = a.info(with: .histogram)

        XCTAssertEqual(s1, ArrayInfo<Int16>(options: ArrayInfo.Options(rawValue: 0), count: 1, sum: 1, elementOverflow: false, sumOverflow: false, avg: 1.0, avgOverflow: false, minValue: Optional(1), maxValue: Optional(1), minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(s1.constantStride, nil)
        XCTAssertEqual(s1.hasConstantStride, false)
        XCTAssertEqual(s2, ArrayInfo<Int16>(options: ArrayInfo.Options(rawValue: 0), count: 1, sum: 1, elementOverflow: false, sumOverflow: false, avg: 1.0, avgOverflow: false, minValue: Optional(1), maxValue: Optional(1), minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: Optional([1: 1])))
        XCTAssertEqual(s2.constantStride, nil)
        XCTAssertEqual(s2.hasConstantStride, false)
    }
    func testElementOverflow() {
        let a:[UInt64] = [UInt64.max]
        XCTAssertEqual(a.info(),
                       ArrayInfo<UInt64>(options: ArrayInfo.Options(rawValue: 0), count: 0, sum: 0, elementOverflow: true, sumOverflow: false, avg: 0.0, avgOverflow: false, minValue: nil, maxValue: nil, minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(a.info().constantStride, nil)
        XCTAssertEqual(a.info().hasConstantStride, false)
        let b:[UInt64] = [0, UInt64.max]
        XCTAssertEqual(b.info(),
                       ArrayInfo<UInt64>(options: ArrayInfo.Options(rawValue: 0), count: 2, sum: 0, elementOverflow: true, sumOverflow: false, avg: 0.0, avgOverflow: false, minValue: Optional(0), maxValue: Optional(0), minDelta: nil, maxDelta: nil, avgDelta: nil, sumDelta: nil, sumDeltaOverflow: false, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(b.info().constantStride, nil)
        XCTAssertEqual(b.info().hasConstantStride, true)
    }
    func testSumOverflow() {
        let a:[Int] = [-1, Int.min]
        let s1 = a.info()
        XCTAssertEqual(s1,
                       ArrayInfo<Int>(options: ArrayInfo.Options(rawValue: 0), count: 2, sum: nil, elementOverflow: false, sumOverflow: true, avg: nil, avgOverflow: false, minValue: Optional(-9223372036854775808), maxValue: Optional(-1), minDelta: Optional(-9223372036854775807), maxDelta: Optional(-9223372036854775807), avgDelta: nil, sumDelta: nil, sumDeltaOverflow: true, deltaOverflow: false, isAscending: false, isStrictAscending: false, histogram: nil))
        XCTAssertEqual(s1.constantStride, -9223372036854775807)
        XCTAssertEqual(s1.hasConstantStride, true)
    }
}
