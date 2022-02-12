function getLines(input) {
  return input.trim().split("\n");
}

function createCaveMap(lines) {
  return lines.reduce((acc, line) => {
    const [c1, c2] = line.split("-");
    return {
      ...acc,
      [c1]: acc[c1] ? [...acc[c1], c2] : [c2],
      [c2]: acc[c2] ? [...acc[c2], c1] : [c1],
    };
  }, {});
}

const startName = "start";
const endName = "end";

const isStart = (cave) => cave === startName;
const isEnd = (cave) => cave === endName;
const isBig = (cave) => cave.toUpperCase() === cave;

function countPaths(caveMap, at, visited, paths, canVisitDouble) {
  if (isEnd(at)) return 1;
  const connections = caveMap[at];
  let subpaths = 0;
  for (const to of connections) {
    if (isStart(to)) continue;
    const newVisited = isBig(at) ? visited : visited.concat(at);
    const seen = visited.includes(to);
    if (seen && canVisitDouble) {
      subpaths += countPaths(caveMap, to, newVisited, paths, false);
    } else if (!seen) {
      subpaths += countPaths(caveMap, to, newVisited, paths, canVisitDouble);
    }
  }
  return subpaths;
}

const exampleInput = `
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
`;

let caveMap, paths;

caveMap = createCaveMap(getLines(exampleInput));
paths = countPaths(caveMap, "start", [], 0);
console.log(`Part One (example input) :::   ${paths} (expected   226)`);
paths = countPaths(caveMap, "start", [], 0, true);
console.log(`Part Two (example input) :::  ${paths} (expected  3509)`);

const fs = require("fs");
const input = fs.readFileSync("inputs/12.txt").toString();

caveMap = createCaveMap(getLines(input));
paths = countPaths(caveMap, "start", [], 0);
console.log(`Part One                 :::  ${paths} (expected  3230)`);
paths = countPaths(caveMap, "start", [], 0, true);
console.log(`Part Two                 ::: ${paths} (expected 83475)`);
