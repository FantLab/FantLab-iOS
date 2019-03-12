import FLKit

final class HTMLEntities {
    static let trie: Trie<String, String> = {
        let t = Trie<String, String>()

        ["&amp;": "&",
         "&lt;": "<",
         "&gt;": ">",
         "&nbsp;": "\u{00a0}",
         "&laquo;": "«",
         "&raquo;": "»",
         "&mdash;": "—",
         "&shy;": ""].forEach(t.insert)

        return t
    }()
}
