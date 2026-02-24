//
//  ARMeasureViewController.swift
//  Bottle of Water
//
//  Created by Yiğit Bal on 17.02.2026.
//

import UIKit
import ARKit
import SceneKit

// MARK: - Measurement step: only width and height (start + end each)
enum MeasurementStep {
    case width(startPoint: SCNVector3?)
    case height(startPoint: SCNVector3?)
}

final class ARMeasureViewController: UIViewController, ARSCNViewDelegate {

    private let sceneView = ARSCNView(frame: .zero)

    private static let pi: Float = 3.14

    // Consistent colors for width and height (lines and overlay)
    private static let widthColor = UIColor.cyan
    private static let heightColor = UIColor.systemGreen

    private var currentStep: MeasurementStep = .width(startPoint: nil)
    private var widthCm: Float = 0
    private var heightCm: Float = 0
    private var widthStartNode: SCNNode?
    private var widthEndNode: SCNNode?
    private var widthLineNode: SCNNode?
    private var heightStartNode: SCNNode?
    private var heightEndNode: SCNNode?
    private var heightLineNode: SCNNode?
    private var measurementComplete = false
    private var hintLabel: UILabel?
    private var measurementOverlay: UIView?
    private var widthLabel: UILabel?
    private var heightLabel: UILabel?
    private var totalVolumeLabel: UILabel?

    /// Called when user finishes volume measurement with value in mL.
    var onVolumeMeasured: ((Int) -> Void)?
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true

        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])


        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)
        addHintLabel()
        addMeasurementOverlay()
        addCloseButton()
        addUndoButton()
        refreshUndoButton()
    }

    /// On-screen panel: Width, Height, Total Volume (Estimated). Values stay fixed once set.
    private func addMeasurementOverlay() {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        container.layer.cornerRadius = 12
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading

        let widthLbl = makeMeasurementRow(title: "Width:", value: "—", valueColor: Self.widthColor)
        let heightLbl = makeMeasurementRow(title: "Height:", value: "—", valueColor: Self.heightColor)
        let totalVolLbl = makeMeasurementRow(title: "Total Volume (Estimated):", value: "—", valueColor: .white)

        widthLabel = widthLbl.valueLabel
        heightLabel = heightLbl.valueLabel
        totalVolumeLabel = totalVolLbl.valueLabel

        [widthLbl.row, heightLbl.row, totalVolLbl.row].forEach { stack.addArrangedSubview($0) }
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        measurementOverlay = container
    }

    private func makeMeasurementRow(title: String, value: String, valueColor: UIColor = .systemGreen) -> (row: UIView, valueLabel: UILabel) {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.textColor = .white
        titleLbl.font = .systemFont(ofSize: 14, weight: .medium)
        let valueLbl = UILabel()
        valueLbl.text = value
        valueLbl.textColor = valueColor
        valueLbl.font = .monospacedDigitSystemFont(ofSize: 14, weight: .semibold)
        row.addArrangedSubview(titleLbl)
        row.addArrangedSubview(valueLbl)
        return (row, valueLbl)
    }

    private func updateWidthOnScreen() {
        widthLabel?.text = String(format: "%.1f cm", widthCm)
    }

    private func updateHeightOnScreen() {
        heightLabel?.text = String(format: "%.1f cm", heightCm)
    }

    private func updateTotalVolumeOnScreen(estimatedML: Int) {
        totalVolumeLabel?.text = "\(estimatedML) mL"
    }

    private func clearMeasurementOverlay() {
        widthLabel?.text = "—"
        heightLabel?.text = "—"
        totalVolumeLabel?.text = "—"
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure AR view always has correct bounds (fixes black camera when presented in sheet)
        if sceneView.frame != view.bounds {
            sceneView.frame = view.bounds
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Restart session with correct view size if needed
        if sceneView.session.currentFrame == nil {
            startARSession()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    private func startARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            updateHint("AR not supported on this device")
            return
        }
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic
        config.isAutoFocusEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        updateHint("Tap start point for WIDTH")
    }

    private func addHintLabel() {
        let label = UILabel()
        label.text = "Tap start point for WIDTH"
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.numberOfLines = 2
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        hintLabel = label
    }

    private func addCloseButton() {
        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeBtn.layer.cornerRadius = 10
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeBtn)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            closeBtn.widthAnchor.constraint(equalToConstant: 70),
            closeBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func addUndoButton() {
        let undoBtn = UIButton(type: .system)
        undoBtn.setTitle("Undo", for: .normal)
        undoBtn.setTitleColor(.white, for: .normal)
        undoBtn.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.7)
        undoBtn.layer.cornerRadius = 10
        undoBtn.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        view.addSubview(undoBtn)
        undoBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            undoBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            undoBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            undoBtn.widthAnchor.constraint(equalToConstant: 64),
            undoBtn.heightAnchor.constraint(equalToConstant: 36)
        ])
        undoButton = undoBtn
    }
    private var undoButton: UIButton?

    @objc private func closeTapped() {
        sceneView.session.pause()
        onDismiss?()
        dismiss(animated: true)
    }

    private func refreshUndoButton() {
        undoButton?.isEnabled = canUndo()
        undoButton?.alpha = canUndo() ? 1 : 0.5
    }

    private func canUndo() -> Bool {
        if measurementComplete { return true }
        switch currentStep {
        case .width(let start): return start != nil
        case .height(let start): return start != nil || widthStartNode != nil
        }
    }

    @objc private func undoTapped() {
        if measurementComplete {
            measurementComplete = false
            heightLineNode?.removeFromParentNode()
            heightLineNode = nil
            heightEndNode?.removeFromParentNode()
            heightEndNode = nil
            heightCm = 0
            heightLabel?.text = "—"
            totalVolumeLabel?.text = "—"
            currentStep = .height(startPoint: heightStartNode?.position)
            updateHint("Tap end point for HEIGHT")
            refreshUndoButton()
            return
        }
        switch currentStep {
        case .width(let start):
            if start != nil {
                widthStartNode?.removeFromParentNode()
                widthStartNode = nil
                currentStep = .width(startPoint: nil)
                updateHint("Tap start point for WIDTH")
            }
        case .height(let start):
            if start != nil {
                heightStartNode?.removeFromParentNode()
                heightStartNode = nil
                currentStep = .height(startPoint: nil)
                updateHint("Tap end point for HEIGHT")
            } else {
                widthLineNode?.removeFromParentNode()
                widthLineNode = nil
                widthEndNode?.removeFromParentNode()
                widthEndNode = nil
                widthCm = 0
                widthLabel?.text = "—"
                currentStep = .width(startPoint: widthStartNode?.position)
                updateHint("Tap end point for WIDTH")
            }
        }
        refreshUndoButton()
    }

    private func updateHint(_ text: String) {
        hintLabel?.text = text
    }

    // MARK: - Tap-based measurement (Width then Height, each start + end)
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: sceneView)
        guard let worldPos = worldPosition(fromScreenPoint: point) else {
            updateHint("Point not found. Aim at a surface.")
            return
        }

        switch currentStep {
        case .width(let start):
            if let start = start {
                widthCm = distance(start, worldPos) * 100
                widthEndNode = addDot(at: worldPos, color: .red)
                widthLineNode = drawLine(from: start, to: worldPos, color: Self.widthColor)
                updateWidthOnScreen()
                currentStep = .height(startPoint: nil)
                updateHint("Tap start point for HEIGHT")
            } else {
                currentStep = .width(startPoint: worldPos)
                widthStartNode = addDot(at: worldPos, color: .green)
                updateHint("Tap end point for WIDTH")
            }
        case .height(let start):
            if let start = start {
                heightCm = distance(start, worldPos) * 100
                heightEndNode = addDot(at: worldPos, color: .red)
                heightLineNode = drawLine(from: start, to: worldPos, color: Self.heightColor)
                finishMeasurement()
            } else {
                currentStep = .height(startPoint: worldPos)
                heightStartNode = addDot(at: worldPos, color: .green)
                updateHint("Tap end point for HEIGHT")
            }
        }
        refreshUndoButton()
    }

    private func finishMeasurement() {
        updateHeightOnScreen()
        // Volume = π × (r²) × height; radius = half of width; π = 3.14
        let radiusCm = widthCm / 2
        let radiusSquared = radiusCm * radiusCm
        let volumeCm3 = Self.pi * radiusSquared * heightCm
        let volumeML = Int(round(volumeCm3))
        let clampedML = max(1, min(50000, volumeML))

        updateTotalVolumeOnScreen(estimatedML: clampedML)
        updateHint("Total Volume: \(clampedML) mL. Use as glass or measure again.")
        measurementComplete = true
        refreshUndoButton()

        let alert = UIAlertController(
            title: "Volume: \(clampedML) mL",
            message: "π × (radius²) × height. Use as glass size or measure again?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Use as my glass", style: .default) { [weak self] _ in
            self?.onVolumeMeasured?(clampedML)
            self?.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Measure again", style: .cancel) { [weak self] _ in
            self?.resetAll()
        })
        present(alert, animated: true)
    }

    @discardableResult
    private func addDot(at position: SCNVector3, color: UIColor) -> SCNNode {
        let sphere = SCNSphere(radius: 0.008)
        sphere.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: sphere)
        node.position = position
        sceneView.scene.rootNode.addChildNode(node)
        return node
    }

    @discardableResult
    private func drawLine(from start: SCNVector3, to end: SCNVector3, color: UIColor) -> SCNNode {
        let node = makeLineNode(from: start, to: end, color: color)
        sceneView.scene.rootNode.addChildNode(node)
        return node
    }

    private func makeLineNode(from start: SCNVector3, to end: SCNVector3, color: UIColor) -> SCNNode {
        let vertices: [SCNVector3] = [start, end]
        let source = SCNGeometrySource(vertices: vertices)
        var indices: [UInt32] = [0, 1]
        let indexData = Data(bytes: &indices, count: indices.count * MemoryLayout<UInt32>.size)
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .line,
            primitiveCount: 1,
            bytesPerIndex: MemoryLayout<UInt32>.size
        )
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = color
        geometry.firstMaterial?.isDoubleSided = true
        return SCNNode(geometry: geometry)
    }

    private func distance(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        let dx = b.x - a.x, dy = b.y - a.y, dz = b.z - a.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }

    private func resetAll() {
        [widthLineNode, widthEndNode, widthStartNode, heightLineNode, heightEndNode, heightStartNode].forEach { $0?.removeFromParentNode() }
        widthStartNode = nil
        widthEndNode = nil
        widthLineNode = nil
        heightStartNode = nil
        heightEndNode = nil
        heightLineNode = nil
        widthCm = 0
        heightCm = 0
        measurementComplete = false
        currentStep = .width(startPoint: nil)
        clearMeasurementOverlay()
        updateHint("Tap start point for WIDTH")
        refreshUndoButton()
    }

    private func worldPosition(fromScreenPoint point: CGPoint) -> SCNVector3? {
        if let query = sceneView.raycastQuery(from: point, allowing: .estimatedPlane, alignment: .any) {
            let results = sceneView.session.raycast(query)
            if let first = results.first {
                let t = first.worldTransform
                return SCNVector3(t.columns.3.x, t.columns.3.y, t.columns.3.z)
            }
        }
        let hits = sceneView.hitTest(point, types: [.featurePoint])
        if let hit = hits.first {
            let t = hit.worldTransform
            return SCNVector3(t.columns.3.x, t.columns.3.y, t.columns.3.z)
        }
        return nil
    }

}
