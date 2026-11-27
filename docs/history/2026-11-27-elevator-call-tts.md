# 엘리베이터 호출 TTS가 울리지 않던 트리거 수정

- 작업일: 2026-11-27 (Asia/Seoul)
- 상태: 완료 — 실제 발화 확인 (사용자, 2026-11-27)
- 운영 적용: 적용 — 2026-11-27 에이전트가 HA UI YAML 편집기에서 저장(사용자 요청 "수정해줘")
- 대상 환경과 버전: Home Assistant UI 자동화 `엘리베이터 호출 TTS`, h2m 코콤 브릿지의 `button.elevator_call`. 현재 HA 버전은 이번 작업에서 미확인
- 관련 기록: [h2m 코콤 전환](2026-11-20-h2m-kocom-heater-light-fan.md)

## 목적과 관찰

사용자 보고: 엘리베이터 호출 TTS가 지금 울리지 않는다.

HA 편집기에서 본 기존 트리거(사용자도 같은 YAML 붙여넣음):

```yaml
- trigger: state
  entity_id:
    - button.elevator_call
  to:
    - 'on'
```

HA의 button 엔티티는 `on` 상태가 없다. 상태값은 마지막으로 누른 시각(타임스탬프)이라 `to: 'on'` 트리거는 한 번도 걸리지 않는다.
2026-11-19 이전 코콤 HACS 통합에서 h2m으로 바꾸면서 엘리베이터 엔티티가 `button`이 됐고, 트리거는 이전 방식(켜짐 상태) 그대로 남은 것으로 보인다. 이전 통합의 엔티티 종류는 확인하지 못했다.

## 변경과 선택 이유

| 파일 | 변경 |
| --- | --- |
| [elevator-call-tts/automation.yaml](../../config/automations/elevator-call-tts/automation.yaml) | `to: 'on'` 삭제. `not_from`·`not_to`에 `unknown`, `unavailable` 지정. description 추가 |
| [elevator-call-tts/history/2026-11-27-before-fix.yaml](../../config/automations/elevator-call-tts/history/2026-11-27-before-fix.yaml) | 수정 전 설정 보관 |

- button은 누를 때마다 타임스탬프가 바뀌므로 `to` 없이 상태 변경 전체를 트리거로 쓴다.
- h2m 브릿지 재시작이나 MQTT 연결 끊김 때 `unavailable` → 타임스탬프 복귀로 헛울림이 나지 않도록 `unknown`·`unavailable` 전환은 뺐다.
- 지연 4초, TTS 대상·문구·`cache: true`, `mode: single`은 그대로 뒀다.

## 검증

| 확인 항목 | 수행 방법 / 명령 | 결과와 근거 |
| --- | --- | --- |
| 로컬 문법·정적 검증 | Ruby `YAML.load_file`, 수정 전후 diff | 통과: 트리거만 바뀜 |
| HA 저장 | Chrome HA YAML 편집기에 붙여넣고 저장 → 새로고침 | 통과: 시각 편집기에 description과 "상태가 알 수 없음 및 사용할 수 없음을 제외한 임의의 상태에서…" 트리거 표시 |
| Home Assistant 구성 검사 | — | 미실행 (UI 저장 시 HA가 스키마 검사함) |
| 실제 시나리오 동작 | 사용자가 엘리베이터 호출 후 거실 스피커 확인 | 통과: 안내가 나옴 (사용자 확인 "된다", 2026-11-27). 에이전트는 실제 호출이라 버튼을 누르지 않았다 |

## 운영 반영과 복구

- 적용: 2026-11-27, HA UI 자동화 편집기(`/config/automation/edit/1779885887867`)에서 YAML 전체 교체 후 저장.
- 복구: 같은 편집기에서 [수정 전 설정](../../config/automations/elevator-call-tts/history/2026-11-27-before-fix.yaml)으로 교체한다(다시 울리지 않는 상태로 돌아간다).

## 미해결과 다음 작업

- 2026-11-27 사용자가 호출 후 안내가 나오는 것을 확인했다. 평일 07:10:30 자동 호출 때도 함께 울리는지는 다음 평일에 확인한다.
- 평일 오전 엘리베이터 호출 자동화 YAML은 여전히 저장소에 없다.
