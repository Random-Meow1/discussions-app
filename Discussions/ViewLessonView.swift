//
//  Created by Random Meow on 9/15/26.
//  You may use any code here, as long as you give credit. Thanks!
    

import SwiftUI

struct ViewLessonView: View {
    @Bindable var lesson: Lesson
    @State private var pressedShow: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView(.vertical) {
                        LazyVStack(spacing: 22) {
                            ForEach($lesson.Sections) { $section in
                                VStack(alignment: .leading) {
                                    HStack {
                                        if !section.header.isEmpty {
                                            Text(section.header)
                                                .font(.headline)
                                                .padding(.bottom, section.isShown ? 10 : 0)
                                        } else if !section.content.isEmpty && !section.isShown {
                                            Text("\(section.content.split(separator: "").prefix(30).joined(separator: ""))...")
                                        }
                                        
                                        if section.isShown {
                                            Spacer(minLength: 0)
                                        }
                                    }
                                    if section.isShown {
                                        if !section.content.isEmpty {
                                            Text(section.content)
                                                .font(section.isQuestion ? .title.bold() : .body)
                                                .padding(.bottom, 10)
                                        }
                                        
                                        if !section.notes.isEmpty {
                                            Text(section.notes)
                                                .font(.caption)
                                                .padding(.bottom, 10)
                                        }
                                        
                                        if section.isQuestion && !section.isOpenEndedQuestion {
                                            Button {
                                                withAnimation(.spring(duration: 0.5)) {
                                                    section.isAnswerShown.toggle()
                                                }
                                            } label: {
                                                Label("\(section.isAnswerShown ? "Hide" : "Show") Answer", systemImage: "eye")
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
                                        
                                        if !section.resources.isEmpty {
                                            ForEach(section.resources) { resource in
                                                Link(destination: URL(string: resource.link)!) {
                                                    if !resource.displayText.isEmpty {
                                                        Label(resource.displayText, systemImage: "arrow.up.right")
                                                            .padding()
                                                            .background(.secondary.quaternary)
                                                            .foregroundStyle(.primary)
                                                            .tint(.primary)
                                                            .clipShape(Capsule())
                                                    } else {
                                                        Label(resource.link, systemImage: "arrow.up.right")
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
                                .onTapGesture {
                                    pressedShow.toggle()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        withAnimation(.spring(duration: 0.5)) {
                                            section.isShown.toggle()
                                        }
                                    }
                                }
                                .onAppear {
                                    withAnimation(.spring(duration: 0.5)) {
                                        section.isShown = true
                                    }
                                }
                                .onDisappear {
                                    withAnimation(.spring(duration: 0.5)) {
                                        section.isShown = false
                                    }
                                }
                                .scrollTransition(
                                    axis: .vertical
                                ) { content, phase in
                                    content
//                                        .opacity((abs(phase.value) * -1) + 1)
//                                        .scaleEffect((abs(phase.value) * -1) + 1)
                                }
                                .padding()
                                .frame(minHeight: section.isShown ? 200 : 20, maxHeight: section.isShown ? .infinity : 100)
                                .background(.secondary.quaternary)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .padding(.bottom, 20)
                            }
                            .onChange(of: pressedShow) {
                                withAnimation(.spring(duration: 0.5)) {
                                    for index in lesson.Sections.indices {
                                        lesson.Sections[index].isShown = false
                                    }
                                }
                            }
                        }
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
}

#Preview {
    ViewLessonView(lesson: Lesson(title: "Why Swift is the best programming language", subtitle: "This is a great introduction to Swift", Sections: [
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
            header: "",
            content: "What makes Swift fast?",
            notes: "Ask the students to guess which language Swift is often compared to in terms of speed.",
            isQuestion: true,
            isOpenEndedQuestion: false,
            answer: "C++",
            resources: []
        ),
        Section(
            header: "",
            content: "",
            isQuestion: false,
            isOpenEndedQuestion: false,
            answer: "",
            resources: [Resource(link: "swift.org", displayText: "Swift Website")]
        ),
        Section(
            header: "",
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
        ),
        Section(
            header: "Introduction to Swift",
            content: "",
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
        ),
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
}
