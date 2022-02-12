(ns rain-risk-test
  (:require [rain-risk :as subject]
            [test-utilities :refer [with-input]]
            [clojure.test :refer [deftest is]]))

(deftest move-ship
  (is (= 25 (subject/move-ship ["F10" "N3" "F7" "R90" "F11"])))
  (is (= 2228 (with-input "12" subject/move-ship))))

(deftest move-ship-with-waypoint
  (is (= 286 (subject/move-ship-with-waypoint ["F10" "N3" "F7" "R90" "F11"])))
  (is (= 42908 (with-input "12" subject/move-ship-with-waypoint))))
