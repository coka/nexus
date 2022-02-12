(ns handheld-halting
  (:require [clojure.string :as string]))

(defn line->instruction [line]
  (let [[operation argument] (string/split line #" ")]
    [(keyword operation) (Integer/parseInt argument)]))

(defn input->code [input]
  (->> input
       string/split-lines
       (map line->instruction)
       (reduce conj [])))

(defn execute [code line-number]
  (let [instruction (get code line-number)
        [operation argument] instruction]
    (case operation
      :acc [(inc line-number) argument]
      :jmp [(+ line-number argument) 0]
      :nop [(inc line-number) 0])))

(defn run-boot-code [code]
  (let [loc (count code)]
    (loop [executed #{}
           line-number 0
           accumulator 0]
      (if (or (contains? executed line-number) (<= loc line-number))
        accumulator
        (let [[next-line v] (execute code line-number)]
          (recur (conj executed line-number)
                 next-line
                 (+ accumulator v)))))))

(defn terminates? [code]
  (let [loc (count code)]
    (loop [executed #{}
           line-number 0]
      (cond (contains? executed line-number) false
            (<= loc line-number) true
            :else (let [[next-line] (execute code line-number)]
                    (recur (conj executed line-number) next-line))))))

(defn flop [instruction]
  (let [[op arg] instruction]
    (case op
      :jmp [:nop arg]
      :nop [:jmp arg]
      op)))

(defn patch [code line]
  (assoc code line (flop (get code line))))

(defn repair-boot-code [code]
  (->> code
       (keep-indexed (fn [i [op _]] (when (or (= op :jmp) (= op :nop)) i)))
       (map (fn [line] (patch code line)))
       (drop-while (fn [patched-code] (not (terminates? patched-code))))
       first))
