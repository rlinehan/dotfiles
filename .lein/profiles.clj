{:user {:plugins [

                 ; [com.jakemccrary/lein-test-refresh "0.3.9" :exclusions [org.clojure/clojure]]
                  ;[lein-difftest "2.0.0"]
                  [lein-pprint "1.1.1"]
                  [venantius/ultra "0.3.3" :exclusions [org.clojure/clojure]]
                  ]
        :ultra  {:color-scheme :solarized_dark}
        :whidbey  {:width 80}
        ;:repl-options  {:nrepl-middleware  [io.aviso.nrepl/pretty-middleware]}
        ;:injections [(require 'pjstadig.humane-test-output)
        ;             (pjstadig.humane-test-output/activate!)]
        :dependencies [[xrepl "0.1.0"]
        ;               [pjstadig/humane-test-output "0.7.0"]
;                       [io.aviso/pretty "0.1.12" :exclusions  [org.clojure/clojure]]
                       [org.thnetos/cd-client "0.3.6" :exclusions [cheshire]]
                       ]}}
