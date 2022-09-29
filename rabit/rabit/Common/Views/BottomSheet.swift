import UIKit
import SnapKit

final class BottomSheet: UIControl {
    
    private let topBarArea: UIView = UIView()
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.roundCorners(4)
        return view
    }()
    
    let contentView = UIView()
    private var minTopOffset: CGFloat = .zero
    private var maxTopOffset: CGFloat = .zero
    private var closeFlag = false {
        didSet { if closeFlag { sendActions(for: .valueChanged) } }
    }
    
    convenience init(_ maxTopOffset: CGFloat, _ minTopOffset: CGFloat) {
        self.init()
        self.maxTopOffset = maxTopOffset
        self.minTopOffset = minTopOffset
        setupViews()
        addPanGestureRecognizer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addPanGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView == self ? nil : hitView
    }
    
    private func addPanGestureRecognizer() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        topBarArea.addGestureRecognizer(recognizer)
    }
    
    @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
        //이동된 y 거리 계산
        let updatedY = frame.minY + recognizer.translation(in: self).y
        
        //updatedY의 범위가 기존의 topOffset 이하인 지 판벼
        if (minTopOffset...maxTopOffset) ~= updatedY {
            updateConstraints(updatedY)
            recognizer.setTranslation(.zero, in: self)
        }
        UIView.animate(withDuration: 0.0, delay: .zero, animations: layoutIfNeeded)
        
        //recognizer이 끝났을 때 상태 업데이트
        guard recognizer.state == .ended else { return }
        let isDownward = recognizer.velocity(in: self).y > 0
        let yPosition: CGFloat = updatedY > maxTopOffset*0.7 ? maxTopOffset : updatedY

        if isDownward {
            updateConstraints(yPosition)
        } else {
            updateConstraints(minTopOffset)
        }
        
        if yPosition >= maxTopOffset {
            closeFlag = true
        }        
    }
    
    private func setupViews() {
        
        addSubview(topBarArea)
        topBarArea.snp.makeConstraints {
            $0.left.right.top.equalToSuperview()
            $0.height.equalTo(21)
        }
        
        topBarArea.addSubview(topBar)
        topBar.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.5)
            $0.height.equalTo(7)
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(topBarArea.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.equalToSuperview().multipliedBy(0.83)
        }
    }
}

extension BottomSheet {
    
    private func updateConstraints(_ topOffset: CGFloat) {
        self.snp.remakeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(topOffset)
        }
    }
    
    func move(upTo topOffset: CGFloat,
              duration: CGFloat,
              animation: @escaping () -> Void,
              completion: @escaping (Bool) -> Void = { _ in }) {
        
        updateConstraints(topOffset)
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            animations: animation,
            completion: completion
        )
    }
}
