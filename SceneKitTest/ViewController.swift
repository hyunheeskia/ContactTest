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
    @IBOutlet var consoleLabel: UILabel!
    
    var rootNode: SCNNode!
    
    var fixedNode: SCNNode!
    var movableNode: SCNNode!
    
    var testing = false
    
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
        
        setupScene()

        setupFixedNode()
        setupMovableNode()
    }
    
    func setupScene() {
        scnView.scene = SCNScene()
        let camera = SCNCamera()
        //        camera.zFar = 350
        camera.zNear = 0.1
        scnView.scene!.rootNode.camera = camera
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = .lightGray
        scnView.debugOptions = [.showPhysicsShapes]
        
        // rootNode
        rootNode = scnView.scene!.rootNode
    }
    
    func setupFixedNode() {
        // create node
        fixedNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        fixedNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        fixedNode.name = "fixed"
        fixedNode.position = SCNVector3(0, 0, -0.3)
        
        // physics
        fixedNode.physicsBody =
        SCNPhysicsBody(type: .static, shape: nil)
        
        rootNode.addChildNode(fixedNode)
    }
    
    func setupMovableNode() {
        movableNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        movableNode.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        movableNode.name = "movable"
        movableNode.position = SCNVector3(0, 0, -0.3)

        // physics
        movableNode.physicsBody =
        SCNPhysicsBody(type: .static, shape: nil)
        
        rootNode.addChildNode(movableNode)
    }

    func contactTest(probePosition: SCNVector3) {
        guard !testing else { return }
        testing = true
        defer { testing = false }
        
        SCNTransaction.flush()
        
        guard let physicsBody = movableNode?.physicsBody,
              let scene = scnView.scene else { return }
        
        let physicsContactList = scene.physicsWorld.contactTest(with: physicsBody)
        
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
}
