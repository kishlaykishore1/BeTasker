
import UIKit

public class Messages {
    //MARK: Network Error Messages
    static let ProblemWithInternet = "Il semble y avoir un problème avec votre connexion Internet. Veuillez réessayer dans quelques instants.".localized
    static let NetworkError = "Erreur Internet".localized
    static let somethingWentWrong = "Oups ! Une erreur s'est produite. Merci de bien vouloir réessayer.".localized
    static let seemsNetworkError = "Oups ! Une erreur s'est produite. Merci de bien vouloir réessayer.".localized
    static let txtClose = "Fermer".localized
    
    //PhoneLogin
    static let emptyPhoneNo = "Veuillez ajouter votre numéro de téléphone.".localized
    static let validPhoneNo = "Entre un numéro de téléphone valide avant de continuer.".localized
    static let validOtp = "Veuillez ajouter le code reçu par SMS.".localized
    static let resendOtp = "Le code de vérification a bien été renvoyé.".localized
    static let wrongOtp = "Le code SMS semble invalide. Merci de bien vouloir le vérifier.".localized
    
    //SignUp
    static let emptyFirstName = "Merci d'indiquer votre prénom !".localized
    static let emptyLastName = "Merci d'indiquer votre nom !".localized
    //static let emptyDob = "Veuillez saisir la date de naissance"
    //static let emptyProfileImg = "Veuillez ajouter une photo afin d’illustrer votre profil."
    static let emptyEmail = "Merci d'indiquer votre email !".localized
    static let validEmail = "Merci d'indiquer un email valide !".localized
    static let agreeTCnPP = "Merci de bien vouloir accepter nos Conditions Générales d’Utilisation et notre Politique de confidentialité avant de continuer.".localized
    
    //Program
    static let emptyProgramName = "Merci d'indiquer un nom à votre programmation !".localized
    static let emptyProgramAction = "Veuillez choisissez les action pour programmation.".localized
    static let txtEditRecurrence = "Modifier la récurrence".localized
    static let txtModify = "Modifier la tâche".localized
    static let txtSendTaskNow = "Envoyer maintenant".localized
    static let txtDuplicate = "Dupliquer la tâche".localized
    static let txtDelete = "Supprimer".localized
    static let txtDeletePrograme = "Supprimer ce programme".localized
    static let txtDeleteConfirmationPrograme = "Êtes-vous sûr de vouloir supprimer ce programme ?".localized
    
    //TASK
    static let txtDeleteConfirmationTask = "Êtes-vous sûr de vouloir supprimer cette tâche ?".localized
    static let txtDeleteTask = "Supprimer cette tâche".localized
    static let txtDeleteTaskMember = "Supprimer le membre".localized
    static let txtDeleteTaskMemberConfirmation = "Êtes-vous sûr de vouloir supprimer ce membre ?".localized
    //Equipment
    static let emptyEquipName = "Merci d'indiquer nom !".localized
    static let emptyEquipTemp = "Merci d'indiquer température !".localized
    
    //Parts
    static let emptyPartName = "Merci de bien vouloir donner un nom à votre pièce.".localized
    
    //
//    static let NetworkError = "Erreur Internet".localized
//    static let somethingWentWrong = "Quelque chose s'est mal passé, veuillez réessayer bientôt !".localized
    
    //MARK:- Alert Messages
    static let logoutMsg = "Êtes-vous sûr de vouloir vous déconnecter ?".localized
    static let deleteAccountMsg = "Voulez-vous vraiment supprimer votre compte? Veuillez noter que cette action est irréversible!".localized
    
    static let cameraNotFound = "Tu n'as pas de caméra".localized
    static let photoMassage = "Sélectionnez une option pour ajouter une image.".localized
    static let mailNotFound = "Les services de messagerie ne sont pas disponibles".localized
    static let bugReportTitle = "Aidez-nous à améliorer l'application en signalant les anomalies rencontrées.".localized

    // Text
    static let txtAlert = "Avertissement!".localized
    static let txtSignOut = "Dé connexion".localized
    static let txtDeleteAccount = "Supprimer mon compte".localized
    static let txtYes = "Oui".localized
    static let txtNo = "Non".localized
    static let txtCancel = "Annuler".localized
    static let txtGallery = "Galerie d'images".localized
    static let txtCamera = "Caméra".localized
    static let txtSetting = "Réglages".localized
    static let txtReportaBug = "Signaler un bug".localized
    static let txtSend = "Envoyer".localized
    static let txtOk = "D'accord"
    static let txtGotIt = "J’ai compris"
    static let txtCameraPermission = "\(Constants.kAppDisplayName) \("souhaite accéder à l'appareil photo de votre appareil pour mettre à jour votre profil.".localized)"
    static let txtLibraryPermission = "\(Constants.kAppDisplayName) \("souhaite accéder à la photothèque de votre appareil pour mettre à jour votre profil.".localized)"
    
    static let cameraPermissionTitle = "« \(Constants.kAppDisplayName) » \("souhaite accéder à l'appareil caméra.".localized)"
    static let photoLibraryPermissionTitle = "« \(Constants.kAppDisplayName) » \("souhaite accéder à l'appareil photo.".localized)"
    
    //MARK:- Helper Classes
    static let txtError = "Erreur".localized
    static let txtAlertMes = "Alerte".localized
    static let txtSuccess = "Succès".localized
    
    //delete account alert text
    static let txtDeleteAlert = "Alerte!".localized
    static let txtDeleteConfirm = "Confirmer".localized
    
    static let txtSettingReportBug = "Signaler un bug".localized
    static let txtSettingSend = "Envoyer".localized
    static let txtSettingBugDetail = "Veuillez saisir les détails du bogue".localized
    
    static let txtSettingReportTextField = "Votre rapport…".localized
    static let emptyWorkSpacename = "Merci de bien vouloir ajouter un nom pour votre espace de travail.".localized
}

class CustomActivityItemProvider: UIActivityItemProvider {
    var titleOfBlog: String!
    let message = "".localized
       init(placeholderItem: Any, titleOfBlog: String) {
        super.init(placeholderItem: placeholderItem)
        self.titleOfBlog = titleOfBlog
     }
    
    override var item: Any {
        switch self.activityType! {
        case UIActivity.ActivityType.postToFacebook:
            return ""
        case UIActivity.ActivityType.message:
            return ""
        case UIActivity.ActivityType.mail:
            return ""
        case UIActivity.ActivityType.postToTwitter:
            return ""
        default:
            return ""
        }
    }
}
