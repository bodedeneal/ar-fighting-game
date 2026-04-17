import ARKit
import RealityKit

class TerrainGenerator {
    static func generateTerrain(anchor: AnchorEntity, gridSize: Int = 9, pixelSize: Float = 1.0) {
        let totalSize = Float(gridSize) * pixelSize
        let halfSize = totalSize / 2
        
        var vertices: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        
        let heightMap = generateHeightMap(gridSize: gridSize)
        
        for z in 0...gridSize {
            for x in 0...gridSize {
                let posX = Float(x) * pixelSize - halfSize
                let posZ = Float(z) * pixelSize - halfSize
                
                let heightIndex = min(z * gridSize + x, heightMap.count - 1)
                let height = heightMap[heightIndex]
                
                vertices.append(SIMD3<Float>(posX, height, posZ))
            }
        }
        
        for z in 0..<gridSize {
            for x in 0..<gridSize {
                let topLeft = UInt32(z * (gridSize + 1) + x)
                let topRight = UInt32(z * (gridSize + 1) + x + 1)
                let bottomLeft = UInt32((z + 1) * (gridSize + 1) + x)
                let bottomRight = UInt32((z + 1) * (gridSize + 1) + x + 1)
                
                indices.append(topLeft)
                indices.append(bottomLeft)
                indices.append(topRight)
                
                indices.append(topRight)
                indices.append(bottomLeft)
                indices.append(bottomRight)
            }
        }
        
        print("📊 Created mesh with \(vertices.count) vertices and \(indices.count/3) triangles")
        
        if let mesh = createMesh(vertices: vertices, indices: indices) {
            var terrainModel = ModelEntity(mesh: mesh, materials: [createTerrainMaterial()])
            terrainModel.position = [0, 0, 0]
            anchor.addChild(terrainModel)
            
            print("🌍 Terrain mesh created and locked to image anchor")
        }
    }
    
    static func generateHeightMap(gridSize: Int) -> [Float] {
        let totalPoints = (gridSize + 1) * (gridSize + 1)
        var heightMap: [Float] = Array(repeating: 0, count: totalPoints)
        
        for z in 0...gridSize {
            for x in 0...gridSize {
                let index = z * (gridSize + 1) + x
                
                let noise1 = sin(Float(x) * 0.3) * cos(Float(z) * 0.3) * 0.3
                let noise2 = sin(Float(x) * 0.15) * cos(Float(z) * 0.15) * 0.2
                
                heightMap[index] = noise1 + noise2
            }
        }
        
        return heightMap
    }
    
    static func createMesh(vertices: [SIMD3<Float>], indices: [UInt32]) -> Mesh? {
        var meshDescriptor = MeshDescriptor()
        
        meshDescriptor.positions = MeshBuffers.Positions(vertices)
        meshDescriptor.primitives = .triangles(indices)
        
        var normals: [SIMD3<Float>] = []
        for _ in vertices {
            normals.append([0, 1, 0])
        }
        meshDescriptor.normals = MeshBuffers.Normals(normals)
        
        var texCoords: [SIMD2<Float>] = []
        for i in 0..<vertices.count {
            let u = Float(i % 10) / 10.0
            let v = Float(i / 10) / 10.0
            texCoords.append([u, v])
        }
        meshDescriptor.textureCoordinates = MeshBuffers.TextureCoordinates(texCoords)
        
        return try? Mesh(from: [meshDescriptor])
    }
    
    static func createTerrainMaterial() -> Material {
        var material = SimpleMaterial()
        material.color = .init(tint: .green)
        return material
    }
}