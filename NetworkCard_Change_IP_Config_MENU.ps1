<#
 
.SYNOPSIS
    Ce script permet de changer de configuration de la carte RZO 
	
.DESCRIPTION
	Le script propose 2 choix, un pour la configuration DHCP et l'autre pour une IP FIXE

.EXAMPLE
	Usage du script ou Clic droit "Executer en powershell"
    PS C:\> .\NetworkCard_Change_IP_Config_MENU.ps1

.NOTES
    Author: FABHANDTEK
    Last Edit: 2021-03-31
	Version 0
    
#>


########################## Configuration des IP  ##########################
$NetworkCard_Name = "Ethernet"   # Pour verifier taper la commande : netsh interface show interface

####RZO 1
$IP1="192.168.1.1"
$MASK1 = "255.255.255.0"
$GATEWAY1 = "192.168.1.254"
$DNS1 = "1.1.1.1"
$DNS2 = "8.8.8.8"

#########################################################################


# Recuperation des informations de l'utilisateur actif
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

# Recupration des droits du role Admin
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

# Verification si le programme est lancé en Exécuté en tant qu' administrateur
if ($myWindowsPrincipal.IsInRole($adminRole))
{
    #Si besoin, pour changer l'execution des scripts powershell
	#Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -force
    # Changement de couleur, taille et titre pour informer du changement de role
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Run As ADMIN)";
    $Host.UI.RawUI.BackgroundColor = "Darkred";
    $Height =  15
    $Width = 70
    $consoleWindow = $Host.UI.RawUI.WindowSize
    $consoleBuffer = $Host.UI.RawUI.BufferSize
    $consoleWindow.Height = ($Height) 
    $consoleWindow.Width = ($Width) 
    $consoleBuffer.Height = ($Height)
    $consoleBuffer.Width = ($Width)
    $Host.UI.RawUI.set_windowSize($consoleWindow)
    $Host.UI.RawUI.set_bufferSize($consoleBuffer)
    #Clear-Host;
}
else {
    # We are not running as an administrator, so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path
    $newProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    Exit;
}

################### Execution du code en elevation de droit... ###################

#######################   FONCTIONS     ###########################################

Function Menu {

do {


    write-host "    ###############################################################" -ForegroundColor white 
    write-host "    #                   MENU CONFIGURATION                        #" -ForegroundColor white 
    write-host "    ###############################################################" -ForegroundColor white 
    write-host "    #        Selectionner la configuration à appliquer            #" -ForegroundColor white 
    write-host "    #        1. Config DHCP                                       #" -ForegroundColor white 
    write-host "    #        2. Config FIXE                                       #" -ForegroundColor white 
    write-host "    #        3. Quitter                                           #" -ForegroundColor white 
    write-host "    ###############################################################" -ForegroundColor white 
    
    write-host $errout
    
    $choix = Read-host '(Choix de 1 à 3)'
    
    switch ($choix)
    {

        1 {Set-dhcp }
        2 {set-ipfixe}
        3 {Exit}
            default {$errout = " Mauvais choix, essayer de nouveau .... 1 à 3" }
     }
     
     } until ($choix -ne "")
     
  }

  Function set-dhcp {


  netsh interface ip set address $NetworkCard_Name dhcp
  netsh interface ip set dns $NetworkCard_Name dhcp


  }

  Function set-ipfixe {

  netsh int ipv4 set address name=$NetworkCard_Name Source='static' address=$IP1 mask=$MASK1 gateway=$GATEWAY1 gwmetric=1 store=persistent
  netsh interface ipv4 set dns $NetworkCard_Name static $DNS1 | Out-Null
  netsh interface ipv4 add dns $NetworkCard_Name $DNS2 index=2 | Out-Null

 
  }

 ####################### PROGRAMME PRINCIPAL ########################################

 #Demarrage fonction Menu
 Menu