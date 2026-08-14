CREATE DATABASE IF NOT EXISTS toilet_db  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


- [ ] 테이블 스키마를 **직접 설계**한다 (`df.to_sql(...)` 사용 금지)
  - 컬럼별 적절한 타입 지정 (`INTEGER`, `REAL`, `TEXT`, `DATE`)
  - PK 지정, 조인에 쓰이는 컬럼에 인덱스 생성
  - CSV 원본 컬럼명을 그대로 쓰지 말고 스네이크케이스 등으로 정규화
- [ ] 전처리 후 적재한다 (결측 처리 기준, 타입 변환, 중복 제거를 코드로 남길 것)
- [ ] 적재 검증: 원본 행 수 vs 적재 행 수 비교, NULL 비율 확인, 샘플 조회


USE toilet_db;

DROP TABLE IF EXISTS tb_toilet, tb_population;

 -- Base 테이블: 화장실 (원자 단위 = 화장실 하나하나)
CREATE TABLE toilet (
    toilet_id      VARCHAR(50) PRIMARY KEY,   -- 화장실 고유번호
    sigungu        VARCHAR(30) NOT NULL,      -- 주소(구까지), FK 역할
    male_seats     INTEGER,                   -- 남 총변기수
    female_seats   INTEGER                    -- 여 총변기수
);
--has_diaper_table INTEGER
-- Join 테이블: 인구 (이미 시군구 단위로 집계된 데이터)
CREATE TABLE population (
    sigungu        VARCHAR(30) PRIMARY KEY,   -- 주소(구까지)
    male_pop       INTEGER,
    female_pop     INTEGER
);


CREATE INDEX idx_store_region   ON store(region_code);
CREATE INDEX idx_store_category ON store(category_l, category_m);

