class SwipeToReplyHandler: NSObject {

    private weak var cell: UITableViewCell?
    private weak var targetView: UIView?
    private let arrowContainerView = UIView()
    private let arrowImageView = UIImageView()
    private var hapticFired = false

    init(for targetView: UIView, in cell: UITableViewCell) {
        self.targetView = targetView
        self.cell = cell
        super.init()
        setupArrowView()
        setupPanGesture()
    }

    private func setupArrowView() {
        guard let contentView = cell?.contentView else { return }

        // Setup container view
        arrowContainerView.backgroundColor = .colorE8E8E8
        arrowContainerView.layer.cornerRadius = 18
        arrowContainerView.clipsToBounds = true
        arrowContainerView.alpha = 0
        arrowContainerView.translatesAutoresizingMaskIntoConstraints = false

        // Setup image view
        arrowImageView.image = UIImage(named: "ic_SwipeReply")
        //arrowImageView.tintColor = .white
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false

        // Add views
        arrowContainerView.addSubview(arrowImageView)
        contentView.addSubview(arrowContainerView)

        // Container constraints
        NSLayoutConstraint.activate([
            arrowContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -6),
            arrowContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            arrowContainerView.widthAnchor.constraint(equalToConstant: 36),
            arrowContainerView.heightAnchor.constraint(equalToConstant: 36)
        ])

        // Image constraints inside container
        NSLayoutConstraint.activate([
            arrowImageView.centerXAnchor.constraint(equalTo: arrowContainerView.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: arrowContainerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    private func setupPanGesture() {
        guard let view = targetView else { return }

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = targetView, let cell = cell else { return }

        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        let swipeX = translation.x
        let swipeY = abs(translation.y)

        // Prevent false positives when scrolling vertically
        if swipeX < 15 || swipeX < swipeY {
            return
        }

        switch gesture.state {
        case .began, .changed:
            if swipeX > 0 {
                let limited = min(swipeX, 100)
                let eased = limited * 0.7
                view.transform = CGAffineTransform(translationX: eased, y: 0)
                arrowContainerView.alpha = min(eased / 80, 1.0)

                if eased > 70, !hapticFired {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    hapticFired = true
                }
            }

        case .ended, .cancelled:
            if swipeX > 70 {
                NotificationCenter.default.post(name: .didSwipeToReply, object: cell)
            }

            UIView.animate(withDuration: 0.25) {
                view.transform = .identity
                self.arrowContainerView.alpha = 0
            }

            hapticFired = false

        default:
            break
        }
    }

}

extension SwipeToReplyHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
