Configuration DC1
{
	$domainCred = Get-AutomationPSCredential -Name "DomainAdmin"
    $DomainName = Get-AutomationVariable -Name "DomainName"
    $DomainDN = Get-AutomationVariable -Name "DomainDN"
	
	# Import the modules needed to run the DSC script
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
	Import-DScResource -ModuleName 'ComputerManagementDsc'
	Import-DscResource -ModuleName 'ActiveDirectoryDsc'	

	Node "Localhost"
	{
	    Computer NewComputerName
        {
            Name = "DC1"
        }       	
		
		WindowsFeature ADDSInstall
		{
			Ensure = "Present"
			Name = "AD-Domain-Services"
			DependsOn = "[Computer]NewComputerName"
		}
		WindowsFeature ADDSTools
		{
			Ensure = "Present"
			Name = "RSAT-ADDS"
		}
		WindowsFeature InstallRSAT-AD-PowerShell
		{
			Ensure = "Present"
			Name = "RSAT-AD-PowerShell"
		}
		
		ADDomain $DomainName
        {
            DomainName                    = $DomainName
            Credential                    = $domainCred
            SafemodeAdministratorPassword = $domainCred
			ForestMode                    = 'WinThreshold'
			DependsOn 					  = "[WindowsFeature]ADDSInstall"
        }	
		WaitForADDomain $DomainName
        {
            DomainName           = $DomainName
			WaitTimeout          = 600
			RestartCount         = 2
            PsDscRunAsCredential = $domainCred
        }
		ADOrganizationalUnit 'Demo'
        {
            Name                            = "Demo"
            Path                            = "$domainDN"
            ProtectedFromAccidentalDeletion = $true
            Description                     = "TopLevel OU"
            Ensure                          = 'Present'
        }
		
		ADOrganizationalUnit 'WebServers'
        {
            Name                            = "WebServers"
            Path                            = "OU=Demo,$domainDN"
            ProtectedFromAccidentalDeletion = $true
            Description                     = "WebServers OU"
			Ensure                          = 'Present'
			DependsOn 						= "[ADOrganizationalUnit]Demo"
		}
		ADOrganizationalUnit 'Administration'
        {
            Name                            = "Administration"
            Path                            = "OU=Demo,$domainDN"
            ProtectedFromAccidentalDeletion = $true
            Description                     = "Administration OU"
			Ensure                          = 'Present'
			DependsOn 						= "[ADOrganizationalUnit]Demo"
		}
		ADOrganizationalUnit 'AdminUsers'
        {
            Name                            = "AdminUsers"
            Path                            = "OU=Administration,OU=Demo,$domainDN"
            ProtectedFromAccidentalDeletion = $true
            Description                     = "Administration OU"
			Ensure                          = 'Present'
			DependsOn 						= "[ADOrganizationalUnit]Administration"
		}
		ADOrganizationalUnit 'ServiceAccounts'
        {
            Name                            = "ServiceAccounts"
            Path                            = "OU=Demo,$domainDN"
            ProtectedFromAccidentalDeletion = $true
            Description                     = "ServiceAccounts OU"
			Ensure                          = 'Present'
			DependsOn 						= "[ADOrganizationalUnit]Demo"
		}
		ADOrganizationalUnit 'Citrix'
        {
            Name                            = "Citrix"
            Path                            = "OU=Demo,$domainDN"
            ProtectedFromAccidentalDeletion = $true
            Description                     = "Citrix OU"
			Ensure                          = 'Present'
			DependsOn 						= "[ADOrganizationalUnit]Demo"
		}		
		ADOrganizationalUnit 'Users'
        {
            Name                            = "Users"
            Path                            = "OU=Demo,$domainDN"
            ProtectedFromAccidentalDeletion = $true
            Description                     = "Users OU"
			Ensure                          = 'Present'
			DependsOn 						= "[ADOrganizationalUnit]Demo"
		}
		ADOrganizationalUnit 'Servers'
        {
            Name                            = "Servers"
            Path                            = "OU=Demo,$domainDN"
            ProtectedFromAccidentalDeletion = $true
            Description                     = "Servers OU"
			Ensure                          = 'Present'
			DependsOn 						= "[ADOrganizationalUnit]Demo"
		}		
		ADUser	 'test123'
		{
			UserName = 'test123'
			Description = "Test account"
			Credential = $Cred
			PasswordNotRequired = $true
			DomainName = 'larzytech.com'
			Path = "OU=ServiceAccounts,OU=Demo,$domainDN"
			Ensure = 'Present'
			DependsOn = "[ADOrganizationalUnit]ServiceAccounts"
			Enabled = $true
			UserPrincipalName = "test123@larzytech.com"
			PasswordNeverExpires = $true
			ChangePasswordAtLogon = $false
		}		
	}
}