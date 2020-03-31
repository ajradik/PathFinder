//
//  ViewController.swift
//  PathFinder
//
//  Created by AJ Radik on 3/23/20.
//  Copyright © 2020 AJ Radik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: Globals
    let GRID_SIZE = 10
    let GRID_GAP_SIZE = 2
    let GRID_NODE_CORNER_RADIUS = 4
    let TEXT_SIZE = (1.2/71) * UIScreen.main.bounds.height
    let CONTROL_BUTTON_CORNER_RADIUS = 10
    let BIG_STACK_SPACING = 10
    let SMALL_STACK_SPACING = 2
    let OPTION_STACK_SPACING = 10
    let STANDARD_CONSTRAINT_CONSTANT: CGFloat = 20
    let FONT_NAME = "LexendDeca-Regular"
    let CONTROL_BUTTON_ALPHA_MAX: CGFloat = 1.0
    let CONTROL_BUTTON_ALPHA_MIN: CGFloat = 0.4
    let CONTROL_BUTTON_ANIMATION_DURATION = 0.2
    
    var nodes: [[Node]] = []
    var verticalGridStack: UIStackView? = nil
    var drawtype: Node.NodeType = .wall
    
    enum SolveAlgorithm {
        case DFS
        case BFS
    }
    
    var solveAlgorithm: SolveAlgorithm = .DFS
    
    //MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = true
        initializeGrid()
        initializeControls()
        
        let thread = Thread.init(target: self, selector: #selector(someAsyncFunction), object: nil)
        thread.start()
        
    }
    
    @objc func someAsyncFunction() {
      // Something that takes some time to complete.
        
        for node in nodes[0] {
            
            DispatchQueue.main.async {
                node.view.backgroundColor = UIColor.systemYellow
            }
            
            usleep(500000)
            
            print(Thread.current)
            
        }
        
    }
    
    //MARK: Drag and Touch Detection
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = event?.allTouches?.first else {return}
        respondToTouch(touch: touch)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = event?.allTouches?.first else {return}
        respondToTouch(touch: touch)
    }
    
    func respondToTouch(touch: UITouch) {
        for nodeRow in nodes {
            for node in nodeRow {
                if node.view.frame.contains(touch.location(in: node.view.superview)) {
                    
                    switch drawtype {
                        case .wall:
                            node.view.backgroundColor = UIColor.systemPink
                        case .space:
                            node.view.backgroundColor = UIColor.systemFill
                        case .start:
                            node.view.backgroundColor = UIColor.systemIndigo
                        case .end:
                            node.view.backgroundColor = UIColor.systemBlue
                    }
                    
                    node.type = drawtype
                    
                }
            }
        }
    }
    
    //MARK: Custom UI Initializers
    func initializeCustomButton(title: String, color: UIColor) -> UIButton {
        let toReturn = UIButton()
        toReturn.setTitle(title, for: .normal)
        toReturn.titleLabel!.font = UIFont(name: FONT_NAME, size: TEXT_SIZE)
        toReturn.setTitleColor(UIColor.label, for: .normal)
        toReturn.backgroundColor = color
        toReturn.cornerRadius = CGFloat(CONTROL_BUTTON_CORNER_RADIUS)
        toReturn.addTarget(self, action: #selector(controlButtonTouchUpInside(sender:)), for: .touchUpInside)
        toReturn.addTarget(self, action: #selector(controlButtonTouchDown(sender:)), for: .touchDown)
        toReturn.addTarget(self, action: #selector(controlButtonTouchDragExit(sender:)), for: .touchDragExit)
        toReturn.alpha = CONTROL_BUTTON_ALPHA_MIN
        return toReturn
    }
    
    func initializeCustomButton(title: String, color: UIColor, alpha: CGFloat) -> UIButton {
        let toReturn = initializeCustomButton(title: title, color: color)
        toReturn.alpha = alpha
        return toReturn
    }
    
    func initializeCustomLabel(title: String) -> UILabel {
        let toReturn = UILabel()
        toReturn.text = title
        toReturn.font = UIFont.init(name: FONT_NAME, size: TEXT_SIZE)
        return toReturn
    }
    
    func initializeCustomStack(axis: NSLayoutConstraint.Axis, spacing: Int) -> UIStackView {
        let toReturn = UIStackView()
        toReturn.axis = axis
        toReturn.alignment = .fill
        toReturn.distribution = .fillEqually
        toReturn.spacing = CGFloat(spacing)
        toReturn.isUserInteractionEnabled = true
        return toReturn
    }
    
    //MARK: Initialize Grid
    func initializeGrid() {
        initializeGridStacks()
        initializeGridNodes()
    }
        
    //MARK: Initialize Grid Stacks
    func initializeGridStacks() {
        verticalGridStack = initializeCustomStack(axis: .vertical, spacing: GRID_GAP_SIZE)
        
        let gridStackConstraints: [NSLayoutConstraint] = [
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: verticalGridStack!.trailingAnchor, constant: STANDARD_CONSTRAINT_CONSTANT),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: verticalGridStack!.leadingAnchor, constant: -1 * STANDARD_CONSTRAINT_CONSTANT),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: verticalGridStack!.topAnchor, constant: -1 * STANDARD_CONSTRAINT_CONSTANT),
            verticalGridStack!.heightAnchor.constraint(equalTo: verticalGridStack!.widthAnchor)
        ]
        
        verticalGridStack!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(verticalGridStack!)
        NSLayoutConstraint.activate(gridStackConstraints)
        
        
        for _ in 1...GRID_SIZE {
            let horizontalStackView = initializeCustomStack(axis: .horizontal, spacing: GRID_GAP_SIZE)
            verticalGridStack!.addArrangedSubview(horizontalStackView)
        }
        
    }
        
    //MARK: Initialize Grid Nodes
    func initializeGridNodes() {
        for horizontalStack in verticalGridStack!.arrangedSubviews {
            nodes.append([])
            for _ in 0...GRID_SIZE-1 {
                let nodeView = UIView()
                nodeView.backgroundColor = UIColor.systemFill
                nodeView.cornerRadius = CGFloat(GRID_NODE_CORNER_RADIUS)
                nodeView.isUserInteractionEnabled = true
                (horizontalStack as! UIStackView).addArrangedSubview(nodeView)
                nodes[nodes.count-1].append(Node(view: nodeView))
            }
        }
    }
    
    //MARK: Initialize Controls
    func initializeControls() {
        
        //Big Stack
        let bigStack = initializeCustomStack(axis: .vertical, spacing: BIG_STACK_SPACING)
        let bigStackConstraints: [NSLayoutConstraint] = [
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: bigStack.trailingAnchor, constant: STANDARD_CONSTRAINT_CONSTANT),
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: bigStack.leadingAnchor, constant: -1 * STANDARD_CONSTRAINT_CONSTANT),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bigStack.bottomAnchor, constant: STANDARD_CONSTRAINT_CONSTANT),
            NSLayoutConstraint(item: bigStack, attribute: .top, relatedBy: .equal, toItem: verticalGridStack, attribute: .bottom, multiplier: 1, constant: STANDARD_CONSTRAINT_CONSTANT)
        ]
        bigStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bigStack)
        NSLayoutConstraint.activate(bigStackConstraints)
        
        //Draw Tool Stack
        let drawStack = initializeCustomStack(axis: .vertical, spacing: SMALL_STACK_SPACING)
        bigStack.addArrangedSubview(drawStack)
        
        drawStack.addArrangedSubview(initializeCustomLabel(title: "CHOOSE DRAW TOOL"))
        
        let drawButtonStack = initializeCustomStack(axis: .horizontal, spacing: OPTION_STACK_SPACING)
        drawStack.addArrangedSubview(drawButtonStack)
        
        drawButtonStack.addArrangedSubview(initializeCustomButton(title: "Wall", color: UIColor.systemPink, alpha: CONTROL_BUTTON_ALPHA_MAX))
        drawButtonStack.addArrangedSubview(initializeCustomButton(title: "Space", color: UIColor.systemFill))
        drawButtonStack.addArrangedSubview(initializeCustomButton(title: "Start", color: UIColor.systemIndigo))
        drawButtonStack.addArrangedSubview(initializeCustomButton(title: "End", color: UIColor.systemBlue))
            
        //Algorithm Stack
        let algorithmStack = initializeCustomStack(axis: .vertical, spacing: SMALL_STACK_SPACING)
        bigStack.addArrangedSubview(algorithmStack)
        
        algorithmStack.addArrangedSubview(initializeCustomLabel(title: "CHOOSE SOLVE ALGORITHM"))
        
        let algorithmButtonStack = initializeCustomStack(axis: .horizontal, spacing: OPTION_STACK_SPACING)
        algorithmStack.addArrangedSubview(algorithmButtonStack)
        
        algorithmButtonStack.addArrangedSubview(initializeCustomButton(title: "Depth-First-Search", color: UIColor.systemGreen, alpha: CONTROL_BUTTON_ALPHA_MAX))
        algorithmButtonStack.addArrangedSubview(initializeCustomButton(title: "Breadth-First-Search", color: UIColor.systemGreen))
        
        //Speed Stack
        let speedStack = initializeCustomStack(axis: .vertical, spacing: SMALL_STACK_SPACING)
        bigStack.addArrangedSubview(speedStack)
        
        speedStack.addArrangedSubview(initializeCustomLabel(title: "SET SOLVE SPEED"))
        speedStack.addArrangedSubview(UISlider())
        
        //Controls, Controls.
        let controlStack = initializeCustomStack(axis: .vertical, spacing: SMALL_STACK_SPACING)
        bigStack.addArrangedSubview(controlStack)
        
        controlStack.addArrangedSubview(initializeCustomLabel(title: "FIND PATH, STOP, AND RESET"))
        
        let controlButtonStack = initializeCustomStack(axis: .horizontal, spacing: OPTION_STACK_SPACING)
        controlStack.addArrangedSubview(controlButtonStack)
        
        controlButtonStack.addArrangedSubview(initializeCustomButton(title: "Find Path", color: UIColor.systemGreen, alpha: CONTROL_BUTTON_ALPHA_MAX))
        controlButtonStack.addArrangedSubview(initializeCustomButton(title: "Reset", color: UIColor.systemPink, alpha: CONTROL_BUTTON_ALPHA_MAX))
        
    }
    
    //MARK: Control Button Handlers
    @objc func controlButtonTouchUpInside(sender: UIButton!) {
       print("Button touched up inside")
        
        for button in (sender.superview as! UIStackView).arrangedSubviews {
            if button == sender {
                UIView.animate(withDuration: CONTROL_BUTTON_ANIMATION_DURATION) {
                    sender.alpha = self.CONTROL_BUTTON_ALPHA_MAX
                }
            }
            
            else if sender.titleLabel!.text != "Find Path" && sender.titleLabel?.text != "Stop" && sender.titleLabel?.text != "Reset"  {
                
                UIView.animate(withDuration: CONTROL_BUTTON_ANIMATION_DURATION) {
                    button.alpha = self.CONTROL_BUTTON_ALPHA_MIN
                }
            }
        }
        
        switch sender.titleLabel?.text {
            case "Wall":
                drawtype = .wall
            case "Space":
                drawtype = .space
            case "Start":
                drawtype = .start
            case "End":
                drawtype = .end
            case "Depth-First-Search":
                solveAlgorithm = .DFS
            case "Breadth-First-Search":
                solveAlgorithm = .BFS
            default:
                break
        }
        
    }
    
    var mostRecentAlpha = 1.0
    
    @objc func controlButtonTouchDown(sender: UIButton!) {
       print("Button touched down")
        
        self.mostRecentAlpha = Double(sender.alpha)
        
        UIView.animate(withDuration: CONTROL_BUTTON_ANIMATION_DURATION) {
            sender.alpha = self.CONTROL_BUTTON_ALPHA_MIN
        }
    }
    
    @objc func controlButtonTouchDragExit(sender: UIButton!) {
       print("Button touch dragged exited")
        
        UIView.animate(withDuration: CONTROL_BUTTON_ANIMATION_DURATION) {
            sender.alpha = CGFloat(self.mostRecentAlpha)
        }
    }
    
}

//MARK: Node Class

class Node {
    
    enum NodeType {
        case wall
        case space
        case start
        case end
    }
    
    var view: UIView
    var type: NodeType = .space
    var isVisited: Bool = false
    
    init(view: UIView) {
        self.view = view
    }
    
}



    
//MARK: UIView Extension
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
