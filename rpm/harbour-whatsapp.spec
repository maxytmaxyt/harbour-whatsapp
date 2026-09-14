Name:           harbour-whatsapp
Version:        1.0.0
Release:        1
Summary:        WhatsApp for Sailfish OS
License:        MIT
URL:            https://github.com/maxytmaxyt/Whatsapp-Sailfish-os
Source0:        %{name}-%{version}.tar.bz2

BuildArch:      noarch
Requires:       sailfishsilica-qt5 >= 0.10.9
Requires:       qt5-qtwebview
Requires:       libsailfishapp-launcher

%description
WhatsApp Web client for Sailfish OS.
Wraps web.whatsapp.com in a native Sailfish OS application
with proper cover, notifications and gesture support.

%prep
%setup -q

%install
mkdir -p %{buildroot}%{_datadir}/%{name}/qml/pages
mkdir -p %{buildroot}%{_datadir}/%{name}/qml/cover
mkdir -p %{buildroot}%{_datadir}/%{name}/translations
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/86x86/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/108x108/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/128x128/apps
mkdir -p %{buildroot}%{_datadir}/icons/hicolor/172x172/apps

cp -r qml %{buildroot}%{_datadir}/%{name}/
cp translations/*.qm %{buildroot}%{_datadir}/%{name}/translations/ 2>/dev/null || true
cp harbour-whatsapp.desktop %{buildroot}%{_datadir}/applications/

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
