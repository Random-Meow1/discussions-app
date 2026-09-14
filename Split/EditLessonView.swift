import SwiftUI
import SwiftData

struct EditLessonView: View {
    @Bindable var lesson: Lesson

    var body: some View {
        NavigationStack {
            List {
                TextField("Title", text: $lesson.title, axis: .vertical)
                    .font(.largeTitle.bold())
                
                TextField("Subtitle", text: $lesson.subtitle, axis: .vertical)
                    .font(.subheadline)

                ForEach($lesson.Sections) { $section in
                    EditSectionView(section: $section)
                }
                .onDelete(perform: deleteSection)
            }
            .listStyle(.plain)
            .navigationTitle("Editing \"\(lesson.title)\"")
            .navigationBarTitleDisplayMode(.inline)
            .navigationSubtitle("Created \(lesson.dateCreated, style: .relative) ago")
            .toolbar {
                ToolbarItem {
                    Button {
                        withAnimation {
                            lesson.Sections.append(Section())
                        }
                    } label: {
                        Label("New Section", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func deleteSection(at offsets: IndexSet) {
        lesson.Sections.remove(atOffsets: offsets)
    }
}

struct EditSectionView: View {
    @Binding var section: Section
    
    var body: some View {
        VStack {
            TextField("Header", text: $section.header, axis: .vertical)
                .font(.headline)
            TextField("Content", text: $section.content, axis: .vertical)
                .font(.body)
            TextField("Notes", text: $section.notes, axis: .vertical)
                .font(.caption)
            
            Divider()
            
            Toggle("Question", isOn: $section.isQuestion)
            if section.isQuestion {
                Toggle("Open-Ended", isOn: $section.isOpenEndedQuestion)
            }
            if section.isQuestion && !section.isOpenEndedQuestion {
                TextField("Answer", text: $section.answer, axis: .vertical)
                    .bold()
            }
            
            Divider()
            
            VStack {
                VStack(alignment: .leading) {
                    Button {
                        section.resources.append(Resource())
                    } label: {
                        Label("Add Resource", systemImage: "link")
                            .padding(8)
                            .background(.secondary.quaternary)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                ForEach($section.resources) { $resource in
                    HStack {
                        TextField("Link", text: $resource.link)
                        Divider()
                        TextField("Display Text", text: $resource.displayText)
                        Button(role: .destructive) {
                            section.resources.removeAll { $0.id == resource.id }
                        } label: {
                            Image(systemName: "minus")
                                .foregroundStyle(.red)
                                .padding()
                                .background(.secondary.quaternary)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        if !resource.link.isEmpty {
                            Link(destination: URL(string: resource.link)!) {
                                Image(systemName: "arrow.up.right")
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                    .background(.secondary.quaternary)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.secondary.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    EditLessonView(lesson: Lesson(title: "Why Swift is the best programming language", subtitle: "This is a great introduction to Swift", Sections: [
                Section(
                    header: "Introduction to Swift",
                    content: "Swift is a powerful and intuitive programming language developed by Apple for iOS, macOS, watchOS, and tvOS.",
                    notes: "Mention that Swift is open source.",
                    isQuestion: false,
                    isOpenEndedQuestion: false,
                    answer: "",
                    resources: [Resource(link: "swift.org", displayText: "Swift Website")]
                ),
                Section(
                    header: "Safety and Performance",
                    content: "Swift eliminates entire classes of unsafe code. Variables are always initialized before use, arrays and integers are checked for overflow, and memory is managed automatically.",
                    notes: "Compare this to Objective-C's manual memory management.",
                    isQuestion: false,
                    isOpenEndedQuestion: false,
                    answer: "",
                    resources: []
                ),
                Section(
                    header: "What makes Swift fast?",
                    content: "Swift uses the high-performance LLVM compiler technology to transform your code into optimized native code.",
                    notes: "Ask the students to guess which language Swift is often compared to in terms of speed.",
                    isQuestion: true,
                    isOpenEndedQuestion: true,
                    answer: "C++",
                    resources: []
                )
            ], dateCreated: Date.now))
//    let container: ModelContainer = {
//        do {
//            let config = ModelConfiguration(isStoredInMemoryOnly: true)
//            return try ModelContainer(for: Lesson.self, configurations: config)
//        } catch {
//            
//        }
//    }()
//    let example = Lesson(title: "Why Swift is the best programming language", subtitle: "This is a great introduction to Swift", Sections: [
//        Section(
//            header: "Introduction to Swift",
//            content: "Swift is a powerful and intuitive programming language developed by Apple for iOS, macOS, watchOS, and tvOS.",
//            notes: "Mention that Swift is open source.",
//            isQuestion: false,
//            isOpenEndedQuestion: false,
//            answer: "",
//            links: []
//        ),
//        Section(
//            header: "Safety and Performance",
//            content: "Swift eliminates entire classes of unsafe code. Variables are always initialized before use, arrays and integers are checked for overflow, and memory is managed automatically.",
//            notes: "Compare this to Objective-C's manual memory management.",
//            isQuestion: false,
//            isOpenEndedQuestion: false,
//            answer: "",
//            links: []
//        ),
//        Section(
//            header: "What makes Swift fast?",
//            content: "Swift uses the high-performance LLVM compiler technology to transform your code into optimized native code.",
//            notes: "Ask the students to guess which language Swift is often compared to in terms of speed.",
//            isQuestion: true,
//            isOpenEndedQuestion: true,
//            answer: "C++",
//            links: []
//        )
//    ], dateCreated: Date.now, dateModified: Date.now)
//    return EditLessonView(lesson: example)
//        .modelContainer(container)
}
