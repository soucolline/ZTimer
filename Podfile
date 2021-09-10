# Uncomment the next line to define a global platform for your project
platform :ios, '14.1'

target 'ZTimer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for ZTimer
  pod "ZScrambler", :git => "https://github.com/soucolline/ZScrambler"
  pod "R.swift", '= 5.4.0'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.1'
      end
    end
  end
end
