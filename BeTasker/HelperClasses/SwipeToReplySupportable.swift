class SwipeToReplyHandler: NSObject {

    private weak var cell: UITableViewCell?
    private weak var targetView: UIView?
    private var arrowView = UIImageView()
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

        arrowView.image = UIImage(systemName: "arrowshape.turn.up.left.fill")
        arrowView.tintColor = .white
        arrowView.backgroundColor = .systemGray3
        arrowView.layer.cornerRadius = 18
        arrowView.clipsToBounds = true
        arrowView.alpha = 0
        arrowView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(arrowView)

        NSLayoutConstraint.activate([
            arrowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -12),
            arrowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            arrowView.widthAnchor.constraint(equalToConstant: 36),
            arrowView.heightAnchor.constraint(equalToConstant: 36)
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
        let swipeX = translation.x

        switch gesture.state {
        case .began, .changed:
            if swipeX > 0 {
                let limited = min(swipeX, 100)
                let eased = limited * 0.7
                view.transform = CGAffineTransform(translationX: eased, y: 0)
                arrowView.alpha = min(eased / 80, 1.0)

                if eased > 70, !hapticFired {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    hapticFired = true
                }
            }

        case .ended, .cancelled:
            if swipeX > 70 {
                NotificationCenter.default.post(name: .didSwipeToReply, object: cell)
            }

            UIView.animate(withDuration: 0.25, animations: {
                view.transform = .identity
                self.arrowView.alpha = 0
            })

            hapticFired = false

        default: break
        }
    }
}

extension SwipeToReplyHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
