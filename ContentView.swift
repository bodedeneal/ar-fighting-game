import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("AR Terrain - Image Locked")
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                VStack {
                    Text("Point camera at a reference image to lock terrain in place (9x9 grid)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}