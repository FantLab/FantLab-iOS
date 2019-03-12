import FLLayoutSpecs

struct SectionListModel {
    let layoutModel: ListSectionTitleLayoutModel
    let tapAction: (() -> Void)?
    let makeListItems: () -> Void
}
