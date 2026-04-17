import UIKit
import ARKit
import RealityKit

class ARViewController: UIViewController, ARSessionDelegate {
    var arView: ARView!
    var terrainAnchor: AnchorEntity?
    var imageAnchor: ARImageAnchor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView = ARView(frame: view.bounds)
        view.addSubview(arView)
        
        setupARSession()
    }
    
    func setupARSession() {
        let configuration = ARImageTrackingConfiguration()
        
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.trackingImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 1
        } else {
            print("⚠️ No reference images found in 'AR Resources' asset catalog")
            print("ℹ️ Add images to Assets.xcassets > Right click > Create new AR Reference Image Set")
        }
        
        if ARImageTrackingConfiguration.isSupported {
            arView.session.run(configuration)
            arView.session.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARImageTrackingConfiguration()
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.trackingImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        
        arView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
    }
}

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [AnchorProtocol]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                DispatchQueue.main.async {
                    self.handleImageDetected(imageAnchor)
                }
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [AnchorProtocol]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                DispatchQueue.main.async {
                    self.updateTerrainPosition(imageAnchor)
                }
            }
        }
    }
    
    func handleImageDetected(_ imageAnchor: ARImageAnchor) {
        print("✅ Image detected: \(imageAnchor.name ?? \"Unknown\")")
        print("📍 Image size: \(imageAnchor.extent)")
        
        self.imageAnchor = imageAnchor
        
        if let oldAnchor = terrainAnchor {
            arView.scene.removeAnchor(oldAnchor)
        }
        
        let anchorEntity = AnchorEntity(anchor: imageAnchor)
        arView.scene.addAnchor(anchorEntity)
        
        TerrainGenerator.generateTerrain(anchor: anchorEntity, gridSize: 9, pixelSize: 1.0)
        
        terrainAnchor = anchorEntity
        print("🎮 9x9 terrain grid locked to image anchor")
    }
    
    func updateTerrainPosition(_ imageAnchor: ARImageAnchor) {
        // Terrain stays locked as the image anchor updates
    }
}
