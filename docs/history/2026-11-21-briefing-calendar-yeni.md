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
| [sunday-briefing/automation.yaml](../../config/automations/sunday-briefing/automation.yaml) | `target.entity_id`와 `schedule_text`의 `expected` 목록 양쪽에 `calendar.yeni` 추가 |

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

## 미해결과 다음 작업

- 평일(월~금 07:03:30, 토 07:40)과 일요일(07:40) 브리핑에서 `calendar.yeni` 일정을 읽는지 확인한다.
- 함께 적용된 instructions 변경(구어체, 개인 호칭 없는 존댓말, 일요일 일정 조회·부분 실패 안내)이 실제 원고·음성에서 의도대로 나오는지 확인한다.
- 에이전트 클릭으로 HA 탭이 죽는 원인은 확인하지 못했다. 2026-11-20에는 같은 방식으로 h2m·자동화 편집이 됐다.
