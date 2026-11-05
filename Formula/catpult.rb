class Catpult < Formula
  desc "Share secrets and streams over encrypted, ephemeral peer-to-peer tunnels"
  homepage "https://github.com/quirkdom/catpult"
  url "https://github.com/quirkdom/catpult/archive/refs/tags/v0.2-beta.tar.gz"
  sha256 "a201b3012ef3cb3bf790d903861fea64717692a8487233b5d8367755dab76d84"
  license "BSD-3-Clause"
  head "https://github.com/quirkdom/catpult.git", branch: "master"

  bottle do
    root_url "https://github.com/quirkdom/homebrew-tap/releases/download/catpult-0.2-beta"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "d53ac3e17d039cd496fe89dbf48da491547bc78caa280ff0ae016b0951f28c9a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "00643be04e6c9213e228690920bcad9784b9363136af637ba07c27d4099f3314"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    tags = if File.exist?("build-tags.txt")
      File.read("build-tags.txt").split
    else
      %w[
        netgo omitidna omitpemdecrypt osusergo
        ts_omit_ace ts_omit_acme ts_omit_advertiseexitnode ts_omit_advertiseroutes
        ts_omit_appconnectors ts_omit_aws ts_omit_bird ts_omit_cachenetmap
        ts_omit_captiveportal ts_omit_capture ts_omit_cliconndiag ts_omit_clientmetrics
        ts_omit_clientupdate ts_omit_cloud ts_omit_colorable ts_omit_completion
        ts_omit_completion_scripts ts_omit_conn25 ts_omit_debug ts_omit_debugeventbus
        ts_omit_debugportmapper ts_omit_desktop_sessions ts_omit_dns ts_omit_doctor
        ts_omit_drive ts_omit_favorites ts_omit_flashappliance ts_omit_health
        ts_omit_hujsonconf ts_omit_identityfederation ts_omit_ipnbus ts_omit_iptables
        ts_omit_kube ts_omit_linkspeed ts_omit_linuxdnsfight ts_omit_listenrawdisco
        ts_omit_logtail ts_omit_netlog ts_omit_networkmanager ts_omit_oauthkey
        ts_omit_osrouter ts_omit_outboundproxy ts_omit_peerapiclient ts_omit_peerapiserver
        ts_omit_portlist ts_omit_portmapper ts_omit_posture ts_omit_qrcodes
        ts_omit_relayserver ts_omit_remoteconfig ts_omit_resolved ts_omit_routecheck
        ts_omit_runtimemetrics ts_omit_sdnotify ts_omit_serve ts_omit_serviceclientprefs
        ts_omit_synology ts_omit_syslog ts_omit_syspolicy ts_omit_systray
        ts_omit_taildrop ts_omit_tailnetlock ts_omit_tap ts_omit_tpm
        ts_omit_tundevstats ts_omit_unixsocketidentity ts_omit_useexitnode
        ts_omit_useproxy ts_omit_usermetrics ts_omit_useroutes ts_omit_wakeonlan
        ts_omit_webbrowser ts_omit_webclient
      ]
    end

    system "go", "build", *std_go_args(ldflags: "-X main.version=v#{version}", tags: tags), "./cmd/catpult"
  end

  test do
    assert_match "catpult v#{version}", shell_output("#{bin}/catpult --version")
  end
end
