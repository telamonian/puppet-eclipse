# Public: Install Steam.app into /Applications.
#
# Examples
#
#   include eclipse
class eclipse {
  package { 'eclipse-cpp-luna-R':
    provider => 'appdmg_eula',
    source   => 'http://mirrors.xmission.com/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-macosx-cocoa-x86_64.tar.gz'
  }
}
