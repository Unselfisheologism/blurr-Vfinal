# Unified Shell Guide (Python + JavaScript)

The agent has access to a **multi-language shell** that supports both **Python** and **JavaScript**.

---

## Language Selection

The shell **AUTO-DETECTS** the language from your code. You can also specify explicitly:

```json
{
  "tool": "unified_shell",
  "params": {
    "code": "console.log('Hello from JS')",
    "language": "javascript"
  }
}
```

**Detection patterns**:
- JavaScript: `const`, `let`, `var`, `function`, `=>`, `console.log`, `d3.`
- Python: `import`, `from`, `def`, `print()`, `pip_install()`

---

## Python Support

All existing Python functionality from `python_shell` is available in `unified_shell`.

### Pre-installed Python Libraries
- **ffmpeg-python** - Video/audio processing
- **Pillow** - Image manipulation
- **pypdf** - PDF reading/merging
- **python-pptx** - PowerPoint generation
- **python-docx** - Word documents
- **openpyxl** - Excel files
- **pandas** - Data analysis
- **numpy** - Numerical computing
- **requests** - HTTP requests

### Python Examples

See `python_shell_guide.md` for comprehensive Python examples including:
- PDF generation
- PowerPoint creation
- Image processing
- Video editing
- Data processing

---

## JavaScript Support (NEW!)

### Pre-installed JavaScript Libraries
- **D3.js** (v7) - Data visualization and SVG generation
- **console** object - console.log(), console.error(), console.warn()
- **fs** object - File system access (fs.writeFile, fs.readFile)

### JavaScript Runtime
- **Engine**: Mozilla Rhino
- **Version**: ES6 support
- **Environment**: Node.js-like (console, fs, but no DOM)

---

## JavaScript Examples

### Basic JavaScript

```javascript
// Variables and data structures
const message = "Hello from JavaScript!";
console.log(message);

const numbers = [1, 2, 3, 4, 5];
const sum = numbers.reduce((a, b) => a + b, 0);
const average = sum / numbers.length;

console.log("Sum:", sum);
console.log("Average:", average);
```

### Array Operations

```javascript
const data = [
  { name: "Alice", age: 30, score: 85 },
  { name: "Bob", age: 25, score: 92 },
  { name: "Charlie", age: 35, score: 78 }
];

// Filter
const highScorers = data.filter(person => person.score >= 80);
console.log("High scorers:", JSON.stringify(highScorers));

// Map
const names = data.map(person => person.name);
console.log("Names:", names.join(", "));

// Sort
const sortedByAge = data.sort((a, b) => a.age - b.age);
console.log("Sorted by age:", JSON.stringify(sortedByAge));
```

### JSON Processing

```javascript
const jsonString = '{"users": [{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]}';
const parsed = JSON.parse(jsonString);

console.log("Total users:", parsed.users.length);
parsed.users.forEach(user => {
  console.log(`User ${user.id}: ${user.name}`);
});

// Create new JSON
const output = {
  timestamp: Date.now(),
  processed: parsed.users.length,
  names: parsed.users.map(u => u.name)
};

console.log("Output:", JSON.stringify(output, null, 2));
```

### File System Operations

```javascript
// Write text file
const content = "Hello, World!\nThis is a text file.";
fs.writeFile("output.txt", content);
console.log("✅ File written: output.txt");

// Write JSON file
const data = { name: "Test", value: 42, items: [1, 2, 3] };
fs.writeFile("data.json", JSON.stringify(data, null, 2));
console.log("✅ JSON file written: data.json");

// Read file
const fileContent = fs.readFile("output.txt");
console.log("File content:", fileContent);

// Write CSV
const csvData = [
  ["Name", "Age", "Score"],
  ["Alice", 30, 85],
  ["Bob", 25, 92],
  ["Charlie", 35, 78]
];
const csv = csvData.map(row => row.join(",")).join("\n");
fs.writeFile("data.csv", csv);
console.log("✅ CSV file written: data.csv");
```

---

## D3.js Data Visualization

D3.js is **pre-installed** for creating data visualizations!

### Bar Chart (SVG)

```javascript
const data = [30, 86, 168, 281, 303, 365];
const barWidth = 60;
const spacing = 10;
const maxHeight = 300;

// Generate SVG rectangles
const bars = data.map((value, index) => {
  const x = index * (barWidth + spacing);
  const height = value;
  const y = maxHeight - height;
  return `<rect x="${x}" y="${y}" width="${barWidth}" height="${height}" fill="steelblue"/>`;
}).join('\n  ');

// Complete SVG
const svg = `<svg width="500" height="300" xmlns="http://www.w3.org/2000/svg">
  ${bars}
</svg>`;

fs.writeFile("bar_chart.svg", svg);
console.log("✅ Bar chart created: bar_chart.svg");
```

### Line Chart (SVG)

```javascript
const data = [30, 86, 168, 281, 303, 365];
const width = 500;
const height = 300;
const padding = 40;

// Calculate points
const xStep = (width - 2 * padding) / (data.length - 1);
const maxValue = Math.max(...data);

const points = data.map((value, index) => {
  const x = padding + index * xStep;
  const y = height - padding - (value / maxValue) * (height - 2 * padding);
  return `${x},${y}`;
}).join(' ');

// Create SVG line chart
const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <!-- Grid lines -->
  <line x1="${padding}" y1="${padding}" x2="${padding}" y2="${height - padding}" stroke="#ccc" stroke-width="2"/>
  <line x1="${padding}" y1="${height - padding}" x2="${width - padding}" y2="${height - padding}" stroke="#ccc" stroke-width="2"/>
  
  <!-- Data line -->
  <polyline points="${points}" fill="none" stroke="steelblue" stroke-width="3"/>
  
  <!-- Data points -->
  ${data.map((value, index) => {
    const x = padding + index * xStep;
    const y = height - padding - (value / maxValue) * (height - 2 * padding);
    return `<circle cx="${x}" cy="${y}" r="5" fill="steelblue"/>`;
  }).join('\n  ')}
</svg>`;

fs.writeFile("line_chart.svg", svg);
console.log("✅ Line chart created: line_chart.svg");
```

### Pie Chart (SVG)

```javascript
const data = [
  { label: "Category A", value: 30 },
  { label: "Category B", value: 45 },
  { label: "Category C", value: 25 }
];

const width = 400;
const height = 400;
const radius = 150;
const centerX = width / 2;
const centerY = height / 2;

// Calculate angles
const total = data.reduce((sum, d) => sum + d.value, 0);
let currentAngle = 0;

const slices = data.map((item, index) => {
  const sliceAngle = (item.value / total) * 2 * Math.PI;
  const startAngle = currentAngle;
  const endAngle = currentAngle + sliceAngle;
  
  // Calculate arc path
  const x1 = centerX + radius * Math.cos(startAngle);
  const y1 = centerY + radius * Math.sin(startAngle);
  const x2 = centerX + radius * Math.cos(endAngle);
  const y2 = centerY + radius * Math.sin(endAngle);
  
  const largeArc = sliceAngle > Math.PI ? 1 : 0;
  const path = `M ${centerX},${centerY} L ${x1},${y1} A ${radius},${radius} 0 ${largeArc},1 ${x2},${y2} Z`;
  
  const colors = ["#4285F4", "#EA4335", "#FBBC04"];
  const color = colors[index % colors.length];
  
  currentAngle = endAngle;
  
  return `<path d="${path}" fill="${color}" stroke="white" stroke-width="2"/>`;
}).join('\n  ');

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  ${slices}
</svg>`;

fs.writeFile("pie_chart.svg", svg);
console.log("✅ Pie chart created: pie_chart.svg");
```

### Multi-Series Bar Chart

```javascript
const data = [
  { month: "Jan", sales: 120, expenses: 80 },
  { month: "Feb", sales: 150, expenses: 90 },
  { month: "Mar", sales: 180, expenses: 100 },
  { month: "Apr", sales: 200, expenses: 110 }
];

const width = 600;
const height = 400;
const padding = 60;
const barWidth = 30;
const groupSpacing = 40;

const maxValue = Math.max(...data.map(d => Math.max(d.sales, d.expenses)));

const bars = data.map((item, index) => {
  const x = padding + index * (barWidth * 2 + groupSpacing);
  
  // Sales bar
  const salesHeight = (item.sales / maxValue) * (height - 2 * padding);
  const salesY = height - padding - salesHeight;
  const salesBar = `<rect x="${x}" y="${salesY}" width="${barWidth}" height="${salesHeight}" fill="#4285F4"/>`;
  
  // Expenses bar
  const expensesHeight = (item.expenses / maxValue) * (height - 2 * padding);
  const expensesY = height - padding - expensesHeight;
  const expensesBar = `<rect x="${x + barWidth + 5}" y="${expensesY}" width="${barWidth}" height="${expensesHeight}" fill="#EA4335"/>`;
  
  // Label
  const labelX = x + barWidth;
  const labelY = height - padding + 20;
  const label = `<text x="${labelX}" y="${labelY}" font-size="14" text-anchor="middle">${item.month}</text>`;
  
  return salesBar + '\n  ' + expensesBar + '\n  ' + label;
}).join('\n  ');

// Legend
const legend = `
  <rect x="450" y="30" width="20" height="20" fill="#4285F4"/>
  <text x="475" y="45" font-size="14">Sales</text>
  <rect x="450" y="60" width="20" height="20" fill="#EA4335"/>
  <text x="475" y="75" font-size="14">Expenses</text>
`;

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <!-- Axes -->
  <line x1="${padding}" y1="${height - padding}" x2="${width - padding}" y2="${height - padding}" stroke="#333" stroke-width="2"/>
  <line x1="${padding}" y1="${padding}" x2="${padding}" y2="${height - padding}" stroke="#333" stroke-width="2"/>
  
  <!-- Bars -->
  ${bars}
  
  <!-- Legend -->
  ${legend}
  
  <!-- Title -->
  <text x="${width / 2}" y="30" font-size="20" font-weight="bold" text-anchor="middle">Sales vs Expenses</text>
</svg>`;

fs.writeFile("multi_series_chart.svg", svg);
console.log("✅ Multi-series chart created: multi_series_chart.svg");
```

### Infographic Template

```javascript
const stats = {
  title: "Q4 2024 Performance",
  revenue: "$1.8M",
  growth: "+25%",
  customers: "1,200",
  satisfaction: "4.8/5"
};

const width = 800;
const height = 600;

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <!-- Background -->
  <rect width="${width}" height="${height}" fill="#f5f5f5"/>
  
  <!-- Title -->
  <text x="${width / 2}" y="60" font-size="36" font-weight="bold" text-anchor="middle" fill="#333">
    ${stats.title}
  </text>
  
  <!-- Revenue Card -->
  <rect x="50" y="120" width="300" height="150" fill="white" stroke="#4285F4" stroke-width="3" rx="10"/>
  <text x="200" y="170" font-size="24" font-weight="bold" text-anchor="middle" fill="#4285F4">Revenue</text>
  <text x="200" y="220" font-size="42" font-weight="bold" text-anchor="middle" fill="#333">${stats.revenue}</text>
  
  <!-- Growth Card -->
  <rect x="450" y="120" width="300" height="150" fill="white" stroke="#34A853" stroke-width="3" rx="10"/>
  <text x="600" y="170" font-size="24" font-weight="bold" text-anchor="middle" fill="#34A853">Growth</text>
  <text x="600" y="220" font-size="42" font-weight="bold" text-anchor="middle" fill="#333">${stats.growth}</text>
  
  <!-- Customers Card -->
  <rect x="50" y="320" width="300" height="150" fill="white" stroke="#FBBC04" stroke-width="3" rx="10"/>
  <text x="200" y="370" font-size="24" font-weight="bold" text-anchor="middle" fill="#FBBC04">Customers</text>
  <text x="200" y="420" font-size="42" font-weight="bold" text-anchor="middle" fill="#333">${stats.customers}</text>
  
  <!-- Satisfaction Card -->
  <rect x="450" y="320" width="300" height="150" fill="white" stroke="#EA4335" stroke-width="3" rx="10"/>
  <text x="600" y="370" font-size="24" font-weight="bold" text-anchor="middle" fill="#EA4335">Satisfaction</text>
  <text x="600" y="420" font-size="42" font-weight="bold" text-anchor="middle" fill="#333">${stats.satisfaction}</text>
</svg>`;

fs.writeFile("infographic.svg", svg);
console.log("✅ Infographic created: infographic.svg");
```

---

## When to Use Which Language

### Use Python For:
- **Document generation**: PDFs, PowerPoint, Word, Excel
- **Data processing**: pandas DataFrames, numpy arrays
- **Machine learning**: scikit-learn, tensorflow (via pip_install)
- **Image/video editing**: Pillow, ffmpeg
- **Scientific computing**: Complex numerical operations
- **Web scraping**: requests, BeautifulSoup (via pip_install)

### Use JavaScript For:
- **Data visualization**: D3.js charts, graphs, infographics
- **SVG generation**: Scalable vector graphics
- **JSON processing**: Parsing, transforming, querying JSON data
- **Quick prototypes**: Fast iteration on data transformations
- **Web-based formats**: HTML, SVG, JSON output

---

## Combining Python and JavaScript

You can use both languages in a workflow!

**Example: Fetch data with Python, visualize with JavaScript**

```python
# Step 1: Python - Fetch and process data
import requests
import json

response = requests.get("https://api.example.com/data")
data = response.json()

# Process and save
processed = [{"month": item["month"], "value": item["sales"]} for item in data["results"]]

with open("data.json", "w") as f:
    json.dump(processed, f)

print("✅ Data processed and saved")
```

Then:

```javascript
// Step 2: JavaScript - Create visualization
const rawData = fs.readFile("data.json");
const data = JSON.parse(rawData);

// Create bar chart from data
const bars = data.map((item, index) => {
  const x = index * 70;
  const height = item.value * 2;
  const y = 300 - height;
  return `<rect x="${x}" y="${y}" width="60" height="${height}" fill="steelblue"/>
          <text x="${x + 30}" y="${320}" text-anchor="middle">${item.month}</text>`;
}).join('\n  ');

const svg = `<svg width="500" height="350">
  ${bars}
</svg>`;

fs.writeFile("chart.svg", svg);
console.log("✅ Chart created");
```

---

## Performance Notes

- **Python**: Slower startup (~1-2 seconds for imports), but fast execution
- **JavaScript**: Fast startup (<100ms), good for quick data transformations
- **File I/O**: Both languages can read/write files in cache directory
- **Memory**: Both share the same Android process memory

---

## Error Handling

Both languages support try-catch error handling:

**Python**:
```python
try:
    result = risky_operation()
    print(f"Success: {result}")
except Exception as e:
    print(f"Error: {e}")
```

**JavaScript**:
```javascript
try {
  const result = riskyOperation();
  console.log("Success:", result);
} catch (error) {
  console.error("Error:", error.message);
}
```

---

## Best Practices

1. **Use auto-detection**: Let the tool detect the language automatically
2. **Clear output**: Always use `print()` or `console.log()` to show results
3. **File paths**: Use simple filenames (files go to cache directory)
4. **Error messages**: Include context in error messages
5. **SVG files**: Can be converted to PNG by the agent if needed

---

---

## Infographic-Specific Examples (Story 4.12)

These examples are specifically designed for the `generate_infographic` tool when user selects D3.js.

### Timeline Infographic

```javascript
const events = [
  { year: 2020, event: "Company Founded" },
  { year: 2021, event: "First Product Launch" },
  { year: 2022, event: "Series A Funding" },
  { year: 2023, event: "1M Users Milestone" },
  { year: 2024, event: "International Expansion" }
];

const width = 1000;
const height = 400;
const padding = 60;
const timelineY = height / 2;

// Create timeline line
const timeline = `<line x1="${padding}" y1="${timelineY}" x2="${width - padding}" y2="${timelineY}" stroke="#4285F4" stroke-width="4"/>`;

// Create event markers
const markers = events.map((event, index) => {
  const x = padding + (index * (width - 2 * padding) / (events.length - 1));
  const isTop = index % 2 === 0;
  const textY = isTop ? timelineY - 40 : timelineY + 60;
  
  return `
    <circle cx="${x}" cy="${timelineY}" r="10" fill="#4285F4"/>
    <text x="${x}" y="${textY}" text-anchor="middle" font-size="14" font-weight="bold">${event.year}</text>
    <text x="${x}" y="${textY + 20}" text-anchor="middle" font-size="12">${event.event}</text>
  `;
}).join('');

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${width}" height="${height}" fill="white"/>
  <text x="${width / 2}" y="40" font-size="28" font-weight="bold" text-anchor="middle">Company Timeline</text>
  ${timeline}
  ${markers}
</svg>`;

fs.writeFile('timeline_infographic.svg', svg);
console.log('✅ Timeline infographic created');
```

### Comparison Infographic

```javascript
const comparison = {
  product1: { name: "Basic Plan", price: "$9", features: ["1 User", "10 GB Storage", "Email Support"] },
  product2: { name: "Pro Plan", price: "$29", features: ["5 Users", "100 GB Storage", "Priority Support", "Advanced Analytics"] }
};

const width = 800;
const height = 600;

const card1 = `
  <rect x="50" y="100" width="300" height="400" fill="#f0f0f0" stroke="#4285F4" stroke-width="3" rx="10"/>
  <text x="200" y="140" font-size="24" font-weight="bold" text-anchor="middle">${comparison.product1.name}</text>
  <text x="200" y="180" font-size="36" font-weight="bold" text-anchor="middle" fill="#4285F4">${comparison.product1.price}</text>
  ${comparison.product1.features.map((f, i) => 
    `<text x="200" y="${220 + i * 40}" font-size="16" text-anchor="middle">✓ ${f}</text>`
  ).join('\n  ')}
`;

const card2 = `
  <rect x="450" y="100" width="300" height="400" fill="#4285F4" stroke="#4285F4" stroke-width="3" rx="10"/>
  <text x="600" y="140" font-size="24" font-weight="bold" text-anchor="middle" fill="white">${comparison.product2.name}</text>
  <text x="600" y="180" font-size="36" font-weight="bold" text-anchor="middle" fill="white">${comparison.product2.price}</text>
  ${comparison.product2.features.map((f, i) => 
    `<text x="600" y="${220 + i * 40}" font-size="16" text-anchor="middle" fill="white">✓ ${f}</text>`
  ).join('\n  ')}
  <text x="600" y="80" font-size="14" font-weight="bold" text-anchor="middle" fill="#FBBC04">⭐ POPULAR</text>
`;

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${width}" height="${height}" fill="white"/>
  <text x="${width / 2}" y="50" font-size="32" font-weight="bold" text-anchor="middle">Choose Your Plan</text>
  ${card1}
  ${card2}
</svg>`;

fs.writeFile('comparison_infographic.svg', svg);
console.log('✅ Comparison infographic created');
```

### Statistical Dashboard

```javascript
const stats = {
  revenue: { value: "$1.8M", change: "+25%", trend: "up" },
  users: { value: "12,450", change: "+18%", trend: "up" },
  satisfaction: { value: "4.8/5", change: "+0.3", trend: "up" },
  support: { value: "2.1h", change: "-15%", trend: "down" }
};

const width = 1000;
const height = 600;

let currentX = 50;
const cards = Object.entries(stats).map(([key, data]) => {
  const cardWidth = 220;
  const cardHeight = 200;
  const x = currentX;
  currentX += cardWidth + 20;
  
  const color = data.trend === "up" ? "#34A853" : "#EA4335";
  const arrow = data.trend === "up" ? "↑" : "↓";
  
  return `
    <rect x="${x}" y="150" width="${cardWidth}" height="${cardHeight}" fill="white" stroke="#e0e0e0" stroke-width="2" rx="10"/>
    <text x="${x + cardWidth / 2}" y="190" font-size="16" text-anchor="middle" fill="#666">${key.toUpperCase()}</text>
    <text x="${x + cardWidth / 2}" y="240" font-size="36" font-weight="bold" text-anchor="middle">${data.value}</text>
    <text x="${x + cardWidth / 2}" y="280" font-size="20" font-weight="bold" text-anchor="middle" fill="${color}">
      ${arrow} ${data.change}
    </text>
  `;
}).join('');

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${width}" height="${height}" fill="#f5f5f5"/>
  <text x="${width / 2}" y="80" font-size="36" font-weight="bold" text-anchor="middle">Q4 Performance Dashboard</text>
  ${cards}
</svg>`;

fs.writeFile('dashboard_infographic.svg', svg);
console.log('✅ Dashboard infographic created');
```

### Process Flow Infographic

```javascript
const steps = [
  { title: "Research", description: "Market analysis", icon: "🔍" },
  { title: "Design", description: "UI/UX creation", icon: "🎨" },
  { title: "Develop", description: "Build product", icon: "💻" },
  { title: "Test", description: "Quality assurance", icon: "✓" },
  { title: "Launch", description: "Go to market", icon: "🚀" }
];

const width = 1200;
const height = 400;
const stepWidth = 180;
const stepHeight = 120;
const spacing = 40;

const totalWidth = steps.length * stepWidth + (steps.length - 1) * spacing;
const startX = (width - totalWidth) / 2;

const processSteps = steps.map((step, index) => {
  const x = startX + index * (stepWidth + spacing);
  const y = 150;
  
  const arrow = index < steps.length - 1 
    ? `<path d="M ${x + stepWidth + 10} ${y + stepHeight / 2} L ${x + stepWidth + 30} ${y + stepHeight / 2}" stroke="#4285F4" stroke-width="3" marker-end="url(#arrowhead)"/>` 
    : '';
  
  return `
    <rect x="${x}" y="${y}" width="${stepWidth}" height="${stepHeight}" fill="#4285F4" stroke="#4285F4" stroke-width="2" rx="10"/>
    <text x="${x + stepWidth / 2}" y="${y + 40}" font-size="32" text-anchor="middle">${step.icon}</text>
    <text x="${x + stepWidth / 2}" y="${y + 70}" font-size="18" font-weight="bold" text-anchor="middle" fill="white">${step.title}</text>
    <text x="${x + stepWidth / 2}" y="${y + 95}" font-size="14" text-anchor="middle" fill="white">${step.description}</text>
    ${arrow}
  `;
}).join('');

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="10" refX="5" refY="5" orient="auto">
      <polygon points="0 0, 10 5, 0 10" fill="#4285F4"/>
    </marker>
  </defs>
  <rect width="${width}" height="${height}" fill="white"/>
  <text x="${width / 2}" y="80" font-size="32" font-weight="bold" text-anchor="middle">Product Development Process</text>
  ${processSteps}
</svg>`;

fs.writeFile('process_flow_infographic.svg', svg);
console.log('✅ Process flow infographic created');
```

### Percentage/Progress Infographic

```javascript
const metrics = [
  { label: "Project Completion", percentage: 85, color: "#34A853" },
  { label: "Budget Utilization", percentage: 72, color: "#4285F4" },
  { label: "Team Satisfaction", percentage: 95, color: "#FBBC04" },
  { label: "Client Approval", percentage: 88, color: "#EA4335" }
];

const width = 800;
const height = 600;
const barHeight = 60;
const barSpacing = 80;
const startY = 150;

const bars = metrics.map((metric, index) => {
  const y = startY + index * barSpacing;
  const barWidth = (metric.percentage / 100) * 600;
  
  return `
    <text x="50" y="${y}" font-size="16" font-weight="bold">${metric.label}</text>
    <rect x="50" y="${y + 10}" width="600" height="${barHeight}" fill="#e0e0e0" rx="5"/>
    <rect x="50" y="${y + 10}" width="${barWidth}" height="${barHeight}" fill="${metric.color}" rx="5"/>
    <text x="${50 + barWidth + 10}" y="${y + barHeight / 2 + 15}" font-size="20" font-weight="bold" fill="${metric.color}">${metric.percentage}%</text>
  `;
}).join('');

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${width}" height="${height}" fill="white"/>
  <text x="${width / 2}" y="80" font-size="32" font-weight="bold" text-anchor="middle">Project Metrics</text>
  ${bars}
</svg>`;

fs.writeFile('progress_infographic.svg', svg);
console.log('✅ Progress infographic created');
```

### Hierarchical Data Infographic

```javascript
const hierarchy = {
  name: "CEO",
  children: [
    { name: "CTO", team: "15 engineers" },
    { name: "CMO", team: "8 marketers" },
    { name: "CFO", team: "5 accountants" }
  ]
};

const width = 800;
const height = 500;
const nodeWidth = 150;
const nodeHeight = 80;

const ceoX = width / 2 - nodeWidth / 2;
const ceoY = 100;

const ceoNode = `
  <rect x="${ceoX}" y="${ceoY}" width="${nodeWidth}" height="${nodeHeight}" fill="#4285F4" stroke="#4285F4" stroke-width="2" rx="10"/>
  <text x="${ceoX + nodeWidth / 2}" y="${ceoY + nodeHeight / 2 + 5}" font-size="20" font-weight="bold" text-anchor="middle" fill="white">${hierarchy.name}</text>
`;

const childNodes = hierarchy.children.map((child, index) => {
  const totalWidth = hierarchy.children.length * nodeWidth + (hierarchy.children.length - 1) * 50;
  const startX = (width - totalWidth) / 2;
  const x = startX + index * (nodeWidth + 50);
  const y = 300;
  
  // Connection line
  const line = `<line x1="${width / 2}" y1="${ceoY + nodeHeight}" x2="${x + nodeWidth / 2}" y2="${y}" stroke="#ccc" stroke-width="2"/>`;
  
  return `
    ${line}
    <rect x="${x}" y="${y}" width="${nodeWidth}" height="${nodeHeight}" fill="white" stroke="#4285F4" stroke-width="2" rx="10"/>
    <text x="${x + nodeWidth / 2}" y="${y + 35}" font-size="18" font-weight="bold" text-anchor="middle">${child.name}</text>
    <text x="${x + nodeWidth / 2}" y="${y + 58}" font-size="12" text-anchor="middle" fill="#666">${child.team}</text>
  `;
}).join('');

const svg = `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${width}" height="${height}" fill="#f9f9f9"/>
  <text x="${width / 2}" y="50" font-size="28" font-weight="bold" text-anchor="middle">Organization Structure</text>
  ${ceoNode}
  ${childNodes}
</svg>`;

fs.writeFile('hierarchy_infographic.svg', svg);
console.log('✅ Hierarchy infographic created');
```

---

## Summary

The `unified_shell` tool gives you the best of both worlds:
- **Python** for heavy lifting, document generation, and data processing
- **JavaScript** for quick visualizations, SVG generation, and JSON work

Choose the right language for the task, or use both in sequence for complex workflows!

**For Story 4.12 Infographics**:
- Use the `generate_infographic` tool which automatically asks user: Nano Banana Pro or D3.js
- If user selects D3.js, the tool uses these JavaScript examples via `unified_shell`
- All examples create SVG files that can be viewed, shared, or converted to PNG
