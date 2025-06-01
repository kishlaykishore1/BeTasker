# Uncomment the next line to define a global platform for your project
 platform :ios, '13.5'

target 'BeTasker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for teamAlerts
    pod 'Alamofire'
    pod 'IQKeyboardManagerSwift'
    pod 'AdvancedPageControl'
    pod 'SwiftMessages'
    pod 'MBProgressHUD'
    
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Firebase/Database'
    pod 'Firebase/Messaging'

    pod 'GoogleSignIn'
    pod 'CountryPickerView'

    pod 'MaterialComponents/TextControls+OutlinedTextAreas'
    pod 'MaterialComponents/TextControls+OutlinedTextFields'
    pod 'MDFInternationalization'

    pod 'BottomPopup'
    pod 'SDWebImage'
    pod 'SDWebImageSVGKitPlugin'

end

post_install do |installer|
  installer.generated_projects.each do |project|
         project.targets.each do |target|
             target.build_configurations.each do |config|
                 config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.5'
             end
         end
     end
  installer.pods_project.targets.each do |target|
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end
  end
end
