import SwiftUI

enum InputOption: String, CaseIterable, Identifiable {

    case camera
    case gallery
    case documents
    case location
	
    var id: String { rawValue }

    var title: String {
        switch self {
        case .camera: return "Camera"
        case .gallery: return "Gallery"
        case .documents: return "Documents"
        case .location: return "Location"
        }
    }

    var systemImageName: String {
        switch self {
        case .camera: return "camera.fill"
        case .gallery: return "photo.fill" // or "photo"
        case .documents: return "folder.fill"
        case .location: return "mappin.and.ellipse"
        }
    }

    // Uses the gradients defined in your previous Color extension
    var gradientColors: [Color] {
        switch self {
		case .camera: return .purpleGradient
		case .gallery: return .brightBlue
        case .documents: return .redOrange
        case .location: return .mintGreen
        }
    }
}
