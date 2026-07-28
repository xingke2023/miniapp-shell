#!/bin/bash
# 生成 API 结果网页，返回可访问网址
# 用法: ./gen-result.sh <title> <html_body>

RESULTS_DIR="/home/ubuntu/shejian-hk/backend/public/results"
SEQ_FILE="$RESULTS_DIR/.seq"
DOMAIN="s.xingke888.com"

# 读取并递增流水号
SEQ=$(cat "$SEQ_FILE")
SEQ=$((SEQ + 1))
echo $SEQ > "$SEQ_FILE"

# 文件名：R + 日期 + 4位流水号
DATE=$(date +%Y%m%d)
FILENAME="R${DATE}$(printf '%04d' $SEQ).html"
FILEPATH="$RESULTS_DIR/$FILENAME"
URL="http://$DOMAIN/results/$FILENAME"

TITLE="${1:-API 结果}"
BODY="${2:-}"
GENERATED_AT=$(date '+%Y-%m-%d %H:%M:%S')

cat > "$FILEPATH" << HTMLEOF
<!DOCTYPE html>
<html lang="zh-HK">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${TITLE} — 舌尖香港</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: -apple-system, BlinkMacSystemFont, "PingFang HK", sans-serif; background: #f5f5f5; color: #222; }
  header { background: #1a1a2e; color: #fff; padding: 20px 32px; display: flex; align-items: center; justify-content: space-between; }
  header h1 { font-size: 18px; font-weight: 600; }
  header .seq { font-size: 12px; color: #aaa; font-family: monospace; }
  .meta { padding: 10px 32px; background: #fff; border-bottom: 1px solid #eee; font-size: 12px; color: #888; }
  .container { padding: 24px 32px; }
  table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
  thead tr { background: #1a1a2e; color: #fff; }
  thead th { padding: 12px 16px; text-align: left; font-size: 13px; font-weight: 500; }
  tbody tr { border-bottom: 1px solid #f0f0f0; }
  tbody tr:last-child { border-bottom: none; }
  tbody tr:hover { background: #fafafa; }
  td { padding: 11px 16px; font-size: 14px; }
  .qty { font-weight: 600; color: #1a1a2e; }
  .low { color: #e94560; }
  .tag { display: inline-block; font-size: 11px; padding: 1px 6px; border-radius: 3px; background: #e8f5e9; color: #2e7d32; }
  .null { color: #bbb; font-size: 12px; }
</style>
</head>
<body>
<header>
  <h1>舌尖香港 · ${TITLE}</h1>
  <span class="seq">${FILENAME}</span>
</header>
<div class="meta">生成时间：${GENERATED_AT}</div>
<div class="container">
${BODY}
</div>
</body>
</html>
HTMLEOF

echo "$URL"
