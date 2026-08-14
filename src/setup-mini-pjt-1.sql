CREATE DATABASE IF NOT EXISTS toilet_db  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;


- [ ] 테이블 스키마를 **직접 설계**한다 (`df.to_sql(...)` 사용 금지)
  - 컬럼별 적절한 타입 지정 (`INTEGER`, `REAL`, `TEXT`, `DATE`)
  - PK 지정, 조인에 쓰이는 컬럼에 인덱스 생성
  - CSV 원본 컬럼명을 그대로 쓰지 말고 스네이크케이스 등으로 정규화
- [ ] 전처리 후 적재한다 (결측 처리 기준, 타입 변환, 중복 제거를 코드로 남길 것)
- [ ] 적재 검증: 원본 행 수 vs 적재 행 수 비교, NULL 비율 확인, 샘플 조회


USE toilet_db;

DROP TABLE IF EXISTS tb_toilet, tb_population;


-- Join 테이블: 인구 (이미 시군구 단위로 집계된 데이터)
CREATE TABLE tb_population (
    sigungu      VARCHAR(30) PRIMARY KEY,
    sido         VARCHAR(20) NOT NULL,
    male_pop     INT NOT NULL DEFAULT 0,
    female_pop   INT NOT NULL DEFAULT 0,
    total_pop    INT NOT NULL DEFAULT 0,
    elderly_pop  INT NOT NULL DEFAULT 0,
    child_pop    INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 -- Base 테이블: 화장실 (원자 단위 = 화장실 하나하나)
CREATE TABLE tb_toilet (
    toilet_id         VARCHAR(30) PRIMARY KEY,
    sigungu           VARCHAR(30) NOT NULL,
    male_seats        INT NOT NULL DEFAULT 0,
    female_seats      INT NOT NULL DEFAULT 0,
    disabled_seats    INT NOT NULL DEFAULT 0,
    child_seats       INT NOT NULL DEFAULT 0,
    total_seats       INT NOT NULL DEFAULT 0,
    has_diaper_table  TINYINT(1) NOT NULL,
    INDEX idx_toilet_sigungu (sigungu),
    CONSTRAINT fk_toilet_sigungu
        FOREIGN KEY (sigungu) REFERENCES population(sigungu)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_toilet_sigungu ON tb_toilet(sigungu);

