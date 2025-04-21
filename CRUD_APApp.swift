//
//  CRUD_APApp.swift
//  CRUD_AP
//
//  Created by Ashley on 4/13/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CRUD_APApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var productName: String = ""
    @State private var shade: String = ""
    @State private var style: String = ""
    @State private var size: String = ""
    @State private var categoryId: String = ""
    @State private var brandId: String = ""
    @State private var collectionId: String = ""
    @State private var documentIDToEdit: String? = nil

    var body: some View {
        ZStack {
            Color.purple.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Text("Makeup Database")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)

                    Text("Add or Edit Products")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)

                    Group {
                        TextField("Product Name", text: $productName)
                        TextField("Shade", text: $shade)
                        TextField("Style", text: $style)
                        TextField("Size", text: $size)
                        TextField("Category ID", text: $categoryId)
                        TextField("Brand ID", text: $brandId)
                        TextField("Collection ID (Optional)", text: $collectionId)
                    }
                    .font(.system(size: 16))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        Button("Add Product") {
                            addProduct()
                        }
                        .buttonStyle(StyledButton(color: .gray))

                        Button("Find Makeup by Name") {
                            findMakeupByName(productName)
                        }
                        .buttonStyle(StyledButton(color: .gray))

                        Button("Update Product") {
                            if let docID = documentIDToEdit {
                                updateProduct(documentID: docID)
                            }
                        }
                        .buttonStyle(StyledButton(color: documentIDToEdit != nil ? .pink : .gray))
                        .disabled(documentIDToEdit == nil)

                        Button("Clear Form") {
                            clearForm()
                        }
                        .buttonStyle(StyledButton(color: .gray))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    func addProduct() {
        let db = Firestore.firestore()
        let categoryRef = db.collection("categories").document(categoryId)
        let brandRef = db.collection("brands").document(brandId)
        
        var data: [String: Any] = [
            "name": productName,
            "shade": shade,
            "style": style,
            "size": size,
            "category_id": categoryRef,
            "brand_id": brandRef
        ]
        
        if collectionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            data["collection_id"] = NSNull()
        } else {
            let collectionRef = db.collection("collections").document(collectionId)
            data["collection_id"] = collectionRef
        }
        
        db.collection("products").addDocument(data: data) { err in
            if let err = err {
                print("Error adding product: \(err)")
            } else {
                print("Product added!")
                clearForm()
            }
        }
    }
    
    func updateProduct(documentID: String) {
        let db = Firestore.firestore()
        let categoryRef = db.collection("categories").document(categoryId)
        let brandRef = db.collection("brands").document(brandId)
        
        var data: [String: Any] = [
            "name": productName,
            "shade": shade,
            "style": style,
            "size": size,
            "category_id": categoryRef,
            "brand_id": brandRef
        ]
        
        if collectionId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            data["collection_id"] = NSNull()
        } else {
            let collectionRef = db.collection("collections").document(collectionId)
            data["collection_id"] = collectionRef
        }
        
        db.collection("products").document(documentID).updateData(data) { err in
            if let err = err {
                print("Error updating product: \(err)")
            } else {
                print("Product updated!")
                clearForm()
            }
        }
    }
    
    func findMakeupByName(_ name: String) {
            let db = Firestore.firestore()
            db.collection("products").whereField("name", isEqualTo: name).getDocuments { (snapshot, err) in
                if let err = err {
                    print("Error finding product: \(err)")
                } else if let doc = snapshot?.documents.first {
                    let data = doc.data()
                    self.documentIDToEdit = doc.documentID
                    self.productName = data["name"] as? String ?? ""
                    self.shade = data["shade"] as? String ?? ""
                    self.style = data["style"] as? String ?? ""
                    self.size = data["size"] as? String ?? ""
                    self.categoryId = (data["category_id"] as? DocumentReference)?.documentID ?? ""
                    self.brandId = (data["brand_id"] as? DocumentReference)?.documentID ?? ""
                    self.collectionId = (data["collection_id"] as? DocumentReference)?.documentID ?? ""

                    print("Product loaded with ID: \(doc.documentID)")
                } else {
                    print("No product found with that name.")
                    clearForm()
                }
            }
        }

        func clearForm() {
            productName = ""
            shade = ""
            style = ""
            size = ""
            categoryId = ""
            brandId = ""
            collectionId = ""
            documentIDToEdit = nil
        }
    }

    struct StyledButton: ButtonStyle {
        var color: Color
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(color.opacity(configuration.isPressed ? 0.6 : 1))
                .foregroundColor(.white)
                .cornerRadius(6)
        }
    }

    #Preview {
        ContentView()
    }
