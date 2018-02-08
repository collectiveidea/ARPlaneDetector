//
//  ARSceneManager.swift
//  ARPlaneDetector
//
//  Created by Ben Lambert on 2/8/18.
//  Copyright © 2018 collectiveidea. All rights reserved.
//

import Foundation
import ARKit

class ARSceneManager: NSObject {
    
    private var planes = [UUID: Plane]()
    
    weak var sceneView: ARSCNView?
    
    func attach(to sceneView: ARSCNView) {
        self.sceneView = sceneView
        
        self.sceneView!.delegate = self
        
        configureSceneView(self.sceneView!)
    }
    
    private func configureSceneView(_ sceneView: ARSCNView) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
    }
    
    func displayDegubInfo() {
        sceneView?.showsStatistics = true
        sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    
}

extension ARSceneManager: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // we only care about planes
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        print("Found plane: \(planeAnchor)")
        
        let plane = Plane(anchor: planeAnchor)
        
        // store a local reference to the plane
        planes[anchor.identifier] = plane
        
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
    
}
