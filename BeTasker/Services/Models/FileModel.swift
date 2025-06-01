//
//  FileModel.swift
//  teamAlerts
//
//  Created by B2Cvertical A++ on 07/05/24.
//
import UIKit

enum FileType: String {
    case Image = "image"
    case Video = "video"
    case PDF = "pdf"
}

struct FileModel: Codable {
    var id: Int? //31,
    var user_id: Int? //24,
    var clue_id: Int? //7,
    var file_name: String? //"",
    var file_type: String? //"Image"
    
    var image: String?
    var media_type: String?
    var image_name: String?
    var image_full_path: String?
}

struct ImageModel {
    var img: UIImage?
    var data: FileViewModel?
}

struct FileViewModel {
    private var data = FileModel()
    init(data: FileModel) {
        self.data = data
    }
    var id: Int {
        return data.id ?? 0
    }
    var userId: Int {
        return data.user_id ?? 0
    }
    var clueId: Int {
        return data.clue_id ?? 0
    }
    var imgFullPath: String {
        return data.image_full_path ?? ""
    }
    var imgURL: URL? {
        return imgFullPath.makeUrl()
    }
    var fileURL: URL? {
        return data.file_name?.makeUrl()
    }
    
    var receivedFileName: String {
        return data.file_name ?? ""
    }
    
    var fileType: FileType {
        if let mediaType = data.media_type, mediaType != "" {
            return FileType(rawValue: mediaType) ?? .Image
        }
        return FileType(rawValue: data.file_type ?? "") ?? .Image
    }
    
    var fileName: String {
        return data.image ?? ""
    }
    
    var imageURL: URL? {
        return data.image?.makeUrl()
    }
    
    var fileNameFormatted: String {
        return fileType == .Image ? "image###B2C###\(fileName)" : fileType == .Video ? "video###B2C###\(fileName)" : "pdf###B2C###\(fileName)"
    }
    
    var imageName: String {
        return data.image_name ?? ""
    }
    
    static func UploadImage(mediaType: FileType, data: Data?, fileName: String? = nil, idx: Int, completion: @escaping(_ imageRes: FileViewModel?, _ idx: Int)->()) {
        let params: [String: Any] = [
            "media_type": mediaType.rawValue
        ]
        let mimeType: MimeType = mediaType == .Image ? .image : mediaType == .Video ? .video : mediaType == .PDF ? .pdf : .audio
        
        HpAPI.uploadImages.requestUploadProgress(params: params, fileOrgName: fileName, files: ["image": data], mimeType: mimeType, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<FileModel, Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let data = FileViewModel(data: res)
                    completion(data, idx)
                    break
                case .failure(_):
                    completion(nil, idx)
                    break
                }
            }
        }
    }
    
}


struct SignupFileModel: Codable {
    var image_name: String?
}

struct SignupFileViewModel: Codable {
    private var data = SignupFileModel()
    init(data: SignupFileModel) {
        self.data = data
    }
    
    var imageName: String {
        return data.image_name ?? ""
    }
    
    static func uploadSignupImage(data: Data?, completion: @escaping(_ imageRes: SignupFileViewModel?)->()) {
        
        HpAPI.uploadSignupProfile.requestUploadProgress(params: [:], files: ["image": data], mimeType: .image, shouldShowError: true, shouldShowSuccess: false, key: nil) { (response: Result<SignupFileModel, Error>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let res):
                    let data = SignupFileViewModel(data: res)
                    completion(data)
                    break
                case .failure(_):
                    completion(nil)
                    break
                }
            }
        }
    }
}
