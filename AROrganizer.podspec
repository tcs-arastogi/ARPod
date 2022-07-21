Pod::Spec.new do |s|
s.name             = 'AROrganizer'
s.version          = '0.0.1'
s.summary          = 'AROrganizer pod creation for tcs projrct'
s.description      = 'Describe the use of pod file ,AROrganizer pod creation for tcs projrct'
s.homepage         = 'https://github.com/tcs-arastogi/ARPod.git'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'aishwarya rastogi' => '502074@containerstore.com' }
s.source           = { :git => "https://github.com/tcs-arastogi/ARPod.git", :tag => 'v0.0.1' }
s.ios.deployment_target = '14.0'
s.source_files     = 'AROrganizer/**/*.{swift}'
end
