import SwiftUI

struct NexusView: View {
    @EnvironmentObject var gemini: GeminiClient
    @EnvironmentObject var store: AppStore
    @EnvironmentObject var router: Router
    @State private var messages = [ChatMessage(isUser: false, text: "Salut Melik 👋 Je suis Nexus. Dis-moi ce dont tu as besoin.")]
    @State private var input = ""

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                MascotView(thinking: gemini.isThinking, size: 90).padding(.top, 8)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(messages) { m in bubble(m).id(m.id) }
                            if gemini.isThinking { Text("Nexus réfléchit…").font(.caption).foregroundStyle(.secondary).id("thinking") }
                        }.padding()
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last { withAnimation { proxy.scrollTo(last.id, anchor: .bottom) } }
                    }
                }
                inputBar
            }
        }
        .hideKeyboardOnTap()
        .onAppear {
            if let p = router.pendingPrompt { router.pendingPrompt = nil; send(p) }
        }
    }

    private func bubble(_ m: ChatMessage) -> some View {
        HStack {
            if m.isUser { Spacer(minLength: 50) }
            Text(m.text)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .foregroundStyle(m.isUser ? Color.black : Color.white)
                .background { if m.isUser { RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color.white) } }
                .modifier(BubbleGlass(enabled: !m.isUser))
            if !m.isUser { Spacer(minLength: 50) }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 6) {
            DictationButton(text: $input)
            TextField("Parle à Nexus…", text: $input, axis: .vertical).lineLimit(1...4).submitLabel(.send)
                .onSubmit { send(input) }
            Button { send(input) } label: { Image(systemName: "arrow.up.circle.fill").font(.title) }
                .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || gemini.isThinking)
        }
        .padding(.horizontal, 10).padding(.vertical, 6).glassCard(30).padding(.horizontal).padding(.bottom, 6)
    }

    private func send(_ text: String) {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        messages.append(ChatMessage(isUser: true, text: t))
        input = ""
        Task {
            do {
                let r = try await gemini.chat(history: messages, store: store)
                messages.append(ChatMessage(isUser: false, text: r))
            } catch {
                messages.append(ChatMessage(isUser: false, text: "⚠️ \(error.localizedDescription)"))
            }
        }
    }
}

private struct BubbleGlass: ViewModifier {
    let enabled: Bool
    func body(content: Content) -> some View {
        if enabled { content.glassCard(20) } else { content }
    }
}
