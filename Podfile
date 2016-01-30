platform :osx, "10.11"

use_frameworks!

shared_app_dependencies = proc do
  pod 'PureLayout', '~> 2.0.6'
  pod 'AMCoreAudio', '~> 2.0.10'
  pod 'StartAtLoginController', '~> 0.0.1'
end

target "AudioMate" do
  shared_app_dependencies.call
  pod 'LetsMove', '~> 1.9'
  pod 'Sparkle', '~> 1.13.1'
end

target "AudioMate-AppStore" do
  shared_app_dependencies.call
end

target "AudioMateLauncher" do

end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.name == 'Release'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        config.build_settings['SWIFT_DISABLE_SAFETY_CHECKS'] = 'YES'
        config.build_settings['LLVM_LTO'] = 'YES'
      end
    end
  end
end
