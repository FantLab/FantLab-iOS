import FantLabUtils

final class Emoticons {
    static let trie: Trie<String, String> = {
        let t = Trie<String, String>()
        table.forEach(t.insert)
        return t
    }()

    static let table: [String: String] = [
        ":smile:": "😊",
        ":wink:": "😉",
        ":glasses:": "🤓",
        ":biggrin:": "😁",
        ":gigi:": "😂",
        ":lol:": "😆",
        ":haha:": "😂",
        ":frown:": "😔",
        ":confused:": "😅",
        ":insane:": "🤪",
        ":weep:": "😭",
        ":abuse:": "🤬",
        ":mad:": "😡",
        ":dont:": "🙅‍♀️",
        ":eek:": "😨",
        ":blush:": "😳",
        ":super:": "😎",
        ":pray:": "🙏",
        ":box:": "🥊",
        ":beer:": "🍻",
        ":shuffle:": "😅",
        ":rev:": "💃",
        ":tired:": "😴",
        ":hihiks:": "😝",
        ":superkiss:": "😘",
        ":hb:": "😚",
        ":kiss2:": "😘",
        ":wink2:": "😉",
        ":love:": "❤️",
        ":gun:": "🔫",
        ":gy:": "😝",
        ":help:": "🆘",
        ":hmm:": "🤔",
        ":kap:": "🏳️",
        ":rom:": "🌼",
        ":sad:": "😞",
        ":shock:": "😱",
        ":sla:": "😋",
        ":wht:": "😟",
        ":glum:": "🤘",
        ":alc:": "🥂",
        ":friends:": "🤝",
        ":appl:": "👏",
        ":bigeyes2:": "😳",
        ":bye:": "👋",
        ":drink:": "🤙",
        ":facepalm:": "🤦‍♀️",
        ":kar:": "🥋",
        ":lady:": "👩",
        ":rolleyes:": "🙄",
        ":spy:": "🕵️‍♂️",
        ":silly:": "🤪",
        ":popcorn:": "🍿"
    ]
}
