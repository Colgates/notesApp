//
//  EntryViewController.swift
//  NotesApp
//
//  Created by Evgenii Kolgin on 02.07.2021.
//

import UIKit

class EntryViewController: UIViewController {
    
    private let titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter title"
        field.font = .systemFont(ofSize: 20, weight: .bold)
        field.becomeFirstResponder()
        field.returnKeyType = .continue
        return field
    }()
    
    private let noteTextView: UITextView = {
        let field = UITextView()
        field.font = .systemFont(ofSize: 17, weight: .light)
        return field
    }()
    
    var completion: ((String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        titleField.delegate = self
        configureNavBar()
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(titleField)
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        
        view.addSubview(noteTextView)
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        noteTextView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10).isActive = true
        noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        noteTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10).isActive = true
    }
    
    @objc private func didTapSave() {
        if let title = titleField.text, !title.isEmpty, let noteText = noteTextView.text, !noteText.isEmpty {
            completion?(title, noteText)
        }
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func configure(note: Note) {
        titleField.text = note.title
        noteTextView.text = note.noteText
    }
}

// MARK: - UITextFieldDelegate
extension EntryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            titleField.resignFirstResponder()
            noteTextView.becomeFirstResponder()
        }
        return true
    }
}
