//
//  NoteDetailView.swift
//  Modern-SwiftUI-Bootcamp-Task-9
//
//  Created by Kürşat Şimşek on 18.09.2025.
//

import SwiftUI
import CoreData

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NoteDetailViewModel
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var hasUnsavedChanges = false

    var body: some View {
        Form {
                Section("Başlık") {
                    if isEditing {
                        TextField("Başlık girin", text: $viewModel.title)
                            .textInputAutocapitalization(.sentences)
                            .autocorrectionDisabled(false)
                            .onChange(of: viewModel.title) {
                                hasUnsavedChanges = true
                            }
                    } else {
                        Text(viewModel.title.isEmpty ? "Başlık yok" : viewModel.title)
                            .foregroundStyle(viewModel.title.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Section("İçerik") {
                    if isEditing {
                        TextEditor(text: $viewModel.content)
                            .frame(minHeight: 200)
                            .onChange(of: viewModel.content) {
                                hasUnsavedChanges = true
                            }
                    } else {
                        if viewModel.content.isEmpty {
                            Text("İçerik yok")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
                        } else {
                            Text(viewModel.content)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                    }
                }
                
                if !isEditing {
                    Section("Bilgiler") {
                        if let date = viewModel.date {
                            Label {
                                Text("Son güncelleme: \(date.formatted(date: .abbreviated, time: .shortened))")
                            } icon: {
                                Image(systemName: "clock")
                                    .foregroundStyle(.blue)
                            }
                        }
                        
                        if let id = viewModel.id {
                            Label {
                                Text("ID: \(id.uuidString)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } icon: {
                                Image(systemName: "tag")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Düzenle" : viewModel.title.isEmpty ? "Not Detayı" : viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button("Kaydet") {
                            Task {
                                do {
                                    try await viewModel.save()
                                    hasUnsavedChanges = false
                                    isEditing = false
                                } catch {
                                    print("Kaydetme hatası: \(error)")
                                }
                            }
                        }
                        .disabled(!viewModel.canSave)
                        .fontWeight(.semibold)
                    } else {
                        Button("Düzenle") {
                            isEditing = true
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if isEditing {
                        Button("Vazgeç") {
                            if hasUnsavedChanges {
                                viewModel.cancelChanges()
                                hasUnsavedChanges = false
                            }
                            isEditing = false
                        }
                    } else {
                        Menu {
                            Button("Sil", role: .destructive) {
                                showingDeleteAlert = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Notu Sil", isPresented: $showingDeleteAlert) {
                Button("Sil", role: .destructive) {
                    Task {
                        do {
                            try await viewModel.delete()
                            dismiss()
                        } catch {
                            print("Silme hatası: \(error)")
                        }
                    }
                }
                Button("Vazgeç", role: .cancel) { }
            } message: {
                Text("Bu notu kalıcı olarak silmek istediğinizden emin misiniz?")
            }
    }
}

