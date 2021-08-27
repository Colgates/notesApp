//
//  ViewController.swift
//  NotesApp
//
//  Created by Evgenii Kolgin on 02.07.2021.
//
import CoreData
import UIKit

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    
    private let noNotesLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        label.text = "No Notes Yet!"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let floatingButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .label
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .secondarySystemBackground
        button.setTitleColor(.systemGroupedBackground, for: .normal)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.layer.cornerRadius = 30
        return button
    }()
    
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"

        view.backgroundColor = .systemBackground
        floatingButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        configureNavBar()
        setupCollectionView()
        
        configureDataSource()
        viewModel.loadNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isNotesEmpty()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(collectionView)
        view.addSubview(noNotesLabel)
        view.addSubview(floatingButton)
        
        floatingButton.frame = CGRect(x: view.frame.size.width - 100, y: view.frame.size.height - 100, width: 60, height: 60)
        collectionView.frame = view.bounds
        noNotesLabel.center = view.center
    }
    
    @objc private func addButtonTapped() {
        let vc = EntryViewController()
        vc.completion = { [weak self] title, noteText in
            
            let newNote = Note(context: CoreDataManager.shared.viewContext)
            newNote.title = title
            newNote.noteText = noteText
            
            self?.viewModel.notes.append(newNote)
            self?.viewModel.save()
            self?.navigationController?.popToRootViewController(animated: true)
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func isNotesEmpty() {
        if viewModel.notes.isEmpty {
            noNotesLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            noNotesLabel.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    private func setupCollectionView() {
        
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        layoutConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
                self?.viewModel.deleteNote(at: indexPath)
                self?.isNotesEmpty()
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Note> { cell, indexPath, note in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = note.title
            configuration.secondaryText = note.noteText
            cell.contentConfiguration = configuration
        }
        
        viewModel.dataSource = UICollectionViewDiffableDataSource<Section, Note>(collectionView: collectionView, cellProvider: { collectionView, indexPath, note in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: note)
        })
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let note = viewModel.dataSource?.itemIdentifier(for: indexPath) else { return }
        
        let vc = EntryViewController()
        vc.configure(note: note)
        
        vc.completion = { [weak self] title, noteText in

            
            note.title = title
            note.noteText = noteText
            self?.viewModel.notes.remove(at: indexPath.row)
            self?.viewModel.notes.insert(note, at: indexPath.row)
            self?.viewModel.save()
            self?.navigationController?.popToRootViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
