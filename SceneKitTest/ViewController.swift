//
//  ViewController.swift
//  SceneKitTest
//
//  Created by Hyunhee Sim on 2/14/24.
//
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
        fixedNode = SCNNode(geometry:
//                                SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
            smallLesionGeometry()
//                              pyramidGeometry()
        )
        fixedNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        fixedNode.name = "fixed"
        fixedNode.position = SCNVector3(0, 0, -0.8)
        
        let (center, radius) = fixedNode.boundingSphere
        
        let physicsBodyNode = SCNNode()
        physicsBodyNode.name = "fixedPhysics"
        physicsBodyNode.position = center
        physicsBodyNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNSphere(radius: CGFloat(radius))))
        fixedNode.addChildNode(physicsBodyNode)
        
        // physics
//        fixedNode.physicsBody =
//            SCNPhysicsBody(type: .static, shape:
//                            SCNPhysicsShape(geometry: smallSphereGeometry())
        ////                            nil
        ////                SCNPhysicsShape(node: fixedNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        ////                           SCNPhysicsShape(node: fixedNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.boundingBox])
//            )
        
        rootNode.addChildNode(fixedNode)
    }
    
    func setupMovableNode() {
        // create node
        movableNode = SCNNode(geometry:
//                                SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//                              smallLesionGeometry()
            smallShapeGeometry()
//                              pyramidGeometry()
//                              smallSphereGeometry()
//                              smallBoxGeometry()
        )
        movableNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        movableNode.name = "movable"
        movableNode.position = SCNVector3(0.3, 0, -0.8)

        // physics
        movableNode.physicsBody =
            SCNPhysicsBody(type: .static, shape:
                nil
//                           SCNPhysicsShape(node: movableNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
//                           SCNPhysicsShape(node: movableNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.boundingBox])
            )
        
        rootNode.addChildNode(movableNode)
    }
    
    func smallLesionGeometry() -> SCNGeometry {
//        let fileName = "0.001_lesion"
        let fileName = "not_origin_0.001_lesion"
        guard let objFilePath = Bundle.main.path(forResource: fileName, ofType: "obj") else {
            fatalError("file path fail")
        }
        
        let asset = MDLAsset(url: URL(fileURLWithPath: objFilePath))
        guard let mesh = asset.object(at: 0) as? MDLMesh else {
            fatalError("mesh fail")
        }
        
        return SCNGeometry(mdlMesh: mesh)
    }
    
    func smallSphereGeometry() -> SCNGeometry {
        return SCNSphere(radius: 0.005)
    }

    func sphereGeometry() -> SCNGeometry {
        return SCNSphere(radius: 0.03)
    }

    func smallBoxGeometry() -> SCNGeometry {
        return SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
    }
    
    func boxGeometry() -> SCNGeometry {
        return SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
    }
    
    func smallShapeGeometry() -> SCNGeometry {
        // nil 넓은 범위 감지
//        return SCNPyramid(width: 0.01, height: 0.01, length: 0.005)
//        return SCNCone(topRadius: 0, bottomRadius: 0.01, height: 0.01)
//        return SCNTorus(ringRadius: 0.01, pipeRadius: 0.005)
//        return SCNCapsule(capRadius: 0.01, height: 0.005)

        // nil 정상 범위 감지
//        return SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
//        return SCNSphere(radius: 0.005)
        return SCNPlane(width: 0.01, height: 0.05)
        //        return SCNCylinder(radius: 0.01, height: 0.01)
        //        return SCNTube(innerRadius: 0.005, outerRadius: 0.01, height: 0.005)
    }

    func pyramidGeometry() -> SCNGeometry {
        return SCNPyramid(width: 0.05, height: 0.05, length: 0.01)
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
