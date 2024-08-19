class Numpy < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/54/a4/f8188c4f3e07f7737683588210c073478abcb542048cf4ab6fedad0b458a/numpy-2.1.0.tar.gz"
  sha256 "7dc90da0081f7e1da49ec4e398ede6a8e9cc4f5ebe5f9e06b443ed889ee9aaa2"
  license "BSD-3-Clause"
  head "https://github.com/numpy/numpy.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "a2979a8604af74e0c82a8c71078afcd5100ccb50337dbaf4721c64b99c24276a"
    sha256 cellar: :any,                 arm64_ventura:  "152a821f3be4ac2bfcb25082f9794fe079a2e5d5e34156df34e0567de6668dd2"
    sha256 cellar: :any,                 arm64_monterey: "bca268c68a1c18ce0c7ee06491627018a15c8317e4e931bcffa58eba9abfd441"
    sha256 cellar: :any,                 sonoma:         "5c2c80c1f503b754e51886bd6d5dceffa703d1d64081b50ab5fce6056b3576e4"
    sha256 cellar: :any,                 ventura:        "552700f8d6e9d6fe01daf0e17f5002fe4fa01f53557662e9fbb2f4c6703f0d19"
    sha256 cellar: :any,                 monterey:       "a2a08c0c03e5cda783a64196b65478e37526925487cbe45ed2abdd9505ccfd06"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "b0c47c7382e22af33327ec27bbff173053a33220f21b853a9873ccb473f1a136"
  end

  depends_on "gcc" => :build # for gfortran
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "openblas"

  on_linux do
    depends_on "patchelf" => :build
  end

  fails_with gcc: "5"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.start_with?("python@") }
        .sort_by(&:version) # so scripts like `bin/f2py` use newest python
  end

  def install
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      system python3, "-m", "pip", "install", "-Csetup-args=-Dblas=openblas",
                                              "-Csetup-args=-Dlapack=openblas",
                                              *std_pip_args(build_isolation: true), "."
    end
  end

  def caveats
    <<~EOS
      To run `f2py`, you may need to `brew install #{pythons.last}`
    EOS
  end

  test do
    pythons.each do |python|
      python3 = python.opt_libexec/"bin/python"
      system python3, "-c", <<~EOS
        import numpy as np
        t = np.ones((3,3), int)
        assert t.sum() == 9
        assert np.dot(t, t).sum() == 27
      EOS
    end
  end
end
