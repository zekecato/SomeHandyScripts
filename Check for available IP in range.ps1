$suffix = (145..179)
$subnet = "192.168.161"

foreach ($octet in $suffix){
    $InUse = $false
    $result = ping -n 2 -w 200 ("$subnet.$octet")
    
    switch ($result) {
        {$_ -like "Reply from *"} {$InUse = $true}
    }
    
    if ($InUse){
        "Suffix $octet in use."
    }else{
        "Suffix $octet available"
    }
}
