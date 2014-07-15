# Public: Install Eclipse runtime binary into directory /Applications/${eclipse_dir}.
#
# Examples
#
#   include eclipse
class eclipse ($eclipse_dir='eclipse') {
  package {'${eclipse_dir}':
    provider => 'compressed_dir',
    source   => 'http://download.eclipse.org/eclipse/downloads/drops4/R-4.4-201406061215/eclipse-platform-4.4-macosx-cocoa-x86_64.tar.gz'
  }
}
