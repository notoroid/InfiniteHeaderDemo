//
//  InfiniteLoopHeaderView.swift
//  InfiniteHeaderDemo
//
//  Created by 能登 要 on 2021/09/23.
//

import UIKit

class HorizontalHitTestScrollView: UIScrollView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superViewBounds = superview?.bounds else {
            let rect = bounds
            return rect.contains(point)
        }
        let rect = convert(superViewBounds, from: superview!)
        return rect.contains(point)
    }
}

class InfiniteLoopHeaderView: UIView {
    var selectedIndex: Int!

    // Sub Views
    private var contentView: UIStackView!
    private var infiniteLoopView = UIView()
    private var scrollView: UIScrollView!
    private var underBarView: UIView = UIView()
    

    // Constraints
    var centerXConstraint: NSLayoutConstraint!
    private var threeColumnWidthConstraint: NSLayoutConstraint!
    private var fiveColumnWidthConstraint: NSLayoutConstraint!

    // const 定義
    enum InfiniteLoopHeaderConst {
        fileprivate static let numberOfSectionsForFiniteLoop = 99
        fileprivate static let centerOfSectionsForFiniteLoop = 49
    }

    // ヘッダ用アセット
    let assets: HeaderAssets
    let visibleColumnNumber: Int // 表示から無数
    let elementCount: Int // 要素数
    let leftOverrun: Int // 左オーバーラン数
    let leftSafeArea: Int // 左安全領域数
    let rightOverrun: Int // 右オーバーラン数
    let rightSafeArea: Int // 右安全領域数
    
    var skipDidScroll = false // スクロール処理スキップ用フラグ
    var scrollNormalizedPosition: Int = .init(0) // 正気かされた位置情報
    
    // 無限ループ上の中央位置を計算
    func centerForFiniteLoop() -> Int {
        InfiniteLoopHeaderConst.centerOfSectionsForFiniteLoop - (elementCount / 2)
    }
    
    // HeaderViewスタイル
    enum HeaderStyle: Int {
        case threeColumn = 3
        case fiveColumn = 5
    }
    
    // ヘッダアセット
    struct HeaderAssets {
        var style: HeaderStyle
        var titles: [String]
        var initialSelectedIndex: Int
        var debugMode: Bool = false
    }
    
    // イニシャライザ
    init(frame: CGRect, assets: HeaderAssets) {
        self.assets = assets
        
        // View内で使用する変数はアセットから取得
        visibleColumnNumber = assets.visibleElementNumber()
        elementCount = assets.titleCount()
        leftOverrun = .init(assets.leftOverrun())
        leftSafeArea = assets.leftSafeArea()
        rightOverrun = .init(assets.rightOverrun())
        rightSafeArea = assets.rightSafeArea()
        
        // 初期選択位置を格納
        selectedIndex = assets.initialSelectedIndex

        super.init(frame: frame)
        
        // Subviewを構築
        constructSubViews()
    }
    
    // イニシャライザ(コードからの)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 画面レイアウト変更に対応
    override func layoutSubviews() {
        super.layoutSubviews()
        constructLayout()
    }

    // レイアウト変更に対してScrool済み位置の修正
    fileprivate func constructLayout() {
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.width * CGFloat(centerForFiniteLoop() + selectedIndex), y: 0)
    }
    
    //  SubViewの構築
    fileprivate func constructSubViews(){
        // 横方向ドラッグを親View領域まで拡張した
        scrollView = HorizontalHitTestScrollView(frame: CGRect(origin: .zero, size: self.frame.size))
        scrollView.delegate = self
        
        // デバッグモード有効時は背景色を指定
        if assets.debugMode {
            scrollView.backgroundColor = .systemBlue
        }
        // ScrollViewを追加
        addSubview(scrollView)
        
        // Ancher を使ってレイアウト設定
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        // カラム別のアンカーを作成
        threeColumnWidthConstraint = scrollView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3333)
        fiveColumnWidthConstraint = scrollView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.20)
        
        // 採用スタイル別にアンカーの有効無効設定
        if visibleColumnNumber == 3 {
            threeColumnWidthConstraint.isActive = true
            fiveColumnWidthConstraint.isActive = false
        } else if visibleColumnNumber == 5 {
            threeColumnWidthConstraint.isActive = false
            fiveColumnWidthConstraint.isActive = true
        }
        
        // ScroolViewのclipsToBounds を無効とし、ScrollView領域外にコンテンツが表示されるように調整
        scrollView.clipsToBounds = false
        
        // ScrollViewのスクロールを設定
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false

        // ScrollView に配置するViewを作成
        infiniteLoopView.backgroundColor = .clear
        scrollView.addSubview(infiniteLoopView)
        infiniteLoopView.translatesAutoresizingMaskIntoConstraints = false
        // レイアウトを調整、幅は利用者がスクロールし続けても余裕がある幅を設定する
        NSLayoutConstraint.activate([
            infiniteLoopView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            infiniteLoopView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            infiniteLoopView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            infiniteLoopView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            infiniteLoopView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            infiniteLoopView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,multiplier: CGFloat(InfiniteLoopHeaderConst.numberOfSectionsForFiniteLoop)),
        ])

        // ページングを有効
        scrollView.isPagingEnabled = true

        // ScrollView に配置したinfiniteLoopView の子要素としてcontentView を追加する
        // StackViewを使ってヘッダー要素を追加する
        contentView = UIStackView()
        contentView.spacing = 0.0
        contentView.axis = .horizontal
        contentView.alignment = .fill
        contentView.distribution = .fillEqually
        infiniteLoopView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // contentViewの位置を調整するための特殊なアンカーを用意する
        centerXConstraint = contentView.centerXAnchor.constraint(equalTo: infiniteLoopView.centerXAnchor)
        
        // contentViewのレイアウト調整
        NSLayoutConstraint.activate([
            centerXConstraint,
            contentView.centerYAnchor.constraint(equalTo: infiniteLoopView.centerYAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: CGFloat(leftOverrun + elementCount + rightOverrun)),
        ])

        let titles = assets.titles
        let debugSeeds: [UIColor] = [.systemGreen, .systemTeal, .systemYellow, .systemPink, .systemOrange, .systemIndigo, .systemRed]
        let debugColors: [UIColor] = titles.enumerated().map { (offset, _) in
            debugSeeds[loop: offset]
        }
        
        // ヘッダー要素を作成
        var count = 0;
        for index in -leftOverrun..<(elementCount + rightOverrun) {
            let elementView = UIView()
            // デバッグモードでは背景色を設定
            if assets.debugMode {
                elementView.backgroundColor = debugColors[loop: index]
            }
            //　ヘッダー要素にラベルを追加
            addLabel(elementView, labelString: titles[loop: index], description: assets.debugMode ? "\(count)" : "")
            contentView.addArrangedSubview(elementView)
            count = count + 1;
        }

        // 選択中のインデックスが分かるようにViewを追亞k
        underBarView.backgroundColor = .link
        self.addSubview(underBarView)
        underBarView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(
            NSLayoutConstraint(item: underBarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 9)
        )
        NSLayoutConstraint.activate([
            underBarView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            underBarView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            underBarView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
    }
    
    // ヘッダー要素にラベルを追加
    fileprivate func addLabel( _ view: UIView, labelString: String, description: String ){
        let label = UILabel()
        label.text = labelString
        label.textColor = .black
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        let labelDescription = UILabel()
        labelDescription.text = description
        labelDescription.textColor = .black
        view.addSubview(labelDescription)
        
        labelDescription.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            labelDescription.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// InfiniteLoopHeaderViewから
extension InfiniteLoopHeaderView.HeaderStyle {
    fileprivate func headerCount() -> Int {
        self.rawValue
    }
    // ユーザーの操作で超えてしまうカラム数を返す
    fileprivate func overrun() -> Int {
        switch self {
        case .threeColumn:
            return 4
        case .fiveColumn:
            return 7
        }
    }
}

extension InfiniteLoopHeaderView.HeaderAssets {
    // タイトル数
    func titleCount() -> Int {
        titles.count
    }
    // 表示される要素数
    func visibleElementNumber() -> Int {
        style.headerCount()
    }
    // 無限ループに必要なオーバーラン領域、安全領域を計算
    func leftOverrun() -> Int {
        style.overrun()
    }
    func leftSafeArea() -> Int {
        -style.headerCount()
    }
    func rightSafeArea() -> Int {
        .init(titleCount())
    }
    func rightOverrun() -> Int {
        titleCount() % 2 == 0 ? (style.overrun() + 1) : style.overrun()
    }
}

extension InfiniteLoopHeaderView: UIScrollViewDelegate {
    // Deceleratingへの対応
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // スクロール位置の正規化が行われていない場合
        guard scrollNormalizedPosition != 0 else {
            return
        }

        // コンテンツの中央位置を取得
        let scrollViewCenter = scrollView.superview!.convert(scrollView.center, to: contentView)

        // 中央位置が含まれる矩形情報を元にヘッダー要素のインデックスを計算
        var targetIndex: Int = -1
        for index in 0..<(leftOverrun + elementCount + rightOverrun) {
            let hitTestRect = CGRect(origin: CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0), size: scrollView.bounds.size)
            if hitTestRect.contains(scrollViewCenter) {
                targetIndex = index
            }
        }
        
        // 得られたインデックスを元にインデックス情報を正規化
        let position = targetIndex - leftOverrun
        let loopIndex = (elementCount + ( (position) % elementCount)) % elementCount
        selectedIndex = loopIndex
        
        // ここでスクロール処理をプロテクトする(scrollNormalizedPositionが変更されてしまう可能性を避けるため)
        skipDidScroll = true
        self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.width * CGFloat(centerForFiniteLoop() + selectedIndex), y: 0)
        skipDidScroll = false
        
        scrollNormalizedPosition = 0
        centerXConstraint.constant = 0
    }
    
    // スクロールへの対応
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // skipDidScrollされている場合はscrollViewDidEndDecelerating での
        guard skipDidScroll != true else {
            return
        }
        
        // ScrollViewのcontentOffsetとscrollNormalizedPositionから位置を得る
        let plainPosition = Int(ceil( (scrollView.contentOffset.x / scrollView.bounds.width) - CGFloat(centerForFiniteLoop()) + CGFloat(scrollNormalizedPosition) ) )
        
        if plainPosition <= leftSafeArea {
            // ヘッダー左の安全領域を超えていた場合はscrollNormalizedPosition に位置を格納しcontentView の位置をずらす
            scrollNormalizedPosition = scrollNormalizedPosition + -plainPosition + (elementCount - visibleColumnNumber)
            centerXConstraint.constant = CGFloat(-scrollNormalizedPosition) * scrollView.bounds.width
        } else if plainPosition >= rightSafeArea {
            // ヘッダー右の安全領域を超えていた場合はscrollNormalizedPosition に位置を格納し の位置をずらす
            scrollNormalizedPosition = scrollNormalizedPosition + -plainPosition
            centerXConstraint.constant = CGFloat(-scrollNormalizedPosition) * scrollView.bounds.width
        } else {
            // その他の場合は通常処理。選択インデックスを変更
            let lIndex = (elementCount + (plainPosition % elementCount)) % elementCount
            selectedIndex = lIndex
        }
    }
}

// 配列上の位置をloopにて計算するためのextension
extension Array{
  subscript (loop index: Int) -> Element {
    let lIndex = (self.count + (index % self.count)) % self.count
    return self[lIndex]
  }
}
