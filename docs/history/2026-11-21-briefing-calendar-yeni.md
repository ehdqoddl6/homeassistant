# 아침·일요일 브리핑에 새 캘린더 `calendar.yeni` 추가

- 작업일: 2026-11-21 (Asia/Seoul)
- 상태: HA 적용 완료 (사용자) / 실제 일정 낭독 미확인
- 운영 적용: 적용 — 2026-11-21 사용자가 HA UI YAML 편집기에서 두 자동화 전체 교체
- 대상 환경과 버전: Home Assistant Google Calendar 통합. 현재 HA 버전은 이번 작업에서 미확인
- 관련 기록: [아침 브리핑](2026-10-04-morning-briefing.md), [일요일 브리핑](2026-10-04-sunday-briefing.md)

## 목적과 관찰

2026-11-20에 Google Calendar에 새로 추가한 캘린더를 평일 아침 브리핑과 일요일 브리핑의 `calendar.get_events` 조회 대상에 넣어, AI 원고와 TTS 일정 안내에 포함되게 한다.

- HA **설정 → 통합 구성 요소 → Google Calendar** 엔티티는 12개다. 기존 브리핑 대상은 가족 2개(`calendar.gajog`, `calendar.gajog_2`), 이체(`calendar.ice`), 직장(`calendar.jigjang`), 캘린더(`calendar.kaelrindeo`)다.
- 새 캘린더는 사용자가 이름 `❤❤❤`로 지목했다. 엔티티 설정 화면에서 엔티티 ID `calendar.yeni`, 활성화·표시 켜짐을 확인했다(사용자 제공 화면, 2026-11-21).

## 변경과 선택 이유

| 파일 | 변경 |
| --- | --- |
| [morning-briefing/automation.yaml](../../config/automations/morning-briefing/automation.yaml) | `calendar.get_events` `target.entity_id`에 `calendar.yeni` 추가 |
| [sunday-briefing/automation.yaml](../../config/automations/sunday-briefing/history/2026-11-27-before-merge.yaml) (2026-11-27 통합으로 이력 파일로 이동) | `target.entity_id`와 `schedule_text`의 `expected` 목록 양쪽에 `calendar.yeni` 추가 |

일요일 브리핑은 `expected` 목록에 있는 캘린더만 응답에서 꺼내 읽고, 목록에 있는데 응답이 없으면 "일부 캘린더의 일정 정보를 가져오지 못했습니다"를 붙인다. 그래서 조회 대상과 `expected`를 함께 바꿨다.
평일 브리핑은 응답에 들어온 캘린더를 모두 순회하므로 조회 대상만 추가하면 된다.
instructions, 트리거 등 나머지 설정은 바꾸지 않았다.

## 검증

| 확인 항목 | 수행 방법 / 명령 | 결과와 근거 |
| --- | --- | --- |
| 로컬 문법·정적 검증 | Ruby `YAML.load_file`로 두 파일 파싱, 조회 대상 목록 출력, 일요일 `expected`와 `target.entity_id` 비교 | 통과: 두 파일 모두 캘린더 6개, 일요일 `expected == target` true |
| Jinja 렌더링 | — | 미실행 (로컬에 Python `yaml`/`jinja2` 없음) |
| Home Assistant 구성 검사 | — | 미실행 |
| 실제 시나리오 동작 | — | 미실행. 실제 브리핑에서 `calendar.yeni` 일정 낭독 미확인 |

## 운영 반영과 복구

- 에이전트가 Chrome의 HA 화면을 cmux-cua로 조작하려 했으나 실패했다. HA 페이지 안을 클릭할 때마다 탭이 "오류 코드 5"로 비정상 종료됐고, 이후 Chrome 접근성 트리도 비어서 진행을 멈췄다. 엔티티 ID는 사용자가 직접 화면에서 확인했다.
- (당초 안내, 아래 후속에서 사용자가 전체 교체를 선택) 로컬 `automation.yaml`에는 2026-10-04·2026-11-01에 수정하고 운영에 반영하지 않은 instructions가 들어 있다. HA 실제 설정과 다를 수 있으므로 **파일 전체를 붙여넣지 않는다.** HA UI 각 자동화의 YAML 편집기에서 `- calendar.kaelrindeo` 아래에 `- calendar.yeni` 한 줄만 추가한다. 일요일 브리핑에 `expected = [...]` 목록이 있으면 그 목록 끝에도 `'calendar.yeni'`를 추가한다.
- 복구: 추가한 `calendar.yeni` 줄(과 `expected` 항목)을 지우고 저장한다.

### 2026-11-21 후속: 사용자 HA 반영

- 에이전트가 두 `automation.yaml` 전체를 차례로 클립보드에 올렸고(`pbcopy`), 사용자가 HA UI의 **평일 아침 브리핑**, **일요일 브리핑** YAML 편집기에서 전체를 교체해 저장했다(사용자 확인).
- 사용자가 부분 수정 대신 전체 교체를 선택했다. 그래서 운영에 넣지 않았던 [2026-10-04 아침 브리핑](2026-10-04-morning-briefing.md)·[2026-10-04 일요일 브리핑](2026-10-04-sunday-briefing.md)의 instructions·일정 조회 수정과 [2026-11-01 호칭·반말 제거](2026-11-01-briefing-tone.md) 중 두 브리핑 부분도 이때 함께 적용됐다.
- 교체 전 HA 실제 YAML은 백업하지 않았다. 캘린더 추가만 되돌릴 때는 HA 편집기에서 `calendar.yeni` 줄과 일요일 `expected` 항목을 지운다. 이전 말투까지 되돌릴 때는 각 폴더 `history/2026-10-04-before-instructions.yaml`을 참고하되, 그 뒤 HA에서 바꾼 트리거(토요일 07:40 등)는 다시 맞춰야 한다. 교체 전 HA에만 있던 수정은 저장소로 복구할 수 없다.

### 2026-11-21 후속: 데이트 일정으로 소개

사용자 설명: `calendar.yeni`(❤❤❤)는 여자친구와의 데이트 일정 캘린더다. 사용자는 브리핑에서 이 일정을 데이트로 소개하는 방식을 골랐다. 다른 선택지는 브리핑에서 빼기, 그대로 두기였다.

| 파일 | 변경 |
| --- | --- |
| 두 `automation.yaml`의 `schedule_text` | `entity_id == 'calendar.yeni'`인 일정 줄 앞에 `[데이트]` 표시 추가 |
| 두 `automation.yaml`의 instructions 일정 부분 | `[데이트]` 표시는 읽지 않고 "[시각]에는 여자친구와 데이트가 있어요"처럼 소개하라는 규칙 추가. 놀리거나 과하게 꾸미는 말은 하지 않도록 함 |

검증:
- 두 파일 Ruby YAML 파싱, `{%`/`%}` 짝(평일 19/19, 일요일 33/33) 확인.
- scratchpad venv의 Jinja2로 두 `schedule_text`를 가짜 응답으로 렌더링했다. 데이트 일정이 있으면 `- [데이트] 저녁 식사 (…) @ 홍대`가 다른 일정 뒤에 나오고, 없으면 기존 줄만 나왔다. 단, HA 템플릿 엔진이 아닌 일반 Jinja2 결과다.
- 실제 AI 원고에서 데이트라고 소개하는지는 미확인.
- 2026-11-27 추가: 아래 후속에서 `calendar.yeni` 전체가 아니라 제목 `new Date()` 일정만 데이트로 보도록 조건을 바꿨다. 이 후속은 HA에 적용하지 않은 채 바뀌었다.

### 2026-11-27 후속: `new Date()` 일정만 데이트, 장소 함께 안내

사용자 설명: `calendar.yeni`에서 제목이 `new Date()`인 일정이 여자친구와의 데이트다. 브리핑에서는 데이트라는 것과 장소를 말해야 한다.

| 파일 | 변경 |
| --- | --- |
| 두 `automation.yaml`의 `schedule_text` | `is_date` 조건 추가: `calendar.yeni`이고 제목을 소문자·공백 제거했을 때 `newdate()`인 경우. 이 일정은 줄을 `- [데이트] 여자친구와 데이트`로 바꿔 `new Date()`를 그대로 읽지 않게 했다. 시작 시각·`@ 장소`는 기존처럼 붙는다. 다른 `calendar.yeni` 일정은 `[데이트]` 표시 없이 일반 일정으로 나간다 |
| 두 `automation.yaml`의 instructions 일정 부분 | "[시각]에는 [장소]에서 여자친구와 데이트가 있어요"처럼 장소를 함께 말하게 했다. 장소는 `@` 뒤 값이고, 긴 주소는 가게·건물·동네 이름 위주로 줄이고 우편번호·국가명은 읽지 않는다. 장소가 없으면 지어내지 않고 데이트만 말한다. 일요일 브리핑의 "장소는 필요할 때만" 규칙보다 이 규칙이 데이트에서는 우선하도록 문장을 바로 뒤에 넣었다 |

선택 이유: 제목 원문 `new Date()`를 AI에 그대로 넘기면 영어 코드 표기를 읽거나 의미를 추측할 수 있어서 템플릿에서 미리 "여자친구와 데이트"로 바꿨다. 제목 비교는 `New Date ( )`처럼 대소문자·띄어쓰기가 달라도 맞도록 정규화했다. 제목 뒤에 다른 글자가 붙은 경우(`new Date() 영화` 등)는 데이트로 보지 않는다.

검증:
- 두 파일 Ruby `YAML.load_file` 파싱 통과, `{%`/`%}` 짝 평일 20/20, 일요일 34/34.
- scratchpad venv의 Jinja2로 두 `schedule_text`를 가짜 응답으로 렌더링했다. `new Date()`(장소 있음) → `- [데이트] 여자친구와 데이트 (… 18:30…) @ 스타벅스 홍대점, …`, `New Date ( )`(종일, 장소 없음) → `- [데이트] 여자친구와 데이트 (2026-11-28)`, 같은 캘린더의 `선물 사기` → 표시 없는 일반 줄로 나왔다. HA 템플릿 엔진이 아닌 일반 Jinja2 결과다.
- Home Assistant 구성 검사, 실제 AI 원고·음성 확인은 미실행.

운영 반영: 미적용. 적용하려면 HA UI의 **평일 아침 브리핑**, **일요일 브리핑** YAML 편집기에서 `schedule_text`의 `set line` 줄과 instructions 일정 부분을 이 파일 내용으로 바꾼다. 2026-11-21 전체 교체 이후 HA에서 따로 바꾼 부분이 있으면 전체 교체 대신 해당 줄만 바꾼다.
같은 날 이 규칙을 포함해 두 브리핑을 하나로 합쳤다. 적용은 [2026-11-27 통합 기록](2026-11-27-briefing-merge.md)의 순서를 따른다.
복구: `is_date` 줄을 지우고 `set line`을 `'- ' ~ summary`로 되돌린 뒤 instructions의 `[데이트]` 문단 다섯 줄을 지운다.

## 미해결과 다음 작업

- 평일(월~금 07:03:30, 토 07:40)과 일요일(07:40) 브리핑에서 `calendar.yeni` 일정을 읽는지 확인한다.
- 함께 적용된 instructions 변경(구어체, 개인 호칭 없는 존댓말, 일요일 일정 조회·부분 실패 안내)이 실제 원고·음성에서 의도대로 나오는지 확인한다.
- 2026-11-27 `new Date()` 데이트 규칙을 HA에 적용한 뒤, 데이트 일정이 "[시각]에는 [장소]에서 여자친구와 데이트"처럼 장소와 함께 낭독되는지 확인한다.
- 에이전트 클릭으로 HA 탭이 죽는 원인은 확인하지 못했다. 2026-11-20에는 같은 방식으로 h2m·자동화 편집이 됐다.
