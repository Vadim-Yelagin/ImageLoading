Pod::Spec.new do |s|
  s.name = 'Fueled-ImageLoading'
  s.version = '0.3'
  s.summary = 'Async image loading.'
  s.homepage = 'https://github.com/Vadim-Yelagin/ImageLoading'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = 'Vadim Yelagin'
  s.ios.deployment_target = '8.0'
  s.source = { :git => 'https://github.com/Vadim-Yelagin/ImageLoading.git', :tag => s.version }
  s.source_files = 'ImageLoading/*.swift'
end