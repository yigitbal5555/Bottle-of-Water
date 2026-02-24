//
//  ARMeasureViewController.swift
//  (Diğer projenize kopyalayın – kamera düzeltmeleri uygulanmış)
//

import UIKit
import ARKit
import SceneKit

final class ARMeasureViewController: UIViewController, ARSCNViewDelegate {

    private let sceneView = ARSCNView(frame: .zero)

    // Volume mode: 3 dimensions from 6 taps (start/end for length, width, height)
    private var lengthStart: SCNNode?
    private var lengthEnd: SCNNode?
    private var widthStart: SCNNode?
    private var widthEnd: SCNNode?
    private var heightStart: SCNNode?
    private var heightEnd: SCNNode?
    private var lineNodes: [SCNNode] = []
    private var textNode: SCNNode?
    private var hintLabel: UILabel?

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
        addCloseButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Kamera düzeltmesi: Sheet içinde siyah kamera sorununu giderir
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
        // View boyutu doğru olduktan sonra frame yoksa oturumu yeniden başlat (kamera düzeltmesi)
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
        updateHint("Tap start of LENGTH (first edge)")
    }

    private func addHintLabel() {
        let label = UILabel()
        label.text = "Tap start of LENGTH (first edge)"
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
        let btn = UIButton(type: .system)
        btn.setTitle("Close", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            btn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            btn.widthAnchor.constraint(equalToConstant: 70),
            btn.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func closeTapped() {
        sceneView.session.pause()
        onDismiss?()
        dismiss(animated: true)
    }

    private func updateHint(_ text: String) {
        hintLabel?.text = text
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: sceneView)
        guard let worldPos = worldPosition(fromScreenPoint: point) else {
            updateHint("Point not found. Aim at a surface.")
            return
        }

        if lengthStart == nil {
            resetAll()
            lengthStart = makeDotNode(at: worldPos, color: .green)
            sceneView.scene.rootNode.addChildNode(lengthStart!)
            updateHint("Tap end of LENGTH")
        } else if lengthEnd == nil {
            lengthEnd = makeDotNode(at: worldPos, color: .red)
            sceneView.scene.rootNode.addChildNode(lengthEnd!)
            drawLine(from: lengthStart!.position, to: lengthEnd!.position, color: .yellow)
            updateHint("Tap start of WIDTH (second edge)")
        } else if widthStart == nil {
            widthStart = makeDotNode(at: worldPos, color: .green)
            sceneView.scene.rootNode.addChildNode(widthStart!)
            updateHint("Tap end of WIDTH")
        } else if widthEnd == nil {
            widthEnd = makeDotNode(at: worldPos, color: .red)
            sceneView.scene.rootNode.addChildNode(widthEnd!)
            drawLine(from: widthStart!.position, to: widthEnd!.position, color: .cyan)
            updateHint("Tap start of HEIGHT (third edge)")
        } else if heightStart == nil {
            heightStart = makeDotNode(at: worldPos, color: .green)
            sceneView.scene.rootNode.addChildNode(heightStart!)
            updateHint("Tap end of HEIGHT")
        } else {
            heightEnd = makeDotNode(at: worldPos, color: .red)
            sceneView.scene.rootNode.addChildNode(heightEnd!)
            drawLine(from: heightStart!.position, to: heightEnd!.position, color: .orange)
            showVolumeAndOfferUse()
        }
    }

    private func showVolumeAndOfferUse() {
        guard let l = lengthStart?.position, let le = lengthEnd?.position,
              let w = widthStart?.position, let we = widthEnd?.position,
              let h = heightStart?.position, let he = heightEnd?.position else { return }

        let lengthM = distance(l, le)
        let widthM = distance(w, we)
        let heightM = distance(h, he)
        let lengthCm = lengthM * 100
        let widthCm = widthM * 100
        let heightCm = heightM * 100
        let volumeCm3 = lengthCm * widthCm * heightCm
        let volumeML = Int(round(volumeCm3))

        let clampedML = max(50, min(2000, volumeML))
        let mid = SCNVector3(
            (l.x + le.x + w.x + we.x + h.x + he.x) / 6,
            (l.y + le.y + w.y + we.y + h.y + he.y) / 6,
            (l.z + le.z + w.z + we.z + h.z + he.z) / 6
        )
        textNode?.removeFromParentNode()
        let text = makeTextNode("\(clampedML) mL\n(L×W×H)", at: mid)
        textNode = text
        sceneView.scene.rootNode.addChildNode(text)

        updateHint("Volume: \(clampedML) mL. Tap anywhere to measure again.")

        let alert = UIAlertController(
            title: "Volume: \(clampedML) mL",
            message: "Use this as your glass size or measure another object?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Use as my glass", style: .default) { [weak self] _ in
            self?.onVolumeMeasured?(clampedML)
            self?.dismiss(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Measure again", style: .cancel) { [weak self] _ in
            self?.resetAll()
            self?.updateHint("Tap start of LENGTH (first edge)")
        })
        present(alert, animated: true)
    }

    private func resetAll() {
        [lengthStart, lengthEnd, widthStart, widthEnd, heightStart, heightEnd].forEach { $0?.removeFromParentNode() }
        lengthStart = nil
        lengthEnd = nil
        widthStart = nil
        widthEnd = nil
        heightStart = nil
        heightEnd = nil
        lineNodes.forEach { $0.removeFromParentNode() }
        lineNodes.removeAll()
        textNode?.removeFromParentNode()
        textNode = nil
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

    private func makeDotNode(at position: SCNVector3, color: UIColor) -> SCNNode {
        let sphere = SCNSphere(radius: 0.008)
        sphere.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: sphere)
        node.position = position
        return node
    }

    private func drawLine(from start: SCNVector3, to end: SCNVector3, color: UIColor) {
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
        let node = SCNNode(geometry: geometry)
        sceneView.scene.rootNode.addChildNode(node)
        lineNodes.append(node)
    }

    private func distance(_ a: SCNVector3, _ b: SCNVector3) -> Float {
        let dx = b.x - a.x, dy = b.y - a.y, dz = b.z - a.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }

    private func makeTextNode(_ text: String, at position: SCNVector3) -> SCNNode {
        let scnText = SCNText(string: text, extrusionDepth: 0.2)
        scnText.font = UIFont.systemFont(ofSize: 6, weight: .bold)
        scnText.firstMaterial?.diffuse.contents = UIColor.white
        let node = SCNNode(geometry: scnText)
        node.position = position
        node.scale = SCNVector3(0.002, 0.002, 0.002)
        node.constraints = [SCNBillboardConstraint()]
        let (minB, maxB) = scnText.boundingBox
        node.pivot = SCNMatrix4MakeTranslation((minB.x + maxB.x) / 2, minB.y, 0)
        return node
    }
}
