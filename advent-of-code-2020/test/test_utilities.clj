(ns test-utilities
  (:require [clojure.java.io :refer [reader]]))

(defn with-input [filename f]
  (with-open [rdr (reader (str "input/" filename ".txt"))]
    (->> rdr line-seq f)))
