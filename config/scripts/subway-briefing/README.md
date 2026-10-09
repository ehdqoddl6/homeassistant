# 평내호평역 지하철 알려줘

사용자가 `configuration.yaml`에 추가한 평내호평역 경춘선 상행 센서의 남은 시간과 `headsign`을 읽는다.
Gemini가 짧은 교통 안내 방송 원고를 만들고 기존 거실 스피커에서 `Leda` 음성으로 재생한다.

## 파일과 적용

- [script.example.yaml](script.example.yaml): Home Assistant의 **새 스크립트 → YAML 편집기**에 전체 내용을 붙여 넣는다.
- 센서 `name`으로부터 예상한 기본 엔티티 ID를 사용한다. 실제 서버의 등록 ID를 확인하지 못해 `*.example.yaml`로 구분했다. 개발자 도구 → 상태에서 아래 ID와 상태·속성을 확인하고, 다르면 `subway_sensors` 목록을 실제 ID로 바꾼다.
- UI 단일 스크립트 매핑이다. 최상위 `script:`나 별도 스크립트 키로 감싸지 않는다.
- 저장소는 서버 설정 경로와 연결되어 있지 않으며 상위 include는 없다. 파일 방식의 `scripts.yaml`에는 기존 매핑 구조에 맞게 별도 스크립트 키 아래 넣어야 한다.
- 저장 후 스크립트를 직접 실행한다. 음성 질의로 실행하려면 저장된 실제 스크립트 엔티티를 기존 호출 경로에 별도로 연결한다.

| 항목 | 근거와 확인 상태 |
| --- | --- |
| `sensor.pyeongnaehopyeong_subway_up_1021` | 사용자 제공 `PyeongnaeHopyeong_Subway_Up_1021`의 예상 기본 ID; 실제 등록 ID 미확인 |
| `sensor.pyeongnaehopyeong_subway_up_1022` | 사용자 제공 `PyeongnaeHopyeong_Subway_Up_1022`의 예상 기본 ID; 실제 등록 ID 미확인 |
| `sensor.pyeongnaehopyeong_subway_up_1023` | 사용자 제공 `PyeongnaeHopyeong_Subway_Up_1023`의 예상 기본 ID; 실제 등록 ID 미확인 |
| 센서 상태 / `headsign` 속성 | 사용자 YAML의 `N분 N초` / 행선지 문자열 |
| `ai_task.google_ai_task` | 기존 [날씨](../weather-briefing/README.md)·[환율](../usd-krw-briefing/README.md) 스크립트 |
| `tts.google_ai_tts` → `media_player.geosil`, 음성 `Leda` | 기존 스크립트의 출력 설정; 현재 서버 가용성·설치 버전 미확인 |

## 안내 동작

각 AI 생성 시도에서 센서에 저장된 값을 다시 읽는다. 네이버 API 직접 호출이나 센서 강제 갱신은 하지 않는다.
`N분 N초` 형식이고 분이 0 이상, 초가 0~59인 시간만 AI 입력에 포함한다. 음수, `unknown`, `unavailable`, 빈 값과 잘못된 형식은 `확인 불가`로 바꾼다.
행선지가 없으면 AI가 '상행 열차'로 안내하도록 지시한다. 일부 시간 누락은 해당 후보만 생략하고, 전부 누락되면 확인이 어렵다는 안내를 생성한다.
0초를 실제 도착 확인으로 해석하지 않으며, 데이터 부재를 운행 종료로 단정하지 않는다.

AI 생성은 최대 3회 시도하고 실패 사이에 2초를 기다린다. 매번 응답을 초기화하고 비어 있지 않은 문자열만 TTS에 전달한다.
모두 실패하면 고정 실패 안내를 재생 요청한다. TTS 오류는 재시도하지 않는다.
`mode: single`은 이 스크립트 실행 중 중복 호출을 막는다. 재생 완료 대기나 다른 스크립트와의 음성 재생 조정은 포함하지 않는다.

센서 상태에 원본 도착 시각과 API 조회 성공 시각이 없으므로 데이터의 신선도를 보장할 수 없다.
AI·TTS 생성 중에도 시간이 흐르며, 안내는 센서 조회 기준의 예상 시간이다. API 조회 실패 뒤 이전 값이 남는 경우까지 이 스크립트에서 판별하지는 못한다.

## 센서 설정에서 함께 확인할 부분

제공된 세 센서의 URL은 `subwayArrivalCount=2`이지만 세 번째 센서는 `upWays[2]`를 읽는다.
2026-10-09 직접 조회에서도 `2` 요청은 상행 항목이 두 개여서 세 번째 항목이 없었다.
같은 날 `3`으로 요청했을 때는 상행 항목 세 개와 세 번째 항목의 `arrivalTime`·`headsign`을 확인했다.
세 번째 열차도 사용하려면 세 센서의 `command` URL에서 다음 부분을 변경한다.

```text
subwayArrivalCount=2 → subwayArrivalCount=3
```

요청 개수를 늘려도 운행 상황에 따라 세 대가 항상 반환되는 것은 아니다.
원본 `value_template`는 `arrivalTime`이 없는 응답에서 변환 오류가 날 수 있으므로, 실제 센서 로그와 누락 상태도 확인해야 한다.
원본의 시간대 없는 `arrivalTime`은 서버 시간대 설정에 영향을 받는다. API에는 `+09:00`이 포함된 `arrivalTimeZ`도 있으므로 서버 시간대와 계산 결과를 확인한다.
이번 작업은 호출형 안내 스크립트만 추가했으며 운영 `configuration.yaml`은 수정하지 않았다.

## 검증과 운영 적용

- 로컬 YAML 파싱·중복 키·단일 스크립트 구조·AI 재시도·TTS 설정 검사 통과.
- Jinja2로 템플릿 4개를 컴파일하고 센서 입력 27가지·AI 응답 11가지, 재시도 대기 경계와 TTS 메시지 공백 제거를 확인했다. HA 상태 함수와 정규식 필터는 로컬 대역을 사용한 검증이다.
- 문서 상대 링크 23개와 변경·추가 파일 6개의 공백 검사 통과.
- Home Assistant 구성 검사, 실제 센서 상태, AI 원고, 스크립트 실행, Assist 연결과 TTS 청취: 미검증.
- 운영 적용: 미적용. 로컬 예제와 적용 안내만 작성했다.
- 복구: 새 스크립트의 음성 호출 연결을 해제하고 해당 스크립트만 삭제한다. 센서 요청 개수를 변경했다면 적용 전 백업값으로 복원한다.

## 히스토리

- [2026-10-09 지하철 도착 음성 안내 스크립트 작성](../../../docs/history/2026-10-09-subway-briefing-script.md)
