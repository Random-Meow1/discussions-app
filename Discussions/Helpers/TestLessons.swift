import SwiftUI

let testLessons: [Lesson] = [
    // MARK: - Lesson 1: How to Video Edit
    Lesson(
        title: "Mastering Video Editing",
        subtitle: "From raw footage to a polished final cut.",
        Sections: [
            Section(
                header: "Organizing Your Media",
                content: "Before trimming a single frame, import your footage into organized bins or folders. Name files logically (e.g., Scene1_A_Cam) to avoid confusion later during complex cuts.",
                notes: "Always back up raw footage to an external drive before starting.",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [
                    Resource(link: "https://example.com/asset-management", displayText: "File Organization Guide")
                ],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "The Assembly Cut",
                content: "Place all your usable clips onto the timeline in chronological order. Don't worry about pacing, smooth transitions, or audio mixing yet; the goal is simply establishing the narrative baseline.",
                notes: "",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "Trimming and Pacing",
                content: "Cut out long pauses, filler words, and awkward movements. Pacing dictates the mood: quick cuts create high urgency, while slow transitions evoke calm or lingering emotion.",
                notes: "Use the 'J-cut' and 'L-cut' techniques to blend audio across scene boundaries.",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [
                    Resource(link: "https://example.com/j-l-cuts", displayText: "J-Cut vs L-Cut Video Tutorial")
                ],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "Knowledge Check: Cut Types",
                content: "What is the primary difference between a J-cut and an L-cut?",
                notes: "Review section 3 if you're unsure.",
                isQuestion: true,
                isOpenEndedQuestion: true,
                answer: "In a J-cut, the audio from the next clip starts before the video changes. In an L-cut, the video changes first while the audio from the previous clip continues playing.",
                resources: [],
                isShown: true,
                isAnswerShown: true
            ),
            Section(
                header: "Color Grading & Export",
                content: "Apply basic exposure and color correction so clips match visually. Once satisfied, export using settings optimized for your destination platform (e.g., H.264 for YouTube).",
                notes: "",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [],
                isShown: false,
                isAnswerShown: false
            )
        ],
        timesOpened: 4
    ),

    // MARK: - Lesson 2: Why Swift is the Best Programming Language
    Lesson(
        title: "The Case for Swift",
        subtitle: "Expressive, fast, and safe by design.",
        Sections: [
            Section(
                header: "Safety First: Optionals & Type Safety",
                content: "Swift eliminates entire classes of bugs at compile time through strict type checking and Optionals. Instead of dealing with unexpected null pointer exceptions at runtime, developers explicitly handle missing values.",
                notes: "",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "Modern Syntax",
                content: "Swift reads like natural English.",
                notes: "Compare Swift closures with C function pointers to demonstrate clarity.",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [
                    Resource(link: "https://swift.org/documentation/", displayText: "Swift API Design Guidelines")
                ],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "High Performance",
                content: "Swift uses the LLVM compiler toolchain to optimize code directly into high-speed machine instructions. It delivers performance comparable to C++ without sacrificing modern memory safety guarantees through Automatic Reference Counting (ARC).",
                notes: "",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "Self-Assessment",
                content: "Which memory management model does Swift use to track and manage app memory usage?",
                notes: "",
                isQuestion: true,
                isOpenEndedQuestion: false,
                answer: "Automatic Reference Counting (ARC)",
                resources: [],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "Open Source and Cross-Platform Potential",
                content: "Since going open-source in 2015, Swift's footprint expanded beyond Apple's ecosystem into Linux server-side development, embedded systems, and Windows, supported by a growing global developer community.",
                notes: "Mention Vapor framework briefly.",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [
                    Resource(link: "https://www.vapor.codes", displayText: "Vapor Web Framework"),
                    Resource(link: "https://github.com/swiftlang/swift", displayText: "Swift GitHub Repository")
                ],
                isShown: true,
                isAnswerShown: false
            )
        ],
        timesOpened: 12
    ),

    // MARK: - Lesson 3: How Apple Focuses on Privacy
    Lesson(
        title: "Apple's Approach to User Privacy",
        subtitle: "Privacy as a fundamental human right.",
        Sections: [
            Section(
                header: "On-Device Processing",
                content: "Apple minimizes data collection by processing personal data directly on the user's device whenever possible. Features like Siri suggestions, photo categorization, and keyboard text prediction rely on the Neural Engine rather than sending private activity to remote servers.",
                notes: "Key principle: Bring the computation to the data, not the data to the computation.",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [
                    Resource(link: "https://www.apple.com/privacy/", displayText: "Apple Privacy Overview")
                ],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "App Tracking Transparency (ATT)",
                content: "ATT requires third-party applications to obtain explicit user consent before tracking their activity across other companies' apps or websites for targeted advertising.",
                notes: "",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "Differential Privacy",
                content: "To improve services without identifying individuals, Apple injects mathematical noise into collected dataset patterns. This allows statistical trend analysis across millions of devices without exposing any single user's raw data.",
                notes: "",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [
                    Resource(link: "https://www.apple.com/privacy/docs/Differential_Privacy_Overview.pdf", displayText: "Differential Privacy Whitepaper")
                ],
                isShown: true,
                isAnswerShown: false
            ),
            Section(
                header: "Private Relay and Mail Privacy Protection",
                content: "iCloud Private Relay uses a dual-hop architecture so no single party—including Apple—can see both a user's IP address and the site they visit.",
                notes: "",
                isQuestion: false,
                isOpenEndedQuestion: false,
                answer: "",
                resources: [],
                isShown: false,
                isAnswerShown: false
            ),
            Section(
                header: "Privacy Checkpoint",
                content: "Explain how Differential Privacy protects individual identities while allowing statistical data collection.",
                notes: "Grade based on understanding of mathematical noise.",
                isQuestion: true,
                isOpenEndedQuestion: true,
                answer: "Differential privacy adds random noise to data before sending it to servers, masking individual identities while preserving overall user behavior patterns.",
                resources: [],
                isShown: true,
                isAnswerShown: true
            )
        ],
        timesOpened: 1
    )
]
