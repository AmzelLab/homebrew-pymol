class Pymol < Formula
  desc "OpenGL based molecular visualization system"
  homepage "https://pymol.org/"
  url "https://downloads.sourceforge.net/project/pymol/pymol/2/pymol-v2.1.0.tar.bz2"
  sha256 "7ae8ebb899533d691a67c1ec731b00518dea456ab3e258aa052a65c24b63eae2"
  head "https://svn.code.sf.net/p/pymol/code/trunk/pymol"

  depends_on "glew"
  depends_on "msgpack"
  depends_on "freetype"
  # Don't know why this causes error on Sierra.
  # depends_on "libxml2"
  depends_on "freeglut"
  depends_on "libpng"
  depends_on "qt5"
  depends_on "python"
  # Sometimes clang 9.0.0 shipped with Apple is problematic.
  depends_on "llvm"
  depends_on :xcode => :build

  needs :cxx11

  def install
    # https://sourceforge.net/p/pymol/bugs/202/ reports that QT-based
    # pymol 2.1 could mistakenly be linked with X11's library. The flag
    # "--osx-frameworks" should be present to prevent such issue.
    args = %W[
      --prefix=#{prefix}
      --install-scripts=#{libexec}/bin
      --osx-frameworks
    ]

    # clang emits >1e5 lines of nullability warnings for pymol, turn them off
    ENV.append_to_cflags "-Wno-nullability-completeness"
    # support for older Mac OS
    ENV.append_to_cflags "-Qunused-arguments" if MacOS.version < :mavericks
    system "python3", "-s", "setup.py", "install", *args
    bin.install libexec/"bin/pymol"
  end

  def caveats; <<~EOS
    This version of Pymol 2.1 is powered with PyQt5. You have to install PyQt5
    with `pip3 install PyQt5` to make it work. We don't want to support the
    depecrated X11/XQuartz anymore since it is always very awkward.
    EOS
  end
end
