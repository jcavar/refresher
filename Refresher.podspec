Pod::Spec.new do |s|

  s.name         = 'Refresher'
  s.version      = '0.7.0'
  s.summary      = 'Pull to refresh in Swift'

  s.description  = <<-DESC
                   Refresher is pull to refresh library written in Swift. It provides easy to use UIScrollView methods to add pull to refresh to your view. Refresher also supports custom animations.
                   DESC

  s.homepage     = 'https://github.com/jcavar/refresher'
  s.screenshots  = 'https://raw.githubusercontent.com/jcavar/refresher/master/previews/anim_beat.gif', 
  				   'https://raw.githubusercontent.com/jcavar/refresher/master/previews/anim_default.gif', 
  				   'https://raw.githubusercontent.com/jcavar/refresher/master/previews/anim_pacman.gif'

  s.license      = 'MIT'

  s.author             = { 'Josip Cavar' => 'josipcavar04@gmail.com' }
  s.social_media_url   = 'http://twitter.com/josip04'

  s.ios.deployment_target = '8.0'

  s.source       = { :git => 'https://github.com/jcavar/refresher.git', :tag => s.version }

  s.source_files  = 'Refresher/*.swift'

end

