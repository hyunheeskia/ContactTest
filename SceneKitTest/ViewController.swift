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
        
//        let physicsBodyNode = SCNNode()
//        physicsBodyNode.name = "fixedPhysics"
//        physicsBodyNode.position = center
//        physicsBodyNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNSphere(radius: CGFloat(radius))))
//        fixedNode.addChildNode(physicsBodyNode)
        
        // physics
        fixedNode.physicsBody =
            SCNPhysicsBody(type: .static, shape:
//                            SCNPhysicsShape(geometry: smallSphereGeometry())
//                                    nil
                        SCNPhysicsShape(node: fixedNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        ////                           SCNPhysicsShape(node: fixedNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.boundingBox])
            )
        
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
//                              probeShapeGeometry()
        )
        movableNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        movableNode.name = "movable"
        movableNode.position = SCNVector3(0.3, 0, -0.8)

        // physics
        movableNode.physicsBody =
            SCNPhysicsBody(type: .static, shape:
//                nil
//                           SCNPhysicsShape(node: movableNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.concavePolyhedron])
//                           SCNPhysicsShape(node: movableNode, options: [SCNPhysicsShape.Option.type : SCNPhysicsShape.ShapeType.boundingBox])
                           SCNPhysicsShape(geometry: smallShapeGeometry())
            )
        
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
        // ============== position ==============
        
        let xpSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 720), size: CGSize(width: 900, height: 20)))
        let ypSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 760), size: CGSize(width: 900, height: 20)))
        let zpSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 800), size: CGSize(width: 900, height: 20)))
        
        let pRange: Float = 0.5
        
        let xpInitial = movableNode.position.x
        xpSlider.tag = 0
        xpSlider.minimumValue = xpInitial - pRange
        xpSlider.maximumValue = xpInitial + pRange
        xpSlider.value = xpInitial
        
        let ypInitial = movableNode.position.y
        ypSlider.tag = 1
        ypSlider.minimumValue = ypInitial - pRange
        ypSlider.maximumValue = ypInitial + pRange
        ypSlider.value = ypInitial
        
        let zpInitial = movableNode.position.z
        zpSlider.tag = 2
        zpSlider.minimumValue = zpInitial - pRange
        zpSlider.maximumValue = zpInitial + pRange
        zpSlider.value = zpInitial
        
        xpSlider.addTarget(self, action: #selector(pSliderValueChanged(_:)), for: .valueChanged)
        ypSlider.addTarget(self, action: #selector(pSliderValueChanged(_:)), for: .valueChanged)
        zpSlider.addTarget(self, action: #selector(pSliderValueChanged(_:)), for: .valueChanged)
        
        view.addSubview(xpSlider)
        view.addSubview(ypSlider)
        view.addSubview(zpSlider)
        
        // ============== rotation ==============
        
        let xrSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 30), size: CGSize(width: 900, height: 20)))
        let yrSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 70), size: CGSize(width: 900, height: 20)))
        let zrSlider = UISlider(frame: CGRect(origin: CGPoint(x: 250, y: 110), size: CGSize(width: 900, height: 20)))
        
        let rRange = Float.pi / 2
        
        let xrInitial: Float = 0
        xrSlider.tag = 0
        xrSlider.minimumValue = xrInitial - rRange
        xrSlider.maximumValue = xrInitial + rRange
        xrSlider.value = xrInitial
        
        let yrInitial: Float = 0
        yrSlider.tag = 1
        yrSlider.minimumValue = yrInitial - rRange
        yrSlider.maximumValue = yrInitial + rRange
        yrSlider.value = yrInitial
        
        let zrInitial: Float = 0
        zrSlider.tag = 2
        zrSlider.minimumValue = zrInitial - rRange
        zrSlider.maximumValue = zrInitial + rRange
        zrSlider.value = zrInitial
        
        xrSlider.addTarget(self, action: #selector(rSliderValueChanged(_:)), for: .valueChanged)
        yrSlider.addTarget(self, action: #selector(rSliderValueChanged(_:)), for: .valueChanged)
        zrSlider.addTarget(self, action: #selector(rSliderValueChanged(_:)), for: .valueChanged)
        
        view.addSubview(xrSlider)
        view.addSubview(yrSlider)
        view.addSubview(zrSlider)
    }
    
    @objc func pSliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 0: movableNode.position = SCNVector3(sender.value, movableNode.position.y, movableNode.position.z)
        case 1: movableNode.position = SCNVector3(movableNode.position.x, sender.value, movableNode.position.z)
        case 2: movableNode.position = SCNVector3(movableNode.position.x, movableNode.position.y, sender.value)
        default: break
        }
        
        contactTest()
    }
    
    @objc func rSliderValueChanged(_ sender: UISlider) {
        switch sender.tag {
        case 0: movableNode.eulerAngles = SCNVector3(sender.value, movableNode.eulerAngles.y, movableNode.eulerAngles.z)
        case 1: movableNode.eulerAngles = SCNVector3(movableNode.eulerAngles.x, sender.value, movableNode.eulerAngles.z)
        case 2: movableNode.eulerAngles = SCNVector3(movableNode.eulerAngles.x, movableNode.eulerAngles.y, sender.value)
        default: break
        }
        
        contactTest()
    }
}
