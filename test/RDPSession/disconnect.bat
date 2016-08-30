for /F "usebackq tokens=1" %%f in (`query session ^| findstr /C:^^^>`) do set session="%%f"
set session=%session:~10,-1%
tscon rdp-tcp#%session% /dest:console