-- Supabase reports 테이블 생성 스크립트
-- 이 스크립트를 Supabase Dashboard의 SQL Editor에서 실행하세요

CREATE TABLE IF NOT EXISTS reports (
    id BIGSERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security) 정책 설정
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 신고를 생성할 수 있도록 허용
CREATE POLICY "Anyone can insert reports" ON reports
    FOR INSERT WITH CHECK (true);

-- 관리자만 신고를 조회할 수 있도록 설정 (선택사항)
-- CREATE POLICY "Only admins can view reports" ON reports
--     FOR SELECT USING (auth.role() = 'admin');

-- 인덱스 생성 (성능 향상)
CREATE INDEX IF NOT EXISTS idx_reports_type ON reports(type);
CREATE INDEX IF NOT EXISTS idx_reports_timestamp ON reports(timestamp);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at);

-- 테이블에 대한 설명 추가
COMMENT ON TABLE reports IS '사용자 신고 데이터를 저장하는 테이블';
COMMENT ON COLUMN reports.type IS '신고 유형 (예: 기도문 신고)';
COMMENT ON COLUMN reports.content IS '신고된 콘텐츠 내용';
COMMENT ON COLUMN reports.timestamp IS '신고 시점의 타임스탬프';
COMMENT ON COLUMN reports.created_at IS '레코드 생성 시간';
COMMENT ON COLUMN reports.updated_at IS '레코드 수정 시간'; 