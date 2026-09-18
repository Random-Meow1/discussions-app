import SwiftUI
import Playgrounds
import SwiftData

@main struct Discussions: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Lesson.self)
    }
}

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

struct Section: Codable, Identifiable {
    var id: UUID = UUID()
    var header: String = ""
    var content: String = ""
    var notes: String = ""
    var isQuestion: Bool = false
    var isOpenEndedQuestion: Bool = false
    var answer: String = ""
//    var color: Color
    var resources: [Resource] = []
    var isShown: Bool = false
    var isAnswerShown: Bool = false
}

struct Resource: Codable, Identifiable {
    var id: UUID = UUID()
    var link: String = ""
    var displayText: String = ""
}

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var lessons: [Lesson]
    @State private var searchText: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State var sortDescriptor = SortDescriptor(\Lesson.dateCreated, order: .reverse)
    @State private var sortMode: Int = 0
    @State private var isSortModeReversed: Bool = false
    
    @AppStorage("Testing Mode") var testingMode: Bool = false
    @AppStorage("Show Info") var showInfo: Bool = true
    @State private var isMoreOptionsShown: Bool = false
    @State private var deleteAllConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Gradient(stops: [
                        Gradient.Stop(color: .clear, location: 0.25),
                        Gradient.Stop(color: .accent.opacity(0.3), location: 1)
                    ]))
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            Button {
                                modelContext.insert(Lesson(title: randomTitle(), dateCreated: Date.now))
                            } label: {
                                Label("New lesson", systemImage: "plus")
                                    .padding()
                                    .background(.secondary.quaternary)
                                    .foregroundStyle(.primary)
                                    .tint(.primary)
                                    .clipShape(Capsule())
                            }
                            
                            if testingMode {
                                Button {
                                    modelContext.insert(Lesson(
                                        title: "Why Swift is the Best Programming Language",
                                        subtitle: "Exploring the features that make Swift powerful and modern.",
                                        Sections: [
                                            Section(id: UUID(), header: "Introduction to Swift", content: "Swift is a fast, safe, and modern language developed by Apple.", notes: "Mention its release in 2014.", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Safety Features", content: "Swift eliminates entire classes of unsafe code.", notes: "", isQuestion: true, isOpenEndedQuestion: false, answer: "Optionals and type safety.", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Performance", content: "Swift is incredibly fast, often matching C++ performance.", notes: "", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [Resource(id: UUID(), link: "https://swift.org", displayText: "Official Swift Website")], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Modern Syntax", content: "The syntax is clean and easy to read.", notes: "", isQuestion: true, isOpenEndedQuestion: true, answer: "", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Community", content: "Swift is open source with a vibrant community.", notes: "", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false)
                                        ],
                                        dateCreated: Date.now,
                                        timesOpened: 2
                                    ))
                                    
                                    modelContext.insert(Lesson(
                                        title: "Apple's Focus on Privacy",
                                        subtitle: "Understanding the core principles of Apple's privacy strategy.",
                                        Sections: [
                                            Section(id: UUID(), header: "Data Minimization", content: "Apple collects only the data necessary to provide a service.", notes: "Key principle.", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "On-Device Processing", content: "Your data is processed on your device, not on Apple's servers.", notes: "", isQuestion: true, isOpenEndedQuestion: false, answer: "True", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Transparency", content: "App Tracking Transparency gives you control over your data.", notes: "", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [Resource(id: UUID(), link: "https://apple.com/privacy", displayText: "Apple Privacy Policy")], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Security", content: "End-to-end encryption protects your messages and data.", notes: "", isQuestion: true, isOpenEndedQuestion: true, answer: "", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "User Control", content: "You decide what to share and when.", notes: "", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false)
                                        ],
                                        dateCreated: Date.now,
                                        timesOpened: 1
                                    ))
                                    
                                    modelContext.insert(Lesson(
                                        title: "Introduction to Video Editing",
                                        subtitle: "Learn the basics of cutting, coloring, and exporting.",
                                        Sections: [
                                            Section(id: UUID(), header: "The Interface", content: "Familiarize yourself with the timeline and media pool.", notes: "Use Final Cut Pro or iMovie.", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "The Rough Cut", content: "Assemble your clips in order without worrying about perfection.", notes: "", isQuestion: true, isOpenEndedQuestion: false, answer: "The first draft of your edit.", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Color Grading", content: "Adjust the exposure and color balance of your footage.", notes: "", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [Resource(id: UUID(), link: "https://apple.com/final-cut-pro", displayText: "Final Cut Pro")], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Audio Mixing", content: "Ensure your dialogue is clear and music is balanced.", notes: "", isQuestion: true, isOpenEndedQuestion: true, answer: "", resources: [], isShown: true, isAnswerShown: false),
                                            Section(id: UUID(), header: "Exporting", content: "Choose the right codec and resolution for your destination.", notes: "", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false)
                                        ],
                                        dateCreated: Date.now,
                                        timesOpened: 0
                                    ))
                                } label: {
                                    Label("Create test lessons", systemImage: "plus.square.on.square")
                                        .padding()
                                        .background(.secondary.quaternary)
                                        .foregroundStyle(.primary)
                                        .tint(.primary)
                                        .clipShape(Capsule())
                                }
                            }
                            
                            Button {
                                withAnimation(.spring(duration: 0.2)) {
                                    isMoreOptionsShown.toggle()
                                }
                            } label: {
                                if isMoreOptionsShown {
                                    Label("Less", systemImage: "chevron.up")
                                        .padding()
                                        .background(.secondary.quaternary)
                                        .foregroundStyle(.primary)
                                        .tint(.primary)
                                        .clipShape(Capsule())
                                } else {
                                    Label("More", systemImage: "chevron.down")
                                        .padding()
                                        .background(.secondary.quaternary)
                                        .foregroundStyle(.primary)
                                        .tint(.primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    if isMoreOptionsShown {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button(role: .destructive) {
                                    if deleteAllConfirmation {
                                        Task {
                                            for lesson in lessons {
                                                modelContext.delete(lesson)
                                            }
                                            deleteAllConfirmation = false
                                        }
                                    } else {
                                        deleteAllConfirmation = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            deleteAllConfirmation = false
                                        }
                                    }
                                } label: {
                                    if deleteAllConfirmation {
                                        Label("Are you sure?", systemImage: "exclamationmark.triangle")
                                            .padding()
                                            .background(.red.quaternary)
                                            .foregroundStyle(.red)
                                            .tint(.red)
                                            .clipShape(Capsule())
                                    } else {
                                        Label("Delete all", systemImage: "trash")
                                            .padding()
                                            .background(.secondary.quaternary)
                                            .foregroundStyle(.primary)
                                            .tint(.primary)
                                            .clipShape(Capsule())
                                    }
                                }
                                .disabled(lessons.isEmpty)
                                
                                Link(destination: URL(string: "mailto:randommeowofficial@icloud.com")!) {
                                    Label("Send feedback", systemImage: "bubble.and.pencil")
                                        .padding()
                                        .background(.secondary.quaternary)
                                        .foregroundStyle(.primary)
                                        .tint(.primary)
                                        .clipShape(Capsule())
                                }
                                
                                HStack {
                                    Label("Testing mode", systemImage: "testtube.2")
                                    Toggle("", isOn: $testingMode)
                                        .frame(maxHeight: 20)
                                }
                                .padding()
                                .background(.secondary.quaternary)
                                .foregroundStyle(.primary)
                                .clipShape(Capsule())
                                
                                if testingMode {
                                    HStack {
                                        Label("Show info", systemImage: "info")
                                        Toggle("", isOn: $showInfo)
                                            .frame(maxHeight: 20)
                                    }
                                    .padding()
                                    .background(.secondary.quaternary)
                                    .foregroundStyle(.primary)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    HStack {
                        HStack {
                            TextField("Search", text: $searchText)
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
                        .padding()
                        .background(.secondary.quaternary)
                        .foregroundStyle(.primary)
                        .tint(.primary)
                        .clipShape(Capsule())
                        .focused($isSearchFieldFocused)
                        
                        if isSearchFieldFocused {
                            Button {
                                isSearchFieldFocused = false
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark")
                                    .padding()
                                    .background(.secondary.quaternary)
                                    .foregroundStyle(.primary)
                                    .tint(.primary)
                                    .clipShape(Circle())
                            }
                        } else {
                            Button {
                                if sortMode < 2 {
                                    sortMode += 1
                                } else {
                                    sortMode = 0
                                }
                                
                                updateSortDescriptor()
                            } label: {
                                switch sortMode {
                                case 0:
                                    Label("Date created\(isSortModeReversed ? " (reversed)" : "")", systemImage: "line.3.horizontal.decrease")
                                        .padding()
                                        .background(.secondary.quaternary)
                                        .foregroundStyle(.primary)
                                        .tint(.primary)
                                        .clipShape(Capsule())
                                case 1:
                                    Label("Times opened\(isSortModeReversed ? " (reversed)" : "")", systemImage: "line.3.horizontal.decrease")
                                        .padding()
                                        .background(.secondary.quaternary)
                                        .foregroundStyle(.primary)
                                        .tint(.primary)
                                        .clipShape(Capsule())
                                case 2:
                                    Label("Name\(isSortModeReversed ? " (reversed)" : "")", systemImage: "line.3.horizontal.decrease")
                                        .padding()
                                        .background(.secondary.quaternary)
                                        .foregroundStyle(.primary)
                                        .tint(.primary)
                                        .clipShape(Capsule())
                                default:
                                    Label("Unknown\(isSortModeReversed ? " (reversed)" : "")", systemImage: "line.3.horizontal.decrease")
                                        .padding()
                                        .background(.secondary.quaternary)
                                        .foregroundStyle(.primary)
                                        .tint(.primary)
                                        .clipShape(Capsule())
                                }
                            }
//                            .onTapGesture(count: 2) {
//                                isSortModeReversed.toggle()
//                                updateSortDescriptor()
//                            }
                        }
                    }
                    
                    LessonListView(sortDescriptor: sortDescriptor, textToSearch: searchText, testingMode: testingMode, showInfo: showInfo)
                    
                    Text("Version 0.0 (Alpha)\(testingMode ? " (Testing mode, show info is \(showInfo ? "ON" : "OFF"))" : "")")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
                .navigationTitle("Lessons")
                .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                .padding()
            }
            .buttonStyle(.plain)
        }
    }
    
    func updateSortDescriptor() {
        if !isSortModeReversed {
            switch sortMode {
            case 0:
                sortDescriptor = SortDescriptor(\Lesson.dateCreated, order: .reverse)
            case 1:
                sortDescriptor = SortDescriptor(\Lesson.timesOpened, order: .reverse)
            case 2:
                sortDescriptor = SortDescriptor(\Lesson.title, order: .forward)
            default:
                sortDescriptor = SortDescriptor(\Lesson.dateCreated, order: .reverse)
            }
        } else {
            switch sortMode {
            case 0:
                sortDescriptor = SortDescriptor(\Lesson.dateCreated, order: .forward)
            case 1:
                sortDescriptor = SortDescriptor(\Lesson.timesOpened, order: .forward)
            case 2:
                sortDescriptor = SortDescriptor(\Lesson.title, order: .reverse)
            default:
                sortDescriptor = SortDescriptor(\Lesson.dateCreated, order: .forward)
            }
        }
    }
}

struct LessonListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var lessons: [Lesson]
    
    @State var searchText: String
    var testingMode: Bool
    var showInfo: Bool
    
    init(
        sortDescriptor: SortDescriptor<Lesson>,
        textToSearch: String,
        testingMode: Bool,
        showInfo: Bool
    ) {
        _lessons = Query(sort: [sortDescriptor])
        searchText = textToSearch
        self.testingMode = testingMode
        self.showInfo = showInfo
    }
    
    func deleteLessons(_ indexSet: IndexSet) {
        for index in indexSet {
            let lesson = lessons[index]
            modelContext.delete(lesson)
        }
    }
    
    var body: some View {
        ScrollView {
            ForEach(lessons) { lesson in
                if lesson.title.lowercased().contains(searchText.lowercased()) ||
                    lesson.dateCreated.description.lowercased().contains(searchText.lowercased()) ||
                    lesson.Sections.contains(where: { $0.content.lowercased().contains(searchText.lowercased()) }) ||
                    lesson.subtitle.lowercased().contains(searchText.lowercased()) ||
                    searchText.isEmpty {
                    NavigationLink(destination: EditLessonView(lesson: lesson)) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                HStack {
                                    if lesson.timesOpened == 0 {
                                        Circle()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(.accentColor)
                                    }
                                    Text(lesson.title)
                                        .font(.title.bold())
                                        .multilineTextAlignment(.leading)
                                }
                                Text(lesson.subtitle)
                                    .multilineTextAlignment(.leading)
                                Text("\(lesson.Sections.count) sections")
                                    .foregroundStyle(.secondary)
                                if testingMode && showInfo {
                                    Divider()
                                    Text("dateCreated: \(lesson.dateCreated)")
                                        .font(.body.monospaced())
                                        .foregroundStyle(.secondary)
                                    Text("timesOpened: \(lesson.timesOpened)")
                                        .font(.body.monospaced())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer(minLength: 0)
                            
#if os(macOS)
                            Button(role: .destructive) {
                                modelContext.delete(lesson)
                            } label : {
                                Label("Delete", systemImage: "trash")
                                    .padding()
                                    .tint(.red)
                                    .background(.secondary.quaternary)
                                    .foregroundStyle(.primary)
                                    .tint(.primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
#endif
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .tint(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.secondary.quaternary)
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            modelContext.delete(lesson)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
        }
    }
}

func randomTitle() -> String {
    let adjectives = [
        "Happy", "Bright", "Quick", "Silent", "Brave",
        "Calm", "Eager", "Fierce", "Gentle", "Jolly",
        "Kind", "Lively", "Merry", "Nice", "Proud",
        "Quiet", "Rich", "Smart", "Tall", "Vast",
        "Warm", "Young", "Zesty", "Bold", "Clever",
        "Daring", "Fair", "Glad", "Keen", "Lucky",
        "Noble", "Polite", "Ready", "Sharp", "Tough",
        "Wise", "Alert", "Clean", "Fresh", "Grand"
    ]
    let nouns = [
        "Apple", "Banana", "Orange", "Strawberry", "Grape",
        "Watermelon", "Blueberry", "Lemon", "Peach", "Pineapple",
        "Mango", "Cherry", "Pear", "Raspberry", "Plum",
        "Blackberry", "Kiwi", "Grapefruit", "Avocado", "Pomegranate",
        "Lime", "Cantaloupe", "Honeydew", "Apricot", "Fig",
        "Tangerine", "Papaya", "Coconut", "Cranberry", "Nectarine",
        "Date", "Passion Fruit", "Guava", "Lychee", "Persimmon",
        "Dragon Fruit", "Starfruit", "Mulberry", "Boysenberry", "Quince"
    ]
    let adjective = adjectives.randomElement()!
    let noun = nouns.randomElement()!
    return "\(adjective) \(noun)"
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
