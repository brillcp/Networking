Pod::Spec.new do |s|
  s.name             = 'Networking-Swift'
  s.version          = '0.9.0'
  s.summary          = 'Networking is a lightweight and powerful HTTP network framework written in Swift'
  s.description      = <<-DESC
  Networking is a lightweight and powerful async / await HTTP network framework written in Swift. Features includes but are not limited to; easily build server configurations and requests for any API, clear request and response logging, URL query and JSON parameter encoding, authentication with Basic and Bearer token.
  DESC

  s.homepage         = 'https://github.com/brillcp/Networking'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Viktor Gidlöf' => 'viktorgidlof@gmail.com' }
  s.source           = { :git => 'https://github.com/brillcp/Networking.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.tvos.deployment_target = '13.0'
  s.watchos.deployment_target = '6.0'

  s.swift_version = '5.4'
  s.source_files = 'Sources/**/*'
end
