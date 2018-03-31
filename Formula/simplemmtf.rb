class Simplemmtf < Formula
  head "https://github.com/schrodinger/simplemmtf-python.git"

  depends_on "python"
  depends_on "msgpack"

  def install
    system "python3", *Language::Python.setup_install_args(prefix)
  end
end
