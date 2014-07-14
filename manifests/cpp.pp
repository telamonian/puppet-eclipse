# Public: Install Eclipse to /Applications
#
# Examples
#
#   include eclipse::cpp
class eclipse::cpp {

  package { 'Eclipse-CPP-Luna-R':
    provider => 'higity',
    source   => 'http://mirrors.xmission.com/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-macosx-cocoa-x86_64.tar.gz'
  }

}
