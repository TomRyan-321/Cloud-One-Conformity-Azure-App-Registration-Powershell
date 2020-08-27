# Cloud-One-Conformity-Azure-App-Registration-Powershell
Powershell script to create the Cloud Conformity app registration with its required permissions. This will configure the App Registration with the name of 'Conformity Azure Access' and setup the required MS & AAD Graph Permissions. You are still required to grant admin consent and associate this app with your desired Azure subscriptions via the UI (currently no powershell cmdlets to allow granting of admin consent).

Once the script finishes it will return the AppID and Secret Key required within Conformity.

### Usage

Connect to your Azure-AD tenant with the command 

```Connect-AzureAD -TenantId <your-tenant-id>```

Execute the script 

```.\register-conformity-app.ps1```

Input the returned values for Application ID and Secret ID into Conformity in order to finish loading your subscriptions.
