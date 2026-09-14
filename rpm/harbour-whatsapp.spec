Name:           harbour-whatsapp
Version:        1.1.0
Release:        1
Summary:        WhatsApp for Sailfish OS
License:        MIT
URL:            https://github.com/maxytmaxyt/harbour-whatsapp
Source0:        %{name}-%{version}.tar.bz2

BuildArch:      noarch
Requires:       sailfishsilica-qt5 >= 0.10.9
Requires:       qt5-qtwebview
Requires:       nemo-qml-plugin-dbus-qt5
Requires:       nemo-qml-plugin-notifications-qt5
Requires:       python3
Requires:       python3-dbus
Requires:       systemd

%description
WhatsApp Web client for Sailfish OS with background notifications.
Wraps web.whatsapp.com in a native Sailfish OS application with:
- Native Sailfish cover with unread badge
- Background daemon for notifications when app is minimized
- Mobile-optimized touch targets
- German localization

%prep
%setup -q

%install
mkdir -p %{buildroot}%{_datadir}/%{name}/qml/pages
mkdir -p %{buildroot}%{_datadir}/%{name}/qml/cover
mkdir -p %{buildroot}%{_datadir}/%{name}/translations
mkdir -p %{buildroot}%{_datadir}/%{name}/daemon
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_userunitdir}

cp -r qml            %{buildroot}%{_datadir}/%{name}/
cp src/daemon/*.py   %{buildroot}%{_datadir}/%{name}/daemon/
chmod +x             %{buildroot}%{_datadir}/%{name}/daemon/harbour-whatsapp-daemon.py
cp translations/*.qm %{buildroot}%{_datadir}/%{name}/translations/ 2>/dev/null || true
cp harbour-whatsapp.desktop %{buildroot}%{_datadir}/applications/
cp systemd/harbour-whatsapp-daemon.service %{buildroot}%{_userunitdir}/

%post
systemctl --user enable harbour-whatsapp-daemon.service 2>/dev/null || true
systemctl --user start  harbour-whatsapp-daemon.service 2>/dev/null || true

%preun
systemctl --user stop    harbour-whatsapp-daemon.service 2>/dev/null || true
systemctl --user disable harbour-whatsapp-daemon.service 2>/dev/null || true

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_userunitdir}/harbour-whatsapp-daemon.service

%changelog
* Mon Sep 14 2026 maxytmaxyt <maxytmaxyt@users.noreply.github.com> - 1.1.0-1
- Background notification daemon via systemd user service
- Native Sailfish notifications with unread count
- Mobile-optimized UI with larger touch targets
- Cover page with animated unread badge

* Mon Sep 14 2026 maxytmaxyt <maxytmaxyt@users.noreply.github.com> - 1.0.0-1
- Initial release: WhatsApp Web wrapped in native Silica UI
- Pull-down menu, loading/error states, hardware back button
