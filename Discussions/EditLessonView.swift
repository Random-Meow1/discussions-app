import SwiftUI
import SwiftData

struct EditLessonView: View {
    @Bindable var lesson: Lesson
    @FocusState private var focusedField
    @State private var isDeletingSection: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    TextField("Title", text: $lesson.title, axis: .vertical)
                        .font(.largeTitle.bold())
                        .focused($focusedField)
                    
                    TextField("Subtitle", text: $lesson.subtitle, axis: .vertical)
                        .font(.subheadline)
                        .focused($focusedField)
                    
                    if !isDeletingSection && !lesson.Sections.isEmpty {
                        ForEach($lesson.Sections) { $section in
                            EditSectionView(section: $section)
                                .focused($focusedField)
                            
                            Button(role: .destructive) {
                                Task {
                                    withAnimation(.smooth(duration: 0.02)) {
                                        isDeletingSection = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        lesson.Sections.removeAll { $0.id == section.id }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            withAnimation(.smooth(duration: 0.02)) {
                                                isDeletingSection = false
                                            }
                                        }
                                    }
                                }
                            } label : {
                                Label("Delete", systemImage: "trash")
                                    .padding()
                                    .background(.secondary.quaternary)
                                    .foregroundStyle(.primary)
                                    .tint(.primary)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom)
                        }
                    } else {
                        Text(isDeletingSection ? "Deleting section..." : "Add a section with +")
                    }
                }
                .padding()
                .listStyle(.plain)
                .navigationTitle("Editing \"\(lesson.title)\"")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationSubtitle("Created \(lesson.dateCreated, style: .relative) ago")
                .toolbar {
                    ToolbarItem {
                        Button {
                            withAnimation {
                                lesson.Sections.append(Section(resources: [Resource()]))
                            }
                        } label: {
                            Label("New Section", systemImage: "plus")
                        }
                    }
                    
                    ToolbarItem {
                        NavigationLink(destination: ViewLessonView(lesson: lesson)) {
                            Label("View", systemImage: "play.fill")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer(minLength: 0)
                        Button {
                            focusedField = false
                        } label: {
                            Label("Done", systemImage: "checkmark")
                        }
                    }
                }
                .onAppear {
                    lesson.timesOpened += 1
                }
            }
        }
    }

    private func deleteSection(at offsets: IndexSet) {
        Task {
            withAnimation(.smooth(duration: 0.02)) {
                isDeletingSection = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                lesson.Sections.remove(atOffsets: offsets)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation(.smooth(duration: 0.02)) {
                        isDeletingSection = false
                    }
                }
            }
        }
    }
}

struct EditSectionView: View {
    @Binding var section: Section
    
    var body: some View {
        VStack {
            TextField("Header", text: $section.header, axis: .vertical)
                .font(.headline)
                .padding(.bottom, 8)
            TextField("Content", text: $section.content, axis: .vertical)
                .font(.body)
                .padding(.bottom, 8)
                .lineLimit(5...Int.max)
            TextField("Notes", text: $section.notes, axis: .vertical)
                .font(.caption)
                .padding(.bottom, 8)
            
            Divider()
                .padding(.bottom, 8)
            
            Toggle("Question", isOn: $section.isQuestion)
                .padding(.bottom, 8)
            if section.isQuestion {
                Toggle("Open-Ended", isOn: $section.isOpenEndedQuestion)
                    .padding(.bottom, 8)
            }
            if section.isQuestion && !section.isOpenEndedQuestion {
                TextField("Answer", text: $section.answer, axis: .vertical)
                    .bold()
                    .padding(.bottom, 8)
            }
            
            Divider()
                .padding(.bottom, 8)
            
            VStack {
                HStack {
                    Button {
                        section.resources.append(Resource())
                    } label: {
                        Label("Add Resource", systemImage: "link")
                            .padding(8)
                            .background(.secondary.quaternary)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    
                    Spacer(minLength: 0)
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
                    .padding(.vertical, 2)
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
