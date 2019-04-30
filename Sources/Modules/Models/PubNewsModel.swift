import Foundation

public final class PubNewsModel {
    public let editionId: Int
    public let dateString: String
    public let imageURL: URL?
    public let typeName: String
    public let authors: String
    public let name: String
    public let info: String
    
    public init(editionId: Int,
                dateString: String,
                imageURL: URL?,
                typeName: String,
                authors: String,
                name: String,
                info: String) {
        
        self.editionId = editionId
        self.dateString = dateString
        self.imageURL = imageURL
        self.typeName = typeName
        self.authors = authors
        self.name = name
        self.info = info
    }
}
