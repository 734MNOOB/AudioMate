platform :osx, "10.10"

use_frameworks!

shared_app_dependencies = proc do
  pod 'AMCoreAudio', '~> 1.4.2'
  pod 'StartAtLoginController', '~> 0.0.1'
  pod 'LVDebounce', '~> 0.0.4'
end

target "AudioMate" do
  shared_app_dependencies.call
  pod 'LetsMove', '~> 1.9'
  pod 'Sparkle', '~> 1.13.0'
end

target "AudioMate-AppStore" do
  shared_app_dependencies.call
end

target "AudioMateLauncher" do

end
