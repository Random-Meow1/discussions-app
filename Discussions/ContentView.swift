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
    @AppStorage("Version Dismissed") var versionDismissed: String = ""
    @State private var isMoreOptionsShown: Bool = false
    @State private var deleteAllConfirmation: Bool = false
    
    @State private var isImportSheetPresented: Bool = false
    @State private var pendingImportURL: URL? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                VStack(alignment: .leading) {
                    PrimaryActionBar(
                        testingMode: testingMode,
                        isMoreOptionsShown: $isMoreOptionsShown,
                        isImportSheetPresented: $isImportSheetPresented,
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
                .blur(radius: isImportSheetPresented || versionDismissed != version ? 20 : 0)
                .opacity(isImportSheetPresented || versionDismissed != version ? 0.3 : 1)
                
                if isImportSheetPresented {
                    ImportSheet(
                        isImportSheetPresented: $isImportSheetPresented,
                        pendingURL: pendingImportURL
                    )
                }
                
                if versionDismissed != version {
                    WhatsNewView()
                        .padding()
                }
            }
            .buttonStyle(.plain)
            .onOpenURL { url in
                pendingImportURL = url
                withAnimation(.snappy(duration: 0.5)) {
                    isImportSheetPresented = true
                }
            }
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
        for lesson in testLessons {
            modelContext.insert(lesson)
        }
    }
    
    func randomTitle() -> String {
        let adjectives = ["Happy", "Bright", "Quick", "Silent", "Brave", "Calm", "Eager"]
        let nouns = ["Apple", "Banana", "Orange", "Strawberry", "Grape", "Lemon"]
        let adjective = adjectives.randomElement()!
        let noun = nouns.randomElement()!
        return "\(adjective) \(noun)"
    }
}

// MARK: - Subviews

private struct PrimaryActionBar: View {
    let testingMode: Bool
    @Binding var isMoreOptionsShown: Bool
    @Binding var isImportSheetPresented: Bool
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
    @AppStorage("Version Dismissed") var versionDismissed: String = ""
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
                
                if let url = URL(string: "https://github.com/Random-Meow1/discussions-app/issues/new") {
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
                
                Button {
                    withAnimation(.snappy(duration: 0.5)) {
                        versionDismissed = ""
                    }
                } label: {
                    Label("Show what's new", systemImage: "eye")
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

private struct ImportSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isImportSheetPresented: Bool
    let pendingURL: URL?

    private var pendingLesson: Lesson? {
        guard let url = pendingURL, let dto = LessonDTO.from(url: url) else { return nil }
        return dto.toModel()
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            isImportSheetPresented = false
                        }
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                            .padding()
                            .background(.secondary.quaternary)
                            .foregroundStyle(.primary)
                            .tint(.primary)
                            .clipShape(Capsule())
                    }

                    Spacer(minLength: 0)

                    Button {
                        if let lesson = pendingLesson {
                            modelContext.insert(lesson)
                            try? modelContext.save()
                        }
                        withAnimation(.snappy(duration: 0.5)) {
                            isImportSheetPresented = false
                        }
                    } label: {
                        Label("Import Lesson", systemImage: "square.and.arrow.down")
                            .padding()
                            .background(.secondary.quaternary)
                            .foregroundStyle(.tint)
                            .tint(.accentColor)
                            .clipShape(Capsule())
                    }
                    .disabled(pendingLesson == nil)
                }

                if let lesson = pendingLesson {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ready to import:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(lesson.title.isEmpty ? "Untitled Lesson" : lesson.title)
                            .font(.title2.bold())

                        if !lesson.subtitle.isEmpty {
                            Text(lesson.subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        Text("\(lesson.Sections.count) section\(lesson.Sections.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.secondary.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Invalid Import Link")
                            .font(.headline)
                            .foregroundStyle(.red)

                        Text("The shared link is corrupt or could not be parsed.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.secondary.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding()
            .background(.secondary.quaternary)
            .foregroundStyle(.primary)
            .tint(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding()
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
                    .contextMenu {
                        Button {
                            modelContext.insert(Lesson(title: lesson.title, subtitle: lesson.subtitle, Sections: lesson.Sections, dateCreated: Date.now, timesOpened: 0))
                        } label: {
                            Label("Duplicate", systemImage: "document.on.document")
                        }
                        
                        if let shareURL = LessonDTO(from: lesson).shareableURL {
                            ShareLink(
                                item: shareURL,
                                subject: Text("\(lesson.title)"),
                                message: Text("\(lesson.title)\n\(lesson.subtitle)")
                            ) {
                                Label("Share...", systemImage: "square.and.arrow.up")
                            }
                        }
                        
                        Divider()
                        
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
                    Text("\(lesson.Sections.count) section\(lesson.Sections.count == 1 ? "" : "s")")
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
    @State private var isWarningShown: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Version \(version)\(testingMode ? " (Testing mode, show info is \(showInfo ? "ON" : "OFF"))" : "")")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        isWarningShown.toggle()
                    }
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.tint)
                }
            }
            if isWarningShown {
                Text("There may be some bugs while in beta. Do not completely rely on Discussions to save your lessons while the app is still pre-release.")
                    .font(.caption.monospaced())
                    .foregroundStyle(.primary)
                    .padding(.top, 4)
            }
        }
        .padding(8)
    }
}

#Preview {
    ContentView()
}
