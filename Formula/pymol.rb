class Pymol < Formula
  desc "OpenGL based molecular visualization system"
  homepage "https://pymol.org/"
  url "https://downloads.sourceforge.net/project/pymol/pymol/2/pymol-v2.1.0.tar.bz2"
  sha256 "7ae8ebb899533d691a67c1ec731b00518dea456ab3e258aa052a65c24b63eae2"
  head "https://svn.code.sf.net/p/pymol/code/trunk/pymol"

  depends_on "glew"
  depends_on "msgpack"
  depends_on :x11

  if OS.mac?
    depends_on "python"
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
    url "https://raw.githubusercontent.com/AmzelLab/homebrew-pymol/master/Patch/pymol-v4.patch"
    sha256 "3a025423e8c7325f279aa6a2cc2699cf5dc9b7a8b64f2ab3e6095117937a20d6"
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

      system "python3", *Language::Python.setup_install_args(prefix), *args
      # system "python2", "-s", "setup.py", "install", *args
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
