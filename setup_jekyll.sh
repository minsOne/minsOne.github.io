#!/bin/zsh

# 1. Homebrew 확인
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew가 설치되어 있지 않습니다. https://brew.sh/ 에서 먼저 설치해주세요."
    exit 1
fi

# 2. rbenv 및 ruby-build 설치
echo "📂 rbenv 및 ruby-build 설치 중..."
brew install rbenv ruby-build

# 3. .zshrc 설정 (이미 있으면 중복 추가 안 함)
if ! grep -q 'rbenv init' ~/.zshrc; then
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc
    echo "✅ ~/.zshrc에 rbenv 설정이 추가되었습니다. 새 터미널을 열거나 source ~/.zshrc를 실행하세요."
fi

# 현재 쉘 세션에 rbenv 바로 적용
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# 4. 루비 설치 (3.2.2 버전 기준, 필요시 변경 가능)
RUBY_VERSION="3.2.2"
echo "💎 Ruby $RUBY_VERSION 설치 중... (시간이 다소 소요될 수 있습니다)"
rbenv install $RUBY_VERSION --skip-existing
rbenv local $RUBY_VERSION

# 5. Bundler 설치
echo "📦 Bundler 2.2.31 설치 중..."
gem install bundler -v 2.2.31

# 6. 프로젝트 의존성 설치
echo "📥 프로젝트 라이브러리 설치 중..."
bundle install

echo "🚀 모든 설정이 완료되었습니다! Jekyll 서버를 실행합니다."
bundle exec jekyll serve --drafts
