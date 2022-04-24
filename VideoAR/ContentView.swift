
//  ContentView.swift
//  VideoAR


import SwiftUI
import RealityKit
import AVFoundation

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        //create a function to play
        detectShape(in: arView)
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func detectShape(in arView: ARView){
        //define monitor dimension
        let dimensions: SIMD3<Float> = [0.5, 0.02, 0.28] //in m, wide,thickness,height
        //create 2 parts, for 3d looks, make it pop up a bit
        let housingMesh = MeshResource.generateBox(size: dimensions)
        let housingMat = SimpleMaterial(color: .black,roughness: 0.4, isMetallic: false)
        let housingEntity = ModelEntity(mesh:housingMesh, materials: [housingMat])
        
        let displayMesh = MeshResource.generatePlane(width: dimensions.x, depth:  dimensions.z)
        let displayMat = SimpleMaterial(color: .white,roughness: 0.2, isMetallic: false)
        let displayEntity = ModelEntity(mesh:displayMesh, materials: [displayMat])
        
        displayEntity.name = "rectangularShape"
        
        //add display screen to Housing
        housingEntity.addChild(displayEntity)
        //pull a bit out to avoid glitch
        displayEntity.setPosition([0,dimensions.y/2+0.001,0], relativeTo: housingEntity)
        
        // create anchor to place monitor on wall
        let anchor = AnchorEntity(plane: .vertical)
        anchor.addChild(housingEntity)
        arView.scene.addAnchor(anchor)
        
        arView.enableTapGesture()
        housingEntity.generateCollisionShapes(recursive:true)
        
    }
    
}
extension ARView{
    func enableTapGesture(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer )
    }
    @objc func handleTap(recognizer:UITapGestureRecognizer){
        let tapLocation = recognizer.location(in: self)
        
        if let entity = self.entity (at:tapLocation) as?ModelEntity, entity.name == "rectangularShape"{
            loadVideoMaterial(for: entity)
        }
    }
    func loadVideoMaterial(for entity: ModelEntity){
        let asset = AVAsset(url:Bundle.main.url(forResource: "HawkerCulture", withExtension: "mp4")!)
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer()
        entity.model?.materials = [VideoMaterial(avPlayer: player)]
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
