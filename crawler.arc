; Получить список коммитеров
; https://api.github.com/repos/svetlyak40wt/dotfiler/commits

; Получить список репозиториев коммитера
; https://api.github.com/users/svetlyak40wt/repos

; Получить список файлов репозитория
; https://api.github.com/repos/svetlyak40wt/dotfiler/git/trees/master?recursive=1
; Если есть .arc файлы, добавить в список и перейти к шагу 1

; тупо через поиск гитхаба
; https://api.github.com/search/repositories?q=language:arc&sort=stars&order=desc
; но работает плохо, например тут всего 1 .arc файл, да и то там про arc нет ничего
; При этом GitHub показывает что код на 80% из Arc
; https://github.com/bixo/bixo

; http://developer.github.com/v3/search/#search-repositories

; Интересное
; https://github.com/sacado/arc2c - Arc Lisp to C compiler
; https://github.com/awwx/ar - заброшенная попытка реализовать платформу для создания языков, подобных Arc
; https://github.com/evanrmurphy/lava-script - заброшенная попытка сделать Arc, компилирующийся в JavaScript
; https://github.com/arclanguage/rainbow-js - вариант Arc для запуска в браузере (2 года не обновлялся)
; https://github.com/akkartik/arc - развивающийся форк Arc3.1
; https://github.com/hasenj/sehm - s-expression based html markup for arc
; https://github.com/esden/arc/blob/2686877db06809d1ba1280fe417c3ff02ef02e58/lib/module/python.arc - форк Arc для встраиваемых систем (и у них есть система модулей)
; https://github.com/hchbaw/swank-arc - попытка сделать swank сервер для arc (более 4 лет не обновлялось)
; https://github.com/shader/metagame какая-то вебовая игрушка на arc (2 года)
; https://github.com/mgiken японская компания, использующая arc. У них много библиотечек

; GitHub Paging:
; Link: <https://api.github.com/repositories/3935/commits?top=master&last_sha=fbd3354db3bb4f5598222a78544ecf30e66a14b2>; rel="next", <https://api.github.com/repositories/3935/commits?sha=master>; rel="first"

($ (require (file "lib/json.ss")))
($ (xdef read-json read-json))
($ (xdef write-json write-json))

(= oauth-token "f619c243b2fb7492e5da8abb89dfd75cf5812b29")

(load "lib/re.arc")

(def get-next-link (headers)
  (caar (rem not
        (map [re-match "Link: .*<(.*?)>; rel=\"next\".*" _]
             headers))))

(def parse-response (response)
  (w/instring f (cadr response) (read-json f)))

(def get-login (item)
  (let author (item 'author)
    (if author
        (author 'login))))


(def get-repo (item)
  (item 'full_name))


(def get-filename (item)
  (item 'path))


(def commiters (repo)
  (let url (+ "https://api.github.com/repos/" repo "/commits")
    (letf work (url)
          (if url
              (do
                (pr "Downloading " url #\newline)
                (withs (response (mkreq url nil "GET" nil (list (+ "Authorization: token " oauth-token)))
                        next-link (get-next-link (car response))
                        parsed-response (parse-response response))
                 (+ (map get-login
                         parsed-response)
                    (work next-link)))))
          (rem nil (dedup (work url))))))


(def repos (user)
  (let url (+ "https://api.github.com/users/" user "/repos")
    (letf work (url)
          (if url
              (do
                (pr "Downloading " url #\newline)
                (withs (response (mkreq url nil "GET" nil (list (+ "Authorization: token " oauth-token)))
                        next-link (get-next-link (car response))
                        parsed-response (parse-response response))
                 (+ (map get-repo
                         parsed-response)
                    (work next-link)))))
          (rem nil (dedup (work url))))))


(def files (repo)
  (let url (+ "https://api.github.com/repos/" repo "/git/trees/HEAD?recursive=1")
    (letf work (url)
          (if url
              (do
                (pr "Downloading " url #\newline)
                (withs (response (mkreq url nil "GET" nil (list (+ "Authorization: token " oauth-token)))
                        next-link (get-next-link (car response))
                        parsed-response (parse-response response))
                 (+ (map get-filename
                         (parsed-response 'tree))
                    (work next-link)))))
          (rem nil (dedup (work url))))))


https://api.github.com/repos/svetlyak40wt/dotfiler/git/trees/master?recursive=1