//
//  CategoriesView.swift
//  HoldingPattern
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WaitCategoryModel.sortOrder) private var categories: [WaitCategoryModel]
    @State private var showAddCategory = false
    @State private var newCategoryName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.gradientBackground.ignoresSafeArea()
                List {
                    ForEach(categories) { cat in
                        HStack(spacing: 12) {
                            Image(systemName: categoryIcon(cat))
                                .font(.system(size: 18))
                                .foregroundStyle(AppTheme.accentPrimary)
                                .frame(width: 28, alignment: .center)
                            Text(displayName(cat))
                                .foregroundStyle(AppTheme.textPrimary)
                            Spacer()
                            if cat.kind == .custom {
                                Button(role: .destructive) {
                                    modelContext.delete(cat)
                                    try? modelContext.save()
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                        .foregroundStyle(AppTheme.negative.opacity(0.9))
                                }
                            }
                        }
                        .listRowBackground(AppTheme.backgroundCard)
                        .listRowSeparatorTint(AppTheme.textMuted.opacity(0.25))
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppTheme.backgroundMid, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddCategory = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.accentPrimary)
                    }
                }
            }
            .onAppear {
                if categories.isEmpty {
                    for cat in WaitCategoryModel.systemCategories() {
                        modelContext.insert(cat)
                    }
                    try? modelContext.save()
                }
            }
            .alert("New Category", isPresented: $showAddCategory) {
                TextField("Name", text: $newCategoryName)
                Button("Cancel", role: .cancel) {
                    newCategoryName = ""
                }
                Button("Add") {
                    addCustomCategory()
                    newCategoryName = ""
                }
                .disabled(newCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
            } message: {
                Text("Add a custom wait category.")
            }
        }
    }

    private func displayName(_ cat: WaitCategoryModel) -> String {
        cat.kind == .custom ? cat.name : String(localized: String.LocalizationValue(cat.name))
    }

    private func categoryIcon(_ cat: WaitCategoryModel) -> String {
        switch cat.kind {
        case .physical: return "figure.walk"
        case .digital: return "laptopcomputer"
        case .social: return "person.2"
        case .decision: return "checkmark.circle"
        case .passiveIdle: return "moon.zzz"
        case .custom: return "tag"
        }
    }

    private func addCustomCategory() {
        let name = newCategoryName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let maxOrder = categories.map(\.sortOrder).max() ?? -1
        let newCat = WaitCategoryModel(name: name, kind: .custom, sortOrder: maxOrder + 1)
        modelContext.insert(newCat)
        try? modelContext.save()
    }
}
