const fs = require('fs');

// HTML5 Canvas를 시뮬레이션하는 간단한 방법
// 실제로는 base64 데이터를 직접 생성하겠습니다

// 간단한 PNG 헤더 (최소한의 금색 아이콘)
const createSimpleIcon = (size) => {
  // 간단한 SVG 기반 PNG 생성 대신
  // Base64로 인코딩된 간단한 금색 원 아이콘을 생성
  
  const svgContent = `<?xml version="1.0" encoding="UTF-8"?>
<svg width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${size}" height="${size}" fill="#F0E6D2"/>
  <circle cx="${size/2}" cy="${size/2}" r="${size*0.4}" fill="#DAA520"/>
  <circle cx="${size*0.6}" cy="${size*0.4}" r="${size*0.05}" fill="white"/>
  <path d="M ${size*0.3} ${size*0.3} Q ${size*0.5} ${size*0.2} ${size*0.7} ${size*0.4}" stroke="#B8860B" stroke-width="${size*0.02}" fill="none"/>
</svg>`;

  return svgContent;
};

// assets 폴더가 없으면 생성
if (!fs.existsSync('assets')) {
  fs.mkdirSync('assets');
}

// 1024x1024 SVG 아이콘 생성
const iconSvg = createSimpleIcon(1024);
fs.writeFileSync('assets/icon.svg', iconSvg);

console.log('SVG 아이콘 생성 완료: assets/icon.svg');
console.log('이제 flutter_launcher_icons를 실행할 수 있습니다.'); 