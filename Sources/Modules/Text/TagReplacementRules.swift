public typealias ReplacementRules = [String: String]

public struct TagReplacementRules {
    static let defaults: ReplacementRules = [
        "br": "\n",
        "hr": "\n"
    ]

    public static let previewAttachments: ReplacementRules = [
        "img": "ИЗОБРАЖЕНИЕ",
        "video": "ВИДЕО",
        "h": "СКРЫТЫЙ ТЕКСТ",
        "spoiler": "СПОЙЛЕР"
    ]

    public static let interactiveAttachments: ReplacementRules = [
        "img": "ИЗОБРАЖЕНИЕ (нажмите, чтобы посмотреть)",
        "video": "ВИДЕО (нажмите, чтобы посмотреть)",
        "h": "СКРЫТЫЙ ТЕКСТ (нажмите, чтобы посмотреть)",
        "spoiler": "СПОЙЛЕР (нажмите, чтобы посмотреть)"
    ]
}
