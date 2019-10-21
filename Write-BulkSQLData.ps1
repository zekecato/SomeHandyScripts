function Write-BulkSQLData {
<#
.Synopsis
   Performs a SQL Bulk import of object data into a table. 
   Requires that the objects imported have property names that are the same as the SQL field names.
   I wrote this because I was having trouble with the built in SqlServer Cmdlets leaving SQL connections open.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Depends on Out-DataTable and Get-Type from https://www.powershellgallery.com/packages/FC_Data/
#>
    [CmdletBinding(DefaultParameterSetName='WindowsAuth')]
    param(
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $ServerInstance,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string]
        $DatabaseName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string]
        $TableName,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,
            ParameterSetName='PlainTextCredential')]
        [ValidateNotNullorEmpty()]
        [string]
        $Username,
        
        [Parameter(Mandatory=$true,
            ParameterSetName='PlainTextCredential')]
        [ValidateNotNullorEmpty()]
        [string]
        $Password,
        
        [Parameter(ParameterSetName='WindowsAuth')]
        [Switch]
        $UseWindowsAuthentication,

        [Parameter(Mandatory=$true,
            ParameterSetName='PSCredential')]
        [PSCredential]
        $Credential,
        
        [int]
        $CommandTimeout=0,

        [Parameter(
            Mandatory=$true
        )]
        [psobject]
        $InputData,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $ColumnMappings
    )
    #Create Connection string
    $ConnectionString = "Server=$ServerInstance; Database=$DatabaseName; "

    If($PSCmdlet.ParameterSetName -eq 'PSCredential'){
        $NetCred = $Credential.GetNetworkCredential()
        $Username = $NetCred.UserName
        $Password = $NetCred.Password
    }
    
    If ($UseWindowsAuthentication) { 
        $ConnectionString += "Trusted_Connection=Yes; Integrated Security=SSPI;" 
    } else { 
        $ConnectionString += "User ID=$username; Password=$password;" 
    }
 

    #Connect to database
    $Connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString);

    try{
    $Connection.Open();
    }catch{
        "Failed to connect to database"
        throw $_
    }

    #Create Datatable object and configure bulk upload connection
    $DataTable = $InputData | Out-DataTable

     #Get columns for table in SQL and compare to column in source DataTable
        $bc = new-object ("System.Data.SqlClient.SqlBulkCopy") $Connection
        $bc.DestinationTableName = "$SchemaName.$TableName"
    
        #Make sure the data columns are mapped correctly

        if ($ColumnMappings.Keys){
            foreach($Source in $ColumnMappings.Keys){
                $bc.ColumnMappings.Add([string]$Source,[string]($ColumnMappings.$Source)) | Out-Null
            }
        }else{
            $InputData[0].psobject.properties.name | ForEach-Object {$bc.ColumnMappings.add($_,$_)} | Out-Null
        }
        $bc.WriteToServer($DataTable)
    $Connection.close()
}