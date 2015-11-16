Pod::Spec.new do |spec|
	spec.name             = 'BWSwipeRevealCell'
	spec.version          = '0.1.0'
	spec.license          = { :type => 'BSD' }
	spec.homepage         = 'https://github.com/bitwit/BWSwipeRevealCell'
	spec.authors          = { 'Kyle Newsome' => 'kyle@bitwit.ca' }
	spec.summary          = 'A swipeable table cell with great flexibility'
	spec.source           = { :git => 'https://github.com/bitwit/BWSwipeRevealCell.git', :tag => 'v0.1.0' }
	spec.source_files     = 'BWSwipeRevealCell/BWSwipeRevealCell.h', 'BWSwipeRevealCell/BWSwipeRevealCell.swift'
	spec.requires_arc     = true
end
