# Python Shell Tool - Usage Guide

You have access to a Python 3.8 execution environment with powerful capabilities.

## PRE-INSTALLED LIBRARIES (Instant Execution)

These libraries are always available with zero wait time:

### Media Processing
- **ffmpeg-python**: Video/audio editing, format conversion, composition
- **Pillow (PIL)**: Image processing, manipulation, creation, filters

### Documents
- **pypdf**: PDF reading, merging, splitting, manipulation
- **python-pptx**: PowerPoint presentation creation and editing
- **python-docx**: Word document creation and editing
- **openpyxl**: Excel file operations

### Data Processing
- **pandas**: Data analysis, CSV/Excel processing
- **numpy**: Numerical computations, arrays, math operations

### Utilities
- **requests**: HTTP requests, file downloads

## DYNAMIC PACKAGE INSTALLATION

You can install ANY Python package from PyPI on-demand:

```python
# Install packages as needed
pip_install('qrcode')
pip_install('matplotlib')

# Then use them
import qrcode
qr = qrcode.QRCode()
qr.add_data('https://example.com')
qr.make_image().save('qr.png')
```

**Note**: Package installation takes 30-60 seconds, but packages are cached permanently for future use.

**Best Practice**: Use web_search to find the best library for specialized tasks.

## USAGE EXAMPLES

### 1. Video Compilation (Music Video Example)

```python
import ffmpeg

# Create slideshow from images (3 seconds each)
img1 = ffmpeg.input('image1.png', loop=1, t=3)
img2 = ffmpeg.input('infographic.png', loop=1, t=4)

# Concatenate images into video
video = ffmpeg.concat(img1, img2, v=1, a=0)

# Load and mix audio tracks
music = ffmpeg.input('music.mp3').audio.filter('volume', 0.6)
voice = ffmpeg.input('voiceover.mp3').audio.filter('volume', 1.0)
mixed_audio = ffmpeg.filter([music, voice], 'amix', inputs=2, duration='first')

# Combine video and audio
output = ffmpeg.output(
    video, 
    mixed_audio,
    'final_video.mp4',
    vcodec='libx264',
    acodec='aac'
)

# Execute
output.run(overwrite_output=True)
print("Video created: final_video.mp4")
```

### 2. Image Collage Creation

```python
from PIL import Image

# Load images
images = [
    Image.open('phone1.png'),
    Image.open('phone2.png'),
    Image.open('phone3.png'),
    Image.open('phone4.png')
]

# Create 2x2 grid
width, height = images[0].size
collage = Image.new('RGB', (width * 2, height * 2))

# Paste images
collage.paste(images[0], (0, 0))
collage.paste(images[1], (width, 0))
collage.paste(images[2], (0, height))
collage.paste(images[3], (width, height))

# Save
collage.save('collage.png')
print("Collage created: collage.png")
```

### 3. PDF Merger

```python
from pypdf import PdfMerger

merger = PdfMerger()

# Add PDFs
merger.append('report1.pdf')
merger.append('report2.pdf')
merger.append('appendix.pdf')

# Write merged PDF
merger.write('complete_report.pdf')
merger.close()

print("PDFs merged: complete_report.pdf")
```

### 4. Audio Mixing

```python
import ffmpeg

# Mix multiple audio tracks with volume control
track1 = ffmpeg.input('music.mp3').filter('volume', 0.5)
track2 = ffmpeg.input('voice.mp3').filter('volume', 1.0)
track3 = ffmpeg.input('effects.mp3').filter('volume', 0.3)

# Mix all tracks
mixed = ffmpeg.filter([track1, track2, track3], 'amix', inputs=3, duration='longest')

# Output
ffmpeg.output(mixed, 'final_audio.mp3').run(overwrite_output=True)
print("Audio mixed: final_audio.mp3")
```

### 5. QR Code Generation (with dynamic install)

```python
pip_install('qrcode')
import qrcode

qr = qrcode.QRCode(version=1, box_size=10, border=5)
qr.add_data('https://twent.app')
qr.make(fit=True)

img = qr.make_image(fill_color='black', back_color='white')
img.save('qr_code.png')

print("QR code generated: qr_code.png")
```

### 6. Data Visualization (with dynamic install)

```python
pip_install('matplotlib')
import pandas as pd
import matplotlib.pyplot as plt

# Read data
df = pd.read_csv('sales_data.csv')

# Create bar chart
df.plot(kind='bar', x='month', y='sales')
plt.title('Monthly Sales')
plt.ylabel('Sales ($)')
plt.tight_layout()
plt.savefig('sales_chart.png')
plt.close()

print("Chart created: sales_chart.png")
```

### 7. Image Watermarking

```python
from PIL import Image, ImageDraw, ImageFont

# Load image
img = Image.open('product.png')
draw = ImageDraw.Draw(img)

# Add watermark
try:
    font = ImageFont.truetype('/system/fonts/Roboto-Regular.ttf', 40)
except:
    font = ImageFont.load_default()

draw.text((10, 10), 'Twent AI', fill='white', font=font)

# Save
img.save('product_watermarked.png')
print("Watermark added: product_watermarked.png")
```

### 8. OCR Text Extraction (with dynamic install)

```python
pip_install('pytesseract')
from PIL import Image
import pytesseract

# Load and process image
image = Image.open('document.png')
text = pytesseract.image_to_string(image)

print('Extracted text:')
print(text)
```

## WORKING WITH FILES

- Working directory: `/cache` (or specified in parameters)
- All generated media files from other tools are in `/cache/generated_*`
- You can read, write, and manipulate any files in the cache directory

```python
import os

# List files in cache
files = os.listdir('/cache/generated_images')
print(f"Found {len(files)} images")

# Read file
with open('/cache/generated_images/image1.png', 'rb') as f:
    data = f.read()
```

## PDF GENERATION WITH REPORTLAB

For PDF generation, use the ReportLab library:

```python
pip_install('reportlab')
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import inch

# Create document
doc = SimpleDocTemplate('report.pdf', pagesize=letter)
story = []
styles = getSampleStyleSheet()

# Add content
story.append(Paragraph('Report Title', styles['Title']))
story.append(Spacer(1, 0.5*inch))
story.append(Paragraph('This is the content of the report.', styles['BodyText']))

# Build PDF
doc.build(story)
print('PDF created: report.pdf')
```

### Common PDF Tasks

**Invoice Generation**:
```python
from reportlab.lib import colors
from reportlab.platypus import Table, TableStyle

data = [
    ['Item', 'Quantity', 'Price'],
    ['Product A', '2', '$100'],
    ['Product B', '1', '$50']
]

table = Table(data)
table.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.grey),
    ('GRID', (0, 0), (-1, -1), 1, colors.black)
]))

story.append(table)
```

**PDF with Image**:
```python
from reportlab.platypus import Image

img = Image('photo.png', width=4*inch, height=3*inch)
story.append(img)
```

**Multi-page Document**:
```python
from reportlab.platypus import PageBreak

story.append(Paragraph('Page 1 content', styles['BodyText']))
story.append(PageBreak())
story.append(Paragraph('Page 2 content', styles['BodyText']))
```

**Documentation**: https://docs.reportlab.com

## POWERPOINT GENERATION WITH PYTHON-PPTX

PowerPoint presentations are **PRE-INSTALLED** and ready to use immediately!

### Basic Presentation

```python
from pptx import Presentation
from pptx.util import Inches, Pt

# Create presentation
prs = Presentation()

# Title slide
title_slide = prs.slides.add_slide(prs.slide_layouts[0])
title_slide.shapes.title.text = "Presentation Title"
title_slide.placeholders[1].text = "Subtitle"

# Content slide with bullets
content_slide = prs.slides.add_slide(prs.slide_layouts[1])
content_slide.shapes.title.text = "Key Points"
body = content_slide.placeholders[1]
tf = body.text_frame
tf.text = "First point"
p = tf.add_paragraph()
p.text = "Second point"
p.level = 0

# Save
prs.save('presentation.pptx')
print('PowerPoint created: presentation.pptx')
```

### Professional Business Presentation

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor

prs = Presentation()

# Slide 1: Title Slide
title_slide = prs.slides.add_slide(prs.slide_layouts[0])
title = title_slide.shapes.title
subtitle = title_slide.placeholders[1]
title.text = "Q4 2024 Business Review"
subtitle.text = "Prepared by AI Assistant"

# Slide 2: Agenda
agenda_slide = prs.slides.add_slide(prs.slide_layouts[1])
agenda_slide.shapes.title.text = "Agenda"
tf = agenda_slide.placeholders[1].text_frame
tf.text = "Executive Summary"
tf.add_paragraph().text = "Financial Performance"
tf.add_paragraph().text = "Key Achievements"
tf.add_paragraph().text = "Next Steps"

# Slide 3: Bullet Points with Formatting
content_slide = prs.slides.add_slide(prs.slide_layouts[1])
content_slide.shapes.title.text = "Key Achievements"
tf = content_slide.placeholders[1].text_frame
tf.clear()

# Add formatted bullets
p = tf.paragraphs[0]
p.text = "Revenue Growth"
p.level = 0
p.font.size = Pt(24)
p.font.bold = True

p = tf.add_paragraph()
p.text = "Increased 25% year-over-year"
p.level = 1
p.font.size = Pt(20)

p = tf.add_paragraph()
p.text = "Customer Acquisition"
p.level = 0
p.font.size = Pt(24)
p.font.bold = True

p = tf.add_paragraph()
p.text = "1,000+ new customers added"
p.level = 1
p.font.size = Pt(20)

# Slide 4: Image Slide
image_slide = prs.slides.add_slide(prs.slide_layouts[6])  # Blank layout
image_slide.shapes.add_picture('chart.png', Inches(1), Inches(1.5), width=Inches(8))

# Add title to image slide
txBox = image_slide.shapes.add_textbox(Inches(1), Inches(0.5), Inches(8), Inches(0.5))
tf = txBox.text_frame
tf.text = "Performance Chart"
tf.paragraphs[0].font.size = Pt(28)
tf.paragraphs[0].font.bold = True

# Save
prs.save('business_review.pptx')
print('Business presentation created: business_review.pptx')
```

### Presentation with Tables

```python
from pptx import Presentation
from pptx.util import Inches
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor

prs = Presentation()

# Create slide with table
slide = prs.slides.add_slide(prs.slide_layouts[5])  # Blank layout
slide.shapes.title.text = "Quarterly Results"

# Define table dimensions
rows, cols = 4, 3
left, top = Inches(2), Inches(2)
width, height = Inches(6), Inches(2)

# Add table
table = slide.shapes.add_table(rows, cols, left, top, width, height).table

# Set column widths
table.columns[0].width = Inches(2.0)
table.columns[1].width = Inches(2.0)
table.columns[2].width = Inches(2.0)

# Write table headers
headers = ['Quarter', 'Revenue', 'Growth']
for col_idx, header in enumerate(headers):
    cell = table.cell(0, col_idx)
    cell.text = header
    cell.text_frame.paragraphs[0].font.bold = True
    cell.fill.solid()
    cell.fill.fore_color.rgb = RGBColor(0, 112, 192)
    cell.text_frame.paragraphs[0].font.color.rgb = RGBColor(255, 255, 255)

# Write table data
data = [
    ['Q1 2024', '$1.2M', '+15%'],
    ['Q2 2024', '$1.5M', '+25%'],
    ['Q3 2024', '$1.8M', '+20%']
]

for row_idx, row_data in enumerate(data, start=1):
    for col_idx, value in enumerate(row_data):
        table.cell(row_idx, col_idx).text = value

prs.save('quarterly_results.pptx')
print('Presentation with table created: quarterly_results.pptx')
```

### Presentation with Charts

```python
from pptx import Presentation
from pptx.chart.data import CategoryChartData
from pptx.enum.chart import XL_CHART_TYPE
from pptx.util import Inches

prs = Presentation()

# Add slide with chart
slide = prs.slides.add_slide(prs.slide_layouts[5])
slide.shapes.title.text = "Sales by Region"

# Define chart data
chart_data = CategoryChartData()
chart_data.categories = ['North', 'South', 'East', 'West']
chart_data.add_series('Q1', (19.2, 21.4, 16.7, 25.3))
chart_data.add_series('Q2', (22.3, 28.6, 15.2, 21.9))
chart_data.add_series('Q3', (20.4, 26.3, 14.2, 23.5))

# Add chart to slide
x, y, cx, cy = Inches(2), Inches(2), Inches(6), Inches(4)
chart = slide.shapes.add_chart(
    XL_CHART_TYPE.COLUMN_CLUSTERED, x, y, cx, cy, chart_data
).chart

# Customize chart
chart.has_legend = True
chart.legend.position = XL_LEGEND_POSITION.BOTTOM
chart.legend.include_in_layout = False

prs.save('sales_chart.pptx')
print('Presentation with chart created: sales_chart.pptx')
```

### Multi-Slide Report Generation

```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN

def create_report(title, sections):
    """Generate multi-slide report from structured data"""
    prs = Presentation()
    
    # Title slide
    title_slide = prs.slides.add_slide(prs.slide_layouts[0])
    title_slide.shapes.title.text = title
    title_slide.placeholders[1].text = "Generated by AI Assistant"
    
    # Create slide for each section
    for section in sections:
        slide = prs.slides.add_slide(prs.slide_layouts[1])
        slide.shapes.title.text = section['title']
        
        tf = slide.placeholders[1].text_frame
        tf.clear()
        
        for idx, point in enumerate(section['points']):
            if idx == 0:
                p = tf.paragraphs[0]
            else:
                p = tf.add_paragraph()
            p.text = point
            p.level = 0
            p.font.size = Pt(20)
    
    return prs

# Usage example
report_data = [
    {
        'title': 'Executive Summary',
        'points': [
            'Strong quarter with 25% revenue growth',
            'Customer satisfaction at all-time high',
            'Launched 3 new product features'
        ]
    },
    {
        'title': 'Key Metrics',
        'points': [
            'Monthly Active Users: 50,000',
            'Revenue: $1.8M',
            'Customer Retention: 95%'
        ]
    },
    {
        'title': 'Next Steps',
        'points': [
            'Expand to new markets',
            'Hire additional team members',
            'Launch mobile app'
        ]
    }
]

prs = create_report('Q4 2024 Report', report_data)
prs.save('automated_report.pptx')
print('Multi-slide report created: automated_report.pptx')
```

### Advanced: Images + Text Layout

```python
from pptx import Presentation
from pptx.util import Inches, Pt

prs = Presentation()

# Blank slide for custom layout
slide = prs.slides.add_slide(prs.slide_layouts[6])

# Add title
title_box = slide.shapes.add_textbox(Inches(0.5), Inches(0.5), Inches(9), Inches(0.8))
title_frame = title_box.text_frame
title_frame.text = "Product Showcase"
title_frame.paragraphs[0].font.size = Pt(40)
title_frame.paragraphs[0].font.bold = True

# Add image
img = slide.shapes.add_picture('product.png', Inches(1), Inches(1.5), width=Inches(4))

# Add description text next to image
text_box = slide.shapes.add_textbox(Inches(5.5), Inches(1.5), Inches(4), Inches(4))
text_frame = text_box.text_frame
text_frame.text = "Key Features:"
text_frame.paragraphs[0].font.size = Pt(24)
text_frame.paragraphs[0].font.bold = True

features = [
    "Advanced AI capabilities",
    "Real-time processing",
    "Cloud integration",
    "Mobile-first design"
]

for feature in features:
    p = text_frame.add_paragraph()
    p.text = f"• {feature}"
    p.font.size = Pt(18)
    p.space_before = Pt(12)

prs.save('product_showcase.pptx')
print('Product showcase created: product_showcase.pptx')
```

### Common PowerPoint Tasks

**Slide Layouts**:
- `0`: Title Slide
- `1`: Title and Content
- `2`: Section Header
- `3`: Two Content
- `4`: Comparison
- `5`: Title Only
- `6`: Blank
- `7`: Content with Caption
- `8`: Picture with Caption

**Text Formatting**:
```python
from pptx.util import Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

p.font.size = Pt(24)
p.font.bold = True
p.font.italic = True
p.font.color.rgb = RGBColor(255, 0, 0)
p.alignment = PP_ALIGN.CENTER
```

**Adding Shapes**:
```python
from pptx.enum.shapes import MSO_SHAPE

left, top = Inches(1), Inches(1)
width, height = Inches(2), Inches(1)
shape = slide.shapes.add_shape(
    MSO_SHAPE.RECTANGLE, left, top, width, height
)
shape.text = "Shape Text"
```

**Capabilities**:
- Multiple slide layouts (title, content, blank, etc.)
- Text formatting (fonts, sizes, colors, alignment)
- Bullet points and numbering with indentation levels
- Images and shapes (rectangles, circles, etc.)
- Tables with custom styling
- Charts (bar, line, pie, column, etc.)
- Custom layouts and positioning
- Hyperlinks and notes

**Documentation**: https://python-pptx.readthedocs.io

## INFOGRAPHIC GENERATION

### IMPORTANT: Always Ask User First!

When user requests an infographic, ALWAYS ask them to choose:

```
Use ask_user tool:
{
  "question": "How would you like to generate the infographic?",
  "options": [
    "Use Nano Banana Pro (AI-generated, professional quality, perfect images)",
    "Use Python matplotlib (basic charts and graphs)"
  ],
  "context": "Nano Banana Pro creates stunning AI-generated infographics that look professional and polished. Python matplotlib creates basic data visualizations. Nano Banana Pro is recommended for best results.",
  "default_option": 0
}
```

### Option 1: Nano Banana Pro (RECOMMENDED)

For professional, AI-generated infographics:

```
Use generate_image tool with Nano Banana Pro model:
{
  "prompt": "Professional infographic about smartphone awards 2025. Show Nothing Phone 3 as winner with key specs: 200MP camera, Glyph Interface 2.0, 5000mAh battery. Include comparison bars with iPhone 16 and Samsung S24. Modern design, clean layout, vibrant colors, data visualization.",
  "model": "nano-banana-pro",
  "size": "1024x1792"
}
```

**Nano Banana Pro Features**:
- World's best at creating non-AI-slop images
- Professional, polished infographics from text prompts
- Perfect for: marketing materials, professional presentations, social media
- Available through all AI providers

### Option 2: Python matplotlib (Basic Charts)

For basic data visualizations, use matplotlib with Pillow:

```python
pip_install('matplotlib')
import matplotlib.pyplot as plt
from PIL import Image, ImageDraw, ImageFont

# Create data visualization
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Bar chart
phones = ['Nothing Phone 3', 'iPhone 16', 'Samsung S24']
ratings = [95, 88, 85]
ax1.bar(phones, ratings, color=['#FF0000', '#999999', '#1428A0'])
ax1.set_title('Smartphone Ratings 2025', fontsize=16, fontweight='bold')
ax1.set_ylabel('Rating Score')

# Pie chart
market_share = [35, 30, 25, 10]
labels = ['iPhone', 'Samsung', 'Nothing', 'Others']
ax2.pie(market_share, labels=labels, autopct='%1.1f%%', startangle=90)
ax2.set_title('Market Share', fontsize=16, fontweight='bold')

plt.tight_layout()
plt.savefig('infographic.png', dpi=300, bbox_inches='tight', facecolor='white')
plt.close()

print('Infographic created: infographic.png')
```

### Advanced: Custom Infographic with Composition

```python
pip_install('matplotlib')
import matplotlib.pyplot as plt
from PIL import Image, ImageDraw, ImageFont

# Create canvas
canvas = Image.new('RGB', (1200, 1600), color='#F0F0F0')
draw = ImageDraw.Draw(canvas)

# Add title
font = ImageFont.truetype('/system/fonts/Roboto-Bold.ttf', 60)
draw.text((50, 50), 'Smartphone Awards 2025', fill='#333333', font=font)

# Generate chart
plt.figure(figsize=(8, 4))
plt.bar(['Camera', 'Design', 'Performance'], [95, 92, 90], color='#FF0000')
plt.title('Nothing Phone 3 - Category Scores')
plt.savefig('chart.png', transparent=True, bbox_inches='tight', dpi=150)
plt.close()

# Insert chart
chart = Image.open('chart.png')
chart = chart.resize((1000, 500))
canvas.paste(chart, (100, 200), chart if chart.mode == 'RGBA' else None)

# Add statistics
font_stat = ImageFont.truetype('/system/fonts/Roboto-Regular.ttf', 40)
draw.text((50, 800), '★ Winner: Nothing Phone 3', fill='#FF0000', font=font_stat)
draw.text((50, 900), '• 200MP Camera System', fill='#333333', font=font_stat)
draw.text((50, 1000), '• Glyph Interface 2.0', fill='#333333', font=font_stat)

# Save
canvas.save('final_infographic.png')
print('Custom infographic created: final_infographic.png')
```

**Capabilities**:
- Data charts (bar, pie, line, scatter, etc.)
- Custom layouts and compositions
- Text overlays with custom fonts
- Icon and image integration
- Color theming
- High-resolution export (300+ DPI)

**Documentation**: https://matplotlib.org/stable/contents.html

## BEST PRACTICES

1. **Use pre-installed libraries when possible** (faster, no wait)
2. **Search for best library before installing** (use web_search tool)
3. **Install only what you need** (smaller installations are faster)
4. **Print status messages** (helps user understand progress)
5. **Handle errors gracefully** (use try-except blocks)

## WORKFLOW PATTERN

For complex tasks:

1. Check if pre-installed library can do it → Use immediately
2. If specialized library needed → Use web_search to find best option
3. Install package with pip_install()
4. Execute task
5. Print success message with output file path

## LIMITATIONS

- Execution timeout: 60 seconds default (max 300)
- Package installation: 30-60 seconds per package (but cached permanently)
- No network access in code (use requests library for HTTP)
- File access limited to app directories

## REMEMBER

- Pre-installed = instant execution
- Dynamic install = 30-60s wait but only once
- Packages remain available forever after installation
- Always print helpful status messages for the user
