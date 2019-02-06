import Foundation
import AVFoundation

public final class BarcodeScanner {
    private final class MetadataDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var didOutput: ((String) -> Void)?

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let codeObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let code = codeObject.stringValue else {
                return
            }

            didOutput?(code)
        }
    }

    private let captureSession: AVCaptureSession
    private let delegate: MetadataDelegate

    public init?(metadataObjectTypes: [AVMetadataObject.ObjectType]) {
        captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return nil
        }

        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return nil
        }

        guard captureSession.canAddInput(captureInput) else {
            return nil
        }

        captureSession.addInput(captureInput)

        let captureOutput = AVCaptureMetadataOutput()

        guard captureSession.canAddOutput(captureOutput) else {
            return nil
        }

        captureSession.addOutput(captureOutput)

        for metadataObjectType in metadataObjectTypes {
            if !captureOutput.availableMetadataObjectTypes.contains(metadataObjectType) {
                return nil
            }
        }

        captureOutput.metadataObjectTypes = metadataObjectTypes

        delegate = MetadataDelegate()

        captureOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
    }

    public var didOutput: ((String) -> Void)? {
        get {
            return delegate.didOutput
        }
        set {
            delegate.didOutput = newValue
        }
    }

    public func start() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    public func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    public func makeVideoLayerWith(videoGravity: AVLayerVideoGravity) -> CALayer {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = videoGravity

        return layer
    }
}
