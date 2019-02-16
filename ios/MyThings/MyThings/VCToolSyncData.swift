//
//  VCSyncData.swift
//  MyThings
//
//  Created by 李巍 on 2017/11/10.
//  Copyright © 2017年 李巍. All rights reserved.
//

import UIKit

// ----------------------------------------------------------------
// MARK: 同步标识定义代码区
// ----------------------------------------------------------------

fileprivate enum SyncFlag: UInt8 {
    case REQ_LIST_SYNC = 1              // 请求开始同步服务器整个数据库列表
    case REQ_LIST_END                   // 请求数据库列表结束，客->服
    case LIST_SYNC_END                  // 同步数据库列表结束，服->客
    
    case REP_GROUP_CNT                  // 发送数据分组数量
    case REQ_GROUP_DATA                 // 请求分组数据
    case REP_GROUP_DATA                 // 应答分组数据
    
    case REQ_DB_ITEM                    // 请求某个数据库条目
    case REP_DB_ITEM                    // 应答某个数据库条目
    
    case REQ_IMG_SYNC                   // 请求开始同步某个指定图片数据
    case REQ_IMG_END                    // 请求结束某个图片数据，客->服
    case IMG_SYNC_END                   // 同步某个图片数据结束，服->客
    case IMG_NOT_FIND                   // 请求的图片无法找到，服->客
}


fileprivate enum SyncType: UInt8 {
    case SYNC_NONE
    
    case SYNC_LIST_CC
    case SYNC_LIST_AREA
    case SYNC_LIST_OWNER
    case SYNC_LIST_MARCHANT
    case SYNC_LIST_CATEGORY
    case SYNC_LIST_POSITION
    case SYNC_LIST_THING
    
    case SYNC_ITEM_CC
    case SYNC_ITEM_AREA
    case SYNC_ITEM_OWNER
    case SYNC_ITEM_MARCHANT
    case SYNC_ITEM_CATEGORY
    case SYNC_ITEM_POSITION
    case SYNC_ITEM_THING
    
    case SYNC_IMG
}


fileprivate enum UnitType: UInt8{
    case UT_ID = 1
    case UT_NAME
    case UT_DETAIL
    case UT_IMG
    case UT_NOIMG
    case UT_OID
    case UT_STATE
    case UT_CT
    case UT_MT
    case UT_CC
    case UT_MAXCOUNT
    case UT_AREA
    case UT_USERNAME
    case UT_PASSWORD
    case UT_CATEGORY
    case UT_POSITION
    case UT_OWNER
    case UT_COUNT
    case UT_DATE
    case UT_EXPEIR
    case UT_PRICE
    case UT_MARCHANT
    case UT_TYPE
}

class VCToolSyncData: UIViewController, GCDAsyncSocketDelegate, UITextFieldDelegate {
    
    
    
    // --------------------------------------------------------------------
    // MARK: data members
    // --------------------------------------------------------------------
    
    // ------ UI Objectives ----
    private var m_textViewSyncInfo: UITextView!         // 数据同步信息
    private var m_labelTotalProgress: UILabel!          // 当前服务器同步总体进度标签
    private var m_progressTotal: UIProgressView!        // 当前服务器同步总体进度条
    private var m_labelTaskProgress: UILabel!           // 当前任务进度标签
    private var m_progressTask: UIProgressView!         // 当前任务进度条
    private var m_textFieldOppoServerIP: UITextField!   // 对方服务器IP地址
    private var m_btnSync: UIButton!                    // 同步按钮
    
    // ------ Data Members ------
    private var m_myServerSocket: GCDAsyncSocket!       // 本方服务器socket
    private var m_myClientSocket: GCDAsyncSocket!       // 本方客户端socket
    private var m_oppoClientSocket: GCDAsyncSocket!     // 对方客户端socket
    
    private var m_arrDeltaCCList: [Int] = []            // 与本地数据库比较后的CC增量数据
    private var m_arrDeltaAreaList: [Int] = []          // 与本地数据库比较后的Area增量数据
    private var m_arrDeltaOwnerList: [Int] = []         // 与本地数据库比较后的Area增量数据
    private var m_arrDeltaMarchantList: [Int] = []      // 与本地数据库比较后的Area增量数据
    private var m_arrDeltaCategoryList: [Int] = []      // 与本地数据库比较后的Area增量数据
    private var m_arrDeltaPositionList: [Int] = []      // 与本地数据库比较后的Area增量数据
    private var m_arrDeltaThingList: [Int] = []         // 与本地数据库比较后的Area增量数据
    
    private var m_arrDeltaImages: [String] = DP.dp.retrieveMissedOrUnusedImgs().missedImgs         // 需同步的图片文件列表
    private var m_strSyncImgTitle: String = ""          // 正在同步的图片标题
    private var m_bytesReceivedImage: [UInt8] = []      // 从服务器获取的图片数据
    
    private var m_bytesGroupData: [UInt8] = []          // 客户端请求的列表数据
    
    private var m_servSyncType: SyncType = .SYNC_NONE
    private var m_clientSyncType: SyncType = .SYNC_NONE
    
    private var m_nTotalGroupCnt = 0                    // 服务端返回的列表数据分组总数
    private var m_nRequestCroupIndex = 0                // 客户端向服务器请求的分组索引号，从0开始
    
    
    
    // --------------------------------------------------------------------
    // MARK: View Controller Delegate
    // --------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ---- layout and data deal ----
        layout()
        dealData()
        
        // ---- Server Setting ----
        StartServer()
        
        // ------ keyboard notification ------
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    
    
    // --------------------------------------------------------------------
    // MARK: UI
    // --------------------------------------------------------------------
    
    func layout() {
        // ---- background color ----
        self.view.backgroundColor = UIColor.white
        
        // ---- Sync Inforamtion Label and Text View ------
        let labelSyncInfo = UILabel(frame: CGRect(x: SAFE_AREA_MARGIN, y: NAV_HEIGHT + SEPARATE_HEIGHT, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        labelSyncInfo.text = "数据同步信息："
        self.view.addSubview(labelSyncInfo)
        
        let textViewHeight = Int(self.view.bounds.size.height) - NAV_HEIGHT - DEFAULT_HEIGHT * 10 - SEPARATE_HEIGHT * 6
        m_textViewSyncInfo = UITextView(frame: CGRect(x: SAFE_AREA_MARGIN, y: Int(labelSyncInfo.frame.origin.y) + DEFAULT_HEIGHT, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: textViewHeight))
        m_textViewSyncInfo.layer.borderColor = UIColor.lightGray.cgColor
        m_textViewSyncInfo.layer.borderWidth = 1
        m_textViewSyncInfo.layer.cornerRadius = 5
        m_textViewSyncInfo.isEditable = false
        self.view.addSubview(m_textViewSyncInfo)
        
        // ---- Total Progress in Current Server
        m_labelTotalProgress = UILabel(frame: CGRect(x: SAFE_AREA_MARGIN, y: Int(m_textViewSyncInfo.frame.origin.y) + textViewHeight + SEPARATE_HEIGHT, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        self.view.addSubview(m_labelTotalProgress)
        
        m_progressTotal = UIProgressView(frame: CGRect(x: SAFE_AREA_MARGIN, y: Int(m_labelTotalProgress.frame.origin.y) + DEFAULT_HEIGHT, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        self.view.addSubview(m_progressTotal)
        
        // ---- Task Progress ----
        m_labelTaskProgress = UILabel(frame: CGRect(x: SAFE_AREA_MARGIN, y: Int(m_progressTotal.frame.origin.y) + DEFAULT_HEIGHT + SEPARATE_HEIGHT, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        self.view.addSubview(m_labelTaskProgress)
        
        m_progressTask = UIProgressView(frame: CGRect(x: SAFE_AREA_MARGIN, y: Int(m_labelTaskProgress.frame.origin.y) + DEFAULT_HEIGHT, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        self.view.addSubview(m_progressTask)
        
        // ---- Opposide Server IP ----
        let labelOppoServerIP = UILabel(frame: CGRect(x: SAFE_AREA_MARGIN, y: Int(m_progressTask.frame.origin.y) + DEFAULT_HEIGHT + SEPARATE_HEIGHT, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        labelOppoServerIP.text = "对方IP："
        self.view.addSubview(labelOppoServerIP)
        
        m_textFieldOppoServerIP = UITextField(frame: CGRect(x: SAFE_AREA_MARGIN, y: Int(labelOppoServerIP.frame.origin.y) + DEFAULT_HEIGHT, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        m_textFieldOppoServerIP.borderStyle = .roundedRect
        m_textFieldOppoServerIP.delegate = self
        m_textFieldOppoServerIP.clearsOnBeginEditing = true
        m_textFieldOppoServerIP.returnKeyType = .done
        m_textFieldOppoServerIP.text = getSyncIP()
        self.view.addSubview(m_textFieldOppoServerIP)
        
        // ---- Sync Button ----
        m_btnSync = UIButton(frame: CGRect(x: SAFE_AREA_MARGIN, y: Int(self.view.bounds.size.height) - DEFAULT_HEIGHT - SEPARATE_HEIGHT * 3, width: Int(self.view.bounds.size.width) - SAFE_AREA_MARGIN * 2, height: DEFAULT_HEIGHT))
        m_btnSync.setTitle("开始同步", for: .normal)
        m_btnSync.setTitleColor(UIColor.darkGray, for: .normal)
        m_btnSync.setTitleColor(UIColor.lightGray, for: UIControlState.highlighted)
        m_btnSync.addTarget(self, action: #selector(btnSyncAction), for: UIControlEvents.touchDown)
        self.view.addSubview(m_btnSync)
    }
    
    // ------ deal data ------
    func dealData() {
        // ---- Total Progress in Current Server
        m_labelTotalProgress.text = "同步进度：初始化数据"
        
        // ---- Task Progress ----
        m_labelTaskProgress.text = "任务：初始化数据"
    }
    
    func addSyncInfoText(text: String) {
        m_textViewSyncInfo.text = m_textViewSyncInfo.text.appendingFormat("%@\n", text)
    }
    
    @objc func btnSyncAction() {    //< 开始同步按钮目标方法
        var serverIP: String = ""       //< 数据验证
        if m_textFieldOppoServerIP.text == "" {
            alertTip(vc: self, message: "请填写服务器IP地址")
            return
        } else {
            serverIP = m_textFieldOppoServerIP.text!
            setSyncIP(ip: serverIP)
        }
        
        m_myClientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)    //< 创建socket
        
        do {  //< 连接服务器
            try m_myClientSocket?.connect(toHost: serverIP, onPort: SYNC_SERVER_PORT)
            addSyncInfoText(text: "客：正在连接服务器：\(serverIP):\(SYNC_SERVER_PORT)......")
            m_btnSync.isEnabled = false
        }catch _ {
            addSyncInfoText(text: "客：尝试连接服务器： \(serverIP):\(SYNC_SERVER_PORT)  -- Failure")
        }
    }
    
    private func getSyncIP() -> String {
        // 判断SyncIp.plist是否存在，若存在读取数据，若不存在创建数据
        let fileMgr = FileManager.default
        let docDir = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        let pListPath = docDir?.appendingPathComponent("SyncIp.plist")
        
        var rst = fileMgr.fileExists(atPath: (pListPath?.path)!)
        
        if !rst {
            rst = fileMgr.createFile(atPath: (pListPath?.path)!, contents: nil, attributes: nil)
            if !rst {
                return ""
            } else {
                setSyncIP(ip: "127.0.0.1")
            }
        }
        
        guard let dicPList = NSMutableDictionary(contentsOfFile: (pListPath?.path)!) else {
            return ""
        }
        return (dicPList["SyncIP"] as! String)
    }
    
    private func setSyncIP(ip: String) {
        let fileMgr = FileManager.default
        let docDir = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let pListPath = docDir?.appendingPathComponent("SyncIp.plist") else {
            return
        }
        
        let dic = NSMutableDictionary()
        dic.setObject(ip, forKey: "SyncIP" as NSCopying)
        dic.write(toFile: pListPath.path, atomically: true)
    }
    
    // -------------------------------------------------------------------
    // MARK: keyboard notification
    @objc func keyboardWillShow(aNotification: NSNotification) {
        let userinfo = aNotification.userInfo
        let nsValue = userinfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRec = nsValue.cgRectValue
        g_dKeyboardHeight = keyboardRec.size.height
    }
    
    // ----------------------------------------------------------------------
    // MARK: Textfield Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == m_textFieldOppoServerIP {
            UIView.animate(withDuration: TEXTFIELD_MOVE_TIME, animations: {
                self.view.frame.origin.y = 0 - g_dKeyboardHeight
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == m_textFieldOppoServerIP {
            UIView.animate(withDuration: TEXTFIELD_MOVE_TIME, animations: {
                self.view.frame.origin.y = 0
            })
        }
    }
    
    
    
    // ------------------------------------------------------------------------
    // MARK: Socket 设置与代理回调代码区
    // ------------------------------------------------------------------------
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {   //< Server接收到新链接
        if newSocket.connectedHost != nil {
            addSyncInfoText(text: "服：客户端连接：\(newSocket.connectedHost!):\(newSocket.connectedPort)  -- OK")
            m_textFieldOppoServerIP.text = "\(newSocket.connectedHost!)"
            m_btnSync.isEnabled = false
        }
        m_oppoClientSocket = newSocket
        m_oppoClientSocket!.readData(withTimeout: -1, tag: 0)   //< 第一次开始读取Data
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {    //< Client连接到服务器
        addSyncInfoText(text: "客：连接服务器：\(host):\(port) 成功  -- OK")
        sock.readData(withTimeout: -1, tag: 0)
        
        // 发送分类组请求报文，从分类组CC开始，格式|REQ_LIST|REQ_LIST_CC|
        m_clientSyncType = .SYNC_LIST_CC
        let bytesData: [UInt8] = [SyncFlag.REQ_LIST_SYNC.rawValue, SyncType.SYNC_LIST_CC.rawValue]
        m_myClientSocket.write(Data(bytes: bytesData), withTimeout: -1, tag: 0)
        addSyncInfoText(text: "客：已发送获取『分类组』列表请求，等待服务器应答......")
        m_labelTotalProgress.text = "同步进度：同步数据库条目列表(1/4)"
        m_progressTotal.progress = 1.0 / 4.0
        m_labelTaskProgress.text = "任务：同步分类组列表(CC List)"
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {           //< 读取数据
        var bytesData: [UInt8] = []
        bytesData.append(contentsOf: data)
        
        let flag = bytesData[0]
        switch flag {
        case SyncFlag.REQ_LIST_SYNC.rawValue:
            dealRequestList(sock: sock, data: data)
        case SyncFlag.REQ_LIST_END.rawValue:
            dealRequestListEnd(sock: sock, data: data)
        case SyncFlag.LIST_SYNC_END.rawValue:
            dealListSyncEnd(sock: sock, data: data)
        case SyncFlag.REP_GROUP_CNT.rawValue:
            dealRepGroupCnt(sock: sock, data: data)
        case SyncFlag.REQ_GROUP_DATA.rawValue:
            dealRequestGroupData(sock: sock, data: data)
        case SyncFlag.REP_GROUP_DATA.rawValue:
            dealReplyGroupData(sock: sock, data: data)
        case SyncFlag.REQ_DB_ITEM.rawValue:
            dealRequestDBItem(sock: sock, data: data)
        case SyncFlag.REP_DB_ITEM.rawValue:
            dealReplyDBItem(sock: sock, data: data)
        case SyncFlag.REQ_IMG_SYNC.rawValue:
            dealRequestImage(sock: sock, data: data)
        case SyncFlag.REQ_IMG_END.rawValue:
            dealRequestImageEnd(sock: sock, data: data)
        case SyncFlag.IMG_SYNC_END.rawValue:
            dealImageSyncEnd(sock: sock, data: data)
        case SyncFlag.IMG_NOT_FIND.rawValue:
            dealImageNotFind(sock: sock, data: data)
        default: print("*** Error: 同步标记类型错误 ***")
        }
        
        sock.readData(withTimeout: -1, tag: 0)
    }
    
    func StartServer() {      //< Server Setting
        m_myServerSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        addSyncInfoText(text: "启动同步服务...")
        do {
            try m_myServerSocket.accept(onPort: SYNC_SERVER_PORT)
            addSyncInfoText(text: "服务器：监听端口：\(SYNC_SERVER_PORT)  -- OK")
        } catch _ {
            addSyncInfoText(text: "服务器：监听失败  -- Failure")
        }
    }
    
    
    
    // ------------------------------------------------------------------------
    // MARK: 列表请求与应答处理代码区
    // ------------------------------------------------------------------------
    
    // ------ 服务器：处理列表请求信息 ------
    private func dealRequestList(sock: GCDAsyncSocket, data: Data) {
        addSyncInfoText(text: "服：接收到『列表请求(REQ_LIST)』同步信息")
        
        //---- 进行一些数据校验 ----
        if data.count != 2 {
            addSyncInfoText(text: "服：接收到『列表请求(REQ_LIST)』同步信息，数据长度错误")
            return
        }
        
        if data[0] != SyncFlag.REQ_LIST_SYNC.rawValue {
            addSyncInfoText(text: "服：接收到『列表请求(REQ_LIST)』同步信息，信息标识不是REQ_LIST")
            return
        }
        
        
        // ---- 成员属性清空，用于存放新的请求列表数据
        m_bytesGroupData.removeAll()
        
        
        // ---- 分析请求的列表类型（分类组列表、区域列表...），获取相应的列表数据
        let requestListType = data[1]
        switch requestListType {
        case SyncType.SYNC_LIST_CC.rawValue:
            m_servSyncType = .SYNC_LIST_CC
            for item in DP.dp.getCCs(state: .STATE_ALL) {
                guard let bytesCTMT = CTMT2Bytes(createtime: item.createtime, modifytime: item.modifytime) else {
                    return
                }
                m_bytesGroupData.append(contentsOf: bytesCTMT)
            }
            m_labelTaskProgress.text = "任务：同步分类组列表(CC List)"
        case SyncType.SYNC_LIST_AREA.rawValue:
            m_servSyncType = .SYNC_LIST_AREA
            for item in DP.dp.getAreas(state: .STATE_ALL) {
                guard let bytesCTMT = CTMT2Bytes(createtime: item.createtime, modifytime: item.modifytime) else {
                    return
                }
                m_bytesGroupData.append(contentsOf: bytesCTMT)
            }
            m_labelTaskProgress.text = "任务：同步区域列表(Area List)"
        case SyncType.SYNC_LIST_OWNER.rawValue:
            m_servSyncType = .SYNC_LIST_OWNER
            for item in DP.dp.getOwners(state: .STATE_ALL) {
                guard let bytesCTMT = CTMT2Bytes(createtime: item.createtime, modifytime: item.modifytime) else {
                    return
                }
                m_bytesGroupData.append(contentsOf: bytesCTMT)
            }
            m_labelTaskProgress.text = "任务：同步用户列表(Owner List)"
        case SyncType.SYNC_LIST_MARCHANT.rawValue:
            m_servSyncType = .SYNC_LIST_MARCHANT
            for item in DP.dp.getMarchants(state: .STATE_ALL) {
                guard let bytesCTMT = CTMT2Bytes(createtime: item.createtime, modifytime: item.modifytime) else {
                    return
                }
                m_bytesGroupData.append(contentsOf: bytesCTMT)
            }
            m_labelTaskProgress.text = "任务：同步商家列表(Marchant List)"
        case SyncType.SYNC_LIST_CATEGORY.rawValue:
            m_servSyncType = .SYNC_LIST_CATEGORY
            for item in DP.dp.getCategorys(state: .STATE_ALL) {
                guard let bytesCTMT = CTMT2Bytes(createtime: item.createtime, modifytime: item.modifytime) else {
                    return
                }
                m_bytesGroupData.append(contentsOf: bytesCTMT)
            }
            m_labelTaskProgress.text = "任务：同步分类列表(Category List)"
        case SyncType.SYNC_LIST_POSITION.rawValue:
            m_servSyncType = .SYNC_LIST_POSITION
            for item in DP.dp.getPositions(state: .STATE_ALL) {
                guard let bytesCTMT = CTMT2Bytes(createtime: item.createtime, modifytime: item.modifytime) else {
                    return
                }
                m_bytesGroupData.append(contentsOf: bytesCTMT)
            }
            m_labelTaskProgress.text = "任务：同步位置列表(Position List)"
        case SyncType.SYNC_LIST_THING.rawValue:
            m_servSyncType = .SYNC_LIST_THING
            for item in DP.dp.getThings(state: .STATE_ALL) {
                guard let bytesCTMT = CTMT2Bytes(createtime: item.createtime, modifytime: item.modifytime) else {
                    return
                }
                m_bytesGroupData.append(contentsOf: bytesCTMT)
            }
            m_labelTaskProgress.text = "任务：同步物品列表(Thing List)"
        default:
            return
        }
        addSyncInfoText(text: "服：客户端请求列表类型为『\(m_servSyncType)』")
        m_labelTotalProgress.text = "同步进度：同步数据库条目列表(1/4)"
        m_progressTotal.progress = 1.0 / 4.0
        
        
        // ---- 计算发送分组数量，并返回REP_GROUP_CNT应答
        m_nTotalGroupCnt = m_bytesGroupData.count / SYNC_SEND_GROUP_MTU
        if (m_bytesGroupData.count % SYNC_SEND_GROUP_MTU) != 0 {
            m_nTotalGroupCnt += 1
        }
        
        var bytesSendReplyGroupCount: [UInt8] = [SyncFlag.REP_GROUP_CNT.rawValue]
        bytesSendReplyGroupCount.append(contentsOf: toByteArray(m_nTotalGroupCnt))
        sock.write(Data(bytesSendReplyGroupCount), withTimeout: -1, tag: 0)
        addSyncInfoText(text: "服：已发送『分组数量应答(REP_GROUP_CNT)』同步数据，分组数为\(m_nTotalGroupCnt)组")
        
        return
    }
    
    
    // ------ 服务器：处理列表数据同步结束（REQ_LIST_END）信息 ------
    private func dealRequestListEnd(sock: GCDAsyncSocket, data: Data) {
        addSyncInfoText(text: "服：接收到『请求列表结束(REQ_LIST_END)』信息")
        
        // 格式：| 标识：UInt8 = REQ_LIST_END |
        
        
        // ---- 数据校验 ----
        if data[0] != SyncFlag.REQ_LIST_END.rawValue {
            addSyncInfoText(text: "服：接收到『请求列表结束(REQ_LIST_END)』信息，同步标识错误")
            return
        }
        
        
        // ---- 发送列表同步结束（LIST_SYNC_END）信息 ----
        // 格式：| 标识：UInt8 = LIST_SYNC_END |
        let bytesListSyncEnd: [UInt8] = [SyncFlag.LIST_SYNC_END.rawValue]
        sock.write(Data(bytesListSyncEnd), withTimeout: -1, tag: 0)
        addSyncInfoText(text: "服：已发送『列表同步结束(LIST_SYNC_END)』信息")
        
        
        // ---- 本地数据清理 ----
        m_nTotalGroupCnt = 0
        m_nRequestCroupIndex = 0
        m_bytesGroupData.removeAll()
        m_servSyncType = .SYNC_NONE
    }
    
    
    // ------ 客户端：处理列表数据同步结束（LIST_SYNC_END）信息 ------
    private func dealListSyncEnd(sock: GCDAsyncSocket, data: Data) {
        addSyncInfoText(text: "客：接收到『列表同步结束(LIST_SYNC_END)』信息，列表\(m_clientSyncType)同步完成")
        
        // ---- 请求获取下一个类型的列表数据 ----
        if m_clientSyncType != .SYNC_LIST_THING {
            switch m_clientSyncType {
            case .SYNC_LIST_CC:
                m_clientSyncType = .SYNC_LIST_AREA
                m_labelTaskProgress.text = "任务：同步区域列表(Area List)"
            case .SYNC_LIST_AREA:
                m_clientSyncType = .SYNC_LIST_OWNER
                m_labelTaskProgress.text = "任务：同步用户列表(Owner List)"
            case .SYNC_LIST_OWNER:
                m_clientSyncType = .SYNC_LIST_MARCHANT
                m_labelTaskProgress.text = "任务：同步商家列表(Marchant List)"
            case .SYNC_LIST_MARCHANT:
                m_clientSyncType = .SYNC_LIST_CATEGORY
                m_labelTaskProgress.text = "任务：同步分类列表(Category List)"
            case .SYNC_LIST_CATEGORY:
                m_clientSyncType = .SYNC_LIST_POSITION
                m_labelTaskProgress.text = "任务：同步位置列表(Position List)"
            case .SYNC_LIST_POSITION:
                m_clientSyncType = .SYNC_LIST_THING
                m_labelTaskProgress.text = "任务：同步物品列表(Thing List)"
            default:
                return
            }
            
            let bytesRequestList: [UInt8] = [SyncFlag.REQ_LIST_SYNC.rawValue, m_clientSyncType.rawValue]
            sock.write(Data(bytesRequestList), withTimeout: -1, tag: 0)
            addSyncInfoText(text: "客：已发送『列表请求(REQ_LIST_SYNC)』信息，请求列表类型\(m_clientSyncType)")
        } else {
            requestDBItem(sock: sock)
        }
    }
    
    
    
    // ------------------------------------------------------------------------
    // MARK: 分组数据请求与应答处理代码区
    // ------------------------------------------------------------------------
    
    // ------ 客户端：处理分组数据应答 ------
    private func dealRepGroupCnt(sock: GCDAsyncSocket, data: Data) {
        // 格式：| SyncFlag(UInt8):REQ_GROUP_DATA | 数据组号(Int):Value |
        
        addSyncInfoText(text: "客：接收到『分组数量应答(REP_GROUP_CNT)』同步信息")
        
        // ---- 数据校验 ----
        if data.count != 9 {
            addSyncInfoText(text: "客：接收到『分组数量应答(REP_GROUP_CNT)』同步信息，数据长度错误")
            return
        }
        
        if data[0] != SyncFlag.REP_GROUP_CNT.rawValue {
            addSyncInfoText(text: "客：接收到『分组数量应答(REP_GROUP_CNT)』同步信息，数据同步类型错误")
            return
        }
        
        
        // ---- 解析分组数GroupCnt ----
        m_nTotalGroupCnt = fromByteArray(getSubBytes(data: data, startIndex: 1, endIndex: 9), Int.self)
        addSyncInfoText(text: "客：解析『分组数量应答』成功，共\(m_nTotalGroupCnt)个MTU传输分组")
        
        
        // ---- 发送获取分组数据请求，获取服务器的分组数据 ----
        // 格式：
        // |标识            |数据组号   |
        // |REQ_GROUP_DATA |Value     |
        // |UInt8          |Int       |
        
        var bytesRequestGroupData: [UInt8] = [SyncFlag.REQ_GROUP_DATA.rawValue]
        bytesRequestGroupData.append(contentsOf: toByteArray(m_nRequestCroupIndex))
        sock.write(Data(bytesRequestGroupData), withTimeout: -1, tag: 0)
        addSyncInfoText(text: "客：已发送『分组数据请求』，请求分组号(\(m_nRequestCroupIndex))")
    }
    
    
    // ------ 服务器：处理分组数据请求信息 ------
    private func dealRequestGroupData(sock: GCDAsyncSocket, data: Data) {
        // 格式：| 标识(UInt8):REQ_GROUP_DATA | 数据组号(Int):Value   |
        
        // ---- 进行一些数据校验 ----
        if data[0] != SyncFlag.REQ_GROUP_DATA.rawValue {
            addSyncInfoText(text: "服：接收到『请求分组数据REQ_GROUP_DATA』信息，数据长度错误")
            return
        }
        
        if data.count != 9 {
            addSyncInfoText(text: "服：接收到『请求分组数据REQ_GROUP_DATA』信息，同步标记错误")
            return
        }
        
        
        // ---- 解析客户端请求的分组索引号 ----
        let requestedGroupIndex = fromByteArray(getSubBytes(data: data, startIndex: 1, endIndex: 9), Int.self)
        
        let sendStartIndex = requestedGroupIndex * SYNC_SEND_GROUP_MTU
        var sendEndIndex = sendStartIndex + SYNC_SEND_GROUP_MTU
        
        if sendStartIndex >= m_bytesGroupData.endIndex {
            addSyncInfoText(text: "服：处理『请求分组数据REQ_GROUP_DATA』信息错误，请求的分组号超出范围")
            return
        }
        
        if sendEndIndex > m_bytesGroupData.count {
            sendEndIndex = m_bytesGroupData.endIndex
        }
        
        print("服：接收到『请求分组数据REQ_GROUP_DATA』信息，请问分组号：\(requestedGroupIndex)")
        
        
        // ---- 发送分组数据应答信息，信息格式：
        // |标识            |数据组号   |数据       |
        // |REP_GROUP_DATA |Value     |Value     |
        // |UInt8          |Int       |[UInt8]   |
        var bytesGroupSend: [UInt8] = [SyncFlag.REP_GROUP_DATA.rawValue]
        bytesGroupSend.append(contentsOf: toByteArray(requestedGroupIndex))
        bytesGroupSend.append(contentsOf: m_bytesGroupData[sendStartIndex..<sendEndIndex])
        
        sock.write(Data(bytesGroupSend), withTimeout: -1, tag: 0)     //< 发送客户端应答
        print("服：已发送『分组数据应答』，数据长度\(bytesGroupSend.count)字节")
        
        m_progressTask.progress = Float(requestedGroupIndex) / Float(m_nTotalGroupCnt)
        
        return
    }
    
    
    // ------ 客户端：处理分组数据应答信息 REP_GROUP_DATA ------
    private func dealReplyGroupData(sock: GCDAsyncSocket, data: Data) {
        
        // addSyncInfoText(text: "客：接收到『分组数据应答』信息")
        
        // 接收到的数据格式
        // |标识            |数据组号   |数据       |
        // |REP_GROUP_DATA |Value     |CTMT      |
        // |UInt8          |Int       |[UInt8]   |
        
        
        // ---- 进行一些数据校验 ----
        if data.count < 9 {
            addSyncInfoText(text: "客：接收到『分组数据应答』信息，同步信息数据长度太短")
            return
        }
        
        if data[0] != SyncFlag.REP_GROUP_DATA.rawValue {
            addSyncInfoText(text: "客：接收到『分组数据应答』信息，同步标识错误")
            return
        }
        
        let nReceivedGroupIndex = fromByteArray(getSubBytes(data: data, startIndex: 1, endIndex: 9), Int.self)
        if nReceivedGroupIndex != m_nRequestCroupIndex {
            addSyncInfoText(text: "客：接收到『分组数据应答』信息，数据错误，接收到分组与请求分组不一致")
            return
        } else {
            print("客：接收到『分组数据应答』信息，分类组(\(nReceivedGroupIndex)/\(m_nTotalGroupCnt))")
            m_progressTask.progress = Float(nReceivedGroupIndex + 1) / Float(m_nTotalGroupCnt)
        }
        
        
        if m_clientSyncType == .SYNC_IMG {
            // ---- 存储图片数据 ----
            m_bytesReceivedImage.append(contentsOf: data[9..<data.endIndex])
        } else {
            // ---- CTMT数据长度校验 ----
            let nReceivedCTMTCnt = data.count - 9
            if nReceivedCTMTCnt % SYNC_CTMT_BYTE_CNT != 0 {
                addSyncInfoText(text: "客：接收到『分组数据应答』信息，CTMT数据长度(\(nReceivedCTMTCnt)字节)错误")
                return
            }
            
            // ---- 解析分组数据中的CTMT数据 ----
            var arrReceivedCTMT: [(createtime: Int, modifytime: Int)] = []
            var nOffset = 9       //< 处理数据偏移量
            while nOffset < data.count {
                let nCT = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset + 8), Int.self)
                nOffset += 8
                let nMT = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset + 8), Int.self)
                nOffset += 8
                arrReceivedCTMT.append((nCT, nMT))
            }
            
            
            // ---- 与本地数据库比较，差异结果保存在m_arrDeltaXXXXList中 ----
            for item in arrReceivedCTMT {
                let nCT = item.createtime
                let nMT = item.modifytime
                
                guard let dateCT = int2Date(n: nCT) else {
                    addSyncInfoText(text: "客：接收到『分组数据应答』信息，转换createtime错误")
                    return
                }
                
                guard let dateMT = int2Date(n: nMT) else {
                    addSyncInfoText(text: "客：接收到『分组数据应答』信息，转换modifytime错误")
                    return
                }
                
                switch m_clientSyncType {
                case .SYNC_LIST_CC:
                    let cc = DP.dp.getCC(createtime: dateCT)
                    if cc == nil {
                        m_arrDeltaCCList.append(nCT)
                    } else if cc!.modifytime < dateMT {
                        m_arrDeltaCCList.append(nCT)
                    }
                case .SYNC_LIST_AREA:
                    let area = DP.dp.getArea(createtime: dateCT)
                    if area == nil {
                        m_arrDeltaAreaList.append(nCT)
                    } else if area!.modifytime < dateMT {
                        m_arrDeltaAreaList.append(nCT)
                    }
                case .SYNC_LIST_OWNER:
                    let owner = DP.dp.getOwner(createtime: dateCT)
                    if owner == nil {
                        m_arrDeltaOwnerList.append(nCT)
                    } else if owner!.modifytime < dateMT {
                        m_arrDeltaOwnerList.append(nCT)
                    }
                case .SYNC_LIST_MARCHANT:
                    let marchant = DP.dp.getMarchant(createtime: dateCT)
                    if marchant == nil {
                        m_arrDeltaMarchantList.append(nCT)
                    } else if marchant!.modifytime < dateMT {
                        m_arrDeltaMarchantList.append(nCT)
                    }
                case .SYNC_LIST_CATEGORY:
                    let category = DP.dp.getCategory(createtime: dateCT)
                    if category == nil {
                        m_arrDeltaCategoryList.append(nCT)
                    } else if category!.modifytime < dateMT {
                        m_arrDeltaCategoryList.append(nCT)
                    }
                case .SYNC_LIST_POSITION:
                    let position = DP.dp.getPosition(createtime: dateCT)
                    if position == nil {
                        m_arrDeltaPositionList.append(nCT)
                    } else if position!.modifytime < dateMT {
                        m_arrDeltaPositionList.append(nCT)
                    }
                case .SYNC_LIST_THING:
                    let thing = DP.dp.getThing(byCT: dateCT)
                    if thing == nil {
                        m_arrDeltaThingList.append(nCT)
                    } else if thing!.modifytime < dateMT {
                        m_arrDeltaThingList.append(nCT)
                    }
                default:
                    print("error")
                }
            }
        }
        
        
        // ---- 发送获取分组数据请求，获取服务器的分组数据 ----
        m_nRequestCroupIndex += 1         // 请求下一组分组索引号
        if m_nRequestCroupIndex != m_nTotalGroupCnt {
            // 格式：| 标识：UInt8 = REQ_GROUP_DATA | 数据组号：Int = Value |
            var bytesRequestGroupData: [UInt8] = [SyncFlag.REQ_GROUP_DATA.rawValue]
            bytesRequestGroupData.append(contentsOf: toByteArray(m_nRequestCroupIndex))
            sock.write(Data(bytesRequestGroupData), withTimeout: -1, tag: 0)
            print("客：已发送『分组数据请求』，请求分组号(\(m_nRequestCroupIndex))")
        } else {
            var bytesRequestEnd: [UInt8] = [SyncFlag.REQ_LIST_END.rawValue]
            
            if m_clientSyncType == .SYNC_IMG {
                bytesRequestEnd[0] = SyncFlag.REQ_IMG_END.rawValue
            }
            
            sock.write(Data(bytesRequestEnd), withTimeout: -1, tag: 0)
            addSyncInfoText(text: "客：已发送『请求数据结束(REQ_END)』信息")
            
            // ---- 成员属性清空，用于存放新的请求列表数据
            m_nTotalGroupCnt = 0
            m_nRequestCroupIndex = 0
        }
    }
    
    
    
    
    // ------------------------------------------------------------------------
    // MARK: 特定条目请求与应答处理代码区
    // ------------------------------------------------------------------------
    
    // ------ 客户端：发送数据库差异数据请求获取信息（REQ_DB_ITEM） ------
    private func requestDBItem(sock: GCDAsyncSocket) {
        // 格式：|SyncFlay:UInt8=REQ_DB_ITEM|SyncType:UInt8=SyncType|Value:[UInt8](8)=CT|
        
        var bytesRequestItem: [UInt8] = [SyncFlag.REQ_DB_ITEM.rawValue]
        
        var syncType: SyncType = .SYNC_NONE
        var nRequestedCT: Int = 0
        
        if !m_arrDeltaCCList.isEmpty {
            nRequestedCT = m_arrDeltaCCList.removeFirst()
            syncType = .SYNC_ITEM_CC
        } else if !m_arrDeltaAreaList.isEmpty {
            nRequestedCT = m_arrDeltaAreaList.removeFirst()
            syncType = .SYNC_ITEM_AREA
        } else if !m_arrDeltaOwnerList.isEmpty {
            nRequestedCT = m_arrDeltaOwnerList.removeFirst()
            syncType = .SYNC_ITEM_OWNER
        } else if !m_arrDeltaMarchantList.isEmpty {
            nRequestedCT = m_arrDeltaMarchantList.removeFirst()
            syncType = .SYNC_ITEM_MARCHANT
        } else if !m_arrDeltaCategoryList.isEmpty {
            nRequestedCT = m_arrDeltaCategoryList.removeFirst()
            syncType = .SYNC_ITEM_CATEGORY
        } else if !m_arrDeltaPositionList.isEmpty {
            nRequestedCT = m_arrDeltaPositionList.removeFirst()
            syncType = .SYNC_ITEM_POSITION
        } else if !m_arrDeltaThingList.isEmpty {
            nRequestedCT = m_arrDeltaThingList.removeFirst()
            syncType = .SYNC_ITEM_THING
        }
        
        if syncType != .SYNC_NONE {
            bytesRequestItem.append(syncType.rawValue)
            bytesRequestItem.append(contentsOf: toByteArray(nRequestedCT))
            
            sock.write(Data(bytesRequestItem), withTimeout: -1, tag: 0)
            addSyncInfoText(text: "客：已发送『数据库条目请求(REQ_DB_ITEM)』信息，同步类型\(syncType)，CT值\(nRequestedCT)")
            
            m_labelTotalProgress.text = "同步进度：同步数据库具体条目(2/4)"
            m_progressTotal.progress = 2.0 / 4.0
        } else {
            addSyncInfoText(text: "客：开始同步『图片数据』")
            m_labelTotalProgress.text = "同步进度：同步图片数据(3/4)"
            m_progressTotal.progress = 3.0 / 4.0
            requestImage(sock: sock)
        }
    }
    
    
    // ------ 服务器：处理数据库差异数据请求获取信息（REQ_DB_ITEM） ------
    private func dealRequestDBItem(sock: GCDAsyncSocket, data: Data) {
        
        // ---- 数据校验 ----
        // 格式：|SyncFlay:UInt8=REQ_DB_ITEM|SyncType:UInt8=SyncType|Value:[UInt8](8)=CT|
        if data.count != 10 {
            addSyncInfoText(text: "服：处理『REQ_DB_ITEM』错误，数据长度错误")
            return
        }
        
        
        // ---- 解析请求ITEM的创建时间CT ----
        let nRequestCT = fromByteArray(getSubBytes(data: data, startIndex: 2, endIndex: 10), Int.self)
        
        
        // ---- 解析同步类型 ----
        var syncType: SyncType = .SYNC_NONE
        
        switch data[1] {
        case SyncType.SYNC_ITEM_CC.rawValue:
            syncType = .SYNC_ITEM_CC
        case SyncType.SYNC_ITEM_AREA.rawValue:
            syncType = .SYNC_ITEM_AREA
        case SyncType.SYNC_ITEM_OWNER.rawValue:
            syncType = .SYNC_ITEM_OWNER
        case SyncType.SYNC_ITEM_MARCHANT.rawValue:
            syncType = .SYNC_ITEM_MARCHANT
        case SyncType.SYNC_ITEM_CATEGORY.rawValue:
            syncType = .SYNC_ITEM_CATEGORY
        case SyncType.SYNC_ITEM_POSITION.rawValue:
            syncType = .SYNC_ITEM_POSITION
        case SyncType.SYNC_ITEM_THING.rawValue:
            syncType = .SYNC_ITEM_THING
        default:
            print("error")
        }
        addSyncInfoText(text: "服：已收到『数据条目请求(REQ_DB_ITEM)』，请求类型\(syncType),条目(CT=\(nRequestCT))")
        
        
        // ---- 生成发送数据 ----
        // 格式：|SyncFlay:UInt8=REP_DB_ITEM|SyncType:UInt8=SyncType|Value:[UInt8]|
        var bytesReplyDBItem: [UInt8] = [SyncFlag.REP_DB_ITEM.rawValue, syncType.rawValue]
        bytesReplyDBItem.append(contentsOf: dbItem2Bytes(syncType: syncType, nRequestCt: nRequestCT))
        sock.write(Data(bytesReplyDBItem), withTimeout: -1, tag: 0)
        addSyncInfoText(text: "服：发送『数据条目应答(REP_DB_ITEM)』，数据长度\(bytesReplyDBItem.count)字节")
        
        m_labelTotalProgress.text = "同步进度：同步数据库具体条目(2/4)"
        m_progressTotal.progress = 2.0 / 4.0
    }
    
    
    // ------ 客户端：处理数据库差异数据应答信息（REP_DB_ITEM） ------
    private func dealReplyDBItem(sock: GCDAsyncSocket, data: Data) {
        // 格式：|SyncFlay:UInt8=REP_DB_ITEM|SyncType:UInt8=SyncType|Value:[UInt8]|
        
        // ---- 数据校验 ----
        if data.count < 10 {
            addSyncInfoText(text: "客：『数据条目应答(REP_DB_ITEM)』错误，长度太短")
            return
        }
        
        if data[0] != SyncFlag.REP_DB_ITEM.rawValue {
            addSyncInfoText(text: "客：『数据条目应答(REP_DB_ITEM)』错误，类型错误")
            return
        }
        
        let nSectionLen = fromByteArray(getSubBytes(data: data, startIndex: 2, endIndex: 10), Int.self)
        if data.count - 10 != nSectionLen {
            addSyncInfoText(text: "客：『数据条目应答(REP_DB_ITEM)』错误，数据长度错误，数据总长度\(data.count)，节长度sectionlen=\(nSectionLen)")
            return
        }
        
        
        // ---- 解析数据 ----
        var id: Int = -1
        var name: String = ""
        var img: String = ""
        var detail: String = ""
        var oid: Int = 0
        var state: Int = 0
        var createtime: Date = Date()
        var modifytime: Date = Date()
        var cc: Int = 0
        var maxcount: Int = 0
        var area: Int = 0
        var username: String = ""
        var password: String = ""
        var category: Int = 0
        var position: Int = 0
        var owner: Int = 0
        var count: Int = 0
        var date: Date = Date()
        var expeir: Date = Date()
        var price: Double = 0
        var marchant: Int = 0
        var type: String = ""
        
        var nOffset = 10
        let nIntLen = 8
        
        while nOffset < data.endIndex {
            let nUnitType: UInt8 = data[nOffset]
            switch nUnitType {
            case UnitType.UT_ID.rawValue:
                nOffset += 1
                id = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_NAME.rawValue:
                nOffset += 1
                let nUnitLen = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
                name = String(data: Data(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nUnitLen)), encoding: .utf8)!
                nOffset += nUnitLen
            case UnitType.UT_IMG.rawValue:
                nOffset += 1
                let nUnitLen = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
                img = String(data: Data(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nUnitLen)), encoding: .utf8)!
                nOffset += nUnitLen
            case UnitType.UT_DETAIL.rawValue:
                nOffset += 1
                let nUnitLen = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
                detail = String(data: Data(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nUnitLen)), encoding: .utf8)!
                nOffset += nUnitLen
            case UnitType.UT_OID.rawValue:
                nOffset += 1
                oid = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_STATE.rawValue:
                nOffset += 1
                state = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_CT.rawValue:
                nOffset += 1
                createtime = int2Date(n: fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self))!
                nOffset += nIntLen
            case UnitType.UT_MT.rawValue:
                nOffset += 1
                modifytime = int2Date(n: fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self))!
                nOffset += nIntLen
            case UnitType.UT_CC.rawValue:
                nOffset += 1
                cc = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_MAXCOUNT.rawValue:
                nOffset += 1
                maxcount = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_AREA.rawValue:
                nOffset += 1
                area = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_USERNAME.rawValue:
                nOffset += 1
                let nUnitLen = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
                username = String(data: Data(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nUnitLen)), encoding: .utf8)!
                nOffset += nUnitLen
            case UnitType.UT_PASSWORD.rawValue:
                nOffset += 1
                let nUnitLen = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
                password = String(data: Data(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nUnitLen)), encoding: .utf8)!
                nOffset += nUnitLen
            case UnitType.UT_CATEGORY.rawValue:
                nOffset += 1
                category = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_POSITION.rawValue:
                nOffset += 1
                position = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_OWNER.rawValue:
                nOffset += 1
                owner = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_COUNT.rawValue:
                nOffset += 1
                count = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_DATE.rawValue:
                nOffset += 1
                date = int2Date(n: fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self))!
                nOffset += nIntLen
            case UnitType.UT_EXPEIR.rawValue:
                nOffset += 1
                expeir = int2Date(n: fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self))!
                nOffset += nIntLen
            case UnitType.UT_PRICE.rawValue:
                nOffset += 1
                price = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Double.self)
                nOffset += nIntLen
            case UnitType.UT_MARCHANT.rawValue:
                nOffset += 1
                marchant = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
            case UnitType.UT_TYPE.rawValue:
                nOffset += 1
                let nUnitLen = fromByteArray(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nIntLen), Int.self)
                nOffset += nIntLen
                type = String(data: Data(getSubBytes(data: data, startIndex: nOffset, endIndex: nOffset+nUnitLen)), encoding: .utf8)!
                nOffset += nUnitLen
            default:
                print("error")
            }
        }
        
        
        // ---- 保存IMG图片名称，用于图片同步 ----
        if img != "" {
            m_arrDeltaImages.append(img)
        }
        
        
        // ---- 更新数据库 ----
        switch data[1] {
        case SyncType.SYNC_ITEM_CC.rawValue:
            let cc = CategoryCollection(id: id, name: name, detail: detail, img: img, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            _ = DP.dp.updateCC(cc: cc)
        case SyncType.SYNC_ITEM_AREA.rawValue:
            let area = Area(id: id, name: name, detail: detail, img: img, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            _ = DP.dp.updateArea(area: area)
        case SyncType.SYNC_ITEM_OWNER.rawValue:
            let owner = Owner(id: id, name: name, img: img, detail: detail, u_name: username, password: password, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            _ = DP.dp.updateOwner(owner: owner)
        case SyncType.SYNC_ITEM_MARCHANT.rawValue:
            let marchant = Marchant(id: id, name: name, img: img, detail: detail, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            _ = DP.dp.updateMarchant(marchant: marchant)
        case SyncType.SYNC_ITEM_CATEGORY.rawValue:
            let category = Category(id: id, name: name, cc: cc, img: img, detail: detail, maxcount: maxcount, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            _ = DP.dp.updateCategory(category: category)
        case SyncType.SYNC_ITEM_POSITION.rawValue:
            let position = Position(id: id, name: name, area: area, img: img, detail: detail, oid: oid, state: state, createtime: createtime, modifytime: modifytime)
            _ = DP.dp.updatePosition(position: position)
        case SyncType.SYNC_ITEM_THING.rawValue:
            let thing = Thing(id: id, name: name, category: category, position: position, owner: owner, count: count, maxcount: maxcount, date: date, expeir: expeir, price: price, img: img, marchant: marchant, type: type, detail: detail, state: state, createtime: createtime, modifytime: modifytime)
            _ = DP.dp.updateThing(thing: thing)
        default:
            print("error")
        }
        
        
        // ---- 继续请求一下个数据库条目 ----
        requestDBItem(sock: sock)
    }
    
    
    // ------ 将指定的数据库条目转换成标准格式的字节数组 ------
    private func dbItem2Bytes(syncType: SyncType, nRequestCt: Int) -> [UInt8] {
        guard let createtime = int2Date(n: nRequestCt) else {
            addSyncInfoText(text: "服：请求的CT(\(nRequestCt))无法转换成Date类型，错误")
            return []
        }
        
        switch syncType {
        case .SYNC_ITEM_CC:
            guard let item = DP.dp.getCC(createtime: createtime) else { return [] }
            return cc2Bytes(item: item)
        case .SYNC_ITEM_AREA:
            guard let item = DP.dp.getArea(createtime: createtime) else { return [] }
            return area2Bytes(item: item)
        case .SYNC_ITEM_OWNER:
            guard let item = DP.dp.getOwner(createtime: createtime) else { return [] }
            return owner2Bytes(item: item)
        case .SYNC_ITEM_MARCHANT:
            guard let item = DP.dp.getMarchant(createtime: createtime) else { return [] }
            return marchant2Bytes(item: item)
        case .SYNC_ITEM_CATEGORY:
            guard let item = DP.dp.getCategory(createtime: createtime) else { return [] }
            return category2Bytes(item: item)
        case .SYNC_ITEM_POSITION:
            guard let item = DP.dp.getPosition(createtime: createtime) else { return [] }
            return position2Bytes(item: item)
        case .SYNC_ITEM_THING:
            guard let item = DP.dp.getThing(createtime: createtime) else { return [] }
            return thing2Bytes(item: item)
        default:
            return []
        }
    }
    
    private func cc2Bytes(item: CategoryCollection) -> [UInt8] {
        // 格式：| Section Len | Unit_Type: ID | Unit_Data | Unit_Type: NAME | Unit_Data_Len | Unit_Data |...
        
        let bytesUnitID: [UInt8] = int2FormatBytes(n: item.id, ut: .UT_ID)
        let bytesUnitName: [UInt8] = string2FormatBytes(str: item.name, ut: .UT_NAME)
        let bytesUnitDetail: [UInt8] = string2FormatBytes(str: item.detail, ut: .UT_DETAIL)
        let bytesUnitImg: [UInt8] = string2FormatBytes(str: item.img, ut: .UT_IMG)
        let bytesUnitOid: [UInt8] = int2FormatBytes(n: item.oid, ut: .UT_OID)
        let bytesUnitState: [UInt8] = int2FormatBytes(n: item.state, ut: .UT_STATE)
        let bytesUnitcreatetime: [UInt8] = date2FormatBytes(date: item.createtime, ut: .UT_CT)
        let bytesUnitmodifytime: [UInt8] = date2FormatBytes(date: item.modifytime, ut: .UT_MT)
        
        var bytesRst: [UInt8] = []
        
        let nSectionLen = bytesUnitID.count + bytesUnitName.count + bytesUnitDetail.count + bytesUnitImg.count + bytesUnitOid.count + bytesUnitState.count + bytesUnitcreatetime.count + bytesUnitmodifytime.count
        print("section length is \(nSectionLen) bytes")
        
        bytesRst.append(contentsOf: toByteArray(nSectionLen))
        bytesRst.append(contentsOf: bytesUnitID)
        bytesRst.append(contentsOf: bytesUnitName)
        bytesRst.append(contentsOf: bytesUnitDetail)
        bytesRst.append(contentsOf: bytesUnitImg)
        bytesRst.append(contentsOf: bytesUnitOid)
        bytesRst.append(contentsOf: bytesUnitState)
        bytesRst.append(contentsOf: bytesUnitcreatetime)
        bytesRst.append(contentsOf: bytesUnitmodifytime)
        
        return bytesRst
    }
    
    private func area2Bytes(item: Area) -> [UInt8] {
        // 格式：| Section Len | Unit_Type: ID | Unit_Data | Unit_Type: NAME | Unit_Data_Len | Unit_Data |...
        
        let bytesUnitID: [UInt8] = int2FormatBytes(n: item.id, ut: .UT_ID)
        let bytesUnitName: [UInt8] = string2FormatBytes(str: item.name, ut: .UT_NAME)
        let bytesUnitImg: [UInt8] = string2FormatBytes(str: item.img, ut: .UT_IMG)
        let bytesUnitDetail: [UInt8] = string2FormatBytes(str: item.detail, ut: .UT_DETAIL)
        let bytesUnitOid: [UInt8] = int2FormatBytes(n: item.oid, ut: .UT_OID)
        let bytesUnitState: [UInt8] = int2FormatBytes(n: item.state, ut: .UT_STATE)
        let bytesUnitcreatetime: [UInt8] = date2FormatBytes(date: item.createtime, ut: .UT_CT)
        let bytesUnitmodifytime: [UInt8] = date2FormatBytes(date: item.modifytime, ut: .UT_MT)
        
        var bytesRst: [UInt8] = []
        
        var nSectionLen = bytesUnitID.count
        nSectionLen += bytesUnitName.count
        nSectionLen += bytesUnitImg.count
        nSectionLen += bytesUnitDetail.count
        nSectionLen += bytesUnitOid.count
        nSectionLen += bytesUnitState.count
        nSectionLen += bytesUnitcreatetime.count
        nSectionLen += bytesUnitmodifytime.count
        
        print("section length is \(nSectionLen) bytes")
        
        bytesRst.append(contentsOf: toByteArray(nSectionLen))
        bytesRst.append(contentsOf: bytesUnitID)
        bytesRst.append(contentsOf: bytesUnitName)
        bytesRst.append(contentsOf: bytesUnitImg)
        bytesRst.append(contentsOf: bytesUnitDetail)
        bytesRst.append(contentsOf: bytesUnitOid)
        bytesRst.append(contentsOf: bytesUnitState)
        bytesRst.append(contentsOf: bytesUnitcreatetime)
        bytesRst.append(contentsOf: bytesUnitmodifytime)
        
        return bytesRst
    }
    
    private func owner2Bytes(item: Owner) -> [UInt8] {
        // 格式：| Section Len | Unit_Type: ID | Unit_Data | Unit_Type: NAME | Unit_Data_Len | Unit_Data |...
        
        let bytesUnitID: [UInt8] = int2FormatBytes(n: item.id, ut: .UT_ID)
        let bytesUnitName: [UInt8] = string2FormatBytes(str: item.name, ut: .UT_NAME)
        let bytesUnitImg: [UInt8] = string2FormatBytes(str: item.img, ut: .UT_IMG)
        let bytesUnitDetail: [UInt8] = string2FormatBytes(str: item.detail, ut: .UT_DETAIL)
        let bytesUnitUserName: [UInt8] = string2FormatBytes(str: item.u_name, ut: .UT_USERNAME)
        let bytesUnitPassword: [UInt8] = string2FormatBytes(str: item.password, ut: .UT_PASSWORD)
        let bytesUnitOid: [UInt8] = int2FormatBytes(n: item.oid, ut: .UT_OID)
        let bytesUnitState: [UInt8] = int2FormatBytes(n: item.state, ut: .UT_STATE)
        let bytesUnitcreatetime: [UInt8] = date2FormatBytes(date: item.createtime, ut: .UT_CT)
        let bytesUnitmodifytime: [UInt8] = date2FormatBytes(date: item.modifytime, ut: .UT_MT)
        
        var bytesRst: [UInt8] = []
        
        var nSectionLen = bytesUnitID.count
        nSectionLen += bytesUnitName.count
        nSectionLen += bytesUnitImg.count
        nSectionLen += bytesUnitDetail.count
        nSectionLen += bytesUnitUserName.count
        nSectionLen += bytesUnitPassword.count
        nSectionLen += bytesUnitOid.count
        nSectionLen += bytesUnitState.count
        nSectionLen += bytesUnitcreatetime.count
        nSectionLen += bytesUnitmodifytime.count
        
        print("section length is \(nSectionLen) bytes")
        
        bytesRst.append(contentsOf: toByteArray(nSectionLen))
        bytesRst.append(contentsOf: bytesUnitID)
        bytesRst.append(contentsOf: bytesUnitName)
        bytesRst.append(contentsOf: bytesUnitImg)
        bytesRst.append(contentsOf: bytesUnitDetail)
        bytesRst.append(contentsOf: bytesUnitUserName)
        bytesRst.append(contentsOf: bytesUnitPassword)
        bytesRst.append(contentsOf: bytesUnitOid)
        bytesRst.append(contentsOf: bytesUnitState)
        bytesRst.append(contentsOf: bytesUnitcreatetime)
        bytesRst.append(contentsOf: bytesUnitmodifytime)
        
        return bytesRst
    }
    
    private func marchant2Bytes(item: Marchant) -> [UInt8] {
        // 格式：| Section Len | Unit_Type: ID | Unit_Data | Unit_Type: NAME | Unit_Data_Len | Unit_Data |...
        
        let bytesUnitID: [UInt8] = int2FormatBytes(n: item.id, ut: .UT_ID)
        let bytesUnitName: [UInt8] = string2FormatBytes(str: item.name, ut: .UT_NAME)
        let bytesUnitImg: [UInt8] = string2FormatBytes(str: item.img, ut: .UT_IMG)
        let bytesUnitDetail: [UInt8] = string2FormatBytes(str: item.detail, ut: .UT_DETAIL)
        let bytesUnitOid: [UInt8] = int2FormatBytes(n: item.oid, ut: .UT_OID)
        let bytesUnitState: [UInt8] = int2FormatBytes(n: item.state, ut: .UT_STATE)
        let bytesUnitcreatetime: [UInt8] = date2FormatBytes(date: item.createtime, ut: .UT_CT)
        let bytesUnitmodifytime: [UInt8] = date2FormatBytes(date: item.modifytime, ut: .UT_MT)
        
        var bytesRst: [UInt8] = []
        
        var nSectionLen = bytesUnitID.count
        nSectionLen += bytesUnitName.count
        nSectionLen += bytesUnitImg.count
        nSectionLen += bytesUnitDetail.count
        nSectionLen += bytesUnitOid.count
        nSectionLen += bytesUnitState.count
        nSectionLen += bytesUnitcreatetime.count
        nSectionLen += bytesUnitmodifytime.count
        
        print("section length is \(nSectionLen) bytes")
        
        bytesRst.append(contentsOf: toByteArray(nSectionLen))
        bytesRst.append(contentsOf: bytesUnitID)
        bytesRst.append(contentsOf: bytesUnitName)
        bytesRst.append(contentsOf: bytesUnitImg)
        bytesRst.append(contentsOf: bytesUnitDetail)
        bytesRst.append(contentsOf: bytesUnitOid)
        bytesRst.append(contentsOf: bytesUnitState)
        bytesRst.append(contentsOf: bytesUnitcreatetime)
        bytesRst.append(contentsOf: bytesUnitmodifytime)
        
        return bytesRst
    }
    
    private func category2Bytes(item: Category) -> [UInt8] {
        // 格式：| Section Len | Unit_Type: ID | Unit_Data | Unit_Type: NAME | Unit_Data_Len | Unit_Data |...
        
        let bytesUnitID: [UInt8] = int2FormatBytes(n: item.id, ut: .UT_ID)
        let bytesUnitName: [UInt8] = string2FormatBytes(str: item.name, ut: .UT_NAME)
        let bytesUnitCC: [UInt8] = int2FormatBytes(n: item.cc, ut: .UT_CC)
        let bytesUnitImg: [UInt8] = string2FormatBytes(str: item.img, ut: .UT_IMG)
        let bytesUnitDetail: [UInt8] = string2FormatBytes(str: item.detail, ut: .UT_DETAIL)
        let bytesUnitMaxCount: [UInt8] = int2FormatBytes(n: item.maxcount, ut: .UT_MAXCOUNT)
        let bytesUnitOid: [UInt8] = int2FormatBytes(n: item.oid, ut: .UT_OID)
        let bytesUnitState: [UInt8] = int2FormatBytes(n: item.state, ut: .UT_STATE)
        let bytesUnitcreatetime: [UInt8] = date2FormatBytes(date: item.createtime, ut: .UT_CT)
        let bytesUnitmodifytime: [UInt8] = date2FormatBytes(date: item.modifytime, ut: .UT_MT)
        
        var bytesRst: [UInt8] = []
        
        var nSectionLen = bytesUnitID.count
        nSectionLen += bytesUnitName.count
        nSectionLen += bytesUnitCC.count
        nSectionLen += bytesUnitImg.count
        nSectionLen += bytesUnitDetail.count
        nSectionLen += bytesUnitMaxCount.count
        nSectionLen += bytesUnitOid.count
        nSectionLen += bytesUnitState.count
        nSectionLen += bytesUnitcreatetime.count
        nSectionLen += bytesUnitmodifytime.count
        
        print("section length is \(nSectionLen) bytes")
        
        bytesRst.append(contentsOf: toByteArray(nSectionLen))
        bytesRst.append(contentsOf: bytesUnitID)
        bytesRst.append(contentsOf: bytesUnitName)
        bytesRst.append(contentsOf: bytesUnitCC)
        bytesRst.append(contentsOf: bytesUnitImg)
        bytesRst.append(contentsOf: bytesUnitDetail)
        bytesRst.append(contentsOf: bytesUnitMaxCount)
        bytesRst.append(contentsOf: bytesUnitOid)
        bytesRst.append(contentsOf: bytesUnitState)
        bytesRst.append(contentsOf: bytesUnitcreatetime)
        bytesRst.append(contentsOf: bytesUnitmodifytime)
        
        return bytesRst
    }
    
    private func position2Bytes(item: Position) -> [UInt8] {
        // 格式：| Section Len | Unit_Type: ID | Unit_Data | Unit_Type: NAME | Unit_Data_Len | Unit_Data |...
        
        let bytesUnitID: [UInt8] = int2FormatBytes(n: item.id, ut: .UT_ID)
        let bytesUnitName: [UInt8] = string2FormatBytes(str: item.name, ut: .UT_NAME)
        let bytesUnitArea: [UInt8] = int2FormatBytes(n: item.area, ut: .UT_AREA)
        let bytesUnitImg: [UInt8] = string2FormatBytes(str: item.img, ut: .UT_IMG)
        let bytesUnitDetail: [UInt8] = string2FormatBytes(str: item.detail, ut: .UT_DETAIL)
        let bytesUnitOid: [UInt8] = int2FormatBytes(n: item.oid, ut: .UT_OID)
        let bytesUnitState: [UInt8] = int2FormatBytes(n: item.state, ut: .UT_STATE)
        let bytesUnitcreatetime: [UInt8] = date2FormatBytes(date: item.createtime, ut: .UT_CT)
        let bytesUnitmodifytime: [UInt8] = date2FormatBytes(date: item.modifytime, ut: .UT_MT)
        
        var bytesRst: [UInt8] = []
        
        var nSectionLen = bytesUnitID.count
        nSectionLen += bytesUnitName.count
        nSectionLen += bytesUnitArea.count
        nSectionLen += bytesUnitImg.count
        nSectionLen += bytesUnitDetail.count
        nSectionLen += bytesUnitOid.count
        nSectionLen += bytesUnitState.count
        nSectionLen += bytesUnitcreatetime.count
        nSectionLen += bytesUnitmodifytime.count
        
        print("section length is \(nSectionLen) bytes")
        
        bytesRst.append(contentsOf: toByteArray(nSectionLen))
        bytesRst.append(contentsOf: bytesUnitID)
        bytesRst.append(contentsOf: bytesUnitName)
        bytesRst.append(contentsOf: bytesUnitArea)
        bytesRst.append(contentsOf: bytesUnitImg)
        bytesRst.append(contentsOf: bytesUnitDetail)
        bytesRst.append(contentsOf: bytesUnitOid)
        bytesRst.append(contentsOf: bytesUnitState)
        bytesRst.append(contentsOf: bytesUnitcreatetime)
        bytesRst.append(contentsOf: bytesUnitmodifytime)
        
        return bytesRst
    }
    
    private func thing2Bytes(item: Thing) -> [UInt8] {
        // 格式：| Section Len | Unit_Type: ID | Unit_Data | Unit_Type: NAME | Unit_Data_Len | Unit_Data |...
        
        let bytesUnitID: [UInt8] = int2FormatBytes(n: item.id, ut: .UT_ID)
        let bytesUnitName: [UInt8] = string2FormatBytes(str: item.name, ut: .UT_NAME)
        let bytesUnitCategory: [UInt8] = int2FormatBytes(n: item.category, ut: .UT_CATEGORY)
        let bytesUnitPosition: [UInt8] = int2FormatBytes(n: item.position, ut: .UT_POSITION)
        let bytesUnitOwner: [UInt8] = int2FormatBytes(n: item.owner, ut: .UT_OWNER)
        let bytesUnitCount: [UInt8] = int2FormatBytes(n: item.count, ut: .UT_COUNT)
        let bytesUnitMaxCount: [UInt8] = int2FormatBytes(n: item.count, ut: .UT_MAXCOUNT)
        let bytesUnitDate: [UInt8] = date2FormatBytes(date: item.date, ut: .UT_DATE)
        let bytesUnitExpeir: [UInt8] = date2FormatBytes(date: item.expeir, ut: .UT_EXPEIR)
        let bytesUnitPrice: [UInt8] = double2FormatBytes(d: item.price, ut: .UT_PRICE)
        let bytesUnitImg: [UInt8] = string2FormatBytes(str: item.img, ut: .UT_IMG)
        let bytesUnitMarchant: [UInt8] = int2FormatBytes(n: item.marchant, ut: .UT_MARCHANT)
        let bytesUnitType: [UInt8] = string2FormatBytes(str: item.type, ut: .UT_TYPE)
        let bytesUnitDetail: [UInt8] = string2FormatBytes(str: item.detail, ut: .UT_DETAIL)
        let bytesUnitState: [UInt8] = int2FormatBytes(n: item.state, ut: .UT_STATE)
        let bytesUnitcreatetime: [UInt8] = date2FormatBytes(date: item.createtime, ut: .UT_CT)
        let bytesUnitmodifytime: [UInt8] = date2FormatBytes(date: item.modifytime, ut: .UT_MT)
        
        var bytesRst: [UInt8] = []
        
        var nSectionLen = bytesUnitID.count
        nSectionLen += bytesUnitName.count
        nSectionLen += bytesUnitCategory.count
        nSectionLen += bytesUnitPosition.count
        nSectionLen += bytesUnitOwner.count
        nSectionLen += bytesUnitCount.count
        nSectionLen += bytesUnitMaxCount.count
        nSectionLen += bytesUnitDate.count
        nSectionLen += bytesUnitExpeir.count
        nSectionLen += bytesUnitPrice.count
        nSectionLen += bytesUnitImg.count
        nSectionLen += bytesUnitMarchant.count
        nSectionLen += bytesUnitType.count
        nSectionLen += bytesUnitDetail.count
        nSectionLen += bytesUnitState.count
        nSectionLen += bytesUnitcreatetime.count
        nSectionLen += bytesUnitmodifytime.count
        
        print("section length is \(nSectionLen) bytes")
        
        bytesRst.append(contentsOf: toByteArray(nSectionLen))
        bytesRst.append(contentsOf: bytesUnitID)
        bytesRst.append(contentsOf: bytesUnitName)
        bytesRst.append(contentsOf: bytesUnitCategory)
        bytesRst.append(contentsOf: bytesUnitPosition)
        bytesRst.append(contentsOf: bytesUnitOwner)
        bytesRst.append(contentsOf: bytesUnitCount)
        bytesRst.append(contentsOf: bytesUnitMaxCount)
        bytesRst.append(contentsOf: bytesUnitDate)
        bytesRst.append(contentsOf: bytesUnitExpeir)
        bytesRst.append(contentsOf: bytesUnitPrice)
        bytesRst.append(contentsOf: bytesUnitImg)
        bytesRst.append(contentsOf: bytesUnitMarchant)
        bytesRst.append(contentsOf: bytesUnitType)
        bytesRst.append(contentsOf: bytesUnitDetail)
        bytesRst.append(contentsOf: bytesUnitState)
        bytesRst.append(contentsOf: bytesUnitcreatetime)
        bytesRst.append(contentsOf: bytesUnitmodifytime)
        
        return bytesRst
    }
    
    private func int2FormatBytes(n: Int, ut: UnitType) -> [UInt8] {
        // 格式：| Unit_Type | Unit Data(8 Bytes) |
        var bytesRst: [UInt8] = [ut.rawValue]
        bytesRst.append(contentsOf: toByteArray(n))
        return bytesRst
    }
    
    private func double2FormatBytes(d: Double, ut: UnitType) -> [UInt8] {
        // 格式：| Unit_Type | Unit Data(8 Bytes) |
        var bytesRst: [UInt8] = [ut.rawValue]
        bytesRst.append(contentsOf: toByteArray(d))
        return bytesRst
    }
    
    private func date2FormatBytes(date: Date, ut: UnitType) -> [UInt8] {
        // 格式：| Unit_Type | Unit Data |
        var bytesRst: [UInt8] = [ut.rawValue]
        guard let nDate = date2Int(date: date) else {
            addSyncInfoText(text: "将Date(\(date))转换成整型失败")
            return []
        }
        bytesRst.append(contentsOf: toByteArray(nDate))
        return bytesRst
    }
    
    private func string2FormatBytes(str: String, ut: UnitType) -> [UInt8] {
        // 格式：| Unit_Type | Unit Data Len | Unit Data |
        var bytesRst: [UInt8] = [ut.rawValue]
        let bytesUnitData = str.data(using: .utf8)!
        let nUnitDataLen = bytesUnitData.count
        bytesRst.append(contentsOf: toByteArray(nUnitDataLen))
        bytesRst.append(contentsOf: bytesUnitData)
        return bytesRst
    }
    
    
    
    // ------------------------------------------------------------------------
    // MARK: 图片请求与应答处理代码区
    // ------------------------------------------------------------------------
    
    // ------ 客户端：请求特定图片同步（REQ_IMG_SYNC） ------
    private func requestImage(sock: GCDAsyncSocket) {
        // 格式：|SyncFlay:UInt8=REQ_IMG_SYNC|Unit_Len:Int=IMG_NAME_LEN|Value:[UInt8]=IMG_NAME|
        
        
        // ---- 如果无图片需要同步，发送同步结束信息（REQ_IMG_END） ----
        if m_arrDeltaImages.isEmpty {
            addSyncInfoText(text: "客：所有图片同步结束")
            
            m_labelTotalProgress.text = "同步进度：同步完成"
            m_progressTotal.progress = 1.0
            m_labelTaskProgress.text = "任务：完成"
            m_progressTask.progress = 1.0
            
            m_btnSync.isEnabled = true
            return
        }
        
        
        // ---- 清理本地存储图片数据 ----
        m_bytesReceivedImage.removeAll()
        
        
        // ---- 构建请求图片同步（REQ_IMG_SYNC）信息 ----
        m_strSyncImgTitle = m_arrDeltaImages.removeFirst()
        if DP.dp.loadImage(img: m_strSyncImgTitle) != nil { // 图片已经存在
            m_strSyncImgTitle = ""
            return
        }
        
        m_clientSyncType = .SYNC_IMG
        
        var bytesRequestImg: [UInt8] = [SyncFlag.REQ_IMG_SYNC.rawValue]
        bytesRequestImg.append(contentsOf: m_strSyncImgTitle.data(using: .utf8)!)
        sock.write(Data(bytesRequestImg), withTimeout: -1, tag: 0)
        addSyncInfoText(text: "客：已发送『同步图片请求(REQ_IMG_SYNC)』信息，请求同步图片\(m_strSyncImgTitle)")
        m_labelTaskProgress.text = "任务：同步图片(\(m_strSyncImgTitle))"
    }
    
    
    // ------ 服务器：处理图片请求信息 ------
    private func dealRequestImage(sock: GCDAsyncSocket, data: Data) {
        addSyncInfoText(text: "服：接收到『请求图片同步(REQ_IMG_SYNC)』信息")
        
        // ---- 进行一些数据校验 ----
        if data[0] != SyncFlag.REQ_IMG_SYNC.rawValue {
            addSyncInfoText(text: "服：接收到『请求图片同步(REQ_IMG_SYNC)』信息，信息标识不是REQ_IMG_SYNC")
            return
        }
        
        
        // ---- 成员属性清空，用于存放新的请求列表数据 ----
        m_bytesGroupData.removeAll()
        m_servSyncType = .SYNC_IMG
        
        
        // ---- 分析请求的图片标题，获取相应的图片数据 ----
        let requestedImageTitle: String = String(data: Data(getSubBytes(data: data, startIndex: 1, endIndex: data.endIndex)), encoding: .utf8)!
        
        guard let requestedImage = DP.dp.loadImage(img: requestedImageTitle) else {
            let bytesSendReplyImgRequest: [UInt8] = [SyncFlag.IMG_NOT_FIND.rawValue]
            sock.write(Data(bytesSendReplyImgRequest), withTimeout: -1, tag: 0)
            addSyncInfoText(text: "服：读取客户请求图片(\(requestedImageTitle))失败，图片不存在，已发送IMG_NOT_FIND信息")
            return
        }
        
        guard let dataRequestedImage = UIImageJPEGRepresentation(requestedImage, 1.0) else {
            addSyncInfoText(text: "服：转换图片(\(requestedImageTitle))为二进制数据错误")
            return
        }
        
        m_bytesGroupData.append(contentsOf: dataRequestedImage)
        
        
        // ---- 计算发送分组数量，并返回REP_GROUP_CNT应答
        m_nTotalGroupCnt = m_bytesGroupData.count / SYNC_SEND_GROUP_MTU
        if (m_bytesGroupData.count % SYNC_SEND_GROUP_MTU) != 0 {
            m_nTotalGroupCnt += 1
        }
        
        var bytesSendReplyGroupCount: [UInt8] = [SyncFlag.REP_GROUP_CNT.rawValue]
        bytesSendReplyGroupCount.append(contentsOf: toByteArray(m_nTotalGroupCnt))
        sock.write(Data(bytesSendReplyGroupCount), withTimeout: -1, tag: 0)
        addSyncInfoText(text: "服：已发送『分组数量应答(REP_GROUP_CNT)』同步数据，分组数为\(m_nTotalGroupCnt)组")
        
        
        // ---- 更新本地进度 ----
        m_labelTotalProgress.text = "同步进度：同步图片数据(3/4)"
        m_progressTotal.progress = 3.0 / 4.0
        m_labelTaskProgress.text = "任务：同步图片(\(requestedImageTitle))"
        m_btnSync.isEnabled = false
        
        return
    }
    
    
    // ------ 服务器：处理图片数据同步结束（REQ_IMG_END）信息 ------
    private func dealRequestImageEnd(sock: GCDAsyncSocket, data: Data) {
        addSyncInfoText(text: "服：接收到『请求图片结束(REQ_IMG_END)』信息")
        
        // 格式：| 标识：UInt8 = REQ_IMG_END |
        
        
        // ---- 数据校验 ----
        if data[0] != SyncFlag.REQ_IMG_END.rawValue {
            addSyncInfoText(text: "服：接收到『请求图片结束(REQ_IMG_END)』信息，同步标识错误")
            return
        }
        
        
        // ---- 发送图片同步结束（IMG_SYNC_END）信息 ----
        // 格式：| 标识：UInt8 = IMG_SYNC_END |
        let bytesImgSyncEnd: [UInt8] = [SyncFlag.IMG_SYNC_END.rawValue]
        sock.write(Data(bytesImgSyncEnd), withTimeout: -1, tag: 0)
        addSyncInfoText(text: "服：已发送『图片同步结束(IMG_SYNC_END)』信息")
        
        
        // ---- 更新本地进度 ----
        m_labelTotalProgress.text = "同步进度：同步完成"
        m_progressTotal.progress = 1.0
        m_labelTaskProgress.text = "任务：完成"
        m_progressTask.progress = 1.0
        
        m_btnSync.isEnabled = true
        
        
        // ---- 本地数据清理 ----
        m_nTotalGroupCnt = 0
        m_nRequestCroupIndex = 0
        m_bytesGroupData.removeAll()
        m_servSyncType = .SYNC_NONE
    }
    
    
    // ------ 客户端：处理图片数据同步结束（IMG_SYNC_END）信息 ------
    private func dealImageSyncEnd(sock: GCDAsyncSocket, data: Data) {
        addSyncInfoText(text: "客：接收到『图片同步结束(IMG_SYNC_END)』信息，图片\(m_strSyncImgTitle)同步完成")
        
        // ---- 保存图片 ----
        _ = DP.dp.saveImage(imgTitle: m_strSyncImgTitle, data: Data(m_bytesReceivedImage))
        
        // ---- 继续请求同步图片数据 ----
        requestImage(sock: sock)
    }
    
    
    // ------ 客户端：处理图片数据未找到（IMG_NOT_FIND）信息 ------
    private func dealImageNotFind(sock: GCDAsyncSocket, data: Data) {
        addSyncInfoText(text: "客：接收到『图片无法找到(IMG_NOT_FIND)』信息，图片\(m_strSyncImgTitle)同步失败")
        
        // ---- 继续请求同步图片数据 ----
        requestImage(sock: sock)
    }
    
    
    
    // ------------------------------------------------------------------------
    // MARK: 字节数据处理代码区
    // ------------------------------------------------------------------------
    func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }
    
    func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBytes {
            $0.baseAddress!.load(as: T.self)
        }
    }
    
    private func CTMT2Bytes(createtime: Date, modifytime: Date) -> [UInt8]? {    //< 将createtime和modifytime转换成字节流
        guard let nCT = date2Int(date: createtime) else {
            return nil
        }
        
        guard let nMT = date2Int(date: modifytime) else {
            return nil
        }
        
        var bytesRst: [UInt8] = toByteArray(nCT)
        bytesRst.append(contentsOf: toByteArray(nMT))
        
        return bytesRst
    }
    
    func date2Int(date: Date) -> Int? {
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "yyyyMMddHHmmss"
        return Int(df.string(from: date))
    }
    
    func int2Date(n: Int) -> Date? {
        let strDate = String(n)
        
        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "yyyyMMddHHmmss"
        
        return df.date(from: strDate)
    }
    
    private func getSubBytes(data: Data, startIndex: Int, endIndex: Int) -> [UInt8] {
        var bytesRst: [UInt8] = []
        
        if startIndex >= data.endIndex || startIndex > endIndex || endIndex > data.endIndex {
            print("*** Error: 获取字节子字符串失败，索引错误 ***")
        }
        
        var i = startIndex
        while i < endIndex {
            bytesRst.append(data[i])
            i += 1
        }
        
        return bytesRst
    }
}




