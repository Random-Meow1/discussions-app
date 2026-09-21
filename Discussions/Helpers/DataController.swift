import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@Model
class Lesson {
    var title: String
    var subtitle: String
    var Sections: [Section]
    var dateCreated: Date
    var timesOpened: Int
    
    init(title: String = "", subtitle: String = "", Sections: [Section] = [], dateCreated: Date = Date.now, timesOpened: Int = 0) {
        self.title = title
        self.subtitle = subtitle
        self.Sections = Sections
        self.dateCreated = dateCreated
        self.timesOpened = timesOpened
    }
}

struct Section: Codable, Identifiable, Equatable {
    static func == (lhs: Section, rhs: Section) -> Bool {
               lhs.header == rhs.header &&
               lhs.content == rhs.content &&
               lhs.notes == rhs.notes &&
               lhs.isQuestion == rhs.isQuestion &&
               lhs.isOpenEndedQuestion == rhs.isOpenEndedQuestion &&
               lhs.answer == rhs.answer &&
               lhs.resources == rhs.resources &&
               lhs.isShown == rhs.isShown &&
               lhs.isAnswerShown == rhs.isAnswerShown
    }
    
    var id: UUID = UUID()
    var header: String = ""
    var content: String = ""
    var notes: String = ""
    var isQuestion: Bool = false
    var isOpenEndedQuestion: Bool = false
    var answer: String = ""
    var resources: [Resource] = []
    var isShown: Bool = false
    var isAnswerShown: Bool = false
}

struct Resource: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var link: String = ""
    var displayText: String = ""
}

// Lightweight Codable DTO for Transfer
struct LessonDTO: Codable {
    var title: String
    var subtitle: String
    var sections: [Section]
    var dateCreated: Date

    // Initialize DTO from SwiftData Model
    init(from lesson: Lesson) {
        self.title = lesson.title
        self.subtitle = lesson.subtitle
        self.sections = lesson.Sections
        self.dateCreated = lesson.dateCreated
    }

    // Convert DTO back to SwiftData Model
    func toModel() -> Lesson {
        Lesson(
            title: self.title,
            subtitle: self.subtitle,
            Sections: self.sections,
            dateCreated: self.dateCreated,
            timesOpened: 0
        )
    }

    // Generate a shareable Deep Link URL (myapp://import-lesson?data=...)
    var shareableURL: URL? {
        guard let jsonData = try? JSONEncoder().encode(self) else { return nil }
        let base64String = jsonData.base64EncodedString()
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return URL(string: "discussions://import-lesson?data=\(base64String)")
    }

    // Decode URL back to LessonDTO
    static func from(url: URL) -> LessonDTO? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItem = components.queryItems?.first(where: { $0.name == "data" }),
              let base64String = queryItem.value,
              let data = Data(base64Encoded: base64String) else {
            return nil
        }
        return try? JSONDecoder().decode(LessonDTO.self, from: data)
    }
}
