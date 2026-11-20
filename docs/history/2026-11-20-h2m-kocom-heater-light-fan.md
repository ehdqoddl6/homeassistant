# Homenet2MQTT 코콤 Room 0 난방 꺼짐 수정, 조명 복구, 환풍기 추가

- 작업일: 2026-11-20 (Asia/Seoul)
- 상태: 적용 완료 / 실제 동작 확인 대기
- 운영 적용: 적용 (h2m 엔티티 설정 수정·추가, 브릿지 재시작 2회)
- 대상 환경과 버전: Homenet2MQTT 애드온 v3.4.0 (slug `h2m`), 브릿지 `kocom_main`, 설정 파일 `default.homenet_bridge.yaml`
- 관련 기록: [보관 폴더](../../config/homenet2mqtt/kocom/README.md)

## 목적과 관찰

1. `Room 0 Heater`를 켜 두어도 저절로 꺼졌다. 다른 방 난방은 유지됐다.
2. `Room 0 Light 2`를 h2m 화면에서 실수로 삭제했다.
3. 이전 코콤 HACS 통합에서는 환풍기 제어가 됐지만, h2m에서는 되지 않았다.

h2m 최근 활동에서 Room 0 Heater는 명령 수신 없이 현재온도·목표온도·모드가 같은 시각에 `0 / 0 / off`로 바뀌었다(2026-11-20 03:36:54, 11:53:06).
엔티티 패킷 로그에서 이 상태를 만든 수신 패킷 두 개를 확인했다.

```text
AA55 30DC 00 36 00 01 00 20 00 00 00 00 00 00 00 00 63 0D0D
AA55 30DC 00 36 00 01 00 3C 00 00 00 00 00 00 00 00 7F 0D0D
```

둘 다 목적지가 0번 방 온도조절기(`36 00`)이고 서브명령이 `0x20`, `0x3C`이며 값 8바이트가 모두 0이다.
기존 상태 패턴 `[30, D0, 00, 36, 00]`(2번째 바이트 마스크 `F0`)은 서브명령을 검사하지 않아 이 패킷을 상태로 해석했다.
1~3번 방에서는 같은 형태의 패킷이 관측되지 않았다.

h2m 백업(`entity_delete`) 비교 결과, `room_0_light_2`는 2026-11-19 13:18:30(UTC) 백업 이후의 삭제에서 사라졌다.
같은 날 13:41:45(UTC) 이후 삭제로 이전 `livingroom_fan`도 제거된 상태였다.
삭제 전 환풍기 설정은 `30 BC 00 01 00 48 …`처럼 목적지를 월패드(`01 00`)로, 출발지를 환기(`48 00`)로 두고 있었다.
lunDreame/kocom-wallpad의 명령 생성 코드는 목적지 `48 RR`, 출발지 `01 00`, 명령 `00`, 값 `[전원, 모드, 풍량, 0…]`를 사용한다.

## 변경과 선택 이유

모든 변경은 h2m 웹 UI(엔티티 YAML 편집기, 항목 추가)로 했다. h2m이 저장할 때마다 자동 백업을 만들었다.

| 엔티티 | 변경 | 이유 |
| --- | --- | --- |
| `room_0_heater` | `state`에 `except: [{index: 10, data: [0x00]}]` 추가 | 정상 상태 패킷의 목표온도는 최소 5°C이다. 꺼짐 상태도 목표온도를 유지했다(예: Room 2 끄기 때 목표 10). `state`에 index가 없으면 `except` 인덱스는 헤더 뒤 기준이라 `10`이 전체 패킷 12번 목표온도 바이트이다. 서브명령 `0x00`만 받도록 하면 조회 응답까지 막힐 수 있어 목표온도 조건을 택했다. |
| `room_0_light_2` | 2026-11-19 13:18:30(UTC) 백업의 원본 블록을 그대로 추가 | 다른 엔티티는 사용자가 의도해서 삭제했으므로 백업 전체 복원 대신 해당 엔티티만 복구했다. |
| `livingroom_fan` | lunDreame 명령 형식으로 새로 작성 | 켜기 `11 00 00`, 끄기 `00 00 00`, 풍량 `11 00 40/80/C0`, 모드 `11 01/02/03/05 00`. 상태는 목적지·출발지 양방향의 `48 00` 중 서브명령 `0x00`일 때만 받도록 `guard`를 넣었다. 상태 해석은 lunDreame와 같이 전원(12번 상위 니블), 모드(11번), 풍량(12번)을 쓴다. |

h2m 동작 근거는 upstream 소스로 확인했다.
`packages/core/src/protocol/device.ts`에서 index 없는 `state`는 헤더 길이를 baseOffset으로 쓰고, `utils/packet-matching.ts`가 같은 baseOffset으로 `except`를 검사한다.

## 검증

| 확인 항목 | 수행 방법 / 명령 | 결과와 근거 |
| --- | --- | --- |
| 로컬 매칭 대역 검증 | h2m 매칭 로직(`state` + `except`, baseOffset 2)을 Python으로 재현해 실제 문제 패킷 2개와 정상 형식 패킷에 적용 | 통과: 문제 패킷 2개 무시, 켜짐(목표 20)·꺼짐(목표 10) 패킷 반영, 1번 방 패킷 미매칭 |
| h2m 설정 반영 | 엔티티 YAML 편집기 저장, 항목 추가, MQTT 디스커버리 미리보기 | 통과: 저장 성공(`entity_update` 백업 생성), 환풍기 디스커버리 페이로드 생성 확인(`fan.geosil_hoanpunggi` 기본 ID) |
| 브릿지 재시작 | h2m의 "추가하고 재시작" 2회 | 통과: 재시작 후 대시보드에 `Room 0 Light 2`, `거실 환풍기` 표시. 시작 시 조회 자동화 실행 |
| Home Assistant 구성 검사 | — | 해당 없음 (HA YAML 변경 없음) |
| Room 0 난방 실제 유지 | 사용자가 Room 0 온도를 한 번 변경한 뒤 h2m 대시보드 확인 | 부분 통과: 현재 20 / 목표 8 / heat로 정상 갱신. 월패드에서는 계속 정상 동작(사용자 확인). 이후 0/off 재발 여부는 장시간 관찰 필요 |
| Light 2 상태·제어 | h2m 대시보드 | 상태 통과(OFF 수신) / 제어 미확인 |
| 환풍기 상태·제어 | 사용자가 HA에서 켜고 월패드에서 확인, h2m 최근 활동 확인 | 통과: 2026-11-20 20:38 HA 제어 후 월패드에서 동작 확인(사용자 확인). h2m에 preset `ventilation`, speed 33→0 상태 반영 |

## 후속: 환풍기를 쓰는 HA 자동화 엔티티 교체

HA 자동화 두 개가 이전 코콤 HACS 통합의 `fan.kocom_ventilation_0_0`을 참조하고 있었다. 이 엔티티는 더 이상 없어서 HA 편집기에 "알 수 없는 엔티티"로 표시됐다.
h2m 환풍기의 HA 엔티티 ID `fan.geosil_hoanpunggi`(HA 엔티티 목록에서 확인)로 바꿔, 2026-11-20 HA UI YAML 편집기에서 저장했다.

| 자동화 | 교체 위치 | 저장소 보관 |
| --- | --- | --- |
| 기기 상태 변경 TTS 알림 | 켜짐·꺼짐 트리거 2곳 | [device-state-tts](../../config/automations/device-state-tts/README.md) |
| 환기팬 2시간 후 자동 끄기 | 트리거·조건·끄기 액션 3곳 | [ventilation-auto-off](../../config/automations/ventilation-auto-off/README.md) |

저장 후 시각 편집기에서 해당 위치가 `거실 환풍기`로 표시되는 것을 확인했다. 환기 음성 안내는 사용자가 확인했다(2026-11-20). 2시간 후 자동 꺼짐은 아직 확인하지 않았다.

## 운영 반영과 복구

- 적용: 2026-11-20 약 20:25~20:29 (KST), h2m UI에서 수정 후 브릿지 재시작.
- 자동 백업: `default.homenet_bridge.yaml.2026-11-20T11-25-23-…entity_update.bak` 등 h2m 설정 > 백업 관리에 저장된다.
- 복구: h2m 설정 > 백업 관리에서 변경 직전 백업을 복원하거나, 각 엔티티 YAML에서 추가한 줄·엔티티를 지우고 브릿지를 재시작한다.
- 작업 중 내려받은 h2m 백업 사본은 Chrome 다운로드 폴더에 `.crdownload` 파일로 남아 있다. 설정 전체가 들어 있으므로 저장소에 넣지 않았다.

## 미해결과 다음 작업

- Room 0 난방을 켠 뒤 같은 0/off 전환이 다시 생기지 않는지 하루 이상 확인한다.
- `0x20`, `0x3C` 패킷의 정확한 의미는 확인하지 못했다.
- 환풍기 켜기·끄기·풍량·모드가 실제로 동작하는지, 상태가 돌아오는지 확인한다. 동작하지 않으면 h2m 패킷 로그에서 월패드로 직접 조작할 때의 `0x48` 패킷을 캡처해 비교한다.
- 이전 자동화 `ventilator_refresh`가 삭제된 `navien_ventilator`를 계속 참조한다. 정리 여부를 결정한다.
- `auto_open_private_door` 자동화도 삭제된 도어벨 엔티티를 참조했다. 벨이 울리면 자동으로 현관을 여는 동작이라, 도어폰 라인을 나중에 연결했을 때 의도치 않게 살아나지 않도록 사용자 요청으로 2026-11-20 h2m UI(자동화 > 관리 > 자동화 삭제)에서 삭제했다. h2m 자동 백업으로 복구할 수 있다.
- 현관문 열기: 코콤 도어폰은 메인 RS485 라인과 별도 라인이고 2바이트 CRC를 쓴다(h2m 이슈 #597). 현재 게이트웨이는 메인 라인 하나뿐이라, 추가하려면 도어폰 라인용 게이트웨이와 별도 브릿지가 필요하다. 패킷 딕셔너리에서 도어폰 패킷(`70 90`, `7A 9E`)은 관측되지 않았다.

## 참고 자료

- [wooooooooooook/homenet2mqtt](https://github.com/wooooooooooook/homenet2mqtt) — `docs/manufacturers/kocom.md`, `gallery/kocom/*.yaml`, `packages/core/src/utils/packet-matching.ts` (2026-11-20 확인)
- [wooooooooooook/HAaddons](https://github.com/wooooooooooook/HAaddons) — `Homenet2MQTT/config.yaml` slug `h2m` (2026-11-20 확인)
- [lunDreame/kocom-wallpad](https://github.com/lunDreame/kocom-wallpad) — `custom_components/kocom_wallpad/controller.py` 환기 명령 생성·상태 해석 (2026-11-20 확인)
