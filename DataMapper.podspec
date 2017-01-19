Pod::Spec.new do |spec|
    spec.name             = "DataMapper"
    spec.version          = "0.1.0"
    spec.summary          = "TODO summary"
    spec.description      = <<-DESC
                       TODO description
                       DESC
    spec.homepage         = "https://github.com/Brightify/DataMapper"
    spec.license          = 'MIT'
    spec.author           = { "Tadeas Kriz" => "tadeas@brightify.org", "Filip Dolnik" => "filip@brightify.org" }
    spec.source           = {
        :git => "https://github.com/Brightify/DataMapper.git",
        :tag => spec.version.to_s
    }
    spec.social_media_url = 'https://twitter.com/BrightifyOrg'
    spec.platform     = :ios, '8.0'
    spec.requires_arc = true

    spec.frameworks = 'Foundation'

    spec.subspec 'Core' do |subspec|
        subspec.source_files = ['Source/Core/**/*.swift']
    end

    spec.subspec 'JsonSerializer' do |subspec|
        subspec.dependency 'DataMapper/Core'
        subspec.source_files = ['Source/JsonSerializer/**/*.swift']
    end
end
