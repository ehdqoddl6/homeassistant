# Home Assistant 설정 관리

검토·버전 관리할 실제 설정과 코드를 이 경로에 추가한다.
이 디렉터리는 서버의 `/config`에 연결되어 있지 않다.
[자동화 보관 폴더](automations/README.md)에 사용자 제공 YAML과 예제를 보관하며, 실제 적용·검증 여부는 각 폴더의 README에 기록한다.

기존 환경을 가져올 때는 그 구조를 우선한다. 다음 경로는 필요할 때 생성한다.

| 경로 예시 | 용도 |
| --- | --- |
| `configuration.yaml` | 주요 설정과 include 연결 |
| `automations/<주제>/` | 자동화 YAML, 적용 안내와 작업 기록 링크 |
| `scripts.yaml` 또는 `scripts/` | 기존 관리 방식에 맞춘 스크립트 |
| `packages/` | 기능 단위 패키지 |
| `custom_components/<domain>/` | 직접 관리하는 커스텀 컴포넌트 |
| `blueprints/` | 직접 관리하는 블루프린트 |

설정 파일을 추가할 때는 로드하는 상위 파일과 적용 위치도 기록한다.
예제와 실제 운영용 파일은 명확하게 구분한다. 미확인 엔티티를 넣은 예제는 실제 적용 파일로 취급하지 않는다.
HACS에서 관리하는 외부 코드는 설치했다는 이유만으로 모두 복사하지 않고, upstream 주소·버전·설치 방법을 우선 기록한다.

파일 기반 YAML의 자격 증명은 지원되는 위치에서 `!secret`으로 분리한다.
UI YAML 편집기의 지원 범위를 확인하고, 실제 `secrets.yaml`은 Git에 추가하지 않는다.
[Home Assistant 비밀정보 관리 문서](https://www.home-assistant.io/docs/configuration/secrets/)를 기준으로 적용한다.

`.storage`, 데이터베이스, 원본 백업, 인증서·키는 가져오지 않는다.
민감한 원본 자료가 필요하면 Git에서 제외한 `private/` 등 별도 위치를 사용한다.
