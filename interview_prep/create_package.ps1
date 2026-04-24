# Simple HTML Package Creator - No Dependencies Required!
# Creates HTML files that you can print to PDF using any browser (Ctrl+P -> Save as PDF)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " LiteKite Interview Prep Package Creator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Files to convert
$files = @(
    "START_HERE.md",
    "INTERVIEW_PREP_GUIDE.md",
    "PRACTICE_QUESTIONS.md",
    "QUICK_REFERENCE.md",
    "PRACTICE_WORKSHEET.md"
)

$outputFolder = "Interview_Prep_Package"
$zipFile = "LiteKite_Interview_Prep.zip"

# Create output folder
if (Test-Path $outputFolder) {
    Remove-Item $outputFolder -Recurse -Force
}
New-Item -ItemType Directory -Path $outputFolder | Out-Null

Write-Host "Converting markdown files to HTML..." -ForegroundColor Yellow
Write-Host ""

# HTML template with professional styling
$htmlTemplate = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{TITLE}</title>
    <style>
        @media print {
            body { margin: 0.5in; }
            .no-print { display: none; }
            pre { page-break-inside: avoid; }
            h1, h2, h3 { page-break-after: avoid; }
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 900px;
            margin: 0 auto;
            padding: 40px 20px;
            background: #fff;
        }
        
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            margin-top: 0;
            font-size: 2.5em;
        }
        
        h2 {
            color: #34495e;
            border-bottom: 2px solid #95a5a6;
            padding-bottom: 8px;
            margin-top: 40px;
            font-size: 1.8em;
        }
        
        h3 {
            color: #555;
            margin-top: 30px;
            font-size: 1.4em;
        }
        
        h4 {
            color: #666;
            margin-top: 20px;
            font-size: 1.2em;
        }
        
        code {
            background: #f5f5f5;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            font-size: 0.9em;
            color: #e74c3c;
        }
        
        pre {
            background: #2c3e50;
            color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
            font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
            font-size: 0.9em;
            line-height: 1.4;
        }
        
        pre code {
            background: none;
            color: #ecf0f1;
            padding: 0;
        }
        
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
            font-size: 0.95em;
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
        
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        
        blockquote {
            border-left: 4px solid #3498db;
            margin: 20px 0;
            padding: 10px 20px;
            background: #ecf0f1;
            font-style: italic;
        }
        
        ul, ol {
            margin: 15px 0;
            padding-left: 30px;
        }
        
        li {
            margin: 8px 0;
        }
        
        a {
            color: #3498db;
            text-decoration: none;
        }
        
        a:hover {
            text-decoration: underline;
        }
        
        .checkbox-item {
            margin: 8px 0;
        }
        
        .checkbox {
            margin-right: 8px;
        }
        
        .print-button {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #3498db;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            z-index: 1000;
        }
        
        .print-button:hover {
            background: #2980b9;
        }
        
        .info-box {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 5px;
            padding: 15px;
            margin: 20px 0;
        }
        
        .success-box {
            background: #d4edda;
            border: 1px solid #28a745;
            border-radius: 5px;
            padding: 15px;
            margin: 20px 0;
        }
        
        .warning-box {
            background: #f8d7da;
            border: 1px solid #dc3545;
            border-radius: 5px;
            padding: 15px;
            margin: 20px 0;
        }
        
        hr {
            border: none;
            border-top: 2px solid #ddd;
            margin: 30px 0;
        }
        
        strong {
            color: #2c3e50;
        }
        
        em {
            color: #555;
        }
    </style>
</head>
<body>
    <button class="print-button no-print" onclick="window.print()">🖨️ Print to PDF</button>
    {CONTENT}
    
    <script>
        // Add print keyboard shortcut hint
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Press Ctrl+P (or Cmd+P on Mac) to print this page as PDF');
        });
    </script>
</body>
</html>
'@

function Convert-MarkdownToHTML {
    param($mdContent)
    
    # Escape HTML special characters in code blocks first
    $mdContent = $mdContent -replace '&', '&amp;'
    $mdContent = $mdContent -replace '<', '&lt;'
    $mdContent = $mdContent -replace '>', '&gt;'
    
    # Convert code blocks
    $mdContent = $mdContent -replace '(?ms)```(\w+)?\r?\n(.*?)\r?\n```', '<pre><code>$2</code></pre>'
    $mdContent = $mdContent -replace '```', ''
    
    # Convert inline code
    $mdContent = $mdContent -replace '`([^`]+)`', '<code>$1</code>'
    
    # Convert headers
    $mdContent = $mdContent -replace '(?m)^#### (.+)$', '<h4>$1</h4>'
    $mdContent = $mdContent -replace '(?m)^### (.+)$', '<h3>$1</h3>'
    $mdContent = $mdContent -replace '(?m)^## (.+)$', '<h2>$1</h2>'
    $mdContent = $mdContent -replace '(?m)^# (.+)$', '<h1>$1</h1>'
    
    # Convert bold and italic
    $mdContent = $mdContent -replace '\*\*\*(.+?)\*\*\*', '<strong><em>$1</em></strong>'
    $mdContent = $mdContent -replace '\*\*(.+?)\*\*', '<strong>$1</strong>'
    $mdContent = $mdContent -replace '\*(.+?)\*', '<em>$1</em>'
    
    # Convert links
    $mdContent = $mdContent -replace '\[([^\]]+)\]\(([^\)]+)\)', '<a href="$2">$1</a>'
    
    # Convert checkboxes
    $mdContent = $mdContent -replace '(?m)^- \[ \] (.+)$', '<div class="checkbox-item"><input type="checkbox" class="checkbox" disabled> $1</div>'
    $mdContent = $mdContent -replace '(?m)^- \[x\] (.+)$', '<div class="checkbox-item"><input type="checkbox" class="checkbox" checked disabled> $1</div>'
    $mdContent = $mdContent -replace '(?m)^- \[X\] (.+)$', '<div class="checkbox-item"><input type="checkbox" class="checkbox" checked disabled> $1</div>'
    
    # Convert unordered lists
    $mdContent = $mdContent -replace '(?m)^- (.+)$', '<li>$1</li>'
    $mdContent = $mdContent -replace '(?m)(<li>.*</li>\r?\n?)+', '<ul>$0</ul>'
    
    # Convert ordered lists
    $mdContent = $mdContent -replace '(?m)^\d+\. (.+)$', '<li>$1</li>'
    
    # Convert horizontal rules
    $mdContent = $mdContent -replace '(?m)^---$', '<hr>'
    $mdContent = $mdContent -replace '(?m)^___$', '<hr>'
    
    # Convert blockquotes
    $mdContent = $mdContent -replace '(?m)^> (.+)$', '<blockquote>$1</blockquote>'
    
    # Convert line breaks
    $mdContent = $mdContent -replace '\r?\n\r?\n', '</p><p>'
    $mdContent = "<p>$mdContent</p>"
    
    # Clean up empty paragraphs
    $mdContent = $mdContent -replace '<p></p>', ''
    $mdContent = $mdContent -replace '<p>\s*</p>', ''
    
    return $mdContent
}

$converted = 0
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Converting $file..." -ForegroundColor Yellow
        
        $content = Get-Content $file -Raw -Encoding UTF8
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $title = "LiteKite Interview Prep - " + ($baseName -replace '_', ' ' -replace '-', ' ')
        
        $htmlContent = Convert-MarkdownToHTML $content
        $html = $htmlTemplate -replace '{TITLE}', $title -replace '{CONTENT}', $htmlContent
        
        $htmlFile = Join-Path $outputFolder "$baseName.html"
        $html | Out-File -FilePath $htmlFile -Encoding UTF8
        
        Write-Host "  ✓ Created $baseName.html" -ForegroundColor Green
        $converted++
    }
    else {
        Write-Host "  ✗ File not found: $file" -ForegroundColor Red
    }
}

# Copy original MD files too
Write-Host ""
Write-Host "Copying original markdown files..." -ForegroundColor Yellow
foreach ($file in $files) {
    if (Test-Path $file) {
        Copy-Item $file -Destination $outputFolder
        Write-Host "  ✓ Copied $file" -ForegroundColor Green
    }
}

# Create a README in the package
$readmeContent = @"
# LiteKite Interview Preparation Package

## 📦 Package Contents

This package contains your complete interview preparation materials in two formats:

### HTML Files (Print-Friendly)
1. **START_HERE.html** - Your roadmap and 7-day prep plan
2. **INTERVIEW_PREP_GUIDE.html** - Complete technical reference
3. **PRACTICE_QUESTIONS.html** - 20+ Q&A with detailed answers
4. **QUICK_REFERENCE.html** - Cheat sheet for quick review
5. **PRACTICE_WORKSHEET.html** - Interactive practice exercises

### Original Markdown Files
All original .md files are also included for editing or viewing in your preferred markdown editor.

## 🖨️ How to Create PDFs

### Option 1: Print from Browser (Recommended)
1. Open any HTML file in your web browser (Chrome, Edge, Firefox)
2. Press **Ctrl+P** (or Cmd+P on Mac) OR click the blue "Print to PDF" button
3. Select **"Save as PDF"** as the destination
4. Click **Save**
5. Repeat for each file you want as PDF

### Option 2: Use Online Converter
1. Visit https://www.markdowntopdf.com or https://md2pdf.netlify.app
2. Upload the .md files
3. Download the generated PDFs

### Option 3: Install Pandoc (Advanced)
1. Install Pandoc: https://pandoc.org/installing.html
2. Run: ``pandoc FILENAME.md -o FILENAME.pdf``

## 📚 Recommended Study Order

1. **START_HERE.html** - Read this first for the study plan
2. **INTERVIEW_PREP_GUIDE.html** - Your main reference (read in sections)
3. **PRACTICE_QUESTIONS.html** - Practice answering out loud
4. **PRACTICE_WORKSHEET.html** - Write your own answers
5. **QUICK_REFERENCE.html** - Review the day before interview

## 💡 Quick Tips

- **Print settings:** Use landscape orientation for wide diagrams
- **For best results:** Use Chrome or Edge browser for printing to PDF
- **Save paper:** Print only the sections you need most
- **Digital study:** The HTML files work great on tablets and phones

## 🚀 Good Luck!

You've got comprehensive materials covering:
- ✅ System architecture
- ✅ Authentication & security
- ✅ Database design
- ✅ API endpoints
- ✅ 50+ interview questions
- ✅ Scaling strategies
- ✅ Practice exercises

Remember: Understanding beats memorization. You built this project - now go show them what you know!

---
Created: $(Get-Date -Format "MMMM dd, yyyy")
"@

$readmeContent | Out-File -FilePath (Join-Path $outputFolder "README.txt") -Encoding UTF8

# Create the zip file
Write-Host ""
Write-Host "Creating zip archive..." -ForegroundColor Yellow

if (Test-Path $zipFile) {
    Remove-Item $zipFile -Force
}

Compress-Archive -Path $outputFolder -DestinationPath $zipFile -Force

$zipSize = (Get-Item $zipFile).Length / 1KB

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " ✓ SUCCESS!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Package created: $zipFile" -ForegroundColor Cyan
Write-Host "   Size: $([math]::Round($zipSize, 2)) KB" -ForegroundColor White
Write-Host "   Files included: $($converted * 2 + 1) files (HTML + MD + README)" -ForegroundColor White
Write-Host ""
Write-Host "📖 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Extract the zip file" -ForegroundColor White
Write-Host "   2. Open any HTML file in your browser" -ForegroundColor White  
Write-Host "   3. Press Ctrl+P to save as PDF" -ForegroundColor White
Write-Host "   4. Or read directly in the browser!" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: The HTML files work on any device - phone, tablet, or computer!" -ForegroundColor Cyan
Write-Host ""

# Open the folder
Write-Host "Opening folder..." -ForegroundColor Yellow
explorer.exe /select,"$((Get-Location).Path)\$zipFile"

Write-Host ""
Write-Host "All done! Good luck with your interview! 🚀" -ForegroundColor Green
Write-Host ""
