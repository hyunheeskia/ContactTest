//
//  ViewController.swift
//  SceneKitTest
//
//  Created by Hyunhee Sim on 2/14/24.
//

import SceneKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var consoleLabel: UILabel!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!

    var skinNode: SCNNode!
    var rootNode: SCNNode!
    
    var lineStartNode: SCNNode?
    var lineEndNode: SCNNode?
    var lineNode: SCNNode?
    
    var testing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareGestureRecognizers()
        setupScene()
        setupScene1()
//        setupScene2()
    }
    
    func setupScene() {
        scnView.scene = SCNScene()
        scnView.scene!.rootNode.camera = SCNCamera()
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true

        // rootNode
        rootNode = scnView.scene!.rootNode
    }
    
    func setupScene1() {
        // skinNode
        skinNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1))
        skinNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        skinNode.geometry?.firstMaterial?.transparency = 0.5
        skinNode.name = "skin"
        skinNode.position = SCNVector3(0, 0, -3)
        rootNode.addChildNode(skinNode)
        
        let testNode1 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode1.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        testNode1.position = SCNVector3(0, 0, -3)
        testNode1.name = "yellow"
        rootNode.addChildNode(testNode1)

        let testNode2 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        testNode2.position = SCNVector3(0.1, 0.3, -3)
//        testNode2.position = SCNVector3(0, 0, -2.5)
        testNode2.name = "green"
        rootNode.addChildNode(testNode2)

        let testNode3 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode3.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        testNode3.position = SCNVector3(-0.2, 0, -2.8)
//        testNode3.position = SCNVector3(0, 0, -2)
        testNode3.name = "blue"
        rootNode.addChildNode(testNode3)

//        let testNode4 = SCNNode(geometry: SCNSphere(radius: 0.1))
//        testNode4.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
//        testNode4.position = SCNVector3(-0.2, 0, -2.8)
////        testNode4.position = SCNVector3(0, 0, -3.5)
//        testNode4.name = "brown"
//        rootNode.addChildNode(testNode4)
    }
    
    func setupScene2() {
        let testNode1 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode1.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        testNode1.position = SCNVector3(0, 0, -3)
        testNode1.name = "red"
        rootNode.addChildNode(testNode1)

        let testNode2 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        testNode2.position = SCNVector3(0.3, 0, -3)
        testNode2.name = "yellow"
//        testNode2.isHidden = true
        rootNode.addChildNode(testNode2)
        
        let testNode3 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode3.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        testNode3.position = SCNVector3(0.6, 0, -3)
        testNode3.name = "green"
        rootNode.addChildNode(testNode3)

        let testNode4 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode4.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        testNode4.position = SCNVector3(0.9, 0, -3)
        testNode4.name = "blue"
        rootNode.addChildNode(testNode4)

    }

    func prepareGestureRecognizers() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanView(_:)))
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        let other: UISwitch = sender == switch1 ? switch2 : switch1
        
        if !sender.isOn {
            // allowsCameraControl 과 함께 쓸 수 없어서 번거롭지만 gesture recognizer 를 껐다 켜는 방법을 사용
            scnView.removeGestureRecognizer(tapGestureRecognizer)
            scnView.removeGestureRecognizer(panGestureRecognizer)
            return
        }

        if other.isOn {
            other.isOn = false
            return
        }

        scnView.addGestureRecognizer(tapGestureRecognizer)
        scnView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        // hit test 에 영향을 주지 않도록 미리 숨김
        lineNodes(isHidden: true)
        defer {
            lineNodes(isHidden: false)
        }
        
        SCNTransaction.flush()

        let touchPoint = sender.location(in: scnView)
        guard let hitResult = scnView.hitTest(touchPoint).first else { return }
        let worldPosition = hitResult.worldCoordinates
        
        hitTest(worldPosition: worldPosition)
    }
    
    @objc func didPanView(_ sender: UIPanGestureRecognizer) {
        // hit test 에 영향을 주지 않도록 미리 숨김
        lineNodes(isHidden: true)
        defer {
            lineNodes(isHidden: false)
        }

        SCNTransaction.flush()

        let touchPoint = sender.location(in: scnView)
        guard let hitResult = scnView.hitTest(touchPoint).first else { return }
        let worldPosition = hitResult.worldCoordinates
        
        hitTest(worldPosition: worldPosition)
    }

    func hitTest(worldPosition: SCNVector3) {
        guard !testing else { return }
        testing = true

        let targetNode = switch1.isOn ? lineStartNode : lineEndNode
        if let targetNode = targetNode {
            targetNode.position = worldPosition
        } else {
            let testNode = SCNNode(geometry: SCNSphere(radius: 0.01))
            testNode.position = worldPosition
            rootNode.addChildNode(testNode)
            if switch1.isOn {
                testNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                testNode.name = "start"
                lineStartNode = testNode
            } else {
                testNode.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan
                testNode.name = "end"
                lineEndNode = testNode
            }
        }
        
        if let lineStartNode = lineStartNode,
           let lineEndNode = lineEndNode {
            let hitTestOptions: [String: Any] = [
                SCNHitTestOption.searchMode.rawValue : SCNHitTestSearchMode.all.rawValue,
                SCNHitTestOption.ignoreHiddenNodes.rawValue : true
            ]

            let hitResultList = rootNode.hitTestWithSegment(from: lineStartNode.position, to: lineEndNode.position, options: hitTestOptions)

            var hitText = ""
            for hitResult in hitResultList {
                if let name = hitResult.node.name {
                    hitText += "\(name)\n"
                }
            }
            consoleLabel.text = hitText
            
            lineNode?.removeFromParentNode()
            // hitTest 에 영향을 주지 않도록 끝나고 생성
            let lineNode = createLine(nodeA: lineStartNode.position, nodeB: lineEndNode.position, color: .black, radius: 0.01)
            lineNode.name = "line"
            rootNode.addChildNode(lineNode)
            self.lineNode = lineNode
        }
        testing = false
    }
    
    func lineNodes(isHidden: Bool) {
        lineNode?.isHidden = isHidden
        lineStartNode?.isHidden = isHidden
        lineEndNode?.isHidden = isHidden
    }
    
    func createLine(nodeA: SCNVector3, nodeB: SCNVector3, color: UIColor, radius: Float) -> SCNNode {
        let height = sqrt(pow(nodeA.x - nodeB.x, 2) + pow(nodeA.y - nodeB.y, 2) + pow(nodeA.z - nodeB.z, 2))
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        cylinder.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: cylinder)
        node.position = SCNVector3Make((nodeA.x + nodeB.x) / 2, (nodeA.y + nodeB.y) / 2, (nodeA.z + nodeB.z) / 2)
        node.eulerAngles = SCNVector3Make(Float(Double.pi / 2), acos((nodeB.z - nodeA.z) / height), atan2(nodeB.y - nodeA.y, nodeB.x - nodeA.x))
        return node
    }
}
