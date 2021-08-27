//
//  HomeViewModel.swift
//  NotesApp
//
//  Created by Evgenii Kolgin on 17.07.2021.
//
import CoreData
import UIKit

enum Section {
    case main
}

class HomeViewModel {
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Note>?
    
    var notes: [Note] = [] {
        didSet {
            updateSnapshot()
        }
    }
    
    func loadNotes() {
        notes = CoreDataManager.shared.fetchContext()
        updateSnapshot()
    }
    
    func save() {
        CoreDataManager.shared.saveContext()
    }
    
    func deleteNote(at indexPath: IndexPath) {
        guard let note = dataSource?.itemIdentifier(for: indexPath) else { return }
        CoreDataManager.shared.deleteNote(note)
        notes.remove(at: indexPath.row)
    }
    
    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Note>()
        snapshot.appendSections([.main])
        snapshot.appendItems(notes)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
