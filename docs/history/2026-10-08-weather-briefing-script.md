# 날씨 전용 음성 안내 스크립트 작성

- 작업일: 2026-10-08 (Asia/Seoul)
- 상태: 로컬 작성·정적 검증 완료 / 실제 호출·음성 확인 대기
- 운영 적용: 미적용
- 대상 환경: 환경 기록상 Core 2026.9.3 / Home Assistant OS. 현재 서버 상태는 조회하지 않음.
- 관련 파일: [날씨 스크립트](../../config/scripts/weather-briefing/README.md)
- 관련 기록: [기존 아침 브리핑](2026-10-04-morning-briefing.md)

## 목적과 근거

사용자는 처음에 날씨 전용 자동화를 요청한 뒤, 정기 자동화가 아니라 호출형 스크립트라고 정정했다.
이어 `잠실가는 버스 알려줘` 스크립트를 제공하며 질의 → 센서 정보 → LLM 답변 → TTS 흐름을 설명했다.
이에 시간·요일 트리거 없이 같은 방식으로 날씨만 안내하는 단일 스크립트를 작성했다.

## 변경과 선택 이유

- `config/scripts/weather-briefing/script.yaml`: 기존 날씨 센서 15개와 AI·TTS·스피커 엔티티, `Leda` 음성을 재사용한다.
- `config/scripts/weather-briefing/README.md`: UI 적용 위치, 의존 엔티티, 음성 호출 연결과 검증 범위를 기록한다.
- `config/README.md`, `docs/history/README.md`: 새 스크립트와 작업 기록을 연결한다.

UI 단일 스크립트 편집기에 사용할 `alias`·`sequence`·`mode` 매핑이다. 저장소 상위 include 연결은 없다.
기존 자동화와 제공된 버스 스크립트는 수정하지 않았다.
자연스러운 반말 원고와 누락 데이터 처리 규칙을 사용하고 일정·시장 정보는 넣지 않았다.
AI 응답은 매회 초기화하고 비어 있지 않은 문자열인지 검사한다. 최대 3회 생성에 실패하면 고정 안내를 요청한다.
유효한 응답은 TTS 요청 후 `stop`으로 종료하므로 별도 `success` 변수가 필요하지 않다.

## 검증

| 확인 항목 | 수행 방법 | 결과 |
| --- | --- | --- |
| YAML 문법·중복 키·구조 | Ruby Psych | 통과: 단일 스크립트 매핑, 중복 키 없음, 최대 3회 반복·응답 초기화·TTS 후 중단 구조 확인 |
| 기존 엔티티 재사용·범위 | 기존 YAML 비교, 트리거·캘린더·주식 입력 부재 확인 | 통과: 날씨 센서 15개와 AI·TTS·스피커 3개 재사용, 기존 자동화 diff 없음 |
| 문서 링크·공백 | Python 상대 링크·공백 검사, `git diff --check` | 통과: 링크 13개, 변경·추가 파일 5개 공백 검사 |
| Home Assistant 구성 검사 | 실행 환경 미연결, 로컬 HA 패키지 없음 | 미실행 |
| Jinja 렌더링 | 로컬 Python에 Jinja2 없음 | 미실행 |
| 실제 센서·AI·TTS·음성 호출 | 서버 및 장치 미접속 | 미실행 |

## 운영 반영과 복구

로컬 파일만 작성했다. 스크립트 저장·실행, Assist 연결, TTS 재생은 수행하지 않았다.
적용 시 UI에서 새 스크립트로 저장하고 기존 버스 질의와 같은 경로에서 호출할 수 있도록 연결한다.
실제 등록되는 스크립트 엔티티 ID는 저장 후 확인한다.
복구는 새 스크립트의 호출 연결을 해제하고 새 스크립트만 삭제하는 방식이다.

## 미확인 사항

- 날씨 센서의 현재 가용성, 단위와 갱신 시각.
- AI 출력의 자연스러움과 누락 처리 준수, 실제 TTS 재생.
- 버스 스크립트를 질의로 호출하는 Assist 구성과 새 스크립트 노출 방식.
- `mode: single`은 스크립트 실행 중에만 적용된다. 음성 재생 완료를 기다리는 기능은 추가하지 않았다.

## 참고 자료

2026-10-08 확인:

- [Home Assistant Scripts](https://www.home-assistant.io/integrations/script/): 스크립트 구조와 호출 방식.
- [Home Assistant AI Task](https://www.home-assistant.io/integrations/ai_task/): 생성 액션과 텍스트 응답.
- [Core 2026.9.3 AI Task 구현](https://github.com/home-assistant/core/blob/2026.9.3/homeassistant/components/ai_task/__init__.py): `entity_id`, `task_name`, `instructions` 및 응답 지원.
- [Home Assistant Scripts syntax](https://www.home-assistant.io/docs/scripts/): 반복, 조건, 지연, 중단과 오류 처리.
- [Home Assistant TTS](https://www.home-assistant.io/integrations/tts/): `tts.speak`와 대상 미디어 플레이어.

공식 웹 문서는 확인 시점 최신 문서이며, AI 액션 스키마는 기록된 Core 버전 소스도 확인했다.
커스텀 TTS 통합의 설치 버전·upstream은 미확인으로, 사용자 제공 옵션을 유지했다.
