//
// Zee5PluggablePlayer.swift
// Zee5PluggablePlayer
//
// Created by Miri on 19/12/2018.
//
import ApplicasterSDK
import ZappPlugins
import UIKit

public class Zee5PluggablePlayer: APPlugablePlayerBase, ZPAdapterProtocol, miniPlayerProtocol, hyBridViewControllerProtocol, pluggablePlayerDelegate, sleepModeProtocol {

    public var pluginStyles: [String : Any]?

    //MARK: Class Variables
    var hybridViewController: HybridViewController?
    var miniPlayerView: MiniPlayerContainerView?
    var currentPlayableItem: ZPPlayable?
    var rootViewController: UIViewController?
    var shouldDissmis: Bool = true
    // Sleep Mode
    var sleepModeCountDown: NSNumber?

    public static func pluggablePlayerInit(playableItem item: ZPPlayable?) -> ZPPlayerProtocol?{
        if let item = item {
            return self.pluggablePlayerInit(playableItems: [item])
        }
        return nil
    }

    public static func pluggablePlayerInit(playableItems items: [ZPPlayable]?, configurationJSON: NSDictionary? = nil) -> ZPPlayerProtocol?{

        let instance: Zee5PluggablePlayer
        // Hybrid presented
        if let lastActiveInstance = Zee5PluggablePlayer.lastActiveInstance() {
            instance = lastActiveInstance
        }
        // No Player Presented
        else {
            instance = Zee5PluggablePlayer()
            instance.hybridViewController = HybridViewController(nibName: "HybridViewController", bundle: nil)
        }


        // Configuration
        instance.configurationJSON = configurationJSON
        instance.currentPlayableItem = items?.first
        instance.hybridViewController?.playerViewController = Zee5PlayerViewController(playableItem: items?.first)
        instance.hybridViewController?.playerViewController?.delegate = instance
        instance.hybridViewController?.currentPlayableItem = items?.first
        instance.hybridViewController?.delegate = instance
        instance.hybridViewController?.configurationJSON = configurationJSON

        if let screenModel = ZAAppConnector.sharedInstance().layoutComponentsDelegate.componentsManagerGetScreenComponentforPluginID(pluginID: "zee_player"),
            screenModel.isPluginScreen(),
            let style = screenModel.style {
            instance.hybridViewController?.pluginStyles = style.object
            instance.pluginStyles = instance.hybridViewController?.pluginStyles
        }
        return instance
    }

    public override func pluggablePlayerViewController() -> UIViewController? {
        return self.hybridViewController
    }

    public func pluggablePlayerCurrentPlayableItem() -> ZPPlayable? {
        return currentPlayableItem
    }

    // MARK: - Available only in Full screen mode

    public override func presentPlayerFullScreen(_ rootViewController: UIViewController, configuration: ZPPlayerConfiguration?) {
        self.rootViewController = rootViewController

        self.shouldDissmis = true
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "APPlayerControllerReachedEndNotification"), object:nil)

        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "APPlayerDidStopNotification"), object:nil)

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "APApplicasterPlayerStartSleepModeNotification"),
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showSleepModeView),
            name: NSNotification.Name(rawValue: "APApplicasterPlayerStartSleepModeNotification"),
            object: nil)


        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stop),
            name: NSNotification.Name(rawValue: "APPlayerControllerReachedEndNotification"),
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stop),
            name: NSNotification.Name(rawValue: "APPlayerDidStopNotification"),
            object: nil)

        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "APApplicasterPlayerMiniCloseNotification"),
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopSleepMode),
            name: NSNotification.Name(rawValue: "APApplicasterPlayerMiniCloseNotification"),
            object: nil)

        let animated : Bool = configuration?.animated ?? true;

        let rootVC : UIViewController = rootViewController.topmostModal()
        if let playerVC = self.pluggablePlayerViewController() as? HybridViewController{
            if rootVC is HybridViewController {
                playerVC.updatePlayerConfiguration()
            } else {
                playerVC.modalPresentationStyle = .fullScreen
                rootVC.present(playerVC, animated:animated, completion: {
                    if let sleepModeCountDown = self.sleepModeCountDown {
                        self.sleepModeConfiguration(minutes: sleepModeCountDown.intValue)
                    }
                })
            }
        } else {
            APLoggerError("Failed creating player view controller for Kaltura player")
        }
    }

    open override func pluggablePlayerType() -> ZPPlayerType {
        return Zee5PluggablePlayer.pluggablePlayerType()
    }

    public static func pluggablePlayerType() -> ZPPlayerType {
        return .undefined
    }

    // MARK: - ZPAdapterProtocol

    public required override init() { }

    public required init(configurationJSON: NSDictionary?) { }

    @objc public func handleUrlScheme(_ params: NSDictionary) {
        print("params \(params)")
        if let stringURL = params["ds"] as? String {
            if let atomFeed = APAtomFeed.init(url: stringURL) {
                APAtomFeedLoader.loadPipes(model: atomFeed) { [weak self] (success, atomFeed) in
                    if success,
                        let atomFeed = atomFeed {
                        if let entries = atomFeed.entries,
                            entries.count > 0 {
                            if let itemId = params["id"] as? String {
                                for entry in entries {
                                    if let atomEntry = entry as? APAtomEntry,
                                        atomEntry.identifier == itemId {
                                        if let playable = atomEntry.playable() {
                                            if let p = atomEntry.parentFeed,
                                                let pipesObject = p.pipesObject {
                                                playable.pipesObject = pipesObject as NSDictionary
                                            }
                                            playable.play()
                                        }
                                    }
                                }
                            }
                            // present the first item
                            else if let atomEntry = entries.first as? APAtomEntry,
                                let playable = atomEntry.playable() {
                                if let p = atomEntry.parentFeed,
                                    let pipesObject = p.pipesObject {
                                    playable.pipesObject = pipesObject as NSDictionary
                                }
                                playable.play()
                            }
                            print("entries \(entries)")
                        }
                    }
                }
            }
        }
    }

    // MARK: - private

    static func lastActiveInstance() -> Zee5PluggablePlayer? {
        // No player present
        guard let lastActiveInstance = ZPPlayerManager.sharedInstance.lastActiveInstance as? Zee5PluggablePlayer else {
            return nil
        }

        guard let topModal = ZAAppConnector.sharedInstance().navigationDelegate.topmostModal() else {
            return nil
        }
        // Mini Player Present and user click on another item
        guard topModal is HybridViewController else {
            let instance = Zee5PluggablePlayer()
            instance.hybridViewController = HybridViewController(nibName: "HybridViewController", bundle: nil)
            instance.sleepModeCountDown = lastActiveInstance.sleepModeCountDown
            Zee5PluggablePlayer.clear(instans: lastActiveInstance)
            return instance
        }

        // Hybrid Player Present and user click on related content
        Zee5PluggablePlayer.clear(instans: lastActiveInstance)
        return lastActiveInstance
    }

    static func clear(instans: Zee5PluggablePlayer) {
        instans.shouldDissmis = false
        instans.hybridViewController?.playerViewController?.delegate = nil
        instans.hybridViewController?.playerViewController?.stop()
        instans.hybridViewController?.playerViewController = nil
        instans.hybridViewController?.currentPlayableItem = nil
        instans.currentPlayableItem = nil
        instans.hybridViewController?.delegate = nil
        instans.closeMiniPlayer()
    }

    @objc func stop() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "APPlayerControllerReachedEndNotification"), object:nil)

        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "APPlayerDidStopNotification"), object:nil)

        if self.shouldDissmis == true,
            let playerVC = self.pluggablePlayerViewController() {
            Zee5AnalyticsManager.shared.playerExit()
            playerVC.dismiss(animated: true, completion: nil)
            self.currentPlayableItem = nil
            self.hybridViewController?.playerViewController = nil
            self.hybridViewController = nil
            self.closeMiniPlayer()
        }
    }
}
