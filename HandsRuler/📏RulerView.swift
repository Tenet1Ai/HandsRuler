import SwiftUI
import RealityKit
import ARKit

struct 📏RulerView: View {
    @StateObject private var model: 📏RulerModel = .init()
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.rootEntity)
            self.model.setUpChildEntities()
            
            let resultEntity = attachments.entity(for: "result")!
            resultEntity.components.set(🧑HeadTrackingComponent())
            resultEntity.name = "result"
            self.model.rootEntity.addChild(resultEntity)
            
            self.model.setUp_simulator()
        } update: { _, attachments in
            self.model.logs.elements.forEach { log in
                let fixedResultEntity = attachments.entity(for: "\(log.id)")!
                fixedResultEntity.components.set(🧑HeadTrackingComponent())
                fixedResultEntity.position = (log.leftPosition + log.rightPosition) / 2
                if let fixedRulerEntity = self.model.rootEntity.findEntity(named: "\(log.id)") {
                    fixedRulerEntity.addChild(fixedResultEntity)
                }
            }
            //重複してentityが追加されてないか後日チェックする
        } attachments: {
            Attachment(id: "result") {
                self.resultView(self.model.resultValue)
            }
            ForEach(self.model.logs.elements) { log in
                Attachment(id: "\(log.id)") {
                    self.resultView(log.lineLength)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.model.tap($0.entity) }
        )
        .task { self.model.run() }
    }
}

private extension 📏RulerView {
    private func resultView(_ lineLength: Float) -> some View {
        Text(🪧ResultFormatter.string(lineLength, self.model.unit))
            .font(.system(size: max(.init(lineLength * 30), 20)))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .glassBackgroundEffect()
            .modifier(Self.SetRandomPosition_Simulator(self.model))
    }
}




//MARK: Simulator
private extension 📏RulerView {
    private struct SetRandomPosition_Simulator: ViewModifier {
        var model: 📏RulerModel
        func body(content: Content) -> some View {
            content
#if targetEnvironment(simulator)
                .onTapGesture { self.model.setRandomPosition_simulator() }
#endif
        }
        init(_ model: 📏RulerModel) {
            self.model = model
        }
    }
}
