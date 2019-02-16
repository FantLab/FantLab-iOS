import Foundation
import FantLabModels

final class RSSParser: NSObject, XMLParserDelegate {
    private let parser: XMLParser

    init(data: Data) throws {
        parser = XMLParser(data: data)

        super.init()

        parser.delegate = self
        parser.parse()

        if let parserError = parser.parserError {
            throw parserError
        }
    }

    private(set) var news: [NewsModel] = []

    private var titleCharacters: String = ""
    private var textCharacters: String = ""
    private var dateCharacters: String = ""
    private var urlCharacters: String = ""

    private var tagName: String = ""

    // MARK: -

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        tagName = elementName

        guard elementName == "item" else {
            return
        }

        titleCharacters = ""
        textCharacters = ""
        dateCharacters = ""
        urlCharacters = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch tagName {
        case "pubDate":
            if dateCharacters.isEmpty {
                dateCharacters = string
            }
        case "link":
            if urlCharacters.isEmpty {
                urlCharacters = string
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard let string = String(data: CDATABlock, encoding: .utf8) else {
            return
        }

        switch tagName {
        case "title":
            if titleCharacters.isEmpty {
                titleCharacters = string
            }
        case "description":
            if textCharacters.isEmpty {
                textCharacters = string
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard elementName == "item" else {
            return
        }

        guard let date = Date.from(string: dateCharacters, format: .rss, useAltShortMonthSymbols: true), let url = URL(string: urlCharacters) else {
            return
        }

        news.append(NewsModel(
            title: titleCharacters,
            text: textCharacters,
            date: date,
            url: url
        ))
    }
}
