import Cocoa

struct VPetPanelInfo {
    var level: Int
    var statusText: String
    var money: Double
    var exp: Double
    var expMax: Double
    var stamina: Double
    var staminaMax: Double
    var mood: Double
    var moodMax: Double
    var satiety: Double
    var satietyMax: Double
    var thirst: Double
    var thirstMax: Double
    var state: String
    var stateDuration: TimeInterval
}

// Custom progress bar with orange/yellow theme
class ThemedProgressBar: NSProgressIndicator {
    private let orangeColor = NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
    private let yellowColor = NSColor.systemYellow
    
    override func draw(_ dirtyRect: NSRect) {
        // Draw the background
        let bgPath = NSBezierPath(roundedRect: bounds, xRadius: 4, yRadius: 4)
        yellowColor.withAlphaComponent(0.2).setFill()
        bgPath.fill()
        
        // Draw border
        orangeColor.setStroke()
        bgPath.lineWidth = 2
        bgPath.stroke()
        
        // Draw the progress
        if doubleValue > 0 {
            let progressWidth = CGFloat(doubleValue / maxValue) * bounds.width
            let progressRect = NSRect(x: 0, y: 0, width: progressWidth, height: bounds.height)
            let progressPath = NSBezierPath(roundedRect: progressRect, xRadius: 4, yRadius: 4)
            yellowColor.setFill()
            progressPath.fill()
        }
    }
}

class VPetStateDisplay: NSView {
    // Main colors for the theme
    private static let primaryColor = NSColor(calibratedRed: 1.0, green: 0.6, blue: 0.0, alpha: 1.0) // Orange
    private static let secondaryColor = NSColor(calibratedRed: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
    private static let thirdColor = NSColor(calibratedRed: 0.9, green: 0.6, blue: 0.1, alpha: 1.0)
    
    private let levelLabel = makeLabel(fontSize: 16, weight: .bold, color: VPetStateDisplay.primaryColor)
    private let statusLabel = makeLabel(fontSize: 11, weight: .regular, color: .darkGray)
    private let moneyLabel = makeLabel(fontSize: 14, weight: .semibold, color: VPetStateDisplay.secondaryColor)

    private let expBar = ThemedProgressBar()
    private let staminaBar = ThemedProgressBar()
    private let moodBar = ThemedProgressBar()
    private let satietyBar = ThemedProgressBar()
    private let thirstBar = ThemedProgressBar()

    private let expValueLabel = makeValueLabel()
    private let staminaValueLabel = makeValueLabel()
    private let moodValueLabel = makeValueLabel()
    private let satietyValueLabel = makeValueLabel()
    private let thirstValueLabel = makeValueLabel()

    private let stateLabel = makeLabel(fontSize: 14, weight: .semibold, color: VPetStateDisplay.secondaryColor, align: .right)
    private let stateDurationLabel = makeLabel(fontSize: 11, weight: .regular, color: .lightGray, align: .right)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
        isHidden = true
        
        // 设置默认值
        let defaultInfo = VPetPanelInfo(
            level: 1,
            statusText: "Nomal",
            money: 0,
            exp: 0,
            expMax: 100,
            stamina: 60,
            staminaMax: 100,
            mood: 60,
            moodMax: 100,
            satiety: 60,
            satietyMax: 100,
            thirst: 60,
            thirstMax: 100,
            state: "Nomal",
            stateDuration: 0
        )
        updatePanel(info: defaultInfo)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        isHidden = true
    }

    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.withAlphaComponent(0.92).cgColor
        layer?.cornerRadius = 12
        layer?.shadowColor = NSColor.black.cgColor
        layer?.shadowOpacity = 0.15
        layer?.shadowOffset = CGSize(width: 0, height: -2)
        layer?.shadowRadius = 6

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 7
        stack.edgeInsets = NSEdgeInsets(top: 12, left: 20, bottom: 10, right: 20)
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        // 顶部三项：Lv1、$100.00、Normal
        let topRow = NSStackView()
        topRow.orientation = .horizontal
        topRow.distribution = .fill
        topRow.alignment = .centerY
        topRow.spacing = 0
        topRow.translatesAutoresizingMaskIntoConstraints = false
        // 左对齐Lv1
        levelLabel.alignment = .left
        // 居中金钱
        moneyLabel.alignment = .center
        // 右对齐Normal
        stateLabel.alignment = .right
        topRow.addArrangedSubview(levelLabel)
        topRow.addArrangedSubview(moneyLabel)
        topRow.addArrangedSubview(stateLabel)
        levelLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        stateLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        stack.addArrangedSubview(topRow)

        // 状态描述
        stack.addArrangedSubview(statusLabel)

        // Setup progress bars
        setupProgressBar(expBar)
        setupProgressBar(staminaBar)
        setupProgressBar(moodBar)
        setupProgressBar(satietyBar)
        setupProgressBar(thirstBar)

        // 进度条区
        addBarRow(to: stack, label: "经验", bar: expBar, valueLabel: expValueLabel)
        addBarRow(to: stack, label: "体力", bar: staminaBar, valueLabel: staminaValueLabel)
        addBarRow(to: stack, label: "心情", bar: moodBar, valueLabel: moodValueLabel)
        addBarRow(to: stack, label: "饱腹度", bar: satietyBar, valueLabel: satietyValueLabel)
        addBarRow(to: stack, label: "口渴度", bar: thirstBar, valueLabel: thirstValueLabel)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupProgressBar(_ bar: ThemedProgressBar) {
        bar.isIndeterminate = false
        bar.minValue = 0
        bar.maxValue = 100
        bar.doubleValue = 0
        bar.controlSize = .small
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.heightAnchor.constraint(equalToConstant: 8).isActive = true
    }

    private func addBarRow(to stack: NSStackView, label: String, bar: NSProgressIndicator, valueLabel: NSTextField) {
        let labelView = makeLabel(text: label, fontSize: 11, weight: .regular, color: .darkGray, align: .left)
        labelView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        bar.controlSize = .small
        bar.heightAnchor.constraint(equalToConstant: 8).isActive = true
        valueLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        valueLabel.alignment = .right
        let hStack = NSStackView(views: [labelView, bar, valueLabel])
        hStack.orientation = .horizontal
        hStack.spacing = 8
        hStack.alignment = .centerY
        hStack.distribution = .fill
        hStack.setHuggingPriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(hStack)
    }

    func updatePanel(info: VPetPanelInfo) {
        levelLabel.stringValue = "Lv \(info.level)"
        statusLabel.stringValue = info.statusText
        moneyLabel.stringValue = String(format: "$ %.2f", info.money)
        updateBar(bar: expBar, valueLabel: expValueLabel, value: info.exp, max: info.expMax)
        updateBar(bar: staminaBar, valueLabel: staminaValueLabel, value: info.stamina, max: info.staminaMax)
        updateBar(bar: moodBar, valueLabel: moodValueLabel, value: info.mood, max: info.moodMax)
        updateBar(bar: satietyBar, valueLabel: satietyValueLabel, value: info.satiety, max: info.satietyMax)
        updateBar(bar: thirstBar, valueLabel: thirstValueLabel, value: info.thirst, max: info.thirstMax)
        stateLabel.stringValue = info.state
        // 不显示 stateDurationLabel
        stateDurationLabel.stringValue = ""
    }

    private func updateBar(bar: NSProgressIndicator, valueLabel: NSTextField, value: Double, max: Double) {
        bar.maxValue = max
        bar.doubleValue = value
        valueLabel.stringValue = String(format: "%.2f / %.0f", value, max)
    }
}

private func makeLabel(text: String = "", fontSize: CGFloat, weight: NSFont.Weight, color: NSColor, align: NSTextAlignment = .left) -> NSTextField {
    let label = NSTextField(labelWithString: text)
    label.font = NSFont.systemFont(ofSize: fontSize, weight: weight)
    label.textColor = color
    label.alignment = align
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}

private func makeValueLabel() -> NSTextField {
    let label = NSTextField(labelWithString: "")
    label.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    label.textColor = .darkGray
    label.alignment = .right
    label.translatesAutoresizingMaskIntoConstraints = false
    label.widthAnchor.constraint(equalToConstant: 80).isActive = true
    return label
}
