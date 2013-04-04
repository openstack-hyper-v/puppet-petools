$url='http://download.microsoft.com/download/9/9/F/99F5E440-5EB5-4952-9935-B99662C3DF70/adk/adksetup.exe'
$file='c:\Windows\Temp\adksetup.exe'
$wc = New-Object system.Net.Webclient
$wc.DownloadFile( $url, $file )
