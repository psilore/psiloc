#!/bin/bash
echo "# 🛠️ Infrastructure & Tooling Audit" > env_summary.md
echo "Generated on: $(date)" >> env_summary.md

echo -e "\n## ☁️ Cloud & On-Prem CLIs" >> env_summary.md
for cmd in az govc terraform ansible; do
    if command -v $cmd &> /dev/null; then
        echo "* **$cmd**: $($cmd --version | head -n 1)" >> env_summary.md
    else
        echo "* **$cmd**: Not Found" >> env_summary.md
    fi
done

echo -e "\n## ☸️ Kubernetes & GitOps" >> env_summary.md
for cmd in kubectl helm argocd flux; do
    if command -v $cmd &> /dev/null; then
        echo "* **$cmd**: $($cmd version --client 2>/dev/null | head -n 1)" >> env_summary.md
    else
        echo "* **$cmd**: Not Found" >> env_summary.md
    fi
done

echo -e "\n## 🚀 Antigravity & MCP Status" >> env_summary.md
if [ -f ~/.gemini/antigravity/mcp_config.json ]; then
    echo "* **MCP Config**: Found" >> env_summary.md
    echo "\`\`\`json" >> env_summary.md
    cat ~/.gemini/antigravity/mcp_config.json >> env_summary.md
    echo -e "\n\`\`\`" >> env_summary.md
else
    echo "* **MCP Config**: Not found in default path." >> env_summary.md
fi

echo -e "\n## 🏗️ Project Structure" >> env_summary.md
echo "* **Skills found**: $(ls .agent/skills 2>/dev/null | tr '\n' ', ' || echo 'None')" >> env_summary.md

echo "Audit complete! File saved to env_summary.md"
