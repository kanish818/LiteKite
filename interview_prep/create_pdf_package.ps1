# LiteKite Interview Prep - PDF Package Creator
# This script converts markdown files to PDFs and creates a zip archive

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " LiteKite Interview Prep PDF Creator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define files to convert
$markdownFiles = @(
    "START_HERE.md",
    "INTERVIEW_PREP_GUIDE.md",
    "PRACTICE_QUESTIONS.md",
    "QUICK_REFERENCE.md",
    "PRACTICE_WORKSHEET.md"
)

$outputFolder = "Interview_Prep_PDFs"
$zipFileName = "LiteKite_Interview_Prep_Package.zip"

# Check if pandoc is installed
Write-Host "Checking for pandoc..." -ForegroundColor Yellow
$pandocInstalled = $null -ne (Get-Command pandoc -ErrorAction SilentlyContinue)

if (-not $pandocInstalled) {
    Write-Host "Pandoc not found. Installing via winget..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Note: This requires winget (Windows Package Manager)." -ForegroundColor Cyan
    Write-Host "If installation fails, you can manually install from: https://pandoc.org/installing.html" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        winget install --id JohnMacFarlane.Pandoc -e --silent
        Write-Host "Pandoc installed successfully!" -ForegroundColor Green
        
        # Refresh the PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Wait a moment for installation to complete
        Start-Sleep -Seconds 3
    }
    catch {
        Write-Host "Failed to install pandoc automatically." -ForegroundColor Red
        Write-Host ""
        Write-Host "Please install pandoc manually:" -ForegroundColor Yellow
        Write-Host "1. Download from: https://github.com/jgm/pandoc/releases/latest" -ForegroundColor White
        Write-Host "2. Or use chocolatey: choco install pandoc" -ForegroundColor White
        Write-Host "3. Then run this script again" -ForegroundColor White
        Write-Host ""
        
        # Alternative: Create HTML versions instead
        Write-Host "Alternative: Creating HTML versions instead..." -ForegroundColor Cyan
        $useHtml = $true
    }
}

# Create output folder
if (Test-Path $outputFolder) {
    Remove-Item $outputFolder -Recurse -Force
}
New-Item -ItemType Directory -Path $outputFolder | Out-Null
Write-Host "Created output folder: $outputFolder" -ForegroundColor Green

# Convert each markdown file
$convertedFiles = @()
$pandocAvailable = $null -ne (Get-Command pandoc -ErrorAction SilentlyContinue)

foreach ($file in $markdownFiles) {
    if (Test-Path $file) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
        
        if ($pandocAvailable) {
            # Convert to PDF using pandoc
            $pdfFile = Join-Path $outputFolder "$baseName.pdf"
            Write-Host "Converting $file to PDF..." -ForegroundColor Yellow
            
            try {
                pandoc $file -o $pdfFile `
                    --pdf-engine=wkhtmltopdf `
                    --metadata title="LiteKite Interview Prep - $baseName" `
                    --toc `
                    --toc-depth=3 `
                    -V geometry:margin=1in `
                    2>&1 | Out-Null
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✓ Created: $pdfFile" -ForegroundColor Green
                    $convertedFiles += $pdfFile
                }
                else {
                    # Try without wkhtmltopdf engine
                    Write-Host "  Trying alternative conversion method..." -ForegroundColor Yellow
                    pandoc $file -o $pdfFile `
                        --metadata title="LiteKite Interview Prep - $baseName" `
                        --toc `
                        --toc-depth=3 `
                        -V geometry:margin=1in `
                        2>&1 | Out-Null
                    
                    if (Test-Path $pdfFile) {
                        Write-Host "  ✓ Created: $pdfFile" -ForegroundColor Green
                        $convertedFiles += $pdfFile
                    }
                }
            }
            catch {
                Write-Host "  ✗ Error converting $file : $_" -ForegroundColor Red
            }
        }
        else {
            # Fallback: Create HTML version
            $htmlFile = Join-Path $outputFolder "$baseName.html"
            Write-Host "Converting $file to HTML..." -ForegroundColor Yellow
            
            $content = Get-Content $file -Raw
            $html = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>LiteKite Interview Prep - $baseName</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            max-width: 900px; 
            margin: 40px auto; 
            padding: 20px;
            line-height: 1.6;
            color: #333;
        }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; border-bottom: 2px solid #95a5a6; padding-bottom: 5px; }
        h3 { color: #555; margin-top: 20px; }
        code { 
            background: #f4f4f4; 
            padding: 2px 6px; 
            border-radius: 3px;
            font-family: 'Consolas', 'Monaco', monospace;
        }
        pre { 
            background: #2c3e50; 
            color: #ecf0f1;
            padding: 15px; 
            border-radius: 5px; 
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', monospace;
        }
        pre code {
            background: none;
            color: #ecf0f1;
        }
        table { 
            border-collapse: collapse; 
            width: 100%; 
            margin: 20px 0;
        }
        th, td { 
            border: 1px solid #ddd; 
            padding: 12px; 
            text-align: left; 
        }
        th { 
            background-color: #3498db; 
            color: white;
            font-weight: bold;
        }
        tr:nth-child(even) { background-color: #f9f9f9; }
        blockquote {
            border-left: 4px solid #3498db;
            margin: 20px 0;
            padding: 10px 20px;
            background: #ecf0f1;
        }
        ul, ol { margin: 15px 0; padding-left: 30px; }
        li { margin: 8px 0; }
        .checkbox { margin-right: 8px; }
    </style>
</head>
<body>
$($content -replace '```(\w+)?', '<pre><code>' -replace '```', '</code></pre>' -replace '`([^`]+)`', '<code>$1</code>' -replace '\*\*([^*]+)\*\*', '<strong>$1</strong>' -replace '\*([^*]+)\*', '<em>$1</em>' -replace '^# (.+)$', '<h1>$1</h1>' -replace '^## (.+)$', '<h2>$1</h2>' -replace '^### (.+)$', '<h3>$1</h3>' -replace '^\- \[ \] (.+)$', '<div><input type="checkbox" class="checkbox" disabled> $1</div>' -replace '^\- \[x\] (.+)$', '<div><input type="checkbox" class="checkbox" checked disabled> $1</div>')
</body>
</html>
"@
            $html | Out-File -FilePath $htmlFile -Encoding UTF8
            Write-Host "  ✓ Created: $htmlFile" -ForegroundColor Green
            $convertedFiles += $htmlFile
        }
    }
    else {
        Write-Host "  ✗ File not found: $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Files converted: $($convertedFiles.Count)" -ForegroundColor Cyan

# Create zip file
if ($convertedFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Creating zip archive..." -ForegroundColor Yellow
    
    if (Test-Path $zipFileName) {
        Remove-Item $zipFileName -Force
    }
    
    Compress-Archive -Path $outputFolder -DestinationPath $zipFileName -Force
    
    $zipSize = (Get-Item $zipFileName).Length / 1MB
    Write-Host "✓ Created: $zipFileName ($([math]::Round($zipSize, 2)) MB)" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host " SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your interview prep package is ready:" -ForegroundColor Cyan
    Write-Host "  Location: $(Get-Location)\$zipFileName" -ForegroundColor White
    Write-Host "  Contains: $($convertedFiles.Count) files" -ForegroundColor White
    Write-Host ""
    Write-Host "To extract, right-click the zip file and select 'Extract All...'" -ForegroundColor Yellow
    Write-Host ""
    
    # Offer to open the folder
    Write-Host "Would you like to open the folder? (Y/N)" -ForegroundColor Cyan
    $response = Read-Host
    if ($response -eq 'Y' -or $response -eq 'y') {
        explorer.exe /select,"$(Get-Location)\$zipFileName"
    }
}
else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host " ERROR: No files were converted" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check that the markdown files exist and try again." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Script completed!" -ForegroundColor Cyan
Write-Host ""
