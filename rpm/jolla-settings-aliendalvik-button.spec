Name:       jolla-settings-aliendalvik-button

BuildArch: noarch

Summary:    Settings plugin adding aliendalvik control button
Version:    0.2.0
Release:    1
Group:      Qt/Qt
License:    TODO
Source0:    %{name}-%{version}.tar.bz2
Requires:   aliendalvik

%description
Settings plugin adding aliendalvik control button


%prep
%setup -q -n %{name}-%{version}

%build

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/share/jolla-settings/pages/aliendalvik
cp -r settings/*.qml %{buildroot}/usr/share/jolla-settings/pages/aliendalvik
mkdir -p %{buildroot}/usr/share/jolla-settings/entries
cp -r settings/*.json %{buildroot}/usr/share/jolla-settings/entries

%files
%defattr(-,root,root,-)
%{_datadir}/jolla-settings/entries
%{_datadir}/jolla-settings/pages
