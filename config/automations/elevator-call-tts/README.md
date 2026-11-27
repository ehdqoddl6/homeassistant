# 엘리베이터 호출 TTS

h2m 코콤 월패드의 엘리베이터 호출 버튼(`button.elevator_call`)이 눌리면 4초 뒤 거실 스피커로 "엘리베이터 호출했어"라고 안내하는 자동화다.

## 파일과 적용

| 파일 | 용도 | 상태 |
| --- | --- | --- |
| [automation.yaml](automation.yaml) | 트리거를 button 엔티티 방식으로 고친 설정 | 2026-11-27 HA UI YAML 편집기에 저장(에이전트, 사용자 요청). 실제 발화 확인(사용자) |
| [history/2026-11-27-before-fix.yaml](history/2026-11-27-before-fix.yaml) | 수정 전 HA 설정(사용자 제공) | 복구·비교용 보관 |

HA UI의 기존 **엘리베이터 호출 TTS** 자동화 YAML 편집기에 넣는 형태다. 저장소를 읽는 include는 없다.

## 엔티티와 동작

| 항목 | 확인 상태 / 근거 |
| --- | --- |
| `button.elevator_call` | HA 자동화 편집기의 기존 설정. h2m(Homenet2MQTT) MQTT 디스커버리 button 엔티티 |
| `tts.google_ai_tts` → `media_player.geosil`, 음성 `Leda` | 기존 설정 그대로 |

- button 엔티티의 상태는 `on`/`off`가 아니라 마지막으로 누른 시각(타임스탬프)이다. 그래서 상태가 바뀔 때마다 실행하고, `unknown`·`unavailable`에서 오거나 그 상태로 가는 변화는 제외했다. 브릿지 재시작 때 헛울림을 막기 위해서다.
- HA에서 버튼을 누르거나 다른 자동화(평일 오전 엘리베이터 호출 등)가 `button.press`를 실행하면 안내한다. 월패드에서 직접 호출한 경우는 HA button 상태가 바뀌지 않아 안내하지 않는다.
- 버튼을 처음 누를 때(상태가 `unknown`인 경우)는 제외 조건 때문에 안내하지 않는다. 이미 여러 번 눌린 엔티티라 영향은 거의 없다.

## 히스토리

| 날짜 | 기록 | 상태 |
| --- | --- | --- |
| 2026-11-27 | [엘리베이터 호출 TTS가 울리지 않던 트리거 수정](../../../docs/history/2026-11-27-elevator-call-tts.md) | HA 저장, 실제 발화 확인(사용자) |
