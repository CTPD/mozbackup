# 
# Skript na tvorbu automatick�ch instala�n�ch bal��k� pro jednotliv� jazykov� verze MozBackupu
#
# Autor: Pavel Cvr�ek <jasnapaka@jasnapaka.com>
# Posledn� �prava: 2008-05-03
#
# P��klad pou�it�:
# .\compile.ps1 1.4.8
# 
# -> vytvo�� release verze 1.4.8 v podadres��i bin

$version = $args[0]

# Zkontroluje se po�et vstupn�ch parametr�
if ($args.length -eq 0) {
  echo "Chyb� vstupn� parametr ud�vaj�c� verzi.";
  return;
}

# Funkce pro zkop�rov�n� soubor� pro dan� jazyk
function copyFiles ([string]$dir, [string]$version) {
  if (test-path .\$dir) {
    del .\$dir -recurse
  } 
  md .\$dir\
  cd .\$dir\
  md .\MozBackup-$version-EN\
  cd .\MozBackup-$version-EN\

  # Nakop�rov�n� pot�ebn�ch soubor�
  cp ..\..\..\source\MozBackup.exe .\MozBackup.exe
  cp ..\..\..\source\backup.ini .\backup.ini  
  cp ..\..\..\source\profilefiles.txt .\profilefiles.txt    
  cp ..\..\..\source\Default.mozprofile .\Default.mozprofile
  
  md .\dll\
  cp ..\..\..\source\dll\DelZip190.dll .\dll\DelZip190.dll
  
  cp ..\..\..\doc\english\changelog.txt .\changelog.txt
  cp ..\..\..\doc\english\license.txt .\license.txt
  cp ..\..\..\doc\english\readme.txt .\readme.txt
  
  cp ..\..\..\doc\english\language.nsi .\language.nsi
}

# Funkce pro nakop�rov�n� a rozbalen� jazykov�ho souboru
function copyLanguage ($language) {
  cp ..\..\..\l10n\$language.zip .\$language.zip
  unzip .\$language.zip -d .
  del .\$language.zip
}

function createZIP ($language, $languageShort, $version) {
  
  cd ..
  $filename = "MozBackup-" + $version + "-" + $languageShort + ".zip";
  zip $filename .\MozBackup-$version-$languageShort\MozBackup.exe
  zip $filename .\MozBackup-$version-$languageShort\backup.ini
  zip $filename .\MozBackup-$version-$languageShort\Default.lng
  zip $filename .\MozBackup-$version-$languageShort\changelog.txt
  zip $filename .\MozBackup-$version-$languageShort\license.txt
  zip $filename .\MozBackup-$version-$languageShort\readme.txt
  zip $filename .\MozBackup-$version-$languageShort\profilefiles.txt    
  zip $filename .\MozBackup-$version-$languageShort\Default.mozprofile  
  
  zip $filename .\MozBackup-$version-$languageShort\dll\DelZip190.dll
  
  mv .\$filename ..\bin\$version\$filename
  cd ..
}

function createInstaller ([string]$version) {
  cp .\installer.nsi .\install\MozBackup-$version-EN\installer.nsi
  cp .\langs.nsi .\install\MozBackup-$version-EN\langs.nsi
  cd .\install
  cd .\MozBackup-$version-EN\
  
  makensis /Dlanguage=$language /DshortLanguage=$languageShort /Dversion=$version .\installer.nsi  
  
  mv .\MozBackup-$version.exe ..\..\bin\$version\MozBackup-$version.exe
  
  cd ..
  cd ..
}

# Funkce pro spu�t�n� v�ech akc� souvisej�c�ch s p��pravou instal�toru a ZIP bal��ku pro dan� jazyk
function createDistribution ([string]$version) {

  if (!(test-path .\bin)) {
    md .\bin	
  }

  if (!(test-path .\bin\$version\)) {
    md .\bin\$version\	
  }

  # Priprava a vytvoreni ZIP verze 
  copyFiles "tempZip" $version;
  copyLanguage "english";
  createZIP "english" "EN" $version;
  
  # Priprava instal�toru
  copyFiles "install" $version;
  md .\l10n
  cd .\l10n
  
  cp ..\..\..\..\l10n\english.zip .\en.zip
  cp ..\..\..\..\l10n\czech.zip .\cs.zip
  cp ..\..\..\..\l10n\slovak.zip .\sk.zip
  cp ..\..\..\..\l10n\german.zip .\de.zip
  cp ..\..\..\..\build\unzip.exe .\unzip.exe
  
  cd ..
  cd ..  
  cd ..

  createInstaller $version;
}

$Dirs = get-childitem .
foreach ($dir in $Dirs) {
if (!( ($dir.extension.length -gt 0) -and ($dir.extension.length -lt $dir.Name.length) )) {    
    del -recurse $dir.name
  }
}

# Vyma�e se adres�� bin
if (test-path .\bin) {
  rm -recurse .\bin
}
md .\bin

# Nakop�ruj� se a rozbal� soubory s jazykov�m nastaven�m
createDistribution $args[0]

#createDistribution "czech" "CZ" $args[0]
#createDistribution "slovak" "SK" $args[0]
#createDistribution "german" "DE" $args[0]

# Vytvo�� se kontroln� sou�ty
fsum bin\$version\* bin\$version\MD5SUM
