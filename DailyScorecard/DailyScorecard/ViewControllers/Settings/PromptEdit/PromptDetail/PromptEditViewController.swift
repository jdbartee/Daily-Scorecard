//
//  PromptEditController.swift
//  DailyScorecard
//
//  Created by JD Bartee on 2/20/20.
//  Copyright © 2020 JD Bartee. All rights reserved.
//

import Foundation
import Combine
import UIKit

class PromptEditViewController: UIViewController, Storyboarded {
    var service: PromptEditViewService?

    var promptModel: AnyPublisher<PromptEditViewModel, Never>?
    var state: PromptEditViewModel?
    var cancelBag = CancelBag()

    var flowController: PromptEditFlowController?
    
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var promptActiveSwitch: UISwitch!

    @IBAction func cancelTapped(_ sender: Any) {
        flowController?.dismissDetail()
    }

    @IBAction func saveTapped(_ sender: Any) {
        if var state = self.state {
            state.prompt = self.promptTextField.text ?? ""
            state.active = promptActiveSwitch.isOn
            self.service?.savePrompt(prompt: state)
        }
        flowController?.dismissDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.promptModel?
            .receive(on: DispatchQueue.main)
            .first()
            .sink( receiveValue: { state in
                self.state = state
                self.applyState()
            })
            .store(in: &cancelBag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        cancelBag.cancelAll()
    }

    func applyState() {
        self.promptTextField.text = self.state?.prompt
        self.promptActiveSwitch.setOn(self.state?.active ?? false, animated: true)
    }
}
