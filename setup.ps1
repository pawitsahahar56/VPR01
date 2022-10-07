Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
& {$P = $env:TEMP + '\chromeremotedesktophost.msi'; Invoke-WebRequest 'https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi' -OutFile $P; Start-Process $P -Wait; Remove-Item $P}



New-Item -ItemType "directory" -Force -Path "c:\down"
New-Item -ItemType "directory" -Force -Path "c:\rclone"
New-Item -ItemType "directory" -Force -Path "c:\TOOLS2"

<# DOWNLOAD WINFSP #>
Invoke-WebRequest -Uri "https://www.dropbox.com/s/5t1hte7y1ctff9j/winfsp.msi?dl=1" -OutFile C:\TOOLS2\winfsp.msi

<# DOWNLOAD RCLONE #>
Invoke-WebRequest -Uri "https://www.dropbox.com/sh/j586zcyqbp0ib25/AABbzc8vi2LBCF2BC4fmYFmoa?dl=1" -OutFile C:\down\rclone.zip
Expand-Archive -LiteralPath 'C:\down\rclone.zip' -DestinationPath C:\rclone\

<# DOWNLOAD TOTAL COMMANDER #>
Invoke-WebRequest -Uri "https://www.dropbox.com/sh/ma6bsg279ap03gf/AABQz-8OOipk4N9VFWWdOVPLa?dl=1" -OutFile C:\down\TCM.zip
Expand-Archive -LiteralPath 'C:\down\TCM.zip' -DestinationPath C:\TOTAL\

<# DOWNLOAD TOTAL COMMANDER CONFIGS #>
Invoke-WebRequest -Uri "https://www.dropbox.com/sh/0g3tprzn60fjq4d/AAAjEkOEng4H825RLXygmbHda?dl=1" -OutFile C:\down\TCM-CFG.zip
Expand-Archive -LiteralPath 'C:\down\TCM-CFG.zip' -DestinationPath C:\Users\runneradmin\AppData\Roaming\GHISLER


Function Set-ScreenResolution { 

<# 
    .Synopsis 
        Sets the Screen Resolution of the primary monitor 
    .Description 
        Uses Pinvoke and ChangeDisplaySettings Win32API to make the change 
    .Example 
        Set-ScreenResolution -Width 1024 -Height 768         
    #> 
param ( 
[Parameter(Mandatory=$true, 
           Position = 0)] 
[int] 
$Width, 

[Parameter(Mandatory=$true, 
           Position = 1)] 
[int] 
$Height 
) 

$pinvokeCode = @" 
using System; 
using System.Runtime.InteropServices; 
namespace Resolution 
{ 
    [StructLayout(LayoutKind.Sequential)] 
    public struct DEVMODE1 
    { 
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
        public string dmDeviceName; 
        public short dmSpecVersion; 
        public short dmDriverVersion; 
        public short dmSize; 
        public short dmDriverExtra; 
        public int dmFields; 
        public short dmOrientation; 
        public short dmPaperSize; 
        public short dmPaperLength; 
        public short dmPaperWidth; 
        public short dmScale; 
        public short dmCopies; 
        public short dmDefaultSource; 
        public short dmPrintQuality; 
        public short dmColor; 
        public short dmDuplex; 
        public short dmYResolution; 
        public short dmTTOption; 
        public short dmCollate; 
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)] 
        public string dmFormName; 
        public short dmLogPixels; 
        public short dmBitsPerPel; 
        public int dmPelsWidth; 
        public int dmPelsHeight; 
        public int dmDisplayFlags; 
        public int dmDisplayFrequency; 
        public int dmICMMethod; 
        public int dmICMIntent; 
        public int dmMediaType; 
        public int dmDitherType; 
        public int dmReserved1; 
        public int dmReserved2; 
        public int dmPanningWidth; 
        public int dmPanningHeight; 
    }; 
    class User_32 
    { 
        [DllImport("user32.dll")] 
        public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE1 devMode); 
        [DllImport("user32.dll")] 
        public static extern int ChangeDisplaySettings(ref DEVMODE1 devMode, int flags); 
        public const int ENUM_CURRENT_SETTINGS = -1; 
        public const int CDS_UPDATEREGISTRY = 0x01; 
        public const int CDS_TEST = 0x02; 
        public const int DISP_CHANGE_SUCCESSFUL = 0; 
        public const int DISP_CHANGE_RESTART = 1; 
        public const int DISP_CHANGE_FAILED = -1; 
    } 
    public class PrmaryScreenResolution 
    { 
        static public string ChangeResolution(int width, int height) 
        { 
            DEVMODE1 dm = GetDevMode1(); 
            if (0 != User_32.EnumDisplaySettings(null, User_32.ENUM_CURRENT_SETTINGS, ref dm)) 
            { 
                dm.dmPelsWidth = width; 
                dm.dmPelsHeight = height; 
                int iRet = User_32.ChangeDisplaySettings(ref dm, User_32.CDS_TEST); 
                if (iRet == User_32.DISP_CHANGE_FAILED) 
                { 
                    return "Unable To Process Your Request. Sorry For This Inconvenience."; 
                } 
                else 
                { 
                    iRet = User_32.ChangeDisplaySettings(ref dm, User_32.CDS_UPDATEREGISTRY); 
                    switch (iRet) 
                    { 
                        case User_32.DISP_CHANGE_SUCCESSFUL: 
                            { 
                                return "Success"; 
                            } 
                        case User_32.DISP_CHANGE_RESTART: 
                            { 
                                return "You Need To Reboot For The Change To Happen.\n If You Feel Any Problem After Rebooting Your Machine\nThen Try To Change Resolution In Safe Mode."; 
                            } 
                        default: 
                            { 
                                return "Failed To Change The Resolution"; 
                            } 
                    } 
                } 
            } 
            else 
            { 
                return "Failed To Change The Resolution."; 
            } 
        } 
        private static DEVMODE1 GetDevMode1() 
        { 
            DEVMODE1 dm = new DEVMODE1(); 
            dm.dmDeviceName = new String(new char[32]); 
            dm.dmFormName = new String(new char[32]); 
            dm.dmSize = (short)Marshal.SizeOf(dm); 
            return dm; 
        } 
    } 
} 
"@ 

Add-Type $pinvokeCode -ErrorAction SilentlyContinue 
[Resolution.PrmaryScreenResolution]::ChangeResolution($width,$height) 
} 

Set-ScreenResolution -Width 1920 -Height 1080

<# INSTALL WINSFP#>
msiexec /i "C:\TOOLS2\winfsp.msi" /q

<# START TOTAL COMMANDER #>
Start-Process -FilePath "C:\TOTAL\TOTALCMD.exe"

<# MOUNT VIPER GALLERIES #>
Start-Process -FilePath "C:\rclone\__COPY-PASTA.bat"
