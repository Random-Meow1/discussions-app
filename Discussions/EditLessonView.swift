import SwiftUI
import SwiftData

struct EditLessonView: View {
    @Bindable var lesson: Lesson
    @FocusState private var focusedField: Bool
    @State private var copiedSection: Section = Section()
    @State private var isDeletingSection: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    headerSection
                    
                    if !isDeletingSection && !lesson.Sections.isEmpty {
                        sectionsList
                    } else {
                        Text(isDeletingSection ? "Deleting section..." : "")
                    }
                    
                    HStack {
                        Button {
                            addSection(section: Section())
                        } label: {
                            Label("Add section", systemImage: "plus")
                                .padding()
                                .background(.secondary.quaternary)
                                .foregroundStyle(.primary)
                                .tint(.primary)
                                .clipShape(Capsule())
                        }
                        
                        if copiedSection != Section() {
                            Button {
                                var newSection = copiedSection
                                newSection.id = UUID()
                                addSection(section: newSection)
                            } label: {
                                Label("Paste", systemImage: "document.on.clipboard")
                                    .padding()
                                    .background(.secondary.quaternary)
                                    .foregroundStyle(.primary)
                                    .tint(.primary)
                                    .clipShape(Capsule())
                            }
                            .contextMenu {
                                Button {
                                    copiedSection = Section()
                                } label: {
                                    Label("Clear copied section", systemImage: "xmark")
                                }
                            }
                        }
                    }
                }
                .padding()
                .navigationTitle("Editing \"\(lesson.title)\"")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationSubtitle("Created \(lesson.dateCreated, style: .relative) ago")
                .toolbar {
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
            .buttonStyle(.plain)
        }
    }

    private var headerSection: some View {
        VStack {
            TextField("Title", text: $lesson.title, axis: .vertical)
                .font(.largeTitle.bold())
                .focused($focusedField)
            
            TextField("Subtitle", text: $lesson.subtitle, axis: .vertical)
                .font(.subheadline)
                .focused($focusedField)
        }
    }

    private var sectionsList: some View {
        ForEach($lesson.Sections) { $section in
            HStack {
                Button {
                    addSection(section: Section())
                } label: {
                    Label("Add section", systemImage: "plus")
                        .padding()
                        .background(.secondary.quaternary)
                        .foregroundStyle(.primary)
                        .tint(.primary)
                        .clipShape(Capsule())
                }
                
                if copiedSection != Section() {
                    Button {
                        var newSection = copiedSection
                        newSection.id = UUID()
                        addSection(section: newSection)
                    } label: {
                        Label("Paste", systemImage: "document.on.clipboard")
                            .padding()
                            .background(.secondary.quaternary)
                            .foregroundStyle(.primary)
                            .tint(.primary)
                            .clipShape(Capsule())
                    }
                    .contextMenu {
                        Button {
                            copiedSection = Section()
                        } label: {
                            Label("Clear copied section", systemImage: "xmark")
                        }
                    }
                }
            }
            
            Divider()
            
            HStack {
                if let index = lesson.Sections.firstIndex(where: { $0.id == section.id }) {
                    if index > 0 {
                        Button {
                            var newSection = section
                            newSection.id = UUID()
                            removeSection(id: section.id)
                            lesson.Sections.insert(newSection, at: index - 1)
                        } label: {
                            Label("Move up", systemImage: "arrow.up")
                                .padding()
                                .background(.secondary.quaternary)
                                .foregroundStyle(.primary)
                                .tint(.primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            
            EditSectionView(section: $section)
                .focused($focusedField)
            
            HStack {
                Button(role: .destructive) {
                    removeSection(id: section.id)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .padding()
                        .background(.secondary.quaternary)
                        .foregroundStyle(.red)
                        .tint(.red)
                        .clipShape(Capsule())
                }
                
                Spacer(minLength: 0)
                
                Button {
                    var sectionToCopy = section
                    sectionToCopy.id = UUID()
                    copiedSection = sectionToCopy
                } label: {
                    Label("Copy", systemImage: "document.on.document")
                        .padding()
                        .background(.secondary.quaternary)
                        .foregroundStyle(.primary)
                        .tint(.primary)
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(.plain)
            
            Divider()
        }
    }

    func addSection(section: Section) {
        lesson.Sections.append(section)
    }

    func removeSection(id: UUID) {
        isDeletingSection = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            lesson.Sections.removeAll { $0.id == id }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                isDeletingSection = false
            }
        }
    }
}

struct EditSectionView: View {
    @Binding var section: Section
    
    var body: some View {
        VStack(alignment: .leading) {
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
            
            Divider().padding(.bottom, 8)
            
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
            
            Divider().padding(.bottom, 8)
            
            resourcesSection
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.secondary.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var resourcesSection: some View {
        VStack {
            HStack {
                Button {
                    section.resources.append(Resource())
                } label: {
                    Label("Add Resource", systemImage: "link")
                        .padding(8)
                        .background(.secondary.quaternary)
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                }
                Spacer(minLength: 0)
            }
            
            ForEach($section.resources) { $resource in
                ResourceRowView(resource: $resource, onDelete: {
                    section.resources.removeAll { $0.id == resource.id }
                })
            }
        }
    }
}

private struct ResourceRowView: View {
    @Binding var resource: Resource
    let onDelete: () -> Void

    var body: some View {
        HStack {
            TextField("Link", text: $resource.link)
            Divider()
            TextField("Display Text", text: $resource.displayText)
            
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "minus")
                    .foregroundStyle(.red)
                    .padding()
                    .background(.secondary.quaternary)
                    .clipShape(Capsule())
            }
            
            if let validURL = URL(string: resource.link), !resource.link.isEmpty {
                Link(destination: validURL) {
                    Image(systemName: "arrow.up.right")
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(.secondary.quaternary)
                        .foregroundStyle(.primary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    EditLessonView(lesson: Lesson())
}
