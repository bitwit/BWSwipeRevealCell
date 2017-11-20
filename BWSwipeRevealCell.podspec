Pod::Spec.new do |spec|
	spec.name             = 'BWSwipeRevealCell'
	spec.version          = '2.0.2'
	spec.license          = { :type => 'BSD' }
	spec.homepage         = 'https://github.com/bitwit/BWSwipeRevealCell'
	spec.authors          = { 'Kyle Newsome' => 'kyle@bitwit.ca' }
	spec.summary          = 'A swipeable table cell with great flexibility'
	spec.source           = { :git => 'https://github.com/bitwit/BWSwipeRevealCell.git', :tag => '2.0.2' }
	spec.source_files     = 'BWSwipeRevealCell/BWSwipeRevealCell.h', 'BWSwipeRevealCell/BWSwipeCell.swift',
'BWSwipeRevealCell/BWSwipeRevealCell.swift'
	spec.ios.deployment_target = 8.0
	spec.requires_arc     = true
	spec.social_media_url = "https://twitter.com/kylnew"
end
