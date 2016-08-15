import UIKit

// 获取当前图形上下文
extension CGContext {

    static var current: CGContext? {
        return UIGraphicsGetCurrentContext()
    }

}

//
extension CGRect {

    func fill() {
        UIRectFill(self)
    }

    func clip() {
        UIRectClip(self)
    }
}

// 缩放path到合适尺寸
extension UIBezierPath {

    func scale(to size: CGSize) {
        // scale path - icons should all be same height
        let scale = size.height / bounds.size.height * 0.5
        apply(CGAffineTransform(scaleX: scale,
                                y: scale))

        // move path to origin
        apply(CGAffineTransform(translationX: -bounds.origin.x,
                                y: -bounds.origin.y))
        // move path into center
        apply(CGAffineTransform(translationX: size.width/2 - bounds.width/2,
                                y: size.height/2 - bounds.height/2))
    }
}

// 画渐变
extension UIView {

    func drawLinearGradient(startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) {

        let colors = [startColor.cgColor, endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0, 1]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: colorLocations)

        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: [])
    }
}

// 弧度转角度, 角度转弧度
extension CGFloat {

    var radiansToDegrees: CGFloat {
        return self / .pi * 180
    }

    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }
}

// Core Animation的timing function封装
extension CAMediaTimingFunction {

    static var easeIn: CAMediaTimingFunction {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
    }

    static var easeOut: CAMediaTimingFunction {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    }

    static var easeInEaseOut: CAMediaTimingFunction {
        return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    }

}

//
extension UIViewControllerContextTransitioning {
    
    var fromViewController: UIViewController? {
        return viewController(forKey: UITransitionContextFromViewControllerKey)
    }

    var fromView: UIView? {
        return view(forKey: UITransitionContextFromViewKey)
    }

    var toViewController: UIViewController? {
        return viewController(forKey: UITransitionContextToViewControllerKey)
    }

    var toView: UIView? {
        return view(forKey: UITransitionContextToViewKey)
    }

}

// 计算文字高度
extension String {
    
    func getHeight(givenWidth: CGFloat, font: UIFont) -> CGFloat {
        let text = self as NSString
        let attributes = [NSFontAttributeName: font]
        let rect = text.boundingRect(with: CGSize(width: givenWidth,
                                       height: CGFloat.infinity),
                          options: .usesLineFragmentOrigin,
                          attributes: attributes, context: nil)
        
        return rect.height
    }
}
