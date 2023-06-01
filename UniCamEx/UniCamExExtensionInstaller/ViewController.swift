import Cocoa

class ViewController: NSViewController {
    let uniCamExInstaller = UniCamExInstaller()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    @IBAction func install(_ sender: Any) {
        uniCamExInstaller.install()
    }
    
    @IBAction func uninstall(_ sender: Any) {
        uniCamExInstaller.uninstall()
    }
}

