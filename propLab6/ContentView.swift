//
//  ContentView.swift
//  propLab6
//
//  Created by student on 27.12.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.code, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var code = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Image(uiImage: UIImage(data: item.data!)!)
                    } label: {
                        Text(item.code!)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Text(errorMessage)
                }
                ToolbarItem {
                    TextField("http code", text: $code)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            if (code.isEmpty || !code.allSatisfy {character in
                character.isNumber
            }) {
                return
            }
            let url = URL(string: "https://http.cat/" + code)!
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data, error == nil else {
                    errorMessage = "Connection error"
                    return
                }
                
                errorMessage = ""
                
                let newItem = Item(context: viewContext)
                newItem.data = data
                newItem.code = code
                
                do {
                    viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    //let nsError = error as NSError
                    //fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
            
            task.resume()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
