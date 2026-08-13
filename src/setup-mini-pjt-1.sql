CREATE DATABASE IF NOT EXISTS toilet_db  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


- [ ] 테이블 스키마를 **직접 설계**한다 (`df.to_sql(...)` 사용 금지)
  - 컬럼별 적절한 타입 지정 (`INTEGER`, `REAL`, `TEXT`, `DATE`)
  - PK 지정, 조인에 쓰이는 컬럼에 인덱스 생성
  - CSV 원본 컬럼명을 그대로 쓰지 말고 스네이크케이스 등으로 정규화
- [ ] 전처리 후 적재한다 (결측 처리 기준, 타입 변환, 중복 제거를 코드로 남길 것)
- [ ] 적재 검증: 원본 행 수 vs 적재 행 수 비교, NULL 비율 확인, 샘플 조회


USE toilet_db;

DROP TABLE IF EXISTS tb_toilet, tb_population;

 
-- 사실 테이블 (Base 데이터)
CREATE TABLE toilet (
    store_id      TEXT PRIMARY KEY,
    name          TEXT,
    category_l    TEXT,
    category_m    TEXT,
    region_code   TEXT REFERENCES region(region_code),
    lon           REAL,
    lat           REAL
);
CREATE INDEX idx_store_region   ON store(region_code);
CREATE INDEX idx_store_category ON store(category_l, category_m);


-- 연결 데이터 (인구 등)
CREATE TABLE population (
    region_code   TEXT REFERENCES region(region_code),
    base_ym       TEXT,               -- 기준연월 'YYYY-MM'
    total_pop     INTEGER,
    household     INTEGER,
    PRIMARY KEY (region_code, base_ym)