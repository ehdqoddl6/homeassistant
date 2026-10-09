# 지하철 도착 음성 안내 스크립트 작성

- 작업일: 2026-10-09 (Asia/Seoul)
- 상태: 로컬 예제 작성·정적 및 Jinja 대역 검증 완료 / 실제 엔티티·호출·음성 확인 대기
- 운영 적용: 미적용
- 대상 환경: 기록상 Core 2026.9.3 / Home Assistant OS. 현재 서버 버전·상태는 조회하지 않음.
- 관련 파일: [지하철 스크립트와 적용 안내](../../config/scripts/subway-briefing/README.md)
- 관련 기록: [날씨 스크립트](2026-10-08-weather-briefing-script.md), [환율 스크립트](2026-10-08-usd-krw-briefing-script.md)

## 목적과 관찰

사용자가 평내호평역 상행 열차 센서 3개를 `configuration.yaml`에 추가했다고 알리고,
스크립트 실행 → LLM 안내문 생성 → TTS 출력을 요청했다.
입력은 각 센서의 `N분 N초` 상태와 `headsign` 속성이다.
센서 이름은 제공됐지만 Home Assistant에 실제 등록된 엔티티 ID는 확인하지 못했다.

네이버 API에 `subwayArrivalCount=2`로 직접 요청했을 때 상행 항목은 두 개였고 `upWays[2]`는 없었다.
`3`으로 요청했을 때 상행 항목 세 개와 세 번째 항목의 `arrivalTime`·`headsign`을 확인했다.
관찰 시점의 응답 개수이며 항상 세 대가 반환된다는 보장은 없다.
원본 템플릿은 누락된 `arrivalTime`에 대한 기본값 처리가 없고, 시간대 없는 `arrivalTime`을 사용한다.
API 응답에는 시간대가 포함된 `arrivalTimeZ`도 있었으며 현재 서버 시간대는 미확인이다.

## 변경과 선택 이유

- `config/scripts/subway-briefing/script.example.yaml`: 기존 센서 이름의 기본 ID를 예상해 작성한 UI 단일 스크립트 예제다. 실제 등록 ID 미확인 상태를 파일명과 안내에 표시했다.
- `config/scripts/subway-briefing/README.md`: UI 적용, 엔티티 ID 확인, 센서 요청 개수 수정, 검증 범위와 복구 방법을 안내한다.
- `config/README.md`, `docs/history/README.md`: 스크립트·기록 링크를 추가한다.
- `docs/environment.md`: 사용자 확인에 근거해 지하철 센서의 파일 관리 위치와 설정 내용을 기록한다.

기존 Gemini AI Task, Google AI TTS, 거실 스피커와 `Leda` 음성을 재사용한다.
각 AI 호출에서 센서 값을 다시 읽고 유효한 음이 아닌 시간과 행선지를 전달한다.
누락·음수·잘못된 형식의 시간은 템플릿에서 `확인 불가`로 바꾸며, 행선지가 없으면 특정 종착역을 추정하지 않도록 지시한다.
정보가 전부 없으면 확인 불가 안내를 생성하며 운행 종료로 해석하지 않는다.
빈 AI 응답·AI 오류는 최대 3회 시도하고 성공하면 TTS 요청 후 중단한다. 모두 실패하면 고정 실패 안내를 요청한다.

자동 실행 트리거가 없는 단일 스크립트 매핑이며 저장소 상위 include는 없다.
센서 조회값은 음성 생성 지연과 원본 조회 실패로 오래된 값일 수 있어 실시간 카운트다운을 보장하지 않는다.
기존 자동화·스크립트와 서버 `configuration.yaml`은 수정하지 않았다.

## 검증

| 확인 항목 | 수행 방법 | 결과 |
| --- | --- | --- |
| 네이버 응답 구조 | 사용자 URL을 읽기 전용으로 조회, 요청 개수 `2`·`3` 비교 | 통과: 관찰 시 각각 상행 2개·3개, 시간·행선지 필드 확인. HA 내부 조회 성공을 뜻하지 않음 |
| YAML 문법·중복 키·구조 | Ruby Psych 및 구조 검사 | 통과: 단일 스크립트 매핑, 중복 키 없음, 최대 3회 생성·응답 초기화·TTS 후 중단·실패 안내·기존 출력 설정 확인 |
| Jinja 입력·AI 응답 검사 | Jinja2 3.1.6과 HA 상태 함수·정규식 필터 대역으로 로컬 렌더링 | 통과: 템플릿 4개 컴파일, 센서 입력 27가지·응답 11가지, 재시도 대기 경계와 메시지 공백 제거. HA 런타임 검증과 구분 |
| 문서 링크·공백 | Python 상대 링크·공백 검사, `git diff --check` | 통과: 로컬 링크 23개, 변경·추가 파일 6개 공백 검사 |
| Home Assistant 구성 검사 | 실행 환경 미연결, 로컬 Home Assistant 미설치 | 미실행 |
| 실제 센서·AI·TTS·음성 호출 | 서버 및 장치 미접속 | 미실행 |

검증용 Jinja2는 저장소 밖 임시 폴더에만 설치했다. 샌드박스의 패키지 서버 DNS 접속 실패 후 승인된 네트워크 접근으로 설치했다.
네이버 `3` 조회의 첫 시도는 빈 출력으로 JSON 파싱에 실패했고, 재시도에서 유효한 응답을 확인했다.

## 운영 반영과 복구

로컬 예제와 문서만 작성했다. 서버 저장, 재시작, 스크립트 실행이나 스피커 재생은 수행하지 않았다.
적용 시 센서 엔티티 ID·상태·`headsign`을 확인한 뒤 UI에서 새 스크립트를 저장한다.
세 번째 열차가 필요하면 센서 세 개의 URL 요청 개수를 `3`으로 맞추되, 적용 전 운영 설정을 백업하고 누락 응답도 점검한다.
되돌리려면 새 스크립트의 호출 연결을 해제하고 해당 스크립트만 삭제한다. 변경한 센서 설정은 적용 전 값으로 복원한다.

## 미해결과 다음 작업

- 실제 센서 엔티티 ID, 현재 상태와 원본 센서의 누락 응답 처리·시간대 계산.
- API 조회 실패 뒤 이전 값 유지 여부와 데이터 신선도. 현재 입력만으로 신선도를 보장할 수 없음.
- 실제 AI가 시간·행선지 연결과 누락 처리 지시를 따르는지, TTS 발음·재생 지연.
- 저장 후 스크립트 엔티티 ID와 Assist 호출 연결 방식.
- Google AI TTS 커스텀 통합의 현재 버전·upstream. 이번에는 기존 옵션을 재사용함.

## 참고 자료

2026-10-09 확인. 공식 문서는 최신판이므로 기록된 Core 버전의 AI Task·Command Line 구현도 함께 확인했다.

- [Home Assistant AI Task](https://www.home-assistant.io/integrations/ai_task/)
- [Home Assistant TTS](https://www.home-assistant.io/integrations/tts/)
- [Home Assistant 스크립트 문법](https://www.home-assistant.io/docs/scripts/)
- [Home Assistant Command Line](https://www.home-assistant.io/integrations/command_line/)
- [Core 2026.9.3 AI Task](https://github.com/home-assistant/core/blob/2026.9.3/homeassistant/components/ai_task/__init__.py)
- [Core 2026.9.3 AI Task 응답](https://github.com/home-assistant/core/blob/2026.9.3/homeassistant/components/ai_task/task.py)
- [Core 2026.9.3 Command Line 센서](https://github.com/home-assistant/core/blob/2026.9.3/homeassistant/components/command_line/sensor.py)

네이버 API 구조는 사용자 제공 URL의 직접 응답에서 확인했다. 공식 공개 API 계약이나 장기 호환성을 확인한 것은 아니다.

## 후속 작업

- [2026-10-10 지하철 안내 말투 개선과 도착 예정 시각 계산](2026-10-10-subway-arrival-time.md): 해요체 안내로 조정하고 현재 시각에 남은 시간을 더한 평내호평역 도착 예정 시각을 함께 전달한다.
