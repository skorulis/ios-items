// Created by Alexander Skorulis on 27/3/2026.

@testable import Items
import Testing

struct CompactNumberFormatterTests {

    @Test
    func formatsValuesWithoutSuffixBelowOneThousand() {
        #expect(CompactNumberFormatter.string(0) == "0")
        #expect(CompactNumberFormatter.string(12) == "12")
        #expect(CompactNumberFormatter.string(12.3) == "12.3")
        #expect(CompactNumberFormatter.string(999.9) == "999.9")
    }

    @Test
    func formatsKiloMegaAndGigaScales() {
        #expect(CompactNumberFormatter.string(1_000) == "1.0K")
        #expect(CompactNumberFormatter.string(1_500_000) == "1.5M")
        #expect(CompactNumberFormatter.string(2_300_000_000) == "2.3B")
    }

    @Test
    func formatsVeryLargeValuesUsingHighestScales() {
        #expect(CompactNumberFormatter.string(1_000_000_000_000) == "1.0T")
        #expect(CompactNumberFormatter.string(1_000_000_000_000_000) == "1.0q")
        #expect(CompactNumberFormatter.string(1_000_000_000_000_000_000) == "1.0Q")
    }

    @Test
    func preservesSignForNegativeValues() {
        #expect(CompactNumberFormatter.string(-950) == "-950")
        #expect(CompactNumberFormatter.string(-1_300) == "-1.3K")
    }
}
