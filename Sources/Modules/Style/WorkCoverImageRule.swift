import UIKit.UIImage

public final class WorkCoverImageRule {
    private init() {}

    private static let idToTypeTable: [Int: String] = [
        1 : "novel",
        3 : "collection",
        4 : "cycle",
        5 : "poem",
        7 : "other",
        8 : "tale",
        11 : "essay",
        12 : "article",
        13 : "epic",
        17 : "antology",
        18 : "piece",
        19 : "scenario",
        20 : "documental",
        21 : "microstory",
        22 : "disser",
        23 : "monography",
        24 : "study",
        25 : "encyclopedy",
        26 : "magazine",
        27 : "poem",
        28 : "poem",
        29 : "poem",
        41 : "comix",
        42 : "manga",
        43 : "graphicnovel",
        44 : "story",
        45 : "shortstory",
        46 : "sketch",
        47 : "reportage",
        48 : "conditionalcycle",
        49 : "excerpt",
        51 : "interview",
        52 : "review"
    ]

    private static let typeToImageNameTable: [String: String] = [
        "novel" :  "coverwork_novel",
        "collection" :  "coverwork_collection",
        "cycle" :  "coverwork_cycle",
        "poem" :  "coverwork_poem",
        "other" :  "coverwork__default",
        "tale" :  "coverwork_poem",
        "essay" :  "coverwork_article",
        "article" :  "coverwork_article",
        "epic" :  "coverwork_cycle",
        "antology" :  "coverwork_antology",
        "piece" :  "coverwork_article",
        "scenario" :  "coverwork_film",
        "documental" :  "coverwork_article",
        "microstory" :  "coverwork_shortstory",
        "disser" :  "coverwork_article",
        "monography" :  "coverwork_article",
        "study" :  "coverwork_novel",
        "encyclopedy" :  "coverwork_novel",
        "magazine" :  "coverwork_magazine",
        "comix" :  "coverwork_comic",
        "manga" :  "coverwork_comic",
        "graphicnovel" :  "coverwork_comic",
        "story" :  "coverwork_story",
        "shortstory" :  "coverwork_shortstory",
        "sketch" :  "coverwork_article",
        "reportage" :  "coverwork_article",
        "conditionalcycle" :  "coverwork_cycle",
        "excerpt" :  "coverwork_shortstory",
        "interview" :  "coverwork_article",
        "review" :  "coverwork_article"
    ]

    public static func coverFor(workType: String) -> UIImage? {
        return UIImage(named: typeToImageNameTable[workType.lowercased()] ?? "coverwork__default")
    }

    public static func coverFor(workTypeId: Int) -> UIImage? {
        return coverFor(workType: idToTypeTable[workTypeId] ?? "")
    }
}
