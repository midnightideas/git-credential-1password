class GitCredential1password < Formula
  desc '1Password Git Credential Helper'
  homepage 'https://github.com/midnightideas/git-credential-1password'
  head 'https://github.com/midnightideas/git-credential-1password.git'
  url 'https://github.com/midnightideas/git-credential-1password/releases/download/$tag/git-credential-1password-$tag.tar.gz'
  sha256 '$sha256'
  license 'MIT'

  def install
    bin.install 'git-credential-1password'
  end
end