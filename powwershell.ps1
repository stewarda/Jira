[String] $target = "http://jirahost:2990";
[String] $username = "username"
[String] $password = "password"
[String] $projectKey = "TP";
[String] $issueType = "Task";
[String] $summary = "summary";
[String] $description = "description"
[String] $priority = "2"
  
[String] $body = '{"fields":{"project":{"key":"'+$projectKey+'"},"issuetype":{"name": "'+$issueType+'"},"summary":"'+$summary+'","description":"'+$description+'", "priority":{"id":"'+$priority+'"}}}';
  
function ConvertTo-Base64($string) {
$bytes = [System.Text.Encoding]::UTF8.GetBytes($string);
$encoded = [System.Convert]::ToBase64String($bytes);
return $encoded;
}
  
try {
  
$b64 = ConvertTo-Base64($username + ":" + $password);
$auth = "Basic " + $b64;
  
$webRequest = [System.Net.WebRequest]::Create($target+"/jira/rest/api/2/issue/")
$webRequest.ContentType = "application/json"
$BodyStr = [System.Text.Encoding]::UTF8.GetBytes($body)
$webrequest.ContentLength = $BodyStr.Length
$webRequest.ServicePoint.Expect100Continue = $false
$webRequest.Headers.Add("Authorization", $auth);
$webRequest.PreAuthenticate = $true
$webRequest.Method = "POST"
$requestStream = $webRequest.GetRequestStream()
$requestStream.Write($BodyStr, 0, $BodyStr.length)
$requestStream.Close()
[System.Net.WebResponse] $resp = $webRequest.GetResponse()
  
$rs = $resp.GetResponseStream()
[System.IO.StreamReader] $sr = New-Object System.IO.StreamReader -argumentList $rs
[string] $results = $sr.ReadToEnd()
Write-Output $results
  
}
  
catch [System.Net.WebException]{
        if ($_.Exception -ne $null -and $_.Exception.Response -ne $null) {
            $errorResult = $_.Exception.Response.GetResponseStream()
            $errorText = (New-Object System.IO.StreamReader($errorResult)).ReadToEnd()
            Write-Warning "The remote server response: $errorText"
            Write-Output $_.Exception.Response.StatusCode
        } else {
            throw $_
        }
    }
