# mcp-toss Home Assistant 앱

이 앱은 `mcp-toss`의 stdio MCP 서버를 Supervisor가 관리하는 컨테이너에서 실행하고,
`mcp-proxy`로 Home Assistant MCP 통합이 사용할 SSE 엔드포인트를 제공한다.

## 설치

1. 이 폴더의 내용을 Home Assistant OS 호스트의 `/addons/mcp-toss`에 복사한다.
2. Settings → Apps에서 로컬 앱 저장소를 새로 고친다.
3. `mcp-toss` 앱을 설치한다.
4. 구성 화면에 `toss_client_id`, `toss_client_secret`, 선택 사항인 `toss_account_no`를 입력한다.
5. 앱을 시작한다.

자격 증명은 저장소나 자동화 YAML에 넣지 않는다.

## Home Assistant MCP 연결

앱 내부 네트워크 주소는 로컬 앱 저장소와 slug에 따라 달라질 수 있다.
일반적인 로컬 앱 이름은 `local-mcp-toss`이며, MCP 통합에는 다음 형태의 주소를 사용한다.

```text
http://local-mcp-toss:8080/sse
```

Supervisor 로그에서 앱이 `mcp-proxy`와 `mcp-toss`를 정상적으로 시작했는지 확인한 뒤 연결한다.
