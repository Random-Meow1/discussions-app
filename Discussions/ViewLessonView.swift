import SwiftUI

struct ViewLessonView: View {
    @Bindable var lesson: Lesson
    @State private var pressedShow: Bool = false
    @State private var visibleSectionID: UUID?
    @State private var activeSectionID: UUID?
    
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 0) {
                            ForEach($lesson.Sections) { $section in
                                SectionCardView(section: $section, onMidYChange: { midY in
                                    checkIfCentered(id: section.id, midY: midY)
                                })
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $visibleSectionID)
                    .scrollTargetBehavior(.paging)
                    .onChange(of: visibleSectionID) { oldValue, newValue in
                        updateShownSection(id: newValue)
                    }
                }
                .navigationTitle("\(lesson.title)")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .padding()
            }
        }
    }
    
    func checkIfCentered(id: UUID, midY: CGFloat) {
        let centerThreshold: CGFloat = screenHeight / 4
        let isCentered = abs(midY - (screenHeight / 2)) < centerThreshold
        
        if isCentered {
            if activeSectionID != id {
                activeSectionID = id
                updateShownSection(id: id)
            }
        } else if activeSectionID == id {
            activeSectionID = nil
            updateShownSection(id: nil)
        }
    }
    
    func updateShownSection(id: UUID?) {
        for index in lesson.Sections.indices {
            withAnimation(.spring(duration: 0.5)) {
                lesson.Sections[index].isShown = (lesson.Sections[index].id == id)
            }
        }
    }
}

// MARK: - Extracted Component Views

private struct SectionCardView: View {
    @Binding var section: Section
    let onMidYChange: (CGFloat) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            SectionHeaderView(section: section)
            
            if section.isShown {
                SectionContentView(section: $section)
            }
        }
        .padding()
        .id(section.id)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.frame(in: .global).midY) { _, newY in
                        onMidYChange(newY)
                    }
            }
        )
        .frame(minHeight: section.isShown ? 200 : 20, maxHeight: section.isShown ? .infinity : 100)
        .background(.secondary.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .containerRelativeFrame(.vertical)
    }
}

private struct SectionHeaderView: View {
    let section: Section

    var body: some View {
        HStack {
            if !section.header.isEmpty {
                Text(section.header)
                    .font(.headline)
                    .padding(.bottom, section.isShown ? 10 : 0)
            } else if !section.content.isEmpty && !section.isShown {
                let previewText = section.content.prefix(30)
                Text("\(previewText)...")
            }
            
            if section.isShown {
                Spacer(minLength: 0)
            }
        }
    }
}

private struct SectionContentView: View {
    @Binding var section: Section

    var body: some View {
        if !section.content.isEmpty {
            let contentFontSize = CGFloat(100 - section.content.count)
            Text(section.content)
                .font(.system(size: contentFontSize > 24 ? contentFontSize : 24))
                .padding(.bottom, 10)
        }
        
        if !section.notes.isEmpty {
            Text(section.notes)
                .font(.caption)
                .padding(.bottom, 10)
        }
        
        if section.isQuestion && !section.isOpenEndedQuestion {
            QuestionAnswerView(section: $section)
        }
        
        Spacer(minLength: 0)
        
        if !section.resources.isEmpty {
            ResourcesListView(resources: section.resources)
        }
    }
}

private struct QuestionAnswerView: View {
    @Binding var section: Section

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1)) {
                section.isAnswerShown.toggle()
            }
        } label: {
            Label("\(section.isAnswerShown ? "Hide" : "Show") Answer", systemImage: "eye\(section.isAnswerShown ? ".slash" : "")")
                .padding()
                .background(.secondary.quaternary)
                .foregroundStyle(.primary)
                .tint(.primary)
                .clipShape(Capsule())
        }
        
        if !section.answer.isEmpty && section.isAnswerShown {
            Divider()
            Text(section.answer)
                .font(.title.bold())
                .padding(.bottom, 10)
        }
    }
}

private struct ResourcesListView: View {
    let resources: [Resource]

    var body: some View {
        ForEach(resources) { resource in
            if let url = URL(string: resource.link) {
                Link(destination: url) {
                    let labelText = resource.displayText.isEmpty ? resource.link : resource.displayText
                    Label(labelText, systemImage: "arrow.up.right")
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

#Preview {
    ViewLessonView(lesson: Lesson(
        title: "Why Swift is the Best Programming Language",
        subtitle: "Exploring the features that make Swift powerful and modern.",
        Sections: [
            Section(id: UUID(), header: "Introduction to Swift", content: "Swift is a fast, safe, and modern language developed by Apple.", notes: "Mention its release in 2014.", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false),
            Section(id: UUID(), header: "Safety Features", content: "Swift eliminates entire classes of unsafe code.", notes: "", isQuestion: true, isOpenEndedQuestion: false, answer: "Optionals and type safety.", resources: [], isShown: true, isAnswerShown: false),
            Section(id: UUID(), header: "Performance", content: "Swift is incredibly fast, often matching C++ performance. Its modern syntax allows developers to write clean and maintainable code efficiently. The language prioritizes safety by eliminating entire classes of common programming errors. Additionally, Swift provides seamless interoperability with existing Objective-C codebases. This makes it an ideal choice for building high-performance applications across all Apple platforms.", notes: "", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [Resource(id: UUID(), link: "https://swift.org", displayText: "Official Swift Website")], isShown: true, isAnswerShown: false),
            Section(id: UUID(), header: "Modern Syntax", content: "The syntax is clean and easy to read.", notes: "", isQuestion: true, isOpenEndedQuestion: true, answer: "", resources: [], isShown: true, isAnswerShown: false),
            Section(id: UUID(), header: "Community", content: "Swift is open source with a vibrant community.", notes: "", isQuestion: false, isOpenEndedQuestion: false, answer: "", resources: [], isShown: true, isAnswerShown: false)
        ],
        dateCreated: Date.now,
        timesOpened: 2
    ))
}
