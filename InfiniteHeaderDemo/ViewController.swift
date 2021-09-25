//
//  ViewController.swift
//  InfiniteHeaderDemo
//
//  Created by 能登 要 on 2021/09/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var placeholderView2: UIView!
    @IBOutlet weak var placeholderView3: UIView!
    @IBOutlet weak var placeholderView4: UIView!
    
    private var infiniteHeaderView: InfiniteLoopHeaderView!
    private var infiniteHeaderView2: InfiniteLoopHeaderView!
    private var infiniteHeaderView3: InfiniteLoopHeaderView!
    private var infiniteHeaderView4: InfiniteLoopHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        infiniteHeaderView = addHeader(placeholderView, assets:
                                            .init(style: .threeColumn,
                                                 titles: ["ヘッダ1", "ヘッダ2", "ヘッダ3", "ヘッダ4", "ヘッダ5", "ヘッダ6",],
                                                 initialSelectedIndex: 0)
                                        )

        infiniteHeaderView2 = addHeader(placeholderView2, assets:
                                            .init(style: .fiveColumn,
                                                 titles: ["ヘッダ1", "ヘッダ2", "ヘッダ3", "ヘッダ4", "ヘッダ5", "ヘッダ6",],
                                                 initialSelectedIndex: 0)
                                        )

        infiniteHeaderView3 = addHeader(placeholderView3, assets:
                                            .init(style: .threeColumn,
                                                 titles: ["ヘッダ1", "ヘッダ2", "ヘッダ3", "ヘッダ4", "ヘッダ5", "ヘッダ6",],
                                                 initialSelectedIndex: 0, debugMode: true)
                                        )

        infiniteHeaderView4 = addHeader(placeholderView4, assets:
                                            .init(style: .fiveColumn,
                                                 titles: ["ヘッダ1", "ヘッダ2", "ヘッダ3", "ヘッダ4", "ヘッダ5", "ヘッダ6",],
                                                 initialSelectedIndex: 0, debugMode: true)
                                        )
        
    }
    
    
    fileprivate func addHeader(_ pfView: UIView, assets: InfiniteLoopHeaderView.HeaderAssets) -> InfiniteLoopHeaderView {
        let infiniteHeaderView: InfiniteLoopHeaderView = InfiniteLoopHeaderView(frame: pfView.frame, assets: assets)
        if assets.debugMode {
            infiniteHeaderView.backgroundColor = .systemRed.withAlphaComponent(0.5)
        }
        
        self.view.addSubview(infiniteHeaderView)

        infiniteHeaderView.translatesAutoresizingMaskIntoConstraints = false
        infiniteHeaderView.topAnchor.constraint(equalTo: pfView.topAnchor).isActive = true
        infiniteHeaderView.leftAnchor.constraint(equalTo: pfView.leftAnchor).isActive = true
        infiniteHeaderView.rightAnchor.constraint(equalTo: pfView.rightAnchor).isActive = true
        infiniteHeaderView.bottomAnchor.constraint(equalTo: pfView.bottomAnchor).isActive = true
        
        let line = UIView(frame: CGRect(origin: pfView.frame.origin, size: CGSize(width: pfView.frame.width, height: 0.5)))
        line.backgroundColor = .separator
        self.view.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.centerYAnchor.constraint(equalTo: infiniteHeaderView.bottomAnchor).isActive = true
        line.leftAnchor.constraint(equalTo: infiniteHeaderView.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: infiniteHeaderView.rightAnchor).isActive = true
        self.view.addConstraint(
            NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0.5)
        )

        return infiniteHeaderView
    }
}
