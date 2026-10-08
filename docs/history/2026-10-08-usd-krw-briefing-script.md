# 원달러 환율 음성 안내 스크립트 작성

- 작업일: 2026-10-08 (Asia/Seoul)
- 상태: 로컬 작성·정적 검증 완료 / 실제 호출·음성 확인 대기
- 운영 적용: 미적용
- 대상 환경: 환경 기록상 Core 2026.9.3 / Home Assistant OS. 현재 서버 상태는 조회하지 않음.
- 관련 파일: [원달러 환율 스크립트](../../config/scripts/usd-krw-briefing/README.md)
- 관련 기록: [날씨 음성 안내 스크립트](2026-10-08-weather-briefing-script.md)

## 목적과 근거

사용자가 날씨와 같은 호출형 스크립트로 원달러 환율 안내도 요청했다.
기존 아침·일요일 브리핑의 `sensor.yahoofinance_krw_x`를 확인해 재사용하고,
버스·날씨 스크립트와 같은 Gemini 원고 생성 → 거실 스피커 TTS 흐름으로 작성했다.

## 변경과 선택 이유

- `config/scripts/usd-krw-briefing/script.yaml`: 원달러 환율 전용 UI 단일 스크립트. 기존 센서·AI·TTS·스피커와 `Leda` 음성을 재사용한다.
- `config/scripts/usd-krw-briefing/README.md`: 적용 위치, 입력·출력, 재시도·검증 범위와 복구 방법을 기록한다.
- `config/README.md`, `docs/history/README.md`: 새 스크립트와 작업 기록을 연결한다.

트리거가 없는 `alias`·`sequence`·`mode` 구조이며 상위 include는 없다.
환율은 호출 시 센서의 저장값을 읽고, AI 생성만 최대 3회 시도한다. 강제 갱신·실시간 시세 조회를 추가하지 않았다.
조회된 달러당 원화 금액만 짧게 전달하고 갱신 시각, 등락과 전망을 지어내지 않도록 지시했다.
빈 AI 응답은 재시도하고 성공 시 TTS를 요청한 뒤 중단한다. TTS 오류는 AI 재시도에 포함하지 않는다.
기존 날씨 스크립트와 자동화는 변경하지 않았다.

## 검증

| 확인 항목 | 수행 방법 | 결과 |
| --- | --- | --- |
| YAML 문법·중복 키·구조 | Ruby Psych | 통과: 단일 스크립트 매핑, 중복 키 없음, 최대 3회 생성·응답 초기화·TTS 후 중단·실패 안내 확인 |
| 엔티티·변경 범위 | 기존 브리핑 및 날씨 스크립트와 비교 | 통과: 기존 엔티티 4개 재사용, 날씨 스크립트의 재시도·응답 검사·TTS 설정과 일치, 기존 자동화 diff 없음 |
| 문서 링크·공백 | Python 상대 링크·공백 검사, `git diff --check` | 통과: 링크 17개와 변경·추가 파일 5개 검사 |
| Home Assistant 구성 검사·Jinja 렌더링 | 실행 환경 미연결, 로컬 HA·Jinja2 미설치 | 미실행 |
| 실제 센서·AI·TTS·음성 호출 | 서버 및 장치 미접속 | 미실행 |

## 운영 반영과 복구

로컬 파일만 작성했다. 새 스크립트 등록, 음성 호출 연결이나 재생은 수행하지 않았다.
적용 시 UI에서 새 스크립트로 저장하고 기존 버스 스크립트의 질의 연결 방식에 맞춰 호출 대상을 연결한다.
되돌리려면 새 스크립트의 호출 연결을 해제하고 해당 스크립트만 삭제한다.

## 미확인 사항

- 센서의 실제 상태, 시세 기준 시각과 현재 가용성.
- AI가 숫자·반올림·누락 처리 지시를 따르는지와 실제 TTS 음성.
- Assist 노출 및 질의 라우팅 방식. 실제 스크립트 엔티티 ID는 저장 후 확인한다.

## 참고 자료

같은 세션에서 확인한 공식 문서와 Core 소스의 스크립트·AI·TTS 구조를 재사용했다.

- [Home Assistant Scripts](https://www.home-assistant.io/integrations/script/)
- [Core 2026.9.3 AI Task 구현](https://github.com/home-assistant/core/blob/2026.9.3/homeassistant/components/ai_task/__init__.py)
- [Home Assistant Scripts syntax](https://www.home-assistant.io/docs/scripts/)
- [Home Assistant TTS](https://www.home-assistant.io/integrations/tts/)

커스텀 TTS의 설치 버전·upstream은 미확인으로 사용자 제공 옵션을 유지했다.
