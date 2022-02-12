(ns rambunctious-recitation)

(defn update-game [[spoken turn last-number]]
  (let [[last-spoken before-that] (get spoken last-number)
        next-turn (inc turn)]
    (if (nil? before-that)
      [(assoc spoken 0 [next-turn (first (get spoken 0))])
       next-turn
       0]
      (let [next-number (- last-spoken before-that)]
        [(assoc spoken next-number [next-turn (first (get spoken next-number))])
         next-turn
         next-number]))))

(defn recite [starting-numbers final-turn]
  (let [spoken (reduce-kv #(assoc %1 %3 [(inc %2)]) {} starting-numbers)
        last-number (last starting-numbers)
        turn (count starting-numbers)
        game [spoken turn last-number]
        final-game (last (take (- final-turn (dec turn)) (iterate update-game game)))
        [_ _ result] final-game]
    result))
