import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            FridgeView()
                .tabItem {
                    Image(systemName: "snowflake")
                    Text("Geladeira")
                }

            ShoppingView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Compras")
                }
        }
        .tint(.blue)
    }
}

// Geladeira
private struct FridgeView: View {
    @State private var isPresentingAddItem: Bool = false
    @State private var newItemName: String = ""
    @State private var items: [FridgeItem] = [
       
    ]
    @State private var shoppingItems: [String] = []
    @State private var pendingRemovedItem: FridgeItem? = nil
    @State private var isShowingMoveToShoppingAlert: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                header

                if items.isEmpty {
                    Text("Nenhum item adicionado")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach($items) { $item in
                            FridgeItemCard(
                                item: $item,
                                onIncrement: {
                                    item.quantity += 1
                                },
                                onDecrement: {
                                    if item.quantity > 1 {
                                        item.quantity -= 1
                                    } else {
                                        // quantity == 1
                                        let removed = item
                                        if let idx = items.firstIndex(where: { $0.id == removed.id }) {
                                            items.remove(at: idx)
                                        }
                                        pendingRemovedItem = removed
                                        isShowingMoveToShoppingAlert = true
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()
            }
            .alert("Adicionar à lista de compras?", isPresented: $isShowingMoveToShoppingAlert, presenting: pendingRemovedItem) { removed in
                Button("Cancelar", role: .cancel) {
                    pendingRemovedItem = nil
                }
                Button("Adicionar") {
                    if let name = removed.name as String? {
                        shoppingItems.append(name)
                    }
                    pendingRemovedItem = nil
                }
            } message: { removed in
                Text("Deseja adicionar \(removed.name) à lista de compras?")
            }
            .sheet(isPresented: $isPresentingAddItem) {
                AddItemSheet(newItemName: $newItemName, onCancel: {
                    newItemName = ""
                    isPresentingAddItem = false
                }, onAdd: {
                    let trimmed = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    items.append(FridgeItem(name: trimmed, quantity: 1))
                    newItemName = ""
                    isPresentingAddItem = false
                })
                .presentationDetents([.fraction(0.25), .medium])
                .presentationDragIndicator(.visible)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack {
            Text("Minha Geladeira")
                .font(.largeTitle).bold()
            Spacer()
            Button {
                isPresentingAddItem = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Adicionar item")
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// Card do item
private struct FridgeItemCard: View {
    @Binding var item: FridgeItem
    var onIncrement: () -> Void
    var onDecrement: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.headline)
            Text("Em estoque")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button {
                    onDecrement()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                }

                Spacer()

                Text("\(item.quantity)")
                    .font(.title3)
                    .monospacedDigit()

                Spacer()

                Button {
                    onIncrement()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

private struct FridgeItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var quantity: Int
}

// Sheet para adicionar item
private struct AddItemSheet: View {
    @Binding var newItemName: String
    var onCancel: () -> Void
    var onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Adicionar item")
                .font(.headline)

            TextField("Nome do item", text: $newItemName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancelar") { onCancel() }
                Spacer()
                Button("Adicionar") { onAdd() }
                    .buttonStyle(.borderedProminent)
                    .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
    }
}

// Aba Compras (placeholder)
private struct ShoppingView: View {
    var body: some View {
        NavigationStack {
            Text("Compras")
                .font(.title)
        }
    }
}

#Preview {
    ContentView()
}
