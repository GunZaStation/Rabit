import UIKit
import SnapKit

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

final class RangeSlider: UIControl {
    
    private let leftThumbButton: ThumbButton = {
        let button = ThumbButton()
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let rightThumbButton: ThumbButton = {
        let button = ThumbButton()
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.isUserInteractionEnabled = false
        view.roundCorners(5)
        return view
    }()
    
    private let trackTintView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var previousTouchedPoint: CGPoint = .zero
    private var isLeftThumbTouched: Bool = false
    private var isRightThumbTouched: Bool = false
    private var leftConstraint: Constraint?
    private var rightConstraint: Constraint?
    private var widthWithoutThumb: Double {
        return self.bounds.width - Double(bounds.height)
    }
    
    private var feedbackGenerator: UISelectionFeedbackGenerator? = nil
    
    private var minValue: Double = 0.0 {
        didSet { self.leftValue = minValue }
    }
    
    private var maxValue: Double = 100.0 {
        didSet { self.rightValue = maxValue }
    }
    
    private var step: CGFloat = 1.0
    
    lazy var leftValue: Double = minValue {
        didSet { self.updateLayout(to: leftValue, direction: .left) }
    }
    
    lazy var rightValue: Double = maxValue {
        didSet { self.updateLayout(to: rightValue, direction: .right) }
    }
    
    var trackViewColor: UIColor = .lightGray {
        didSet {
            trackView.backgroundColor = trackViewColor
        }
    }
    
    var trackTintViewColor: UIColor = .systemBlue {
        didSet {
            trackTintView.backgroundColor = trackTintViewColor
        }
    }
    
    convenience init(min: Double, max: Double, step: CGFloat = 1.0) {
        self.init()
        
        self.minValue = min
        self.maxValue = max
        self.step = step
        
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout(to: rightValue, direction: .right)
        updateLayout(to: leftValue, direction: .left)
    }
    
    private func setupViews() {
        
        addSubview(trackView)
        addSubview(trackTintView)
        addSubview(leftThumbButton)
        addSubview(rightThumbButton)
        
        leftThumbButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.right.lessThanOrEqualTo(rightThumbButton.snp.left)
            $0.left.greaterThanOrEqualToSuperview()
            $0.width.equalTo(self.snp.height)
            self.leftConstraint = $0.left.equalTo(self.snp.left).priority(999).constraint
        }
        
        rightThumbButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.greaterThanOrEqualTo(leftThumbButton.snp.right)
            $0.right.lessThanOrEqualToSuperview()
            $0.width.equalTo(self.snp.height)
            self.rightConstraint = $0.left.equalTo(self.snp.left).priority(999).constraint
        }
        
        trackView.snp.makeConstraints {
            $0.left.right.centerY.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.4)
        }
        
        trackTintView.snp.makeConstraints {
            $0.left.equalTo(leftThumbButton.snp.right)
            $0.right.equalTo(rightThumbButton.snp.left)
            $0.top.bottom.equalTo(trackView)
        }
    }
    
    //슬라이더 전체가 아닌 ThumbButton 범위에서만 터치 이벤트 받도록 설정
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        return leftThumbButton.frame.contains(point) || rightThumbButton.frame.contains(point)
    }
    
    //터치 시작 시에, 리턴값에 따라 터치 이벤트 처리를 계속 할 지 결정
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator?.prepare()
        
        let touchedPoint = touch.location(in: self)
        isLeftThumbTouched = leftThumbButton.frame.contains(touchedPoint)
        isRightThumbTouched = rightThumbButton.frame.contains(touchedPoint)
        previousTouchedPoint = touchedPoint
        
        leftThumbButton.isSelected = isLeftThumbTouched
        rightThumbButton.isSelected = isRightThumbTouched
        
        return isLeftThumbTouched || isRightThumbTouched
    }
    
    //beginTracking에서 true리턴 후, 터치 이벤트를 지속하기 위한 메소드(드래그 구현 시 사용)
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        // Thumb 이동 여부를 확인하기 위해 기존의 left/rightValue 저장
        let prevLeftValue = self.leftValue
        let prevRightValue = self.rightValue
        
        let touchedPoint = CGPoint(
            x: round(touch.location(in: self).x / step) * step,
            y: touch.location(in: self).y
        )
        let draggedValue = Double(touchedPoint.x - previousTouchedPoint.x)
        let scale = maxValue - minValue
        let scaledValue = scale * draggedValue / widthWithoutThumb
        
        if isLeftThumbTouched {
            leftValue = (leftValue + scaledValue).clamped(to: minValue...rightValue)
        } else {
            rightValue = (rightValue + scaledValue).clamped(to: leftValue...maxValue)
        }
        
        // Thumb이 이동했을 경우에만 햅틱 피드백
        if prevLeftValue != leftValue || prevRightValue != rightValue {
            feedbackGenerator?.selectionChanged()
        }
        feedbackGenerator?.prepare()
        
        previousTouchedPoint = touchedPoint
        sendActions(for: .valueChanged)

        return true
    }
    
    //터치가 끝난 시점(화면에서 손가락을 뗀 시점)에 버튼의 isSelected를 모두 false로 처리
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        feedbackGenerator = nil
        
        sendActions(for: .valueChanged)
        
        leftThumbButton.isSelected = false
        rightThumbButton.isSelected = false
    }
    
    //업데이트 된 rangleValue에 맞춰 터치된 버튼의 left 레이아웃 속성을 업데이트
    private func updateLayout(to rangeValue: CGFloat, direction: SlidingDirection) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let startValue = rangeValue - self.minValue
            let scale = self.maxValue - self.minValue
            let offset = self.widthWithoutThumb * startValue / scale
            
            switch direction {
            case .left:
                self.leftConstraint?.update(offset: offset)
            case .right:
                self.rightConstraint?.update(offset: offset)
            }
        }
    }
}

private extension RangeSlider {
    
    enum SlidingDirection {
        case left
        case right
    }
    
    final class ThumbButton: UIButton {
        
        override func layoutSubviews() {
            super.layoutSubviews()
            setAttributes()
        }
        
        private func setAttributes() {
            roundCorners(frame.height/2)
            backgroundColor = .white
            layer.borderWidth = 1.0
            layer.borderColor = UIColor.gray.cgColor
        }
    }
}
