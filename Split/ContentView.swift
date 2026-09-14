import SwiftUI
import Playgrounds
import SwiftData

@main struct MyApp: App {
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
    
    init(title: String = "", subtitle: String = "", Sections: [Section] = [], dateCreated: Date = Date.now) {
        self.title = title
        self.subtitle = subtitle
        self.Sections = Sections
        self.dateCreated = dateCreated
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
}

struct Resource: Codable, Identifiable {
    var id: UUID = UUID()
    var link: String = ""
    var displayText: String = ""
}

struct ContentView: View {
    @Query var lessons: [Lesson]
    @Environment(\.modelContext) var modelContext
    @State private var backgroundColor: Color = .accentColor
    
    func deleteDestinations(_ indexSet: IndexSet) {
        for index in indexSet {
            let lesson = lessons[index]
            modelContext.delete(lesson)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Gradient(stops: [
                        Gradient.Stop(color: .clear, location: 0.25),
                        Gradient.Stop(color: backgroundColor, location: 1)
                    ]))
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    HStack {
                        Button {
                            modelContext.insert(Lesson(title: "New Lesson", dateCreated: Date.now))
                        } label: {
                            Label("New lesson", systemImage: "plus")
                                .padding()
                                .background(.secondary.quaternary)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        
                        HStack {
                            ColorPicker("Color", selection: $backgroundColor, supportsOpacity: false)
                        }
                        .padding(11)
                        .background(.secondary.quaternary)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    ScrollView {
                        ForEach(lessons) { lesson in
                            NavigationLink(destination: EditLessonView(lesson: lesson)) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading) {
                                        Text(lesson.title)
                                            .font(.title.bold())
                                            .multilineTextAlignment(.leading)
                                        Text(lesson.subtitle)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer(minLength: 0)
                                    
                                    VStack(alignment: .trailing) {
                                        Text("\(lesson.Sections.count) sections")
                                            .font(.monospaced)
                                            .foregroundStyle(.secondary)
                                        Text("\(lesson.Sections.count) sections")
                                            .font(.monospaced)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .tint(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.secondary.quaternary)
                            .foregroundStyle(.white)
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
                        .onDelete(perform: deleteDestinations)
                    }
                }
                .navigationTitle("Lessons")
                .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}

#Playground {
    _ = 1 + 2
}
