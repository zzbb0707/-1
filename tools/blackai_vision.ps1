param(
    [Parameter(Mandatory=$true)][string]$Image,
    [Parameter(Mandatory=$true)][string]$Question,
    [string]$Model = "gpt-5.6-sol"
)
# BlackAI GPT-5.6 看图（Invoke-RestMethod，稳定）
$key = 'sk-aa18a5696e03ed41b2d812f9a8d21c1f09c0362fc8e9172024674e1416956c3b'
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Image))
$mime = 'image/png'
$ext = [IO.Path]::GetExtension($Image).ToLower()
if ($ext -in '.jpg','.jpeg') { $mime = 'image/jpeg' }
elseif ($ext -eq '.webp') { $mime = 'image/webp' }
elseif ($ext -eq '.gif') { $mime = 'image/gif' }
$body = @{
    model = $Model
    messages = @(@{
        role = 'user'
        content = @(
            @{ type = 'text'; text = $Question },
            @{ type = 'image_url'; image_url = @{ url = "data:$mime;base64,$b64" } }
        )
    })
} | ConvertTo-Json -Depth 10
$headers = @{ Authorization = "Bearer $key" }
for ($i = 1; $i -le 4; $i++) {
    try {
        $resp = Invoke-RestMethod -Uri 'https://www.blackaicoding.com/v1/chat/completions' -Method Post -Headers $headers -ContentType 'application/json' -Body $body -TimeoutSec 90
        $answer = $resp.choices[0].message.content
        Write-Host "BLACKAI_VISION_OK model=$($resp.model)"
        Write-Host "ANSWER: $answer"
        exit 0
    } catch {
        Write-Host "attempt $i failed: $($_.Exception.Message)"
        Start-Sleep -Seconds 3
    }
}
Write-Host "BLACKAI_VISION_FAIL"
exit 1
