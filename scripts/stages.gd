extends RefCounted
## Authored layouts share dimensions and spawn/house contracts with the base.
const INFO = [
	{"name":"PÓRTICO NEON", "primary":"45d4ef", "secondary":"e349a4", "wall":"44365e", "speed":1.0, "par":110.0, "challenge":"Capture 2 fantasmas", "hint":"E: escudo por 8s, absorve um contato."},
	{"name":"JARDIM IÔNICO", "primary":"5becac", "secondary":"58baff", "wall":"234f50", "speed":1.06, "par":125.0, "challenge":"Conclua sem perder vidas", "hint":"R: ímã por 6s. Atrai apenas pontos vizinhos."},
	{"name":"REATOR SOLAR", "primary":"ffbf62", "secondary":"ff597e", "wall":"63384c", "speed":1.12, "par":140.0, "challenge":"Vença uma aposta com Q", "hint":"Use o escudo para preparar sua caçada."}
]
const GARDEN = [
	"#################", "#o......#......o#", "#.#..##.#.##..#.#",
	"#...#...........#", "#.##...###...##.#", "#..#.#.....#....#",
	"###.###...###.###", "#....#.....#.#..#", "#.##.#..#..#.##.#",
	"#...............#", "#.#..##.#.##..#.#", "#o.....#.......o#",
	"#################"
]
const REACTOR = [
	"#################", "#o..#.......#..o#", "#.##.#..#..#.##.#",
	"#.........#.....#", "#..#.#.###.#.#..#", "#...##.....##...#",
	"###..##...##..###", "#.#..#.....#..#.#", "#.##.#.###.#.##.#",
	"#.....#.........#", "#.##.##.#.##.##.#", "#o..#.......#..o#",
	"#################"
]
static func layout(index:int, base:Array) -> Array:
	return [base, GARDEN, REACTOR][clampi(index,0,2)].duplicate()

static func medal_count(mask:int) -> int:
	return int(bool(mask & 1)) + int(bool(mask & 2)) + int(bool(mask & 4))
