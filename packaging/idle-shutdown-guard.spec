Name:           idle-shutdown-guard
Version:        0.1.0
Release:        1%{?dist}
Summary:        User-session idle shutdown guard

License:        MIT
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
BuildRequires:  systemd-rpm-macros
Requires:       python3
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

%files
%{_bindir}/idle-shutdown-guard
%config(noreplace) %{_sysconfdir}/idle-shutdown-guard/config.ini
%{_userunitdir}/idle-shutdown-guard.service

%changelog
* Mon Jun 01 2026 Codex <codex@example.invalid> - 0.1.0-1
- Initial package.
