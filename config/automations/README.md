# 자동화 기록

자동화를 작성하거나 수정할 때 주제별 폴더에 YAML과 README를 함께 보관한다.
후속 수정은 같은 폴더에서 관리하고, 날짜별 작업 기록은 `docs/history/`에 누적한다.

| 폴더 | 내용 | 상태 |
| --- | --- | --- |
| [sunday-briefing/](sunday-briefing/README.md) | 일요일 날씨·일정·환율 브리핑 | 일정 조회·instructions 수정, 운영 미적용 |
| [morning-briefing/](morning-briefing/README.md) | 날씨·일정·시장 아침 브리핑 | instructions 수정, 운영 미적용 |
| [lg-washer-tts/](lg-washer-tts/README.md) | LG 세탁기 완료·완료 10분 전 TTS 알림 | 제공한 설정 사용·사전 알림 테스트 성공 (사용자 확인) |

## 보관 규칙

- 각 폴더의 README에 목적, 파일 설명, 적용 위치와 include 관계, 확인된 엔티티, 검증·운영 적용 상태를 적는다.
- 엔티티나 동작 전제가 미확인인 초안은 `*.example.yaml`로 구분한다.
- 날짜별 기록은 [작업 양식](../../docs/templates/change.md)을 바탕으로 `docs/history/YYYY-MM-DD-주제.md`에 작성한다.
- 해당 폴더의 README와 [전체 히스토리](../../docs/history/README.md)에서 같은 기록을 연결한다.
- 폴더 생성이나 YAML 저장을 운영 적용으로 취급하지 않는다.

현재 파일은 UI의 단일 자동화 YAML 편집기에 넣는 형태로 보관한다.
이 디렉터리를 읽는 상위 `configuration.yaml`이나 `!include`는 없으며, 폴더 전체를 자동으로 로드하지 않는다.
파일 기반 관리가 확인되면 해당 환경의 기존 include 구조와 목록 형식에 맞춰 별도로 연결한다.
