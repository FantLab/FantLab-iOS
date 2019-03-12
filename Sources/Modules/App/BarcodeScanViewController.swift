import UIKit
import AVFoundation
import FLKit
import FLStyle

final class BarcodeScannerViewController: UIViewController {
    private let scanner: BarcodeScanner

    private var videoLayer: CALayer?

    init?(metadataObjectTypes: [AVMetadataObject.ObjectType] = [.ean13, .ean8]) {
        guard let scanner = BarcodeScanner(metadataObjectTypes: metadataObjectTypes) else {
            return nil
        }

        self.scanner = scanner

        super.init(nibName: nil, bundle: nil)
    }

    var close: ((String?) -> Void)?

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black

        do {
            let layer = scanner.makeVideoLayerWith(videoGravity: .resizeAspectFill)
            view.layer.addSublayer(layer)

            videoLayer = layer
        }

        do {
            let text = "Наведите камеру\nна ISBN штрихкод".attributed()
                .font(Fonts.system.medium(size: 32))
                .foregroundColor(UIColor.white)
                .shadow(offsetX: 1, offsetY: -1, blurRadius: 2, color: UIColor.black)
                .make()

            let label = UILabel()
            label.numberOfLines = 0
            label.attributedText = text

            view.addSubview(label)

            label.pin(.centerX).to(view).equal()
            label.pin(.top).to(view.safeAreaLayoutGuide).const(24).equal()
        }

        do {
            let text = "Закрыть".attributed()
                .font(Fonts.system.medium(size: 24))
                .foregroundColor(UIColor.white)
                .shadow(offsetX: 1, offsetY: -1, blurRadius: 2, color: UIColor.black)
                .make()

            let btn = UIButton(type: .system)
            btn.setAttributedTitle(text, for: .normal)
            btn.all_setEventHandler(for: .touchUpInside) { [weak self] in
                self?.close?(nil)
            }

            view.addSubview(btn)

            btn.pin(.centerX).to(view).equal()
            btn.pin(.bottom).to(view.safeAreaLayoutGuide).const(-100).equal()
        }

        do {
            view.all_addGestureRecognizer { [weak self] (swipe: UISwipeGestureRecognizer) in
                self?.close?(nil)
            }.direction = .down
        }

        scanner.didOutput = { [weak self] code in
            self?.found(code: code)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        scanner.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        scanner.stop()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        videoLayer?.frame = view.bounds
    }

    // MARK: -

    private func found(code: String) {
        close?(code)
    }
}
