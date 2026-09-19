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
    @Environment(\.modelContext) private var modelContext
    @Query var lessons: [Lesson]
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var sortDescriptor = SortDescriptor(\Lesson.dateCreated, order: .reverse)
    @State private var sortMode: Int = 0
    @State private var isSortModeReversed: Bool = false
    
    @AppStorage("Testing Mode") private var testingMode: Bool = false
    @AppStorage("Show Info") private var showInfo: Bool = true
    @State private var isMoreOptionsShown: Bool = false
    @State private var deleteAllConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(alignment: .leading) {
                    PrimaryActionBar(
                        testingMode: testingMode,
                        isMoreOptionsShown: $isMoreOptionsShown,
                        onNewLesson: createNewLesson,
                        onCreateTestLessons: createTestLessons
                    )
                    
                    if isMoreOptionsShown {
                        SecondaryActionBar(
                            testingMode: $testingMode,
                            showInfo: $showInfo,
                            deleteAllConfirmation: $deleteAllConfirmation,
                            isDisabled: lessons.isEmpty,
                            onDeleteAll: deleteAllLessons
                        )
                    }
                    
                    searchAndSortSection
                    
                    LessonListView(
                        sortDescriptor: sortDescriptor,
                        textToSearch: searchText,
                        testingMode: testingMode,
                        showInfo: showInfo
                    )
                    
                    FooterView(testingMode: testingMode, showInfo: showInfo)
                }
                .navigationTitle("Discussions")
                .navigationSubtitle("\(lessons.count) lessons")
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding()
            }
            .buttonStyle(.plain)
        }
    }
    
    private var backgroundGradient: some View {
        Rectangle()
            .fill(Gradient(stops: [
                Gradient.Stop(color: .clear, location: 0.25),
                Gradient.Stop(color: .accent.opacity(0.3), location: 1)
            ]))
            .ignoresSafeArea()
    }
    
    private var searchAndSortSection: some View {
        HStack {
            HStack {
                TextField("Search", text: $searchText)
                
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
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
                Button(action: toggleSortMode) {
                    Label(sortTitle, systemImage: "line.3.horizontal.decrease")
                        .padding()
                        .background(.secondary.quaternary)
                        .foregroundStyle(.primary)
                        .tint(.primary)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var sortTitle: String {
        let suffix = isSortModeReversed ? " (reversed)" : ""
        switch sortMode {
        case 0: return "Date created\(suffix)"
        case 1: return "Times opened\(suffix)"
        case 2: return "Name\(suffix)"
        default: return "Unknown\(suffix)"
        }
    }
    
    private func createNewLesson() {
        modelContext.insert(Lesson(title: randomTitle(), dateCreated: Date.now))
    }
    
    private func deleteAllLessons() {
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
    }
    
    private func toggleSortMode() {
        sortMode = (sortMode < 2) ? sortMode + 1 : 0
        updateSortDescriptor()
    }
    
    private func updateSortDescriptor() {
        let order: SortOrder = isSortModeReversed ? .forward : .reverse
        let reversedOrder: SortOrder = isSortModeReversed ? .reverse : .forward
        
        switch sortMode {
        case 0: sortDescriptor = SortDescriptor(\Lesson.dateCreated, order: order)
        case 1: sortDescriptor = SortDescriptor(\Lesson.timesOpened, order: order)
        case 2: sortDescriptor = SortDescriptor(\Lesson.title, order: reversedOrder)
        default: sortDescriptor = SortDescriptor(\Lesson.dateCreated, order: order)
        }
    }
    
    private func createTestLessons() {
        modelContext.insert(Lesson(
            title: "Why Swift is the Best Programming Language",
            subtitle: "Exploring the features that make Swift powerful and modern.",
            Sections: [
                Section(id: UUID(), header: "Introduction to Swift", content: "Swift is a fast, safe, and modern language developed by Apple.", notes: "Mention its release in 2014.", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false),
                Section(id: UUID(), header: "Safety Features", content: "Swift eliminates entire classes of unsafe code.", notes: "", isQuestion: true, isOpenEndedQuestion: false, answer: "Optionals and type safety.", resources: [], isShown: true, isAnswerShown: false)
            ],
            dateCreated: Date.now,
            timesOpened: 2
        ))
    }
}

// MARK: - Subviews

private struct PrimaryActionBar: View {
    let testingMode: Bool
    @Binding var isMoreOptionsShown: Bool
    let onNewLesson: () -> Void
    let onCreateTestLessons: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action: onNewLesson) {
                    Label("New lesson", systemImage: "plus")
                        .padding()
                        .background(.secondary.quaternary)
                        .foregroundStyle(.primary)
                        .tint(.primary)
                        .clipShape(Capsule())
                }
                
                if testingMode {
                    Button(action: onCreateTestLessons) {
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
                    Label(
                        isMoreOptionsShown ? "Less" : "More",
                        systemImage: isMoreOptionsShown ? "chevron.up" : "chevron.down"
                    )
                    .padding()
                    .background(.secondary.quaternary)
                    .foregroundStyle(.primary)
                    .tint(.primary)
                    .clipShape(Capsule())
                }
            }
        }
    }
}

private struct SecondaryActionBar: View {
    @Binding var testingMode: Bool
    @Binding var showInfo: Bool
    @Binding var deleteAllConfirmation: Bool
    let isDisabled: Bool
    let onDeleteAll: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(role: .destructive, action: onDeleteAll) {
                    Label(
                        deleteAllConfirmation ? "Are you sure?" : "Delete all",
                        systemImage: deleteAllConfirmation ? "exclamationmark.triangle" : "trash"
                    )
                    .padding()
                    .background(.secondary.quaternary)
                    .foregroundStyle(deleteAllConfirmation ? .red : .primary)
                    .tint(deleteAllConfirmation ? .red : .primary)
                    .clipShape(Capsule())
                }
                .disabled(isDisabled)
                
                if let url = URL(string: "mailto:randommeowofficial@icloud.com") {
                    Link(destination: url) {
                        Label("Send feedback", systemImage: "bubble.and.pencil")
                            .padding()
                            .background(.secondary.quaternary)
                            .foregroundStyle(.primary)
                            .tint(.primary)
                            .clipShape(Capsule())
                    }
                }
                
                ToggleCapsule(title: "Testing mode", icon: "testtube.2", isOn: $testingMode)
                
                if testingMode {
                    ToggleCapsule(title: "Show info", icon: "info", isOn: $showInfo)
                }
                
                if let url = URL(string: "https://github.com/Random-Meow1/discussions-app") {
                    Link(destination: url) {
                        Label("Open source", systemImage: "arrow.up.right")
                            .padding()
                            .background(.secondary.quaternary)
                            .foregroundStyle(.primary)
                            .tint(.primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

private struct ToggleCapsule: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Toggle("", isOn: $isOn)
                .frame(maxHeight: 20)
        }
        .padding()
        .background(.secondary.quaternary)
        .foregroundStyle(.primary)
        .clipShape(Capsule())
    }
}

struct LessonListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var lessons: [Lesson]
    
    let searchText: String
    let testingMode: Bool
    let showInfo: Bool
    
    init(
        sortDescriptor: SortDescriptor<Lesson>,
        textToSearch: String,
        testingMode: Bool,
        showInfo: Bool
    ) {
        _lessons = Query(sort: [sortDescriptor])
        self.searchText = textToSearch
        self.testingMode = testingMode
        self.showInfo = showInfo
    }
    
    private var filteredLessons: [Lesson] {
        guard !searchText.isEmpty else { return lessons }
        let query = searchText.lowercased()
        return lessons.filter { lesson in
            lesson.title.lowercased().contains(query) ||
            lesson.subtitle.lowercased().contains(query) ||
            lesson.Sections.contains(where: { $0.content.lowercased().contains(query) })
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(filteredLessons) { lesson in
                    LessonRowView(
                        lesson: lesson,
                        testingMode: testingMode,
                        showInfo: showInfo,
                        onDelete: { modelContext.delete(lesson) }
                    )
                }
            }
        }
    }
}

private struct LessonRowView: View {
    let lesson: Lesson
    let testingMode: Bool
    let showInfo: Bool
    let onDelete: () -> Void

    var body: some View {
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
                Button(role: .destructive, action: onDelete) {
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
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
    }
}

private struct FooterView: View {
    let testingMode: Bool
    let showInfo: Bool

    var body: some View {
        Text("Version 0.1 (Beta)\(testingMode ? " (Testing mode, show info is \(showInfo ? "ON" : "OFF"))" : "")")
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
            .padding(8)
    }
}

func randomTitle() -> String {
    let adjectives = ["Happy", "Bright", "Quick", "Silent", "Brave", "Calm", "Eager"]
    let nouns = ["Apple", "Banana", "Orange", "Strawberry", "Grape", "Lemon"]
    let adjective = adjectives.randomElement()!
    let noun = nouns.randomElement()!
    return "\(adjective) \(noun)"
}

#Preview {
    ContentView()
}
