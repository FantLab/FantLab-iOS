import XCTest

@testable
import FantLabText

class TextParserTests: XCTestCase {
    func testEmptyString() {
        let text = FLStringPreview(string: "")

        XCTAssert(text.value.isEmpty)
    }

    func testOpenTag() {
        let text = FLStringPreview(string: "[b]")

        XCTAssert(text.value.isEmpty)
    }

    func testSingleBBTag() {
        let text = FLStringPreview(string: "[b]lorem ipsum[/b]")

        XCTAssert(text.value == "lorem ipsum")
    }

    func testMultipleBBTags() {
        let text = FLStringPreview(string: "x y [b][u]z[/u][/b] a [i]b[/i] [p]c[/p] d e")

        XCTAssert(text.value == "x y z a b c d e")
    }

    func testBBTagWithParam() {
        let text = FLStringPreview(string: "some [person=1]person[/person]")

        XCTAssert(text.value == "some person")
    }

    func testURLInBBTag() {
        let text = FLStringPreview(string: "some [url=https://google.com?q=fantlab]url[/url]")

        XCTAssert(text.value == "some url")
    }

    func testSingleHTMLTag() {
        let text = FLStringPreview(string: "<b>lorem ipsum</b>")

        XCTAssert(text.value == "lorem ipsum")
    }

    func testHTMLLink() {
        let text = FLStringPreview(string: "<a href=\"link\">lorem ipsum</a>")

        XCTAssert(text.value == "lorem ipsum")
    }

    func testHTMLLink2() {
        let text = FLStringPreview(string: "<a href=\"link\" href='link2' href=“link3“>lorem ipsum</a>")

        XCTAssert(text.value == "lorem ipsum")
    }

    func testHTMLAndBBTags() {
        let text = FLStringPreview(string: "<a href=\"link\">[b]lorem ipsum[/b]</a>")

        XCTAssert(text.value == "lorem ipsum")
    }

    func testSingleEmoticon() {
        let text = FLStringPreview(string: "lorem :smile: ipsum")

        XCTAssert(text.value == "lorem \(Emoticons.table[":smile:"]!) ipsum")
    }

    func testSingleUnknownEmoticon() {
        let text = FLStringPreview(string: "lorem :smil: ipsum")

        XCTAssert(text.value == "lorem :smil: ipsum")
    }

    func testEmoticons() {
        let text = FLStringPreview(string: "lorem :smile::help::hmm: ipsum")

        XCTAssert(text.value == "lorem \(Emoticons.table[":smile:"]!)\(Emoticons.table[":help:"]!)\(Emoticons.table[":hmm:"]!) ipsum")
    }

    func testHybridText() {
        let text = FLStringPreview(string: "lorem <a href='link'>ipsum</a> dolor [b]sit[/b] amet, consectetur adipiscing <b><i>:smile:</i></b>:foo")

        XCTAssert(text.value == "lorem ipsum dolor sit amet, consectetur adipiscing \(Emoticons.table[":smile:"]!):foo")
    }

    func testHiddenTag() {
        let text = FLStringPreview(string: "lorem [h]ipsum <b>dolor</b> sit[/h] amet")

        XCTAssert(text.value == "lorem СКРЫТЫЙ ТЕКСТ amet")
    }

    func testSingleBBTags1() {
        let text = FLStringPreview(string: "list [LIST][*]1st [*]2nd [*]3rd ...[/LIST] end")

        XCTAssert(text.value == "list 1st 2nd 3rd ... end")
    }

    func testSingleBBTags2() {
        let text = FLStringPreview(string: "my [IMG]link[/IMG] and my [VIDEO=video_link] !!!")

        XCTAssert(text.value == "my ИЗОБРАЖЕНИЕ and my ВИДЕО !!!")
    }

    func testSingleHTMLTags() {
        let text = FLStringPreview(string: "my <img src'link'/> and <br> !!!")

        XCTAssert(text.value == "my ИЗОБРАЖЕНИЕ and \n !!!")
    }

    func testHtmlEntities() {
        let text = FLStringPreview(string: "Переводные издания Новинки Айлингтон Джеймс &laquo;Тень ушедшего&raquo;Алендер")

        XCTAssert(text.value == "Переводные издания Новинки Айлингтон Джеймс «Тень ушедшего»Алендер")
    }

    func testHtmlEntitiesAndSingleAnd() {
        let text = FLStringPreview(string: "Переводные издания Новинки Айлингтон Джеймс &laquo;Тень ушедшего&raquo;&Алендер")

        XCTAssert(text.value == "Переводные издания Новинки Айлингтон Джеймс «Тень ушедшего»&Алендер")
    }

    func testHtmlUnknownEntity() {
        let text = FLStringPreview(string: "Переводные издания Новинки Айлингтон Джеймс &laqo;Тень ушедшего&raqo;&Алендер")

        XCTAssert(text.value == "Переводные издания Новинки Айлингтон Джеймс &laqo;Тень ушедшего&raqo;&Алендер")
    }
}
