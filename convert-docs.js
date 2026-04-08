const fs = require('fs');
const path = require('path');
const { marked } = require('marked');

const BASE_DIR = __dirname;
const DOCS_DIR = '/workspace/LinguaFlow-Docs';

// ── Slug 生成 ────────────────────────────────────
function toSlug(text) {
  return text
    .replace(/<[^>]+>/g, '')   // 去掉内嵌HTML标签
    .replace(/[^\w\u4e00-\u9fff\s]/g, '')  // 只保留文字/数字/中文
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim()
    .replace(/^-|-$/g, '')
    .toLowerCase();
}

// ── 从原始 Markdown 提取标题列表 ──────────────────
function extractHeadings(md) {
  const headings = [];
  for (const line of md.split('\n')) {
    const m = line.match(/^(#{1,4})\s+(.+)$/);
    if (m) {
      const text = m[2].trim().replace(/\*\*/g, '').replace(/`/g, '');
      headings.push({ level: m[1].length, text, slug: toSlug(text) });
    }
  }
  return headings;
}

// ── 后处理：为 h1-h4 注入 id 属性 ───────────────
function injectHeadingIds(html) {
  return html.replace(/<(h[1-4])([^>]*)>([^<]*(?:<[^>]+>[^<]*)*)<\/\1>/g, function(match, tag, attrs, content) {
    var text = content.replace(/<[^>]+>/g, '');  // 提取纯文本
    if (!text.trim()) return match;
    var slug = toSlug(text);
    return '<' + tag + attrs + ' id="' + slug + '">' + content + '</' + tag + '>';
  });
}

// ── CSS ───────────────────────────────────────────
const CSS = `<style>
*{box-sizing:border-box}
body{font-family:-apple-system,BlinkMacSystemFont,'PingFang SC','Microsoft YaHei',sans-serif;font-size:16px;line-height:1.8;color:#1a1a2e;background:#f8f9fc;padding:24px 220px 80px 24px;max-width:100%}
.toc-sidebar{position:fixed;right:16px;top:80px;width:190px;background:white;border:1px solid #e2e8f0;border-radius:12px;padding:14px;max-height:calc(100vh-100px);overflow-y:auto;z-index:100;box-shadow:0 4px 16px rgba(0,0,0,0.08);font-size:12px;transition:opacity 0.3s}
.toc-sidebar-title{font-weight:700;font-size:12px;color:#1a1a2e;margin-bottom:10px;padding-bottom:8px;border-bottom:1px solid #e2e8f0}
.toc-item{display:block;padding:5px 6px;border-radius:6px;color:#64748b;font-size:12px;line-height:1.4;cursor:pointer;text-decoration:none;transition:all 0.15s}
.toc-item:hover{color:#4F46E5;background:#f5f3ff}
.toc-item.active{color:#4F46E5;font-weight:700;background:#f5f3ff;border-left:2px solid #4F46E5;padding-left:4px}
.toc-h3{padding-left:14px;font-size:11px}
.toc-h4{padding-left:26px;font-size:11px;color:#94a3b8}
.back-btn{display:inline-flex;align-items:center;gap:6px;background:#4F46E5;color:white;padding:8px 16px;border-radius:8px;font-size:14px;font-weight:600;margin-bottom:20px;text-decoration:none}
.back-btn:hover{background:#3730A3;text-decoration:none}
.document-meta{font-size:13px;color:#888;margin-bottom:20px;padding:8px 14px;background:#f8f9fc;border-radius:8px;border:1px solid #e2e8f0}
a{color:#4F46E5;text-decoration:none}a:hover{text-decoration:underline}
h1{font-size:1.8em;font-weight:800;color:#0f0f1a;border-bottom:3px solid #4F46E5;padding-bottom:10px;margin:28px 0 16px;line-height:1.3}
h2{font-size:1.35em;font-weight:700;color:#1a1a2e;margin:24px 0 10px;border-left:4px solid #4F46E5;padding-left:10px}
h3{font-size:1.1em;font-weight:700;color:#333;margin:20px 0 8px}
h4{font-size:1em;font-weight:700;color:#555;margin:16px 0 6px}
p{margin:12px 0;color:#333}
table{border-collapse:collapse;width:100%;margin:16px 0;font-size:14px;overflow-x:auto;display:block}
th{background:#4F46E5;color:white;padding:10px 14px;text-align:left;font-weight:600;position:sticky;top:0;z-index:1}
td{padding:9px 14px;border:1px solid #e2e8f0}
tr:nth-child(even) td{background:#f1f5f9}tr:nth-child(odd) td{background:#fff}
ul,ol{padding-left:24px;margin:10px 0}li{margin:5px 0;color:#333}
blockquote{border-left:4px solid #4F46E5;margin:14px 0;padding:10px 16px;background:#f0f0ff;border-radius:0 8px 8px 0;color:#555;font-style:italic}
code{background:#f1f5f9;border:1px solid #e2e8f0;border-radius:4px;padding:2px 6px;font-size:0.88em;font-family:'Fira Code','Consolas',monospace;color:#7C3AED}
pre{background:#1e1e2e;border-radius:10px;padding:16px 20px;overflow-x:auto;margin:14px 0}
pre code{background:none;border:none;color:#a6e3a1;font-size:0.9em;padding:0}
hr{border:none;border-top:2px solid #e2e8f0;margin:24px 0}img{max-width:100%;height:auto;border-radius:8px;margin:8px 0}
@media(max-width:900px){.toc-sidebar{display:none}body{padding:24px 16px 80px}}
</style>`;

// ── 悬浮侧边栏 JS ─────────────────────────────────
const SCRIPT = `<script>
(function(){
  var sidebar = document.getElementById('toc-sidebar');
  if(!sidebar) return;

  // 点击目录项 → 平滑滚动到对应章节
  sidebar.addEventListener('click',function(e){
    var link = e.target.closest('.toc-item');
    if(!link) return;
    var id = link.getAttribute('data-id');
    var el = document.getElementById(id);
    if(el) el.scrollIntoView({behavior:'smooth',block:'start'});
  });

  // IntersectionObserver → 滚动时高亮当前章节
  var tocLinks = sidebar.querySelectorAll('.toc-item');
  var headingEls = [];
  document.querySelectorAll('h1[id],h2[id],h3[id],h4[id]').forEach(function(el){
    headingEls.push(el);
  });

  var observer = new IntersectionObserver(function(entries){
    entries.forEach(function(entry){
      if(entry.isIntersecting){
        tocLinks.forEach(function(a){
          a.classList.toggle('active', a.getAttribute('data-id')===entry.target.id);
        });
      }
    });
  }, {rootMargin:'-20% 0px -70% 0px'});

  headingEls.forEach(function(el){ observer.observe(el); });

  // 滚动 > 120px 时显示，否则隐藏
  window.addEventListener('scroll',function(){
    sidebar.style.opacity = window.scrollY<120?'0':'1';
  },{passive:true});
  sidebar.style.opacity='0';
})();
</script>`;

// ── 主处理 ───────────────────────────────────────
function processFile(fullPath, rel) {
  const raw = fs.readFileSync(fullPath, 'utf-8');
  let title = rel.replace(/\.md$/, '');
  let content = raw;

  // 去掉 YAML frontmatter
  if (raw.startsWith('---')) {
    const end = raw.indexOf('---', 3);
    if (end !== -1) {
      content = raw.slice(end + 3).trim();
      const fm = raw.slice(3, end);
      const m = fm.match(/[#]?\s*(?:title|title):\s*(.+)/i);
      if (m) title = m[1].trim();
    }
  }

  // 1. 从原始 Markdown 提取标题列表（用于侧边栏）
  const headings = extractHeadings(content);

  // 2. marked 解析 Markdown → HTML
  let bodyHtml = marked.parse(content);

  // 3. 后处理：为 h1-h4 注入 id 属性（解决 marked 默认不带 id 的问题）
  bodyHtml = injectHeadingIds(bodyHtml);

  // 4. 构建悬浮侧边栏
  const tocItems = headings.map(h => {
    const cls = h.level === 2 ? '' : h.level === 2 ? '' : h.level === 3 ? ' toc-h3' : h.level === 4 ? ' toc-h4' : '';
    return '        <a class="toc-item' + cls + '" data-id="' + h.slug + '">' + h.text + '</a>';
  }).join('\n');
  const sidebar = '<div class="toc-sidebar" id="toc-sidebar">\n  <div class="toc-sidebar-title">&#128203; 目录</div>\n' + tocItems + '\n      </div>';

  const category = rel.includes('/') ? rel.slice(0, rel.lastIndexOf('/')) : '文档';
  const html = '<!DOCTYPE html>\n<html lang="zh-CN>\n<head>\n  <meta charset="UTF-8">\n  <meta name="viewport" content="width=device-width, initial-scale=1.0">\n  <title>' + title + ' — LinguaFlow 文档中心</title>\n  ' + CSS + '\n</head>\n<body>\n  <a class="back-btn" href="javascript:void(0)" onclick="history.back()">&#8592; 文档管理中心</a>\n  <div class="document-meta">&#128193; ' + category + '</div>\n  ' + bodyHtml + '\n  ' + sidebar + '\n  ' + SCRIPT + '\n</body>\n</html>';

  fs.writeFileSync(fullPath.replace(/\.md$/, '.html'), html);
  return { md: rel, headings: headings.length };
}

function processDir(dir, relPath) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    const rel = relPath ? relPath + '/' + entry.name : entry.name;
    if (entry.isDirectory()) {
      results.push(...processDir(fullPath, rel));
    } else if (entry.name.endsWith('.md')) {
      try {
        const r = processFile(fullPath, rel);
        console.log('  OK ' + r.md + ' (' + r.headings + ' headings)');
        results.push(r);
      } catch(e) {
        console.error('  ERR ' + entry.name + ': ' + e.message);
      }
    }
  }
  return results;
}

console.log('Converting Markdown -> HTML (floating TOC v3)...\n');
const results = processDir(DOCS_DIR, '');
console.log('\nDone! ' + results.length + ' files converted.');
