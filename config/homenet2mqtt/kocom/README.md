# Homenet2MQTT 코콤 월패드 엔티티

Homenet2MQTT(h2m) 애드온의 코콤 브릿지(`kocom_main`) 설정 중 직접 수정·복구한 엔티티를 보관한다.
실제 설정 파일은 Home Assistant 설정 경로의 `default.homenet_bridge.yaml`이며, 이 폴더는 서버와 연결되어 있지 않다.
각 YAML은 h2m 엔티티 YAML 편집기에 넣는 단일 엔티티 형식이다.

| 파일 | 엔티티 | 내용 | 상태 |
| --- | --- | --- | --- |
| [room_0_heater.yaml](room_0_heater.yaml) | `climate.room_0_heater` | 목표온도 바이트가 0인 비상태 패킷을 `except`로 제외 | 적용 / 상태 정상 갱신 확인, 장기 재발 여부 관찰 중 |
| [room_0_light_2.yaml](room_0_light_2.yaml) | `light.room_0_light_2` | 실수로 삭제한 엔티티를 2026-11-19 h2m 백업 원본 그대로 복구 | h2m 적용·브릿지 재시작 완료 / 상태·제어 확인 대기 |
| [livingroom_fan.yaml](livingroom_fan.yaml) | `fan.livingroom_fan` | 표준 코콤 환기(`0x48`) 패킷으로 새로 작성 | 적용 / HA 제어·월패드 확인 완료 (2026-11-20 사용자 확인) |

## 기록

- [2026-11-20 Room 0 난방 꺼짐, 조명 복구, 환풍기 추가](../../../docs/history/2026-11-20-h2m-kocom-heater-light-fan.md)
