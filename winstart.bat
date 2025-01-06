schtasks /Create ^
  /TN "Start WSL at logon" ^
  /SC ONLOGON ^
  /TR "C:\Windows\System32\wsl.exe" ^
  /RU "DOMAIN\Username" ^
  /RL HIGHEST
