//
//  ViewController.swift
//  new2
//
//  Created by Just aLoli on 2023/8/27.
//

import Cocoa

class ViewController: NSViewController {
    
    //抄的
    @IBOutlet weak var imagev: NSImageView!
    //注意这一行左边有个圆圈。要在storyboard里面，viewcontroller，右键，菜单中找到这个imagev，和视图中的imageview连线，这样左边的圈变成实心的。
    
    var chooseActionMenu = ChooseActionMenu()
    @IBOutlet weak var viewMainMenu:NSMenu!
    
    var player: AnimePlayer!
    
    
    @IBOutlet weak var workingOverlayView: NSView!
    @IBOutlet weak var workingOverlayTitle: NSTextField!
    @IBOutlet weak var workingOverlayStop: NSButton!
    
    // 状态显示面板
    private lazy var statePanel: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        view.layer?.cornerRadius = 10
        return view
    }()
    
    private lazy var stateLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center
        return label
    }()
    
    private lazy var stateDurationLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center
        return label
    }()
    
    // 计时器数字UI
    var timerLabel: NSTextField = {
        let label = NSTextField(labelWithString: "00:00:00")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.alignment = .center
        label.isHidden = true
        return label
    }()
    
    @IBOutlet weak var panelView: VPetStateDisplay!
    
    override func viewDidLoad() {
        print("viewdidload")
        super.viewDidLoad()
        // ✅ 启动时隐藏状态面板
            panelView.isHidden = true

        
        // 添加状态显示面板
        setupStatePanel()
        
        // 将计时器UI添加到工作浮层并稍微向下偏移
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        workingOverlayView.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: workingOverlayView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: workingOverlayView.centerYAnchor, constant: 4),
            timerLabel.widthAnchor.constraint(equalToConstant: 180),
            timerLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        initButton()
        initMouseEvent()
        initViewMainMenu()
    }
    
    func setAnimePlayer(_ player: AnimePlayer) {
        self.player = player
    }
    
    func initViewMainMenu(){
        self.view.menu = viewMainMenu
        self.view.menu?.item(withTitle: "互动")!.submenu = chooseActionMenu.menu
//        self.view.menu?.addItem(withTitle: "退出当前互动", action: #selector(onActionMenuItemClicked),keyEquivalent: "")
    }
    func initButton(){
        for subv in self.view.subviews{
            if let button = subv as? NSButton{
//                if(button.title == "一键爬行"){continue;}
                button.isHidden = true
            }
        }
        
        self.workingOverlayView.isHidden = true;
    }
    func initMouseEvent(){
        //鼠标事件：鼠标右键切换按钮的显示和隐藏
        NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp, .leftMouseDragged], handler: { (event) -> NSEvent? in
            switch event.type{
            case .leftMouseDown:
                print("Mouse Down Event")
                guard let windowController = self.view.window?.windowController as? WindowController else{
                    print("Failed to get window controller")
                    return event
                }
                guard let VPET = windowController.VPET else{
                    print("Failed to get VPET")
                    return event
                }
                VPET.handleLeftMouseDown(event.locationInWindow)
                break;
            case .rightMouseUp:
                break;
            case .leftMouseDragged:
                print("Mouse Dragged Event")
                guard let windowController = self.view.window?.windowController as? WindowController else{
                    return event
                }
                guard let VPET = windowController.VPET else{
                    return event
                }
                VPET.handleLeftMouseDragged(event.locationInWindow)
                break;
            case .leftMouseUp:
                print("Mouse Up Event")
                guard let windowController = self.view.window?.windowController as? WindowController else{
                    return event
                }
                guard let VPET = windowController.VPET else{
                    return event
                }
                VPET.handleLeftMouseUp()
            default:break;
            }
            return event
        })
    }
    
    
    @IBAction func onButtonClicked(_ sender: NSButton) {
        if(sender.identifier?.rawValue == "workOverlayStopButton"){
            guard let windowController = self.view.window?.windowController as? WindowController else{
                return;
            }
            guard let VPET = windowController.VPET else{
                return;
            }
            VPET.workAndSleepHandler.endplayFromCurrentActionTitle();
            VPET.updateAnimation();
        }
        if(sender.title == "一键爬行"){
            guard let windowController = self.view.window?.windowController as? WindowController else{
                return;
            }
            guard let VPET = windowController.VPET else{
                return;
            }
            VPET.autoActionHendler.movehandler!.startAutoMove()
        }
        
    }
    
    
    
    @IBAction func onActionMenuItemClicked(_ sender: NSMenuItem) {
        print(sender.title)
        guard let windowController = self.view.window?.windowController as? WindowController else{
            return;
        }
        guard let VPET = windowController.VPET else{
            return;
        }
        switch sender.title{
        case "面板":
            // 切换面板显示/隐藏
            panelView.isHidden.toggle()
            if !panelView.isHidden {
                // 构造面板数据
                let info = VPetPanelInfo(
                    level: 1,
                    statusText: "已关闭数据计算, 可放心挂机",
                    money: 100.0,
                    exp: -388.65, expMax: 100,
                    stamina: 50.84, staminaMax: 104,
                    mood: 62.61, moodMax: 102,
                    satiety: 99.90, satietyMax: 104,
                    thirst: 99.90, thirstMax: 104,
                    state: windowController.stateManager?.currentStateType?.rawValue ?? "Normal",
                    stateDuration: 0 // 可根据实际状态管理器获取
                )
                panelView.updatePanel(info: info)
            }
            break;
        case "退出":
            VPET.shutdown();break;
        case "退出当前互动":break;
        default:break;
        }
    }
    
    func setsize(width:Double,height:Double){
//        imagev.setFrameSize(NSSize(width: width, height: height))
//        view.setFrameSize(NSSize(width:width,height:height))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func mouseMoved(with event: NSEvent) {
        // 移除鼠标移动事件处理，因为我们不再需要它
    }

    private func setupStatePanel() {
        // 添加状态面板
        statePanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statePanel)
        
        // 添加状态标签
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        statePanel.addSubview(stateLabel)
        
        // 添加持续时间标签
        stateDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        statePanel.addSubview(stateDurationLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 状态面板约束
            statePanel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            statePanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            statePanel.widthAnchor.constraint(equalToConstant: 120),
            statePanel.heightAnchor.constraint(equalToConstant: 60),
            
            // 状态标签约束
            stateLabel.topAnchor.constraint(equalTo: statePanel.topAnchor, constant: 8),
            stateLabel.leadingAnchor.constraint(equalTo: statePanel.leadingAnchor, constant: 8),
            stateLabel.trailingAnchor.constraint(equalTo: statePanel.trailingAnchor, constant: -8),
            
            // 持续时间标签约束
            stateDurationLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 4),
            stateDurationLabel.leadingAnchor.constraint(equalTo: statePanel.leadingAnchor, constant: 8),
            stateDurationLabel.trailingAnchor.constraint(equalTo: statePanel.trailingAnchor, constant: -8),
            stateDurationLabel.bottomAnchor.constraint(equalTo: statePanel.bottomAnchor, constant: -8)
        ])
        
        // 初始隐藏状态面板
        statePanel.isHidden = true
    }
    
    // 更新状态显示
    func updateStateDisplay(state: String, duration: TimeInterval) {
        stateLabel.stringValue = state
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        stateDurationLabel.stringValue = String(format: "%02d:%02d", minutes, seconds)
        statePanel.isHidden = false
    }

}

