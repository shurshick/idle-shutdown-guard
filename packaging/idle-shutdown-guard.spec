Name:           idle-shutdown-guard
Version:        0.2.0
Release:        1%{?dist}
Summary:        User-session idle shutdown guard

License:        MIT
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  systemd-rpm-macros
Requires:       python3
Requires:       python3-gobject
Requires:       gtk3
Requires:       systemd
Requires:       zenity
Suggests:       xprintidle

%description
Small user-session service that watches desktop idle time after a configured
hour, warns the user, allows postponing shutdown, and powers off the computer
when the warning is ignored.

%prep
%setup -q

%build

%install
install -Dpm0755 src/idle-shutdown-guard \
  %{buildroot}%{_bindir}/idle-shutdown-guard
install -Dpm0644 config/config.ini \
  %{buildroot}%{_sysconfdir}/idle-shutdown-guard/config.ini
install -Dpm0644 systemd/idle-shutdown-guard.service \
  %{buildroot}%{_userunitdir}/idle-shutdown-guard.service
install -Dpm0644 icons/idle-shutdown-guard.svg \
  %{buildroot}%{_datadir}/icons/hicolor/scalable/apps/idle-shutdown-guard.svg

%files
%{_bindir}/idle-shutdown-guard
%config(noreplace) %{_sysconfdir}/idle-shutdown-guard/config.ini
%{_userunitdir}/idle-shutdown-guard.service
%{_datadir}/icons/hicolor/scalable/apps/idle-shutdown-guard.svg

%changelog
* Mon Jun 01 2026 Codex <codex@example.invalid> - 0.2.0-1
- Add tray icon and graphical settings form.

* Mon Jun 01 2026 Codex <codex@example.invalid> - 0.1.0-1
- Initial package.
