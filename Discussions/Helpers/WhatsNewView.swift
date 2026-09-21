import SwiftUI

struct WhatsNewView: View {
    @AppStorage("Version Dismissed") var versionDismissed: String = ""
    private var notes: String = """
        Bug fixes
        Improvements to scrolling and transitions when viewing lessons
        All new editing features for editing lessons
        Duplicate lessons
        Share lessons with an import link
        New link for sending feedback
        A new "What's new" feature
        """
    
    var body: some View {
        if versionDismissed != version {
            HStack {
                VStack(alignment: .leading) {
                    Text("What's new in Version \(version)")
                        .font(.title.bold())
                        .padding(.bottom, 4)
                    
                    ForEach(notes.split(separator: "\n"), id: \.self) { note in
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark")
                            Text(note)
                        }
                    }
                    
                    Text("You can bring this up again by going to **More > Show what's new**")
                        .padding(.vertical, 4)
                        .font(.caption)
                    
                    Button {
                        withAnimation(.snappy(duration: 0.5)) {
                            versionDismissed = version
                        }
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                            .padding()
                            .background(.secondary.quaternary)
                            .foregroundStyle(.primary)
                            .tint(.primary)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer(minLength: 0)
            }
            .tint(.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.secondary.quaternary)
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }
}

#Preview {
    WhatsNewView()
}
