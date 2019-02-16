import FantLabUtils

final class HTMLEntities {
    static let trie: Trie<String, String> = {
        let t = Trie<String, String>()
        table.forEach(t.insert)
        return t
    }()

    static let table: [String: String] = [
        "&amp;": "&",
        "&lt;": "<",
        "&gt;": ">",
        "&nbsp;": "\u{00a0}",
        "&laquo;": "«",
        "&raquo;": "»",
        "&mdash;": "—"
    ]
}
