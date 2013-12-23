---
layout: post
title: "[번역]GitHub / Collaborating / Pull 요청 만들기"
description: ""
category: "lesson"
tags: [git, github]
---
{% include JB/setup %}

다음의 [Creating a pull request](https://help.github.com/articles/creating-a-pull-request) 번역하였습니다.

---

### Pull 요청 만들기

Pull 요청을 열기 전에 로컬 저장소에 브랜치를 만들어야 하고, 로컬 저장소에 커밋을 해야 하고 그리고 GitHub의 fork 또는 저장소에 브랜치를 Push해야 합니다.

1. Push한 저장소로 이동합니다.

2. 저장소에 있는 **Compare and Review**를 클릭합니다.<br/><img src="https://github-images.s3.amazonaws.com/help/pull-request-start-review-button.png" alt="Pull Request button" style="width: 400px;"/><br /><br />

3. 비교 페이지로 바로 도착할 수 있습니다. Head 브랜치 드랍다운을 사용하여 합칠 새로운 브랜치를 고르기 위해 상단에 있는 **Edit**를 클릭할 수 있습니다.<br/><img src="https://github-images.s3.amazonaws.com/help/pullrequest-headbranch.png" alt="Head branch selection dropdown" style="width: 400px;"/><br/><br/>

4. Base 브랜치 드랍다운을 사용하여 합칠 타켓 브랜치를 선택합니다.<br/><img src="https://github-images.s3.amazonaws.com/help/pullrequest-basebranch.png" alt="Base branch selection dropdown" style="width: 400px;"/><br/><br/>

5. 제안받은 변경사항을 검토합니다.

6. **Click to create a pull request for this comparison**를 클릭합니다.<br/><img src="https://github-images.s3.amazonaws.com/help/pull-request-click-to-create.png" alt="Link to turn a discussion into a pull request" style="width: 400px;"/><br/><br/>

7. Pull 요청을 위해 제목과 설명을 입력합니다.<br/><img src="https://github-images.s3.amazonaws.com/help/pullrequest-description.png" alt="Pull Request description page" style="width: 400px;"/><br/><br/>

8. **Send pull request**를 클릭합니다.<br/><img src="https://github-images.s3.amazonaws.com/help/pullrequest-send.png" alt="Send Pull Request button" style="width:200px;"/><br/><br/>

Pull 요청이 검토된 후에 [저장소에 합치기](https://help.github.com/articles/merging-a-pull-request)를 할 수 있습니다.



[Pull Request button img]: https://github-images.s3.amazonaws.com/help/pull-request-start-review-button.png
[Head branch selection dropdown img]: https://github-images.s3.amazonaws.com/help/pullrequest-headbranch.png
[Base branch selection dropdown img]: https://github-images.s3.amazonaws.com/help/pullrequest-basebranch.png
[Link to turn a discussion into a pull request img]: https://github-images.s3.amazonaws.com/help/pull-request-click-to-create.png
[Pull Request description page img]: https://github-images.s3.amazonaws.com/help/pullrequest-description.png
[Send Pull Request button img]: https://github-images.s3.amazonaws.com/help/pullrequest-send.png