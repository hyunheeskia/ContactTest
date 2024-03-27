//
//  ViewController.swift
//  SceneKitTest
//
//  Created by Hyunhee Sim on 2/14/24.
//
//
import SceneKit
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
        
        setupUI()
    }
    
    func setupScene() {
        scnView.scene = SCNScene()
        let camera = SCNCamera()
        //        camera.zFar = 350
        camera.zNear = 0.1
        scnView.scene!.rootNode.camera = camera
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = .systemYellow
        scnView.debugOptions = [.showPhysicsShapes]
        
        // rootNode
        rootNode = scnView.scene!.rootNode
    }
    
    func setupFixedNode() {
        // create node
        fixedNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        fixedNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        fixedNode.name = "fixed"
        fixedNode.position = SCNVector3(0, 0, -0.8)
        
        // physics
        fixedNode.physicsBody =
            SCNPhysicsBody(type: .static, shape: nil)
        
        rootNode.addChildNode(fixedNode)
    }
    
    func setupMovableNode() {
        // create node
        movableNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        movableNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        movableNode.name = "movable"
        movableNode.position = SCNVector3(0.3, 0, -0.8)

        // physics
        movableNode.physicsBody =
            SCNPhysicsBody(type: .static, shape: nil)
        
        rootNode.addChildNode(movableNode)
    }

    func contactTest() {
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
    
    func setupUI() {
        let xSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 720), size: CGSize(width: 900, height: 20)))
        let ySlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 760), size: CGSize(width: 900, height: 20)))
        let zSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 800), size: CGSize(width: 900, height: 20)))

        let range: Float = 0.5

        let xInitial = movableNode.position.x
        xSlider.tag = 0
        xSlider.minimumValue = xInitial - range
        xSlider.maximumValue = xInitial + range
        xSlider.value = xInitial

        let yInitial = movableNode.position.y
        ySlider.tag = 1
        ySlider.minimumValue = yInitial - range
        ySlider.maximumValue = yInitial + range
        ySlider.value = yInitial

        let zInitial = movableNode.position.z
        zSlider.tag = 2
        zSlider.minimumValue = zInitial - range
        zSlider.maximumValue = zInitial + range
        zSlider.value = zInitial
        
        xSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        ySlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        zSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)

        view.addSubview(xSlider)
        view.addSubview(ySlider)
        view.addSubview(zSlider)
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 0: movableNode.position = SCNVector3(sender.value, movableNode.position.y, movableNode.position.z)
        case 1: movableNode.position = SCNVector3(movableNode.position.x, sender.value, movableNode.position.z)
        case 2: movableNode.position = SCNVector3(movableNode.position.x, movableNode.position.y, sender.value)
        default: break
        }
        
        contactTest()
    }
}
