# Getting IBKR Desktop Stable

This projects aims to find a way to run the IBKR desktop app in a stable manner, this project aims fixing it on Linux, contributions for Windows and Mac are welcome.

Many 'IBKR Desktop' users have reported memory leaks, slowdowns with the app, after looking around it seems that the main launcher `ntws.exe` is a java launcher based on 32-bit Zulu JVM, so the idea is to try to run it with a different JVM.

## Install IBKR Desktop On Linux

1. Make sure you have [Wine](https://gitlab.winehq.org/wine/wine/-/wikis/Download) installed on your linux distribution.
2. Naviage to The IBKR Desktop [download page](https://www.interactivebrokers.com/en/trading/ibkr-desktop-download.php) and download the Windows version.
3. Set WINEPREFIX to a new folder, for example `~/.wine-ibkr` and run the installer with:

```sh
export WINEPREFIX=~/.wine-ibkr
wget https://download2.interactivebrokers.com/installers/ntws/latest-standalone/ntws-latest-standalone-windows-x64.exe
wine ./ntws-latest-standalone-windows-x64.exe
```

4. Install the app as usual, make sure it installs to `C:\ntws` and skip the desktop icon creation.

**You have to start IBKR Desktop before proceeding to the next step, this will create the necessary configuration files. You can close when you see the login screen.**

5. Install your JVM of choice on Wine, I recommend [Temurin of the eclipse foundation](https://adoptium.net/temurin/releases), I used 64-bit Windows version of Java 21. Make sure to use the same WINEPREFIX as before.

```sh
wine ./OpenJDK21U-jdk_x64_windows_hotspot_21.0.8_9.msi
```

6. Test if java is working:

```sh
wine java -version
```

7. Copy the launcher script to the `C:\ntws` folder and make it executable:

```sh
cp run-ntws.sh ~/.wine-ibkr/drive_c/ntws/run-ntws.sh
chmod +x ~/.wine-ibkr/drive_c/ntws/run-ntws.sh
```

8. Create a desktop shortcut by running the `setup-shortcut.sh` script:

```sh
bash setup-desktop.sh
```

## Performance Tuning

Since you are no longer depend on the bundled 32-bit Zulu JVM, you can now set your own memory limits and garbage collection options by editing `ntws.vmoptions` in Wine's `C:\ntws` directory, for example `~/.wine-ibkr/drive_c/ntws/ntws.vmoptions`.

```ini
# Set initial Java heap size to 8 GB
-Xms8g
# Set maximum Java heap size to 32 GB
-Xmx32g

# Use G1 Garbage Collector
-XX:+UseG1GC

-XX:MaxGCPauseMillis=20
-XX:ParallelGCThreads=8
-XX:ConcGCThreads=8
```

## Contributing

Feel free to open issues or submit pull requests if you have any improvements or fixes.
This project is open to contributions for other platforms like Windows and MacOS.

## Disclaimer

This is not an official Interactive Brokers product, use at your own risk, make sure to read the scripts before running them.
