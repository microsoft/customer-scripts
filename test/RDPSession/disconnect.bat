REM This batch script disconnects the Remote Desktop Session without locking the machine. Run with Administrator privileges.
REM Useful in case of running Coded UI Tests where user want to end the remote desktop session but at the same time doesn't want to lock the machine

for /F "usebackq tokens=1" %%f in (`query session ^| findstr /C:^^^>`) do set session="%%f"
set session=%session:~10,-1%
tscon rdp-tcp#%session% /dest:console