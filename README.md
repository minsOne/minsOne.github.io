# minsone.github.io

## 로컬 개발 환경 설정 (Mac)

이 프로젝트는 Jekyll을 사용하여 구축되었습니다. 로컬에서 서버를 띄워 포스팅을 미리 보려면 아래 단계를 따르세요.

### 1. 자동 설정 스크립트 실행
프로젝트 루트에 포함된 `setup_jekyll.sh` 스크립트를 사용하면 `rbenv`, `Ruby`, `Bundler` 및 필요한 모든 라이브러리를 한 번에 설치하고 서버를 실행합니다.

```bash
# 실행 권한 부여 (필요한 경우)
chmod +x setup_jekyll.sh

# 환경 설정 및 서버 실행
./setup_jekyll.sh
```

### 2. 수동 서버 실행
설치가 이미 완료된 상태에서 서버만 다시 띄우고 싶을 때는 아래 명령어를 사용하세요.

```bash
# 초안(Drafts) 포함 및 증분 빌드(--incremental)로 서버 실행
bundle exec jekyll serve --drafts --incremental
```

---

## License
MIT
