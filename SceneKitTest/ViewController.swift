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
    var scnView: SCNView!
    var consoleLabel: UILabel!
    
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
        setupView()
        setupScene()

        setupFixedNode()
        setupMovableNode()
        
        setupUI()
    }
    
    func setupView() {
        scnView = SCNView(frame: view.frame)
        view.addSubview(scnView)
        consoleLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 200, height: view.frame.height)))
        consoleLabel.backgroundColor = .gray
        view.addSubview(consoleLabel)
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
//            smallLesionGeometry()
                            smallBoxGeometry()
//                              pyramidGeometry()
        )
        fixedNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        fixedNode.name = "fixed"
        fixedNode.position = SCNVector3(0, 0, -0.8)
        
//        let (center, radius) = fixedNode.boundingSphere
        
//        let physicsBodyNode = SCNNode()
//        physicsBodyNode.name = "fixedPhysics"
//        physicsBodyNode.position = center
//        physicsBodyNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNSphere(radius: CGFloat(radius))))
//        fixedNode.addChildNode(physicsBodyNode)
        
        // physics
        fixedNode.physicsBody =
            SCNPhysicsBody(type: .static, shape:
                            SCNPhysicsShape(geometry: smallBoxGeometry())
//                                    nil
//                        SCNPhysicsShape(node: fixedNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        ////                           SCNPhysicsShape(node: fixedNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.boundingBox])
            )
        
        rootNode.addChildNode(fixedNode)
    }
    
    var lineNodeA = SCNVector3(0.3, 0, -0.8)
    var lineNodeB = SCNVector3(0.35, 0.1, -0.8)
    
    func setupMovableNode() {
        // create node
        movableNode = createLine(nodeA: lineNodeA, nodeB: lineNodeB, color: .blue, radius: 0.001)
//        movableNode = SCNNode(geometry:
//                                SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//                              smallLesionGeometry()
//            smallShapeGeometry()
//                              pyramidGeometry()
//                              smallSphereGeometry()
//                              smallBoxGeometry()
//                              probeShapeGeometry()
//        )
//        movableNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//        movableNode.name = "movable"
//        movableNode.position = SCNVector3(0.3, 0, -0.8)

        // physics
//        movableNode.physicsBody =
//            SCNPhysicsBody(type: .static, shape:
//                nil
//                           SCNPhysicsShape(node: movableNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
//                           SCNPhysicsShape(node: movableNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.boundingBox])
//                           SCNPhysicsShape(geometry: smallShapeGeometry())
//            )
        
        rootNode.addChildNode(movableNode)
    }
    
    func smallLesionGeometry() -> SCNGeometry {
//        let fileName = "0.001_lesion"
//        let fileName = "not_origin_0.001_lesion"
//        let fileName = "small_bone"
        let fileName = "small_artery"
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
//        return SCNPlane(width: 0.01, height: 0.05)
                return SCNCylinder(radius: 0.0005, height: 0.1)
        //        return SCNTube(innerRadius: 0.005, outerRadius: 0.01, height: 0.005)
    }

    func pyramidGeometry() -> SCNGeometry {
        return SCNPyramid(width: 0.05, height: 0.05, length: 0.001)
    }
    
    func probeShapeGeometry() -> SCNGeometry {
        let side: Float = 0.05
        let angle = Float.pi * 20 / 180
        
        let v0 = SCNVector3Zero
        let v1 = SCNVector3Make(-side * sin(1.5*angle), side * cos(1.5*angle), 0)
        let v2 = SCNVector3Make(-side * sin(0.5*angle), side * cos(0.5*angle), 0)
        let v3 = SCNVector3Make(side * sin(0.5*angle), side * cos(0.5*angle), 0)
        let v4 = SCNVector3Make(side * sin(1.5*angle), side * cos(1.5*angle), 0)
        
        let vertices = [v0, v1, v2, v3, v4]
        
        let sources = SCNGeometrySource(vertices: vertices)
        let index: [Int32] = [
            0, 1, 2,
            0, 2, 3,
            0, 3, 4
        ]
        
        let elements = SCNGeometryElement(indices: index, primitiveType: .triangles)
        
        return SCNGeometry(sources: [sources], elements: [elements])
    }

    func contactTest() {
        guard !testing else { return }
        testing = true
        defer { testing = false }
        
        SCNTransaction.flush()
        
        guard let movablePhysicsBody = movableNode?.physicsBody,
              let fixedPhysicsBody = fixedNode?.physicsBody,
              let scene = scnView.scene else { return }
        
        let physicsContactList = scene.physicsWorld.contactTestBetween(movablePhysicsBody, fixedPhysicsBody)
        
//        var contactPairList = [ContactPair]()
//        for contact in physicsContactList {
//            guard let nameA = contact.nodeA.name,
//                  let nameB = contact.nodeB.name else { continue }
//            
//            let contactPair = ContactPair(nodeA: nameA, nodeB: nameB)
//            
//            if !contactPairList.contains(contactPair) {
//                contactPairList.append(contactPair)
//            }
//        }
//        
//        var contactText = ""
//        for pair in contactPairList {
//            contactText += "\(pair.nodeA), \(pair.nodeB)\n"
//        }
//        consoleLabel.text = contactText
        
        consoleLabel.text = "contact: \(!physicsContactList.isEmpty)"
    }
    
    func setupUI() {
        // ============== a ==============
        let axSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 720), size: CGSize(width: 900, height: 20)))
        let aySlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 760), size: CGSize(width: 900, height: 20)))
        let azSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 800), size: CGSize(width: 900, height: 20)))
        
        let range: Float = 0.5
        
        let axInitial = lineNodeA.x
        axSlider.tag = 0
        axSlider.minimumValue = axInitial - range
        axSlider.maximumValue = axInitial + range
        axSlider.value = axInitial
        
        let ayInitial = lineNodeA.y
        aySlider.tag = 1
        aySlider.minimumValue = ayInitial - range
        aySlider.maximumValue = ayInitial + range
        aySlider.value = ayInitial
        
        let azInitial = lineNodeA.z
        azSlider.tag = 2
        azSlider.minimumValue = azInitial - range
        azSlider.maximumValue = azInitial + range
        azSlider.value = azInitial
        
        axSlider.addTarget(self, action: #selector(aSliderValueChanged(_:)), for: .valueChanged)
        aySlider.addTarget(self, action: #selector(aSliderValueChanged(_:)), for: .valueChanged)
        azSlider.addTarget(self, action: #selector(aSliderValueChanged(_:)), for: .valueChanged)
        
        view.addSubview(axSlider)
        view.addSubview(aySlider)
        view.addSubview(azSlider)
        
        // ============== b ==============
        
        let bxSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 30), size: CGSize(width: 900, height: 20)))
        let bySlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 70), size: CGSize(width: 900, height: 20)))
        let bzSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 110), size: CGSize(width: 900, height: 20)))
        
        let bxInitial: Float = lineNodeB.x
        bxSlider.tag = 0
        bxSlider.minimumValue = bxInitial - range
        bxSlider.maximumValue = bxInitial + range
        bxSlider.value = bxInitial
        
        let byInitial: Float = lineNodeB.y
        bySlider.tag = 1
        bySlider.minimumValue = byInitial - range
        bySlider.maximumValue = byInitial + range
        bySlider.value = byInitial
        
        let bzInitial: Float = lineNodeB.z
        bzSlider.tag = 2
        bzSlider.minimumValue = bzInitial - range
        bzSlider.maximumValue = bzInitial + range
        bzSlider.value = bzInitial
        
        bxSlider.addTarget(self, action: #selector(bSliderValueChanged(_:)), for: .valueChanged)
        bySlider.addTarget(self, action: #selector(bSliderValueChanged(_:)), for: .valueChanged)
        bzSlider.addTarget(self, action: #selector(bSliderValueChanged(_:)), for: .valueChanged)
        
        view.addSubview(bxSlider)
        view.addSubview(bySlider)
        view.addSubview(bzSlider)
    }
    
    @objc func aSliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 0: lineNodeA = SCNVector3(sender.value, lineNodeA.y, lineNodeA.z)
        case 1: lineNodeA = SCNVector3(lineNodeA.x, sender.value, lineNodeA.z)
        case 2: lineNodeA = SCNVector3(lineNodeA.x, lineNodeA.y, sender.value)
        default: break
        }
        
        movableNode.removeFromParentNode()
        movableNode = createLine(nodeA: lineNodeA, nodeB: lineNodeB, color: .blue, radius: 0.001)
        rootNode.addChildNode(movableNode)
        
        contactTest()
    }
    
    @objc func bSliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 0: lineNodeB = SCNVector3(sender.value, lineNodeB.y, lineNodeB.z)
        case 1: lineNodeB = SCNVector3(lineNodeB.x, sender.value, lineNodeB.z)
        case 2: lineNodeB = SCNVector3(lineNodeB.x, lineNodeB.y, sender.value)
        default: break
        }

        movableNode.removeFromParentNode()
        movableNode = createLine(nodeA: lineNodeA, nodeB: lineNodeB, color: .blue, radius: 0.001)
        rootNode.addChildNode(movableNode)
        
        contactTest()
    }
    
    func createLine(nodeA: SCNVector3, nodeB: SCNVector3, color: UIColor, radius: Float) -> SCNNode {
        let height = sqrt(pow(nodeA.x - nodeB.x, 2) + pow(nodeA.y - nodeB.y, 2) + pow(nodeA.z - nodeB.z, 2))
        let cylinder = SCNCylinder(radius: CGFloat(radius), height: CGFloat(height))
        cylinder.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: cylinder)
        node.physicsBody = SCNPhysicsBody(
            type: .static,
            shape: SCNPhysicsShape(
                geometry: cylinder,
                options: [
                    SCNPhysicsShape.Option.scale : SCNVector3(x: 1, y: 1, z: 1)
                ]
            )
        )

        node.position = SCNVector3Make((nodeA.x + nodeB.x) / 2, (nodeA.y + nodeB.y) / 2, (nodeA.z + nodeB.z) / 2)
        node.eulerAngles = SCNVector3Make(Float(Double.pi / 2), acos((nodeB.z - nodeA.z) / height), atan2(nodeB.y - nodeA.y, nodeB.x - nodeA.x))
        return node
    }
}
