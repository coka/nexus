(require '[clojure.edn :as edn]
         '[clojure.string :refer [split split-lines]])

(defn parse-line [line]
  (let [[policy password] (split line #": ")
        [range letter] (split policy #" ")
        [n1 n2] (map edn/read-string (split range #"-"))]
    [n1 n2 (.charAt letter 0) password]))

(defn valid-for-sled-rental? [line]
  (let [[min max letter password] (parse-line line)
        occurrences (get (frequencies password) letter)]
    (when occurrences (<= min occurrences max))))

(defn valid-for-toboggan-corp? [line]
  (let [[i j letter password] (parse-line line)
        letter-at? #(if (= letter (.charAt password (dec %))) 1 0)]
    (= 1 (+ (letter-at? i) (letter-at? j)))))

(defn solve [input valid?]
  (count (filter valid? (split-lines input))))

(println (solve (slurp "input.txt") valid-for-sled-rental?))
(println (solve (slurp "input.txt") valid-for-toboggan-corp?))
