(ns rambunctious-recitation-test
  (:require [rambunctious-recitation :as subject]
            [clojure.test :refer [deftest is]]))

(deftest recite
  (is (=  436 (subject/recite [0 3 6] 2020)))
  (is (=    1 (subject/recite [1 3 2] 2020)))
  (is (=   10 (subject/recite [2 1 3] 2020)))
  (is (=   27 (subject/recite [1 2 3] 2020)))
  (is (=   78 (subject/recite [2 3 1] 2020)))
  (is (=  438 (subject/recite [3 2 1] 2020)))
  (is (= 1836 (subject/recite [3 1 2] 2020)))
  (is (=  447 (subject/recite [8 11 0 19 1 2] 2020))))

(deftest recite-hardcore
  (is (=   175594 (subject/recite [0 3 6] 30000000)))
  (is (=     2578 (subject/recite [1 3 2] 30000000)))
  (is (=  3544142 (subject/recite [2 1 3] 30000000)))
  (is (=   261214 (subject/recite [1 2 3] 30000000)))
  (is (=  6895259 (subject/recite [2 3 1] 30000000)))
  (is (=       18 (subject/recite [3 2 1] 30000000)))
  (is (=      362 (subject/recite [3 1 2] 30000000)))
  (is (= 11721679 (subject/recite [8 11 0 19 1 2] 30000000))))
