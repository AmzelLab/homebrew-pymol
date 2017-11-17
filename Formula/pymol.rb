class Pymol < Formula
  desc "OpenGL based molecular visualization system"
  homepage "https://pymol.org/"
  url "https://downloads.sourceforge.net/project/pymol/pymol/1.8/pymol-v1.8.6.0.tar.bz2"
  sha256 "7eaaf90ac1e1be0969291cdb1154b3631b5b6403cce1d697133d90cd37a3c565"
  head "https://svn.code.sf.net/p/pymol/code/trunk/pymol"

  bottle do
    cellar :any
    sha256 "360f9b56c4d7b424d467fac925591ac059380d4257d1d61c6f6af46b8d6689e4" => :sierra
    sha256 "6808607ebd79f398f42bc479d6b48697bad55289f0b52df0af2f5b3ff9404bab" => :el_capitan
    sha256 "217df24e99b9b96b13a9b33b137bb3ba811c407d79896091e1ef443074030df6" => :yosemite
  end

  depends_on "glew"
  depends_on "msgpack"
  depends_on :x11

  if OS.mac?
    depends_on :python
  else
    depends_on "freetype"
    depends_on "gpatch" # see homebrew/homebrew-science#5102
    depends_on "tcl-tk"
    depends_on "libxml2"
    depends_on "python" => "with-tcl-tk"
  end

  needs :cxx11

  # Patch that makes the OS X native windowing system (Aqua) and PyMol play nicely together.
  # Fixes https://sourceforge.net/p/pymol/bugs/187/ (05.09.17) and
  # https://github.com/Homebrew/homebrew-science/issues/5505 (04.27.17), in which bad GUI calls were causing segfaults.
  patch do
    url "https://raw.githubusercontent.com/telamonian/homebrew-pymol/master/Patch/pymol-v3.patch"
    sha256 "8bc0babbb72e8a6b112f7d34faa6e5e4eb5b1389cee754f2e530e7c81fde2d5e"
  end

  def install
    args = %W[
      --bundled-pmw
      --install-scripts=#{libexec}/bin
      --install-lib=#{libexec}/lib/python2.7/site-packages
    ]

    if OS.mac?
      # clang emits >1e5 lines of nullability warnings for pymol, turn them off
      ENV.append_to_cflags "-Wno-nullability-completeness"

      # support for older Mac OS
      ENV.append_to_cflags "-Qunused-arguments" if MacOS.version < :mavericks

      system "python", "-s", "setup.py", "install", *args
    else
      # on linux, add the path hint that setup.py needs in order to find the freetype and libxml2 headers
      ENV.prepend_path "PREFIX_PATH", ENV["HOMEBREW_PREFIX"]

      # because the linux python dep is specified with "python" instead of :python, python2 is needed here
      system "python2", "-s", "setup.py", "install", *args
    end

    bin.install libexec/"bin/pymol"
  end

  def caveats; <<-EOS.undent
    On some Macs, the graphics drivers do not properly support stereo
    graphics. This will cause visual glitches and shaking that stay
    visible until X11 is completely closed. This may even require
    restarting your computer. Launch explicitly in Mono mode using:
      pymol -M
    EOS
  end

  test do
    system bin/"pymol", libexec/"lib/python2.7/site-packages/pymol/pymol_path/data/demo/pept.pdb"
  end
end
