# 환기팬 2시간 후 자동 끄기

거실 환풍기가 켜지고 2시간이 지나면 자동으로 끄는 UI 자동화다.
Home Assistant에 이미 있던 `환기팬 2시간 후 자동 끄기` 자동화를 보관하고, 환풍기 엔티티를 Homenet2MQTT 엔티티로 바꿨다.

## 파일과 적용

- [automation.yaml](automation.yaml): UI의 단일 자동화 YAML 편집기에 넣는 매핑이다.
- 운영 자동화: `automation/edit/1783435687527` (UI 관리).

## 확인된 엔티티

| 엔티티 | 근거 |
| --- | --- |
| `fan.geosil_hoanpunggi` | h2m `livingroom_fan`의 MQTT 디스커버리 엔티티. HA 엔티티 목록에서 확인 |
| `fan.kocom_ventilation_0_0` (이전) | 이전 코콤 HACS 통합 엔티티. 현재 HA에서 "알 수 없는 엔티티"로 표시됨 |

## 검증과 운영 상태

- 2026-11-20: HA UI YAML 편집기에서 엔티티 3곳을 교체하고 저장했다. 시각 편집기에서 트리거·조건·끄기 액션이 모두 `거실 환풍기`로 표시됐다.
- 실제 2시간 후 자동 꺼짐: 미확인.
- 복구: YAML의 `fan.geosil_hoanpunggi`를 이전 엔티티로 되돌린다. 이전 엔티티는 현재 존재하지 않는다.

## 히스토리

- [2026-11-20 h2m 코콤 Room 0 난방·조명·환풍기 작업](../../../docs/history/2026-11-20-h2m-kocom-heater-light-fan.md)
