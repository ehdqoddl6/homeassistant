# Home Assistant 구축과 운영 기록

우리 집 Home Assistant를 구축하고 개선하는 프로젝트다.
자동화 YAML과 커스텀 컴포넌트 연동을 관리하고, 작업 과정에서 쌓인 기록을 블로그 구축기로 이어간다.
설정 파일뿐 아니라 **왜 바꿨는지, 어떻게 확인했는지, 무엇이 아직 남았는지**를 함께 남긴다.

## 작업 범위

- **구축과 설정:** 설치 환경, 기기 구성, 대시보드, 운영 설정 정리
- **자동화:** 자동화·스크립트·템플릿·패키지 YAML 작성과 문제 해결
- **연동:** 공식 통합 및 HACS/수동 설치 커스텀 컴포넌트 연결, 호환성 확인, 필요한 코드 수정
- **운영 기록:** 변경 이유, 시행착오, 검증 결과, 복구 방법 축적
- **블로그:** 실제 작업 기록에 근거한 구축기 초안과 발행 이력 관리

## 현재 상태

2026-10-03 기준 프로젝트 문서와 스킬을 초기 구성했다.
2026-10-04 자동화별 보관 폴더를 만들었다. 세탁기 10분 전 알림은 사용자 테스트 성공을 기록했고, 평일·일요일 브리핑은 자연스러운 말투를 위한 instructions 수정본을 보관했다.
실제 Home Assistant 설정 파일과 실행 환경은 아직 연결하지 않았다.
설치 방식, 버전, 기기 목록은 [환경 기록](docs/environment.md)에 확인된 내용부터 추가한다.

## 구성

| 경로 | 용도 |
| --- | --- |
| [AGENTS.md](AGENTS.md) | 프로젝트 작업 원칙, 스킬 선택, 히스토리 기록 규칙 |
| [config/](config/README.md) | 버전 관리할 Home Assistant 설정과 코드 |
| [config/automations/](config/automations/README.md) | 자동화별 YAML, 적용 상태와 작업 기록 링크 |
| [docs/environment.md](docs/environment.md) | 확인된 설치 환경과 장비·연동 정보 |
| [docs/history/](docs/history/README.md) | 날짜별 작업 기록과 목록 |
| [docs/templates/change.md](docs/templates/change.md) | 설정·연동·문제 해결 기록 양식 |
| [docs/templates/blog.md](docs/templates/blog.md) | 구축기 작성 양식 |
| [blog/](blog/README.md) | 블로그 초안과 발행 정보 |
| `.codex/skills/` | 프로젝트 전용 스킬 원본 |
| `.agents/skills/` | 같은 스킬 원본을 가리키는 탐색용 심볼릭 링크 |

`config/`는 저장소의 관리 경로다. 실제 서버의 설정 경로나 배포 대상은 환경 확인 후 정한다.
현재는 서버로 파일을 보내거나 자동 적용하는 기능이 없다.

## 전용 스킬

| 스킬 | 사용할 때 |
| --- | --- |
| [homeassistant-config](.codex/skills/homeassistant-config/SKILL.md) | 자동화 YAML, 스크립트, 템플릿, 설정 수정과 검증 |
| [homeassistant-integration](.codex/skills/homeassistant-integration/SKILL.md) | 기기·커스텀 컴포넌트 연동, 호환성 확인, 연동 오류 해결 |
| [homeassistant-blog](.codex/skills/homeassistant-blog/SKILL.md) | 작업 히스토리를 바탕으로 구축기 작성·수정 |

예를 들어 아래처럼 요청하면 된다.

```text
$homeassistant-config 현관 움직임 감지 시 조명을 켜는 자동화를 작성해줘.
$homeassistant-integration 이 커스텀 컴포넌트의 설치 방법과 현재 환경 호환성을 확인해줘.
$homeassistant-blog 이번 연동 작업 기록으로 구축기 초안을 작성해줘.
```

스킬은 이 프로젝트에만 설치한다. 원본은 `.codex/skills/`에서 관리하고,
[OpenAI 공식 문서의 저장소 스킬 탐색 규칙](https://learn.chatgpt.com/docs/build-skills)에 맞춰 `.agents/skills/`에서도 찾을 수 있도록 연결한다.

## 기록 흐름

1. 환경 기록과 관련 작업 이력을 읽는다.
2. 설정·코드를 수정하거나 조사 결과를 정리한다. 자동화는 `config/automations/<주제>/`에 YAML과 README를 함께 보관한다.
3. 가능한 검증을 수행하고 미검증 항목을 구분한다.
4. `docs/history/YYYY-MM-DD-주제.md`에 결과를 남기고 목록에 연결한다. 자동화 작업은 해당 폴더의 README에도 기록 링크를 추가한다.
5. 구축기 작성 요청이 있으면 관련 기록을 바탕으로 `blog/YYYY-MM-DD-주제.md`를 작성한다.

로컬 파일 작성, Home Assistant 구성 검사, 실기기 동작 확인은 각각 구분해 기록한다.
토큰·비밀번호·개인 위치 등은 Git과 공개 글에 넣지 않는다.

## 시작할 때 채울 정보

설치 방식과 Home Assistant 버전, 주요 기기·통합 목록, 기존 설정 파일의 관리 방식을 확인한다.
정보가 없는 항목은 추정해서 채우지 않고 `미확인`으로 남긴다.
첫 작업은 [프로젝트 초기 구성 기록](docs/history/2026-10-03-project-setup.md)에 남겼다.
