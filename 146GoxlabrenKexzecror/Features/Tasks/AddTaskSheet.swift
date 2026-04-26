//
//  AddTaskSheet.swift
//  146GoxlabrenKexzecror
//

import SwiftUI

struct AddTaskSheet: View {
    @EnvironmentObject private var app: AppData
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var notes = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case title
        case notes
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedTitle.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background
                    .ignoresSafeArea()
                AppFloatingOrbs()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        heroHeader

                        fieldBlock(
                            label: "Title",
                            hint: "What you’ll do next.",
                            content: {
                                TextField("e.g. Draft the outline", text: $title)
                                    .textFieldStyle(.plain)
                                    .focused($focusedField, equals: .title)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .notes }
                            }
                        )

                        fieldBlock(
                            label: "Details",
                            hint: "Optional context.",
                            content: {
                                TextField("Add notes…", text: $notes, axis: .vertical)
                                    .textFieldStyle(.plain)
                                    .focused($focusedField, equals: .notes)
                                    .lineLimit(3...6)
                            }
                        )

                        if !trimmedTitle.isEmpty {
                            previewCard
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
                .appScreenBackground()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New task")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(AppColor.textPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColor.textSecondary)
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveBar
            }
        }
        .tint(AppColor.primary)
        .presentationDragIndicator(.visible)
        .onAppear { focusedField = .title }
    }

    private var heroHeader: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppColor.primary.opacity(0.45), AppColor.accent.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(AppVisual.cardBorderGradient(strong: false), lineWidth: 1)
                    )
                    .shadow(color: AppColor.primary.opacity(0.35), radius: 10, y: 4)
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Capture it")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, AppColor.primary.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("A title is enough to land it on your list.")
                    .font(.caption.weight(.medium))
                    .foregroundColor(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }

    private func fieldBlock(
        label: String,
        hint: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColor.accent)
                .textCase(.uppercase)
                .tracking(0.6)
            content()
                .font(.body)
                .foregroundColor(AppColor.textPrimary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCardChrome(cornerRadius: 16, style: .hero)
            Text(hint)
                .font(.caption)
                .foregroundColor(AppColor.textSecondary)
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Preview", systemImage: "eye.fill")
                .font(.caption.weight(.semibold))
                .foregroundColor(AppColor.textSecondary)
            Text(trimmedTitle)
                .font(.headline.weight(.semibold))
                .foregroundColor(AppColor.textPrimary)
                .lineLimit(2)
            if !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundColor(AppColor.textSecondary)
                    .lineLimit(4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardChrome(cornerRadius: 16, style: .showcase)
    }

    private var saveBar: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.clear, AppColor.background.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            VStack(spacing: 12) {
                Button {
                    guard canSave else { return }
                    Haptics.lightImpact()
                    app.addUserTask(title: trimmedTitle, notes: notes)
                    dismiss()
                } label: {
                    Text("Save to list")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 52)
                        .foregroundColor(AppColor.textPrimary)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppVisual.primaryButtonFill)
                                .opacity(canSave ? 1 : 0.45)
                        )
                        .shadow(
                            color: canSave ? AppColor.primary.opacity(0.45) : Color.clear,
                            radius: 14,
                            y: 5
                        )
                }
                .disabled(!canSave)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .background(AppColor.background.opacity(0.98))
        }
    }
}

#Preview {
    AddTaskSheet()
        .environmentObject(AppData())
}
