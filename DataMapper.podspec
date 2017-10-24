Pod::Spec.new do |spec|
    spec.name             = "DataMapper"
    spec.version          = "0.2.0"
    spec.summary          = "Universal object deserialization/serialization in Swift."
    spec.description      = <<-DESC
                        DataMapper is a framework for safe deserialization/serialization of objects from/to different data representation standards (as of now we support JSON but others can be added easily).
                       DESC
    spec.homepage         = "https://github.com/Brightify/DataMapper"
    spec.license          = 'MIT'
    spec.author           = { "Tadeas Kriz" => "tadeas@brightify.org", "Filip Dolnik" => "filip@brightify.org" }
    spec.source           = {
        :git => "https://github.com/Brightify/DataMapper.git",
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.requires_arc = true

    spec.ios.deployment_target = '8.0'
    spec.osx.deployment_target = '10.11'

    spec.frameworks = 'Foundation'

    spec.subspec 'Core' do |subspec|
        subspec.source_files = 'Source/Core/**/*.swift'
    end

    spec.subspec 'JsonSerializer' do |subspec|
        subspec.dependency 'DataMapper/Core'
        subspec.source_files = 'Source/JsonSerializer/**/*.swift'
    end
end
