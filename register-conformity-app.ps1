<#
.SYNOPSIS
	Create an Azure AD App Registration for Cloud One Conformity
	
.DESCRIPTION
	Create an Azure AD App Registration for Cloud One Conformity with a Key valid for 1 year with the required MS Graph and AAD Graph Permissions
	 
.EXAMPLE

	C:\PS> register-conformity-app.ps1
	
.NOTES
	Author  : Tom Ryan
#>

$appName = "Conformity Azure Access"

if(!($myApp = Get-AzureADApplication -Filter "DisplayName eq '$($appName)'"  -ErrorAction SilentlyContinue))
{
	#Microsoft Graph Permissions
	$MSGsvcprincipal = Get-AzureADServicePrincipal -All $true | ? { $_.DisplayName -eq "Microsoft Graph" }

	### Microsoft Graph
	$reqMSGraph = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
	$reqMSGraph.ResourceAppId = $MSGsvcprincipal.AppId

	##MSGraph Delegated Permissions
    $MSGdelPermission1ID = $MSGsvcprincipal.OAuth2Permissions | ? { $_.Value -eq "User.Read" }
	$MSGdelPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $MSGdelPermission1ID.Id,"Scope"
    $MSGdelPermission2ID = $MSGsvcprincipal.OAuth2Permissions | ? { $_.Value -eq "User.Read.All" }
    $MSGdelPermission2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $MSGdelPermission2ID.Id,"Scope"

	##MSGraph Application Permissions
    $MSGappPermission1ID = $MSGsvcprincipal.AppRoles | ? { $_.Value -eq "Directory.Read.All" }
	$MSGappPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $MSGappPermission1ID.Id,"Role"
    $MSGappPermission2ID = $MSGsvcprincipal.AppRoles | ? { $_.Value -eq "User.Read.All" }
    $MSGappPermission2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $MSGappPermission2ID.Id,"Role"
 
    $reqMSGraph.ResourceAccess = $MSGdelPermission1,$MSGdelPermission2,$MSGappPermission1,$MSGappPermission2

	#AAD Graph Permissions
	$AADsvcprincipal = Get-AzureADServicePrincipal -All $true | ? { $_.DisplayName -eq "Windows Azure Active Directory" }

	### AAD Graph
	$reqAADGraph = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
	$reqAADGraph.ResourceAppId = $AADsvcprincipal.AppId

	##AAD Graph Delegated Permissions
    $AADdelPermission1ID = $AADsvcprincipal.OAuth2Permissions | ? { $_.Value -eq "User.Read" }
	$AADdelPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $AADdelPermission1ID.Id,"Scope"
    $AADdelPermission2ID = $AADsvcprincipal.OAuth2Permissions | ? { $_.Value -eq "User.Read.All" }
    $AADdelPermission2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $AADdelPermission2ID.Id,"Scope"
    $AADdelPermission3ID = $AADsvcprincipal.OAuth2Permissions | ? { $_.Value -eq "Directory.Read.All" }
    $AADdelPermission3 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $AADdelPermission3ID.Id,"Scope"

	##AAD Graph Application Permissions
    $AADappPermission1ID = $AADsvcprincipal.AppRoles | ? { $_.Value -eq "Directory.Read.All" }
	$AADappPermission1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $AADappPermission1ID.Id,"Role"
 
    $reqAADGraph.ResourceAccess = $AADdelPermission1,$AADdelPermission2,$AADdelPermission3,$AADappPermission1
    
    #Create App with permissions
    $myApp = New-AzureADApplication -DisplayName $appName -RequiredResourceAccess @($reqMSGraph,$reqAADGraph)
	#
    # Application Password Credentials (ClientSecret)
    #
    $startDate = Get-Date
    $endDate = $startDate.AddYears(1)
    $aadAppKeyPwd = New-AzureADApplicationPasswordCredential -ObjectId $myApp.ObjectId -CustomKeyIdentifier "Primary" -StartDate $startDate -EndDate $endDate
    
   
	$AppDetailsOutput = "Application Details for the $AADApplicationName application:
=========================================================
Application Name: 	$appName
Application Id:   	$($myApp.AppId)
Secret Key:       	$($aadAppKeyPwd.Value)
"
	Write-Host
	Write-Host $AppDetailsOutput
}
else
{
	Write-Host
	Write-Host -f Yellow Azure AD Application $appName already exists.
}

Write-Host
Write-Host -f Green "Finished"
Write-Host
