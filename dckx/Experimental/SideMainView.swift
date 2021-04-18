//
//  SideMainView.swift
//  dckx
//
//  Created by Vito Royeca on 4/18/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

import SwiftUI

struct SideMainView: View {
    @StateObject var store = MailStore()
    @State private var selectedLabel: String? = "Inbox"
    @State private var selectedMail: Mail?
    
    var body: some View {
//        WindowGroup {
            NavigationView {
                Sidebar(
                    store: store,
                    selectedFolder: $selectedLabel,
                    selectedMail: $selectedMail
                )

                Text("Select label...")
                Text("Select mail...")
            }
//        }
    }
}

struct SideMainView_Previews: PreviewProvider {
    static var previews: some View {
        SideMainView()
    }
}

// MARK: - MailView

struct MailView2: View {
    let mail: Mail

    var body: some View {
        VStack(alignment: .leading) {
            Text(mail.subject)
                .font(.headline)
            Text(mail.date, style: .date)
            Text(mail.body)
        }
    }
}

// MARK: - FolderView

struct FolderView: View {
    let title: String
    let mails: [Mail]
    @Binding var selectedMail: Mail?

    var body: some View {
        List {
            ForEach(mails) { mail in
                NavigationLink(
                    destination: MailView2(mail: mail),
                    tag: mail,
                    selection: $selectedMail
                ) {
                    VStack(alignment: .leading) {
                        Text(mail.subject)
                        Text(mail.date, style: .date)
                    }
                }
            }
        }.navigationTitle(title)
    }
}

// MARK: - Sidebar

struct Sidebar: View {
    @ObservedObject var store: MailStore
    @Binding var selectedFolder: String?
    @Binding var selectedMail: Mail?

    var body: some View {
        List {
            ForEach(Array(store.allMails.keys), id: \.self) { folder in
                NavigationLink(
                    destination: FolderView(
                        title: folder,
                        mails: store.allMails[folder, default: []],
                        selectedMail: $selectedMail
                    ),
                    tag: folder,
                    selection: $selectedFolder
                ) {
                    Text(folder).font(.headline)
                }
            }
        }.listStyle(SidebarListStyle())
    }
}

// MARK: - Mail

struct Mail: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let subject: String
    let body: String
    var isFavorited = false
}

final class MailStore: ObservableObject {
    @Published var allMails: [String: [Mail]] = [
        "Inbox": [ .init(date: Date(), subject: "Subject1", body: "Very long body...") ],
        "Sent": [ .init(date: Date(), subject: "Subject2", body: "Very long body...") ],
    ]
}
