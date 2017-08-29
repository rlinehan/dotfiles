{:user {:plugins [
                  ;[pjstadig/humane-test-output "0.7.1"]
                  ;[venantius/ultra "0.3.4" :exclusions [org.clojure/clojure]]
                  ;[lein-difftest "2.0.0"]
                  ]
        :ultra  {:color-scheme :solarized_dark}
        :whidbey  {:width 80}
        :dependencies [;[xrepl "0.1.0"]
                       ]
        :puppetserver-heap-size "5G"
        }
  :ruth {:plugins [[venantius/ultra "0.3.4" :exclusions [org.clojure/clojure]]]}}
