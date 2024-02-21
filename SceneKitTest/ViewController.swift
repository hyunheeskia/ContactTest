//
//  ViewController.swift
//  SceneKitTest
//
//  Created by Hyunhee Sim on 2/14/24.
//

import SceneKit
import SceneKit.ModelIO
import UIKit

class ViewController: UIViewController {
    @IBOutlet var scnView: SCNView!
    @IBOutlet var switch1: UISwitch!
    @IBOutlet var switch2: UISwitch!
    @IBOutlet var consoleLabel: UILabel!
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    var panGestureRecognizer: UIPanGestureRecognizer!

    var skinNode: SCNNode!
    var rootNode: SCNNode!
    
    var probeNode: SCNNode?
    
    var lineStartNode: SCNNode?
    var lineEndNode: SCNNode?
    var lineNode: SCNNode?
    
    var testing = false
    var testType: TestType = .contactTest
    
    enum TestType {
        case hitTest, contactTest
    }

    struct ContactPair: Equatable {
        var nodeA: String
        var nodeB: String
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            if lhs.nodeA == rhs.nodeA, lhs.nodeB == rhs.nodeB { return true }
            if lhs.nodeA == rhs.nodeB, lhs.nodeB == rhs.nodeA { return true }
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareGestureRecognizers()
        setupScene()
        setupSkinBox()
        setupSpheresInSkinBox()
//        setupSpheresInLine()
        setupCustomObj()
        if testType == .contactTest {
            setupProbeNode()
        }
    }
    
    func setupScene() {
        scnView.scene = SCNScene()
        scnView.scene!.rootNode.camera = SCNCamera()
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true

        // rootNode
        rootNode = scnView.scene!.rootNode
    }
    
    func setupSkinBox() {
        // skinNode
        skinNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1))
        skinNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        skinNode.geometry?.firstMaterial?.transparency = 0.5
        skinNode.name = "skin"
        skinNode.position = SCNVector3(0, 0, -3)
        rootNode.addChildNode(skinNode)
    }
    
    func setupSpheresInSkinBox() {
        let testNode1 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode1.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        testNode1.position = SCNVector3(0, 0, -3)
//        testNode1.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//        testNode1.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: testNode1, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.convexHull]))
        testNode1.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: testNode1, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        testNode1.name = "yellow"
        rootNode.addChildNode(testNode1)

        let testNode2 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        testNode2.position = SCNVector3(0.1, 0.3, -3)
//        testNode2.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//        testNode2.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: testNode2, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.convexHull]))
        testNode2.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: testNode2, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        testNode2.name = "green"
        rootNode.addChildNode(testNode2)

        let testNode3 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode3.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        testNode3.position = SCNVector3(-0.2, 0, -2.8)
//        testNode3.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//        testNode3.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: testNode3, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.convexHull]))
        testNode3.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: testNode3, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        testNode3.name = "blue"
        rootNode.addChildNode(testNode3)
    }
    
    func setupSpheresInLine() {
        let testNode1 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode1.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        testNode1.position = SCNVector3(0, 0, -3)
        testNode1.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        testNode1.name = "red"
        rootNode.addChildNode(testNode1)

        let testNode2 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode2.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        testNode2.position = SCNVector3(0.3, 0, -3)
        testNode2.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        testNode2.name = "yellow"
        rootNode.addChildNode(testNode2)
        
        let testNode3 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode3.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        testNode3.position = SCNVector3(0.6, 0, -3)
        testNode3.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        testNode3.name = "green"
        rootNode.addChildNode(testNode3)

        let testNode4 = SCNNode(geometry: SCNSphere(radius: 0.1))
        testNode4.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        testNode4.position = SCNVector3(0.9, 0, -3)
        testNode4.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        testNode4.name = "blue"
        rootNode.addChildNode(testNode4)
    }

    func setupProbeNode() {
        let probeNode = SCNNode(geometry: SCNBox(width: 0.01, height: 0.2, length: 1.0, chamferRadius: 0))
        probeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        probeNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//        probeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: probeNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.convexHull]))
//        probeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: probeNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron]))
        probeNode.name = "probe"
        rootNode.addChildNode(probeNode)
        self.probeNode = probeNode
    }
    
    func setupCustomObj() {
        guard let objFilePath = Bundle.main.path(forResource: "Bone", ofType: "obj") else {
            print("file path fail")
            return
        }
        
        let asset = MDLAsset(url: URL(fileURLWithPath: objFilePath))
        guard let mesh = asset.object(at: 0) as? MDLMesh else {
            print("mesh fail")
            return
        }
        
        let customNode = SCNNode(geometry: SCNGeometry(mdlMesh: mesh))
        customNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        customNode.name = "bone"
        customNode.position = SCNVector3(0, 0, -3)
//        customNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
//        customNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: customNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.convexHull]))
        customNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: customNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron]))
        rootNode.addChildNode(customNode)
        print("success")
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
        probeNode(isHidden: true)
        defer {
            probeNode(isHidden: false)
        }
        
        SCNTransaction.flush()

        let touchPoint = sender.location(in: scnView)
        guard let hitResult = scnView.hitTest(touchPoint).first else { return }
        let worldPosition = hitResult.worldCoordinates
        
        switch testType {
        case .hitTest:
            hitTest(worldPosition: worldPosition)
        case .contactTest:
            contactTest(probePosition: worldPosition)
        }
    }
    
    @objc func didPanView(_ sender: UIPanGestureRecognizer) {
        // hit test 에 영향을 주지 않도록 미리 숨김
        lineNodes(isHidden: true)
        defer {
            lineNodes(isHidden: false)
        }
        probeNode(isHidden: true)
        defer {
            probeNode(isHidden: false)
        }

        SCNTransaction.flush()

        let touchPoint = sender.location(in: scnView)
        guard let hitResult = scnView.hitTest(touchPoint).first else { return }
        let worldPosition = hitResult.worldCoordinates
        
        switch testType {
        case .hitTest:
            hitTest(worldPosition: worldPosition)
        case .contactTest:
            contactTest(probePosition: worldPosition)
        }
    }

    func hitTest(worldPosition: SCNVector3) {
        guard !testing else { return }
        testing = true
        defer { testing = false }

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
           let lineEndNode = lineEndNode
        {
            let hitTestOptions: [String: Any] = [
                SCNHitTestOption.searchMode.rawValue: SCNHitTestSearchMode.all.rawValue,
                SCNHitTestOption.ignoreHiddenNodes.rawValue: true
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
    }
    
    func contactTest(probePosition: SCNVector3) {
        guard !testing else { return }
        testing = true
        defer { testing = false }
        
        probeNode?.position = probePosition
        
        SCNTransaction.flush()

        guard let probePhysicsBody = probeNode?.physicsBody,
              let scene = scnView.scene else { return }
        
        let physicsContactList = scene.physicsWorld.contactTest(with: probePhysicsBody)
        
        var contactPairList = [ContactPair]()
        for contact in physicsContactList {
            guard let nameA = contact.nodeA.name,
                  let nameB = contact.nodeB.name else { continue }
            
            let contactPair = ContactPair(nodeA: nameA, nodeB: nameB)
            
            if !contactPairList.contains(contactPair) {
                contactPairList.append(contactPair)
            }
        }
        
        var contactText = ""
        for pair in contactPairList {
            contactText += "\(pair.nodeA), \(pair.nodeB)\n"
        }
        consoleLabel.text = contactText
    }
    
    func lineNodes(isHidden: Bool) {
        lineNode?.isHidden = isHidden
        lineStartNode?.isHidden = isHidden
        lineEndNode?.isHidden = isHidden
    }
    
    func probeNode(isHidden: Bool) {
        probeNode?.isHidden = isHidden
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
