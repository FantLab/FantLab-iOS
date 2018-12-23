import XCTest

@testable
import FantLabText

class TextParserTests: XCTestCase {
    func testEmptyString() {
        let text = parse("")

        XCTAssert(text.string.isEmpty)
    }

    func testOpenTag() {
        let text = parse("[b]")

        XCTAssert(text.string.isEmpty)
    }

    func testSingleBBTag() {
        let text = parse("[b]lorem ipsum[/b]")

        XCTAssert(text.string == "lorem ipsum")
        XCTAssert(text.nodeRanges[0].node.tag.name == "b")
        XCTAssert(text.nodeRanges[0].range == text.string.startIndex..<text.string.endIndex)
    }

    func testMultipleBBTags() {
        let text = parse("x y [b][u]z[/u][/b] a [i]b[/i] [p]c[/p] d e")

        XCTAssert(text.string == "x y z a b c d e")

        XCTAssert(text.nodeRanges.map({ $0.node.tag.name }) == ["u", "b", "i", "p", ""])
        XCTAssert(text.nodeRanges.map({ text.string[$0.range] }) == ["z", "z", "b", "c", "x y z a b c d e"])
    }

    func testBBTagWithParam() {
        let text = parse("some [person=1]person[/person]")

        XCTAssert(text.string == "some person")
        XCTAssert(text.nodeRanges[0].node.tag.name == "person")
        XCTAssert(text.nodeRanges[0].node.tag.value == "1")
    }

    func testURLInBBTag() {
        let text = parse("some [url=https://google.com?q=fantlab]url[/url]")

        XCTAssert(text.string == "some url")
        XCTAssert(text.nodeRanges[0].node.tag.name == "url")
        XCTAssert(text.nodeRanges[0].node.tag.value == "https://google.com?q=fantlab")
    }

    func testSingleHTMLTag() {
        let text = parse("<b>lorem ipsum</b>")

        XCTAssert(text.string == "lorem ipsum")
        XCTAssert(text.nodeRanges[0].node.tag.name == "b")
        XCTAssert(text.nodeRanges[0].range == text.string.startIndex..<text.string.endIndex)
    }

    func testHTMLLink() {
        let text = parse("<a href=\"link\">lorem ipsum</a>")

        XCTAssert(text.string == "lorem ipsum")
        XCTAssert(text.nodeRanges[0].node.tag.name == "a")
        XCTAssert(text.nodeRanges[0].node.tag.value == "link")
        XCTAssert(text.nodeRanges[0].range == text.string.startIndex..<text.string.endIndex)
    }

    func testHTMLLink2() {
        let text = parse("<a href=\"link\" href='link2' href=“link3“>lorem ipsum</a>")

        XCTAssert(text.string == "lorem ipsum")
        XCTAssert(text.nodeRanges[0].node.tag.name == "a")
        XCTAssert(text.nodeRanges[0].node.tag.value == "link3")
        XCTAssert(text.nodeRanges[0].range == text.string.startIndex..<text.string.endIndex)
    }

    func testHTMLAndBBTags() {
        let text = parse("<a href=\"link\">[b]lorem ipsum[/b]</a>")

        XCTAssert(text.string == "lorem ipsum")

        XCTAssert(text.nodeRanges[0].node.tag.name == "b")
        XCTAssert(text.nodeRanges[1].node.tag.name == "a")
    }

    func testSingleEmoticon() {
        let text = parse("lorem :smile: ipsum")

        XCTAssert(text.string == "lorem \(Emoticons.table[":smile:"]!) ipsum")
    }

    func testEmoticons() {
        let text = parse("lorem :smile::help::hmm: ipsum")

        XCTAssert(text.string == "lorem \(Emoticons.table[":smile:"]!)\(Emoticons.table[":help:"]!)\(Emoticons.table[":hmm:"]!) ipsum")
    }

    func testHybridText() {
        let text = parse("lorem <a href='link'>ipsum</a> dolor [b]sit[/b] amet, consectetur adipiscing <b><i>:smile:</i></b>:foo")

        XCTAssert(text.string == "lorem ipsum dolor sit amet, consectetur adipiscing \(Emoticons.table[":smile:"]!):foo")
        XCTAssert(text.nodeRanges.map({ $0.node.tag.name }) == ["a", "b", "i", "b", ""])
    }

    func testHiddenTag() {
        let text = parse("lorem [h]ipsum <b>dolor</b> sit[/h] amet")

        XCTAssert(text.string == "lorem \(TagReplacementRules.previewAttachments["h"]!) amet")
    }

    func testSingleBBTags1() {
        let text = parse("list [LIST][*]1st [*]2nd [*]3rd ...[/LIST] end")

        XCTAssert(text.string == "list 1st 2nd 3rd ... end")
        XCTAssert(text.nodeRanges.count == 5)
        XCTAssert(text.nodeRanges[3].node.tag.name == "list")
        XCTAssert(text.string[text.nodeRanges[3].range] == "1st 2nd 3rd ...")
    }

    func testSingleBBTags2() {
        let text = parse("my [IMG]link[/IMG] and my [VIDEO=video_link] !!!")

        XCTAssert(text.string == "my ИЗОБРАЖЕНИЕ and my ВИДЕО !!!")
    }

    func testSingleHTMLTags() {
        let text = parse("my <img src'link'/> and <br> !!!")

        XCTAssert(text.string == "my ИЗОБРАЖЕНИЕ and \n !!!")
    }

    // MARK: -

    private func parse(_ string: String) -> FLText {
        let combinedReplacementRules = TagReplacementRules.defaults.merging(TagReplacementRules.previewAttachments) { (_, new) in new }

        let text = FLTextBuilder.makeTextFrom(node: FLTextParser.parse(string: string), replacementRules: combinedReplacementRules)

        return text
    }
}
