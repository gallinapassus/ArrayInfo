import XCTest
@testable import ArrayInfo

extension ArrayInfo : Equatable {
    public static func == (lhs: ArrayInfo, rhs: ArrayInfo) -> Bool {
        return lhs.issues == rhs.issues &&
        lhs.count == rhs.count &&
        lhs.isEmpty == rhs.isEmpty &&
        lhs.sum == rhs.sum &&
        lhs.exactSum == rhs.exactSum &&
        lhs.exactSumOverflow == rhs.exactSumOverflow &&
        lhs.elementOverflow == rhs.elementOverflow &&
        lhs.allElementsEqual == rhs.allElementsEqual &&
        lhs.avg == rhs.avg &&
        lhs.minValue == rhs.minValue &&
        lhs.maxValue == rhs.maxValue &&
        lhs.minValueIndex == rhs.minValueIndex &&
        lhs.maxValueIndex == rhs.maxValueIndex &&
        lhs.exactMinDelta == rhs.exactMinDelta &&
        lhs.exactMaxDelta == rhs.exactMaxDelta &&
        lhs.minDelta == rhs.minDelta &&
        lhs.maxDelta == rhs.maxDelta &&
        lhs.avgDelta == rhs.avgDelta &&
        lhs.exactSumDelta == rhs.exactSumDelta &&
        lhs.sumDelta == rhs.sumDelta &&
        lhs.exactSumDeltaOverflow == rhs.exactSumDeltaOverflow &&
        lhs.exactMinMaxDeltaOverflow == rhs.exactMinMaxDeltaOverflow &&
        lhs.isAscending == rhs.isAscending &&
        lhs.isStrictlyAscending == rhs.isStrictlyAscending &&
        lhs.isDescending == rhs.isDescending &&
        lhs.isStrictlyDescending == rhs.isStrictlyDescending &&
        lhs.hasConstantExactDelta == rhs.hasConstantExactDelta &&
        lhs.constantExactDelta == rhs.constantExactDelta &&
        lhs.median == rhs.median &&
        lhs.histogram == rhs.histogram &&
        lhs.mode == rhs.mode
    }
}
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
        do {
            let array = [1,2,4,8,16]
            let info = array.info(.histogram)
            print(info)
            print(array[3...].info().exactSum as Any) // Optional(24)
            print(array.reversed().info().isAscending) // false
        }/*
        do {
            let array:[UInt8] = [1,2,4,8,16]
            var info = array.info(.histogram)
        }
        do {
            let array = [1.0, 2.0, 4.0, 8.0, 16.0]
            var info = array.info(.histogram)
            print(info)
        }*/
    }
    func testCodable() {
        do {
            let a:[Float] = [-1.0, 2.0, 0.0]
            let s = a.info(.histogram)
            let encoder = JSONEncoder()
            encoder.nonConformingFloatEncodingStrategy = .throw
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(s)
            guard let str = String(data: data, encoding: .utf8) else {
                XCTFail("UTF8 encoding failed")
                return
            }
            print(str)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ArrayInfo<Float>.self, from: data)
            /*
            print(type(of: decoded))
            print(decoded)
            var tokens:[String] = []
            for (k,v) in Mirror(reflecting: s).children {
                guard let lbl = k else { continue }
                let label = lbl.description.replacingOccurrences(of: "_", with: "")
                tokens.append("lhs.\(label) == rhs.\(label)")
            }
            print("return", tokens.joined(separator: " &&\n"))
             */
            XCTAssertEqual(s, decoded)
        } catch let e {
            XCTFail(e.localizedDescription)
        }
    }
    func testEmptyArray() {
        do {
            let a:[UInt64] = []
            let s = a.info()
            XCTAssertEqual(s.issues, [])
            XCTAssertEqual(s.count, 0)
            XCTAssertEqual(s.isEmpty, true)
            XCTAssertEqual(s.sum, nil)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertEqual(s.exactSumOverflow, false)
            XCTAssertEqual(s.allElementsEqual, false)
            XCTAssertEqual(s.avg, nil)
            XCTAssertEqual(s.minValue, nil)
            XCTAssertEqual(s.maxValue, nil)
            XCTAssertEqual(s.minValueIndex, nil)
            XCTAssertEqual(s.maxValueIndex, nil)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.minDelta, nil)
            XCTAssertEqual(s.maxDelta, nil)
            XCTAssertEqual(s.avgDelta, nil)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.sumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.isAscending, true)
            XCTAssertEqual(s.isStrictlyAscending, true)
            XCTAssertEqual(s.isDescending, true)
            XCTAssertEqual(s.isStrictlyDescending, true)
            XCTAssertEqual(s.hasConstantExactDelta, false)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.median, nil)
            XCTAssertEqual(s.histogram, nil)
            XCTAssertEqual(s.mode, nil)
        }
    }
    func testArrayWithZeroAsOnlyElement() {
        do {
            let a:[UInt64] = [0]
            let s = a.info(.histogram)
            XCTAssertEqual(s.issues, [])
            XCTAssertEqual(s.count, 1)
            XCTAssertEqual(s.sum, 0)
            XCTAssertEqual(s.exactSum, 0)
            XCTAssertEqual(s.exactSumOverflow, false)
            XCTAssertEqual(s.elementOverflow, false)
            XCTAssertEqual(s.avg, 0)
            XCTAssertEqual(s.minValue, Optional(0))
            XCTAssertEqual(s.maxValue, Optional(0))
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 0)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.avgDelta, nil)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.isAscending, true)
            XCTAssertEqual(s.isStrictlyAscending, true)
            XCTAssertEqual(s.isDescending, true)
            XCTAssertEqual(s.isStrictlyDescending, true)
            XCTAssertEqual(s.median, 0)
            XCTAssertEqual(s.histogram, [0:1])
            XCTAssertEqual(s.mode, nil)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.hasConstantExactDelta, false)
        }
    }
    func testArrayWithSingleNegativeElement() {
        do {
            let a:[Int16] = [-1]
            let s = a.info(.histogram)
            XCTAssertEqual(s.issues, [])
            XCTAssertEqual(s.count, 1)
            XCTAssertEqual(s.sum, -1)
            XCTAssertEqual(s.exactSum, -1)
            XCTAssertEqual(s.exactSumOverflow, false)
            XCTAssertEqual(s.elementOverflow, false)
            XCTAssertEqual(s.avg, -1)
            XCTAssertEqual(s.minValue, Optional(-1))
            XCTAssertEqual(s.maxValue, Optional(-1))
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 0)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.avgDelta, nil)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.isAscending, true)
            XCTAssertEqual(s.isStrictlyAscending, true)
            XCTAssertEqual(s.isDescending, true)
            XCTAssertEqual(s.isStrictlyDescending, true)
            XCTAssertEqual(s.median, -1)
            XCTAssertEqual(s.histogram, [-1:1])
            XCTAssertEqual(s.mode, nil)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.hasConstantExactDelta, false)
        }
    }
    func testArrayWithSinglePositiveElement() {
        do {
            let a:[Int16] = [1]
            let s = a.info(.histogram)
            XCTAssertEqual(s.issues, [])
            XCTAssertEqual(s.count, 1)
            XCTAssertEqual(s.sum, 1)
            XCTAssertEqual(s.exactSum, 1)
            XCTAssertEqual(s.exactSumOverflow, false)
            XCTAssertEqual(s.elementOverflow, false)
            XCTAssertEqual(s.avg, 1)
            XCTAssertEqual(s.minValue, Optional(1))
            XCTAssertEqual(s.maxValue, Optional(1))
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 0)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.avgDelta, nil)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.isAscending, true)
            XCTAssertEqual(s.isStrictlyAscending, true)
            XCTAssertEqual(s.isDescending, true)
            XCTAssertEqual(s.isStrictlyDescending, true)
            XCTAssertEqual(s.median, 1)
            XCTAssertEqual(s.histogram, [1:1])
            XCTAssertEqual(s.mode, nil)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.hasConstantExactDelta, false)
        }
    }
    func testElementOverflow() {
        do {
            let a:[UInt64] = [UInt64.max]
            let s = a.info(.histogram)
            XCTAssertEqual(s.issues, [.element(18446744073709551615)])
            XCTAssertEqual(s.count, 1)
            XCTAssertEqual(s.sum, nil)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertEqual(s.exactSumOverflow, true)
            XCTAssertEqual(s.elementOverflow, true)
            XCTAssertEqual(s.avg, nil)
            XCTAssertEqual(s.minValue, 18446744073709551615)
            XCTAssertEqual(s.maxValue, 18446744073709551615)
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 0)
            XCTAssertEqual(s.minDelta, nil)
            XCTAssertEqual(s.maxDelta, nil)
            XCTAssertEqual(s.avgDelta, nil)
            XCTAssertEqual(s.sumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.isAscending, true)
            XCTAssertEqual(s.isStrictlyAscending, true)
            XCTAssertEqual(s.isDescending, true)
            XCTAssertEqual(s.isStrictlyDescending, true)
            XCTAssertEqual(s.median, 1.8446744073709552e+19)
            XCTAssertEqual(s.histogram, [18446744073709551615: 1])
            XCTAssertEqual(s.mode, nil)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.hasConstantExactDelta, false)
        }
        do {
            let a:[UInt64] = [0, UInt64(Int.max) + 1, UInt64(Int.max) + 2]
            let s = a.info()
            XCTAssertEqual(s.issues, [.element(9223372036854775808), .element(9223372036854775809)])
            XCTAssertEqual(s.count, 3)
            XCTAssertEqual(s.sum, 1.8446744073709552e+19)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertEqual(s.exactSumOverflow, true)
            XCTAssertEqual(s.elementOverflow, true)
            XCTAssertEqual(s.avg, 6.148914691236517e+18)
            XCTAssertEqual(s.minValue, Optional(0))
            XCTAssertEqual(s.maxValue, Optional(9223372036854775809))
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 2)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.avgDelta, 4.611686018427388e+18)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.isAscending, true)
            XCTAssertEqual(s.isStrictlyAscending, true)
            XCTAssertEqual(s.isDescending, false)
            XCTAssertEqual(s.isStrictlyDescending, false)
            XCTAssertEqual(s.median, 9.223372036854776e+18)
            XCTAssertEqual(s.histogram, nil)
            XCTAssertEqual(s.mode, nil)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.hasConstantExactDelta, false)
        }
        do {
            let a:[Double] = [0, Double(Int.max) + 1, Double(Int.max) + 2049]
            let s = a.info()
            XCTAssertEqual(s.issues, [])
            XCTAssertEqual(s.count, 3)
            XCTAssertEqual(s.sum, 1.8446744073709552e+19)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertEqual(s.exactSumOverflow, false)
            XCTAssertEqual(s.elementOverflow, false)
            XCTAssertEqual(s.avg, 6.148914691236517e+18)
            XCTAssertEqual(s.minValue, Optional(0))
            XCTAssertEqual(s.maxValue, Optional(9.223372036854778e+18))
            XCTAssertEqual(s.minValueIndex, 0)
            XCTAssertEqual(s.maxValueIndex, 2)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.avgDelta, 4.611686018427389e+18)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.isAscending, true)
            XCTAssertEqual(s.isStrictlyAscending, true)
            XCTAssertEqual(s.isDescending, false)
            XCTAssertEqual(s.isStrictlyDescending, false)
            XCTAssertEqual(s.median, 9.223372036854776e+18)
            XCTAssertEqual(s.histogram, nil)
            XCTAssertEqual(s.mode, nil)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.hasConstantExactDelta, false)
        }
    }
    func testSumOverflow() {
        do {
            let a:[Int8] = []
            let s = a.info()
            XCTAssertFalse(s.exactSumOverflow)
            XCTAssertNil(s.exactSum)
        }
        do {
            let a:[Int64] = [Int64.max]
            let s = a.info()
            XCTAssertFalse(s.exactSumOverflow)
            XCTAssertEqual(s.exactSum, 9223372036854775807)
        }
        do {
            let a:[Int64] = [1,Int64.max]
            let s = a.info()
            XCTAssertEqual(s.issues, [])
            XCTAssertTrue(s.exactSumOverflow)
            XCTAssertFalse(s.elementOverflow)
            XCTAssertNil(s.exactSum)
            XCTAssertEqual(s.sum, Optional(9.223372036854776e+18))
        }
        do {
            let a:[Int] = [-1, Int.min]
            let s = a.info()
            XCTAssertEqual(s.issues, [])
            XCTAssertEqual(s.count, 2)
            XCTAssertEqual(s.sum, -9.223372036854776e+18)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertEqual(s.exactSumOverflow, true)
            XCTAssertEqual(s.elementOverflow, false)
            XCTAssertEqual(s.avg, -4.611686018427388e+18)
            XCTAssertEqual(s.minValue, -9223372036854775808)
            XCTAssertEqual(s.maxValue, -1)
            XCTAssertEqual(s.minValueIndex, 1)
            XCTAssertEqual(s.maxValueIndex, 0)
            XCTAssertEqual(s.exactMinDelta, 9223372036854775807)
            XCTAssertEqual(s.exactMaxDelta, 9223372036854775807)
            XCTAssertEqual(s.avgDelta, 9.223372036854776e+18)
            XCTAssertEqual(s.exactSumDelta, 9223372036854775807)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.isAscending, false)
            XCTAssertEqual(s.isStrictlyAscending, false)
            XCTAssertEqual(s.isDescending, true)
            XCTAssertEqual(s.isStrictlyDescending, true)
            XCTAssertEqual(s.median, -4.611686018427388e+18)
            XCTAssertEqual(s.histogram, nil)
            XCTAssertEqual(s.mode, nil)
            XCTAssertEqual(s.constantExactDelta, 9223372036854775807)
            XCTAssertEqual(s.hasConstantExactDelta, true)
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
            XCTAssertNil(s.exactMinDelta)
            XCTAssertNil(s.exactMaxDelta)
        }
        do {
            let a:[Int] = [1,2]
            let s = a.info()
            XCTAssertEqual(s.exactMinDelta, 1)
            XCTAssertEqual(s.exactMaxDelta, 1)
        }
        do {
            let a:[Int] = [1,2,4]
            let s = a.info()
            XCTAssertEqual(s.exactMinDelta, 1)
            XCTAssertEqual(s.exactMaxDelta, 2)
        }
        do {
            let a:[Int] = [1,2,4,0,3]
            let s = a.info()
            XCTAssertEqual(s.exactMinDelta, 1)
            XCTAssertEqual(s.exactMaxDelta, 4)
        }
        do {
            let a:[Int] = [-1,1]
            let s = a.info()
            XCTAssertEqual(s.exactMinDelta, 2)
            XCTAssertEqual(s.exactMaxDelta, 2)
        }
        do {
            let a:[Int] = [-10,1,10]
            let s = a.info()
            XCTAssertEqual(s.exactMinDelta, 9)
            XCTAssertEqual(s.exactMaxDelta, 11)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertNil(s.exactMinDelta)
            XCTAssertNil(s.exactMaxDelta)
        }
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertNil(s.exactMinDelta)
            XCTAssertNil(s.exactMaxDelta)
        }
    }
    func testAvg() {
        do {
            let a:[UInt] = [UInt(Int.max)]
            let s = a.info()
            XCTAssertEqual(s.avg, Double(Int.max))
        }
        do {
            let a:[UInt] = [UInt(Int.max), 1]
            let s = a.info()
            XCTAssertNil(s.exactSum)
            XCTAssertEqual(s.avg, Optional(4.611686018427388e+18))
        }
        do {
            let a:[UInt] = [UInt(Int.max), UInt(Int.max)]
            let s = a.info()
            XCTAssertNil(s.exactSum)
            XCTAssertEqual(s.count, 2)
            XCTAssertEqual(s.sum, 18446744073709551616)//...614
            XCTAssertEqual(s.avg, Optional(9.223372036854776e+18))
        }
        do {
            let a:[UInt] = [UInt(Int.max), 1, 2]
            let s = a.info()
            XCTAssertNil(s.exactSum)
            XCTAssertEqual(s.avg, Optional(3.0744573456182584e+18))
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
            XCTAssertFalse(s.hasConstantExactDelta)
            XCTAssertNil(s.constantExactDelta)
        }
        do {
            let a:[Int] = [0]
            let s = a.info()
            XCTAssertFalse(s.hasConstantExactDelta)
            XCTAssertNil(s.constantExactDelta)
        }
        do {
            let a:[Int] = [0,5]
            let s = a.info()
            XCTAssertTrue(s.hasConstantExactDelta)
            XCTAssertEqual(s.constantExactDelta, 5)
        }
        do {
            let a:[Int] = [-5,0,5]
            let s = a.info()
            XCTAssertTrue(s.hasConstantExactDelta)
            XCTAssertEqual(s.constantExactDelta, 5)
        }
        do {
            let a:[Int] = [-5,0,3,5]
            let s = a.info()
            XCTAssertFalse(s.hasConstantExactDelta)
            XCTAssertNil(s.constantExactDelta)
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
            XCTAssertNil(s.median)
        }
        #if os(Linux)
        do {
            let a:[Float16] = [0, 1.1, 1.5]
            let s = a.info(.exact)
            XCTAssertEqual(s.median, 1.099609375)
        }
        do {
            let a:[Float16] = [32768, 38016.5, 40000]
            let s = a.info(.exact)
            XCTAssertEqual(s.median, 38016.0)
        }
        do {
            let a:[Float16] = [0, 1/3, 2/3, 1.5]
            let s = a.info(.exact)
            XCTAssertEqual(s.median, 0.4998779296875)
        }
        #else
        do {
            let a:[Float32] = [0, 1.1, 1.5]
            let s = a.info(.exact)
            XCTAssertEqual(s.median, 1.100000023841858)
        }
        do {
            let a:[Float32] = [32768, 38016.5, 40000]
            let s = a.info(.exact)
            XCTAssertEqual(s.median, 38016.5)
        }
        do {
            let a:[Float32] = [0, 1/3, 2/3, 1.5]
            let s = a.info(.exact)
            XCTAssertEqual(s.median, 0.5000000149011612)
        }
        #endif
        do {
            let a:[Double] = [0, 1/3, 2/3, 2]
            let s = a.info(.exact)
            XCTAssertEqual(s.median, 0.5)
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
    func testDelta() {
        do {
            let a:[Int] = []
            let s = a.info()
            XCTAssertEqual(s.hasConstantExactDelta, false)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.avgDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.issues, [])
        }
        do {
            let a:[Double] = []
            let s = a.info()
            XCTAssertEqual(s.hasConstantExactDelta, false)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.avgDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.issues, [])
        }
        do {
            let a:[Int] = [42]
            let s = a.info()
            XCTAssertEqual(s.hasConstantExactDelta, false)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.avgDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.issues, [])
        }
        do {
            let a:[Int8] = [-127,127]
            let s = a.info()
            XCTAssertEqual(s.hasConstantExactDelta, true)
            XCTAssertEqual(s.constantExactDelta, 254)
            XCTAssertEqual(s.exactSumDelta, 254)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.avgDelta, 254.0)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinDelta, 254)
            XCTAssertEqual(s.exactMaxDelta, 254)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.issues, [])
        }
        do {
            let a:[UInt] = [UInt(Int.max) + 1, UInt(Int.max) + 4096]
            let s = a.info()
            XCTAssertEqual(s.hasConstantExactDelta, true)
            XCTAssertEqual(s.constantExactDelta, 4095)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.avgDelta, 4096)
            XCTAssertEqual(s.sumDelta, 4096)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinDelta, 4095)
            XCTAssertEqual(s.exactMaxDelta, 4095)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.issues, [.element(9223372036854779903), .element(9223372036854775808)])
        }
        #if os(Linux)
        do {
            let a:[Float16] = [-127, 0, 127]
            let s = a.info()
            XCTAssertEqual(s.hasConstantExactDelta, true)
            XCTAssertEqual(s.constantExactDelta, 127)
            XCTAssertEqual(s.exactSumDelta, 254)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.avgDelta, 127.0)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinDelta, 127)
            XCTAssertEqual(s.exactMaxDelta, 127)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.issues, [])
        }
        #else
        do {
            let a:[Float16] = [-127, 0, 127]
            let s = a.info()
            XCTAssertEqual(s.hasConstantExactDelta, true)
            XCTAssertEqual(s.constantExactDelta, 127)
            XCTAssertEqual(s.exactSumDelta, 254)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.avgDelta, 127.0)
            XCTAssertEqual(s.exactSumDeltaOverflow, false)
            XCTAssertEqual(s.exactMinDelta, 127)
            XCTAssertEqual(s.exactMaxDelta, 127)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, false)
            XCTAssertEqual(s.issues, [])
        }
        #endif
    }
    func testDeltaOverflow() {
        do {
            let a:[Int] = [0,Int.max,0,Int.max,Int.min]
            let s = a.info()
            XCTAssertEqual(s.issues, [])
            XCTAssertEqual(s.count, 5)
            XCTAssertEqual(s.isEmpty, false)
            XCTAssertEqual(s.sum, 9.223372036854776e+18)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertEqual(s.exactSumOverflow, true)
            XCTAssertEqual(s.elementOverflow, false)
            XCTAssertEqual(s.allElementsEqual, false)
            XCTAssertEqual(s.avg, 1.8446744073709553e+18)
            XCTAssertEqual(s.minValue, -9223372036854775808)
            XCTAssertEqual(s.maxValue, 9223372036854775807)
            XCTAssertEqual(s.minValueIndex, 4)
            XCTAssertEqual(s.maxValueIndex, 1)
            XCTAssertEqual(s.exactMinDelta, nil)
            XCTAssertEqual(s.exactMaxDelta, nil)
            XCTAssertEqual(s.minDelta, 9.223372036854776e+18)
            XCTAssertEqual(s.maxDelta, 9.223372036854776e+18)
            XCTAssertEqual(s.avgDelta, 4.611686018427388e+18)
            XCTAssertEqual(s.exactSumDelta, nil)
            XCTAssertEqual(s.sumDelta, 1.8446744073709552e+19)
            XCTAssertEqual(s.exactSumDeltaOverflow, true)
            XCTAssertEqual(s.exactMinMaxDeltaOverflow, true)
            XCTAssertEqual(s.isAscending, false)
            XCTAssertEqual(s.isStrictlyAscending, false)
            XCTAssertEqual(s.isDescending, false)
            XCTAssertEqual(s.isStrictlyDescending, false)
            XCTAssertEqual(s.hasConstantExactDelta, false)
            XCTAssertEqual(s.constantExactDelta, nil)
            XCTAssertEqual(s.median, nil)
            XCTAssertEqual(s.histogram, nil)
            XCTAssertEqual(s.mode, nil)
        }
    }
    func testSlices() {
        let a:[Int] = [1,2,4,8,16,12,10,8,6,4,2,1]
        do {
            let s = a[1...3].info()
            XCTAssertEqual(s.count, 3)
            XCTAssertEqual(s.exactSum, 14)
            XCTAssertFalse(s.exactSumOverflow)
            XCTAssertFalse(s.elementOverflow)
            XCTAssertFalse(s.allElementsEqual)
            XCTAssertEqual(s.avg, Optional(4.666666666666667))
            XCTAssertEqual(s.maxValue, Optional(8))
            XCTAssertEqual(s.minValueIndex, Optional(1))
            XCTAssertEqual(s.maxValueIndex, Optional(3))
            XCTAssertEqual(s.exactMinDelta, Optional(2))
            XCTAssertEqual(s.exactMaxDelta, Optional(4))
            XCTAssertEqual(s.avgDelta, Optional(3.0))
            XCTAssertEqual(s.exactSumDelta, Optional(6))
            XCTAssertFalse(s.exactSumDeltaOverflow)
            XCTAssertFalse(s.exactMinMaxDeltaOverflow)
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
            XCTAssertEqual(s.exactSum, 59)
            XCTAssertFalse(s.exactSumOverflow)
            XCTAssertFalse(s.elementOverflow)
            XCTAssertFalse(s.allElementsEqual)
            XCTAssertEqual(s.avg, Optional(7.375))
            XCTAssertEqual(s.minValue, Optional(1))
            XCTAssertEqual(s.maxValue, Optional(16))
            XCTAssertEqual(s.minValueIndex, Optional(11))
            XCTAssertEqual(s.maxValueIndex, Optional(4))
            XCTAssertEqual(s.exactMinDelta, Optional(1))
            XCTAssertEqual(s.exactMaxDelta, Optional(4))
            XCTAssertEqual(s.avgDelta, Optional(2.142857142857143))
            XCTAssertEqual(s.exactSumDelta, Optional(15))
            XCTAssertFalse(s.exactSumDeltaOverflow)
            XCTAssertFalse(s.exactMinMaxDeltaOverflow)
            XCTAssertFalse(s.isAscending)
            XCTAssertFalse(s.isStrictlyAscending)
            XCTAssertTrue(s.isDescending)
            XCTAssertTrue(s.isStrictlyDescending)
            XCTAssertEqual(s.median, Optional(7.0))
            XCTAssertNil(s.histogram)
            XCTAssertNil(s.mode)
        }
    }
    func testDoubleSlices() {
        do {
            let a = [1.0, 2.0, 4.0, 8.0, 16.0]
            let s = a.info(.histogram)
            XCTAssertEqual(s.count, 5)
            XCTAssertEqual(s.sum, 31)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertFalse(s.exactSumOverflow)
            XCTAssertFalse(s.elementOverflow)
            XCTAssertFalse(s.allElementsEqual)
            XCTAssertEqual(s.avg, Optional(6.2))
            XCTAssertEqual(s.minValue, Optional(1))
            XCTAssertEqual(s.maxValue, Optional(16))
            XCTAssertEqual(s.minValueIndex, Optional(0))
            XCTAssertEqual(s.maxValueIndex, Optional(4))
            XCTAssertEqual(s.exactMinDelta, Optional(1))
            XCTAssertEqual(s.exactMaxDelta, Optional(8))
            XCTAssertEqual(s.avgDelta, Optional(3.75))
            XCTAssertEqual(s.exactSumDelta, Optional(15))
            XCTAssertFalse(s.exactSumDeltaOverflow)
            XCTAssertFalse(s.exactMinMaxDeltaOverflow)
            XCTAssertTrue(s.isAscending)
            XCTAssertTrue(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertFalse(s.hasConstantExactDelta)
            XCTAssertEqual(s.median, Optional(4.0))
            XCTAssertNil(s.mode)
        }
        do {
            let a = [1.0, 2.0, 4.0, 8.0, 16.0]
            let s = a[1...3].info(.histogram)
            XCTAssertEqual(s.count, 3)
            XCTAssertEqual(s.sum, 14)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertFalse(s.exactSumOverflow)
            XCTAssertFalse(s.elementOverflow)
            XCTAssertFalse(s.allElementsEqual)
            XCTAssertEqual(s.avg, Optional(4.666666666666667))
            XCTAssertEqual(s.minValue, Optional(2))
            XCTAssertEqual(s.maxValue, Optional(8))
            XCTAssertEqual(s.minValueIndex, Optional(1))
            XCTAssertEqual(s.maxValueIndex, Optional(3))
            XCTAssertEqual(s.exactMinDelta, Optional(2))
            XCTAssertEqual(s.exactMaxDelta, Optional(4))
            XCTAssertEqual(s.avgDelta, Optional(3))
            XCTAssertEqual(s.exactSumDelta, Optional(6))
            XCTAssertFalse(s.exactSumDeltaOverflow)
            XCTAssertFalse(s.exactMinMaxDeltaOverflow)
            XCTAssertTrue(s.isAscending)
            XCTAssertTrue(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertFalse(s.hasConstantExactDelta)
            XCTAssertEqual(s.median, Optional(4.0))
            XCTAssertNil(s.mode)
        }
        #if os(Linux)
        do {
            let a:[Float16] = [1.0, 2.0, 4.0, 8.0, 16.0]
            let s = a[1...3].info(.histogram)
            XCTAssertEqual(s.count, 3)
            XCTAssertEqual(s.sum, 14)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertFalse(s.exactSumOverflow)
            XCTAssertFalse(s.elementOverflow)
            XCTAssertFalse(s.allElementsEqual)
            XCTAssertEqual(s.avg, Optional(4.666666666666667))
            XCTAssertEqual(s.minValue, Optional(2))
            XCTAssertEqual(s.maxValue, Optional(8))
            XCTAssertEqual(s.minValueIndex, Optional(1))
            XCTAssertEqual(s.maxValueIndex, Optional(3))
            XCTAssertEqual(s.exactMinDelta, Optional(2))
            XCTAssertEqual(s.exactMaxDelta, Optional(4))
            XCTAssertEqual(s.avgDelta, Optional(3))
            XCTAssertEqual(s.exactSumDelta, Optional(6))
            XCTAssertFalse(s.exactSumDeltaOverflow)
            XCTAssertFalse(s.exactMinMaxDeltaOverflow)
            XCTAssertTrue(s.isAscending)
            XCTAssertTrue(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertFalse(s.hasConstantExactDelta)
            XCTAssertEqual(s.median, Optional(4.0))
            XCTAssertNil(s.mode)
        }
        #endif
        do {
            let a:[Float32] = [1.0, 2.0, 4.0, 8.0, 16.0]
            let s = a[2...4].info(.histogram)
            XCTAssertEqual(s.count, 3)
            XCTAssertEqual(s.sum, 28)
            XCTAssertEqual(s.exactSum, nil)
            XCTAssertFalse(s.exactSumOverflow)
            XCTAssertFalse(s.elementOverflow)
            XCTAssertFalse(s.allElementsEqual)
            XCTAssertEqual(s.avg, Optional(9.333333333333334))
            XCTAssertEqual(s.minValue, Optional(4))
            XCTAssertEqual(s.maxValue, Optional(16))
            XCTAssertEqual(s.minValueIndex, Optional(2))
            XCTAssertEqual(s.maxValueIndex, Optional(4))
            XCTAssertEqual(s.exactMinDelta, Optional(4))
            XCTAssertEqual(s.exactMaxDelta, Optional(8))
            XCTAssertEqual(s.avgDelta, Optional(6))
            XCTAssertEqual(s.exactSumDelta, Optional(12))
            XCTAssertFalse(s.exactSumDeltaOverflow)
            XCTAssertFalse(s.exactMinMaxDeltaOverflow)
            XCTAssertTrue(s.isAscending)
            XCTAssertTrue(s.isStrictlyAscending)
            XCTAssertFalse(s.isDescending)
            XCTAssertFalse(s.isStrictlyDescending)
            XCTAssertFalse(s.hasConstantExactDelta)
            XCTAssertEqual(s.median, Optional(8.0))
            XCTAssertNil(s.mode)
        }
    }
    func testOverflowCases() {
        do {
            XCTAssertEqual(ArrayInfo<Int>.Issue.sum.description, "Exact sum calculation overflow")
            XCTAssertEqual(ArrayInfo<Int>.Issue.avg.description, "Accurate average calculation was not possible")
            XCTAssertEqual(ArrayInfo<UInt>.Issue.element(UInt(Int.max)+1).description, "Element 9223372036854775808 can not be represented exactly as 'Int' (64-bit integer)")
        }
    }
    /*
    func testEmitCoverageTests() {
        
        let arrays:[(Any,Any)] = [
            
            // Empty arrays
            (Array<Int>([]), ArrayInfo<Int>.Options([])),
            (Array<Int>([]), ArrayInfo<Int>.Options([.histogram])),
            (Array<Int>([]), ArrayInfo<Int>.Options([.histogram, .exact])),
            (Array<Int8>([]), ArrayInfo<Int8>.Options([])),
            (Array<Int16>([]), ArrayInfo<Int16>.Options([])),
            (Array<Int32>([]), ArrayInfo<Int32>.Options([])),
            (Array<UInt>([]), ArrayInfo<UInt>.Options([])),
            (Array<UInt8>([]), ArrayInfo<UInt8>.Options([])),
            (Array<UInt16>([]), ArrayInfo<UInt16>.Options([])),
            (Array<UInt32>([]), ArrayInfo<UInt32>.Options([])),
            //(Array<Float16>([]), ArrayInfo<Float16>.Options([])),
            (Array<Float32>([]), ArrayInfo<Float32>.Options([])),
            (Array<Float64>([]), ArrayInfo<Float64>.Options([])),
            (Array<Float64>([]), ArrayInfo<Float64>.Options([.histogram])),
            (Array<Float64>([]), ArrayInfo<Float64>.Options([.histogram, .exact])),

            // Single element
            (Array<Int>([42]), ArrayInfo<Int>.Options([])),
            (Array<Int>([42]), ArrayInfo<Int>.Options([.histogram])),
            (Array<Int>([42]), ArrayInfo<Int>.Options([.histogram, .exact])),
            (Array<Int8>([42]), ArrayInfo<Int8>.Options([])),
            (Array<Int16>([42]), ArrayInfo<Int16>.Options([])),
            (Array<Int32>([42]), ArrayInfo<Int32>.Options([])),
            (Array<UInt>([42]), ArrayInfo<UInt>.Options([])),
            (Array<UInt8>([42]), ArrayInfo<UInt8>.Options([])),
            (Array<UInt16>([42]), ArrayInfo<UInt16>.Options([])),
            (Array<UInt32>([42]), ArrayInfo<UInt32>.Options([])),
            //(Array<Float16>([42]), ArrayInfo<Float16>.Options([])),
            (Array<Float32>([42]), ArrayInfo<Float32>.Options([])),
            (Array<Float64>([42]), ArrayInfo<Float64>.Options([])),
            (Array<Float64>([42]), ArrayInfo<Float64>.Options([.histogram])),
            (Array<Float64>([42]), ArrayInfo<Float64>.Options([.histogram, .exact])),

            // Two elements
            (Array<Int>([1,3]), ArrayInfo<Int>.Options([])),
            (Array<Int>([1,3]), ArrayInfo<Int>.Options([.histogram])),
            (Array<Int>([1,3]), ArrayInfo<Int>.Options([.histogram, .exact])),
            (Array<Int8>([1,3]), ArrayInfo<Int8>.Options([])),
            (Array<Int16>([1,3]), ArrayInfo<Int16>.Options([])),
            (Array<Int32>([1,3]), ArrayInfo<Int32>.Options([])),
            (Array<UInt>([1,3]), ArrayInfo<UInt>.Options([])),
            (Array<UInt8>([1,3]), ArrayInfo<UInt8>.Options([])),
            (Array<UInt16>([1,3]), ArrayInfo<UInt16>.Options([])),
            (Array<UInt32>([1,3]), ArrayInfo<UInt32>.Options([])),
            //(Array<Float16>([1,3]), ArrayInfo<Float16>.Options([])),
            (Array<Float32>([1,3]), ArrayInfo<Float32>.Options([])),
            (Array<Float64>([1,3]), ArrayInfo<Float64>.Options([])),
            (Array<Float64>([1,3]), ArrayInfo<Float64>.Options([.histogram])),
            (Array<Float64>([1,3]), ArrayInfo<Float64>.Options([.histogram, .exact])),

            // Three elements ascending
            (Array<Int>([1,2,3]), ArrayInfo<Int>.Options([])),
            (Array<Int>([1,2,3]), ArrayInfo<Int>.Options([.histogram])),
            (Array<Int>([1,2,3]), ArrayInfo<Int>.Options([.histogram, .exact])),
            (Array<Int8>([1,2,3]), ArrayInfo<Int8>.Options([])),
            (Array<Int16>([1,2,3]), ArrayInfo<Int16>.Options([])),
            (Array<Int32>([1,2,3]), ArrayInfo<Int32>.Options([])),
            (Array<UInt>([1,2,3]), ArrayInfo<UInt>.Options([])),
            (Array<UInt8>([1,2,3]), ArrayInfo<UInt8>.Options([])),
            (Array<UInt16>([1,2,3]), ArrayInfo<UInt16>.Options([])),
            (Array<UInt32>([1,2,3]), ArrayInfo<UInt32>.Options([])),
            //(Array<Float16>([1,2,3]), ArrayInfo<Float16>.Options([])),
            (Array<Float32>([1,2,3]), ArrayInfo<Float32>.Options([])),
            (Array<Float64>([1,2,3]), ArrayInfo<Float64>.Options([])),
            (Array<Float64>([1,2,3]), ArrayInfo<Float64>.Options([.histogram])),
            (Array<Float64>([1,2,3]), ArrayInfo<Float64>.Options([.histogram, .exact])),

            // Four elements descending
            (Array<Int>([16,8,4,2]), ArrayInfo<Int>.Options([])),
            (Array<Int>([16,8,4,2]), ArrayInfo<Int>.Options([.histogram])),
            (Array<Int>([16,8,4,2]), ArrayInfo<Int>.Options([.histogram, .exact])),
            (Array<Int8>([16,8,4,2]), ArrayInfo<Int8>.Options([])),
            (Array<Int16>([16,8,4,2]), ArrayInfo<Int16>.Options([])),
            (Array<Int32>([16,8,4,2]), ArrayInfo<Int32>.Options([])),
            (Array<UInt>([16,8,4,2]), ArrayInfo<UInt>.Options([])),
            (Array<UInt8>([16,8,4,2]), ArrayInfo<UInt8>.Options([])),
            //(Array<UInt16>([16,8,4,2]), ArrayInfo<UInt16>.Options([])),
            (Array<UInt32>([16,8,4,2]), ArrayInfo<UInt32>.Options([])),
            (Array<Float16>([16,8,4,2]), ArrayInfo<Float16>.Options([])),
            (Array<Float32>([16,8,4,2]), ArrayInfo<Float32>.Options([])),
            (Array<Float64>([16,8,4,2]), ArrayInfo<Float64>.Options([])),
            (Array<Float64>([16,8,4,2]), ArrayInfo<Float64>.Options([.histogram])),
            (Array<Float64>([16,8,4,2]), ArrayInfo<Float64>.Options([.histogram, .exact])),

            // Four elements, all equal
            (Array<Int>([-1,-1,-1,-1]), ArrayInfo<Int>.Options([])),
            (Array<Int>([-1,-1,-1,-1]), ArrayInfo<Int>.Options([.histogram, .exact])),

            // First element overflow
            (Array<UInt>([UInt(Int.max) + 1]), ArrayInfo<UInt>.Options([])),
            (Array<UInt>([UInt(Int.max) + 1]), ArrayInfo<UInt>.Options([.histogram, .exact])),

            // Last element overflow
            (Array<UInt>([0, UInt(Int.max) + 1]), ArrayInfo<UInt>.Options([])),
            (Array<UInt>([0, UInt(Int.max) + 1]), ArrayInfo<UInt>.Options([.histogram, .exact])),

            // All element overflow
            (Array<UInt>([UInt(Int.max) + 1, UInt(Int.max) + 2]), ArrayInfo<UInt>.Options([])),
            (Array<UInt>([UInt(Int.max) + 1, UInt(Int.max) + 2]), ArrayInfo<UInt>.Options([.histogram, .exact])),
            
            // Multi-mode
            (Array<Int>([0,1,1,2,2]), ArrayInfo<Int>.Options([.histogram])),

            // Tricky
            //(Array<Float16>([-1.1, 2.51, 0.01]), ArrayInfo<Float16>.Options([.histogram])),
            //(Array<Float16>([-1.1, 2.51, 0.01]), ArrayInfo<Float16>.Options([.exact])),
            //(Array<Float16>([-1.1, 2.51, 0.01]), ArrayInfo<Float16>.Options([.histogram, .exact])),
            //(Array<Float16>([-1.1, 0.01, 2.51]), ArrayInfo<Float16>.Options([.histogram, .exact])),
        ]
        func genIntCode<T:BinaryInteger>(a:Array<T>, options:ArrayInfo<T>.Options) -> String {
            var testCases = ""
            let s = a.info(options)
            let asserts:String = {
                var tmp:[String] = []
                for (k,v) in Mirror(reflecting: s).children {
                    guard let lbl = k else { continue }
                    let label = lbl.replacingOccurrences(of: "_", with: "")
                    if let str = v as? Set<ArrayInfo<T>.Issue> {
                        let occurrence = "ArrayInfo.ArrayInfo<Swift.\(type(of: T.self))>.Issue".replacingOccurrences(of: ".Type", with: "")
                        tmp.append("XCTAssertEqual(s.\(label), \(str.description.replacingOccurrences(of: occurrence, with: "")))")
                    }
                    else {
                        tmp.append("XCTAssertEqual(s.\(label), \(v))")
                    }
                }
                return tmp.joined(separator: "\n\t\t\t")
            }()
            let t = "\(type(of: T.self))".replacingOccurrences(of: ".Type", with: "")
            print(
                """
                
                        do {
                            let a = \(type(of: a))(\(a))
                            let s = a.info(ArrayInfo<\(t)>.Options(rawValue: \(options.rawValue)))
                            \(asserts)
                        }
                """, to: &testCases
            )
            return testCases
        }
        func genFloatCode<T:BinaryFloatingPoint>(a:Array<T>, options: ArrayInfo<T>.Options) -> String {
            var testCases = ""
            let s = a.info(options)
            let asserts:String = {
                var tmp:[String] = []
                for (k,v) in Mirror(reflecting: s).children {
                    guard let lbl = k else { continue }
                    let label = lbl.replacingOccurrences(of: "_", with: "")
                    if let str = v as? Set<ArrayInfo<T>.Issue> {
                        let occurrence = "ArrayInfo.ArrayInfo<Swift.\(type(of: T.self))>.Issue".replacingOccurrences(of: ".Type", with: "")
                        tmp.append("XCTAssertEqual(s.\(label), \(str.description.replacingOccurrences(of: occurrence, with: "")))")
                    }
                    else {
                        tmp.append("XCTAssertEqual(s.\(label), \(v))")
                    }
                }
                return tmp.joined(separator: "\n\t\t\t")
            }()
            let t = "\(type(of: T.self))".replacingOccurrences(of: ".Type", with: "")
            print(
                """
                
                        do {
                            let a = \(type(of: a))(\(a))
                            let s = a.info(ArrayInfo<\(t)>.Options(rawValue: \(options.rawValue)))
                            \(asserts)
                        }
                """, to: &testCases
            )
            return testCases
        }
        var coverageTestFile =
            """
            import XCTest
            @testable import ArrayInfo

            final class CoverageTests : XCTestCase {
                func testCoverage() {
            """
        for arr in arrays {
            //var testCases = ""
            if let a = arr.0 as? Array<Int>, let o = arr.1 as? ArrayInfo<Int>.Options {
                coverageTestFile += genIntCode(a: a, options: o)
            }
            
            else if let a = arr.0 as? Array<Int8>, let o = arr.1 as? ArrayInfo<Int8>.Options {
                coverageTestFile += genIntCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<Int16>, let o = arr.1 as? ArrayInfo<Int16>.Options {
                coverageTestFile += genIntCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<Int32>, let o = arr.1 as? ArrayInfo<Int32>.Options {
                coverageTestFile += genIntCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<UInt>, let o = arr.1 as? ArrayInfo<UInt>.Options {
                coverageTestFile += genIntCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<UInt8>, let o = arr.1 as? ArrayInfo<UInt8>.Options {
                coverageTestFile += genIntCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<UInt16>, let o = arr.1 as? ArrayInfo<UInt16>.Options {
                coverageTestFile += genIntCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<UInt32>, let o = arr.1 as? ArrayInfo<UInt32>.Options {
                coverageTestFile += genIntCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<Float16>, let o = arr.1 as? ArrayInfo<Float16>.Options {
                coverageTestFile += genFloatCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<Float32>, let o = arr.1 as? ArrayInfo<Float32>.Options {
                coverageTestFile += genFloatCode(a: a, options: o)
            }
            else if let a = arr.0 as? Array<Float64>, let o = arr.1 as? ArrayInfo<Float64>.Options {
                coverageTestFile += genFloatCode(a: a, options: o)
            }
        }
        coverageTestFile +=
        """
            }
        }
        """
        do {
            let target = URL(fileURLWithPath: #file.replacingOccurrences(of: "ArrayInfoTests.swift", with: "CoverageTests.swift"))
            try coverageTestFile.write(to: target, atomically: true, encoding: .utf8)
        } catch let e {
            print(e.localizedDescription)
        }
    }*/
}
