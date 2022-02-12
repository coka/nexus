const fs = require("fs");
const input = fs.readFileSync("inputs/13.txt").toString();
const lines = input.trim().split("\n");
const blankLineIndex = lines.findIndex((line) => line === "");
const dots = lines.slice(0, blankLineIndex).map((line) => {
  const [x, y] = line.split(",");
  return [parseInt(x), parseInt(y)];
});
const instructions = lines.slice(blankLineIndex + 1).map((line) => {
  const [text, n] = line.split("=");
  const axis = text[text.length - 1];
  return [axis, parseInt(n)];
});

function fold(dots, instruction) {
  const [axis, amount] = instruction;
  const idx = axis === "x" ? 0 : 1;
  const innerDots = dots.filter((d) => d[idx] < amount);
  const outerDots = dots.filter((d) => d[idx] > amount);
  outerDots.forEach((d) => {
    if (idx === 0) {
      const dist = d[0] - amount;
      const ux = amount - dist;
      const y = d[1];
      if (innerDots.findIndex((id) => id[0] === ux && id[1] === y) === -1) {
        innerDots.push([ux, y]);
      }
    } else {
      const dist = d[1] - amount;
      const x = d[0];
      const uy = amount - dist;
      if (innerDots.findIndex((id) => id[0] === x && id[1] === uy) === -1) {
        innerDots.push([x, uy]);
      }
    }
  });
  return innerDots;
}

// --- Part One ---
const foldedDots = fold(dots, instructions[0]);
console.log(foldedDots.length);

// --- Part Two ---
const result = instructions.reduce(fold, dots);
let width = 0;
let height = 0;
for (const dot of result) {
  const [x, y] = dot;
  if (x + 1 > width) width = x + 1;
  if (y + 1 > height) height = y + 1;
}
for (let j = 0; j < height; j++) {
  let line = "";
  for (let i = 0; i < width; i++) {
    if (result.findIndex((d) => d[0] === i && d[1] === j) === -1) {
      line += ".";
    } else {
      line += "#";
    }
  }
  console.log(line);
}
