extends RefCounted
## Authored layouts share dimensions and spawn/house contracts with the base.
const INFO = [
	{"name":"PÓRTICO NEON", "primary":"45d4ef", "secondary":"e349a4", "wall":"44365e", "speed":1.0, "par":110.0, "challenge":"Capture 2 fantasmas", "hint":"E: escudo por 8s, absorve um contato."},
	{"name":"JARDIM IÔNICO", "primary":"5becac", "secondary":"58baff", "wall":"234f50", "speed":1.06, "par":125.0, "challenge":"Conclua sem perder vidas", "hint":"R: ímã por 6s. Atrai apenas pontos vizinhos."},
	{"name":"REATOR SOLAR", "primary":"ffbf62", "secondary":"ff597e", "wall":"63384c", "speed":1.12, "par":140.0, "challenge":"Vença uma aposta com Q", "hint":"Use o escudo para preparar sua caçada."},
	{"name":"ANEL DE FUGA","primary":"a992ff","secondary":"4de8ef","wall":"39334f","speed":1.12,"par":140.0,"challenge":"Conclua sem dash","hint":"Três pares de túneis conectam as rotas."},
	{"name":"MERCADO FUGAZ","primary":"f48bc6","secondary":"ffe18c","wall":"513447","speed":1.15,"par":145.0,"challenge":"Faça uma cadeia de 4","hint":"As frutas móveis são mais rápidas e valiosas."},
	{"name":"NÚCLEO COLOSSAL","primary":"ff9063","secondary":"bd8cff","wall":"443044","speed":1.18,"par":200.0,"challenge":"Derrote o Colosso","hint":"Colete núcleos e use F na recuperação do Colosso."}
]
const PORTICO = [
	"#################", "#o.............o#", "#.##.##.#.##.##.#",
	"#...............#", "#.##..##.###.##.#", ".....##...##.....",
	"###.###...###.###", "#....#######....#", "#.##.#.###.#.##.#",
	".................", "#.##.##.#.##.##.#", "#o.............o#",
	"#################"
]
const GARDEN = [
	"#################", "#o......#......o#", "#.#..##.#.##..#.#",
	"#...#...........#", "#.##..##.##..##.#", "...#.##...##.....",
	"#.#.###...###.###", "#....#######.#..#", "#.##.#..#..#.##.#",
	".................", "#.#..##.#.##..#.#", "#o.............o#",
	"#################"
]
const REACTOR = [
	"#################", "#o..#.......#..o#", "#.##.#..#..#.##.#",
	"#.........#.....#", "#..#..##.###.#..#", "....###...###....",
	"###..##...##..###", "#.#..#######..#.#", "#.##...###.#.##.#",
	"......#..........", "#.##.##.#.##.##.#", "#o..........#..o#",
	"#################"
]
const RING=[
	"#################","#o.............o#","#.#..##.#.##..#.#",
	".................","#.##..##.##..##.#",".....##...##.....",
	"###.###...###.###","#....#######....#","#.##.#..#..#.##.#",
	".................","#.#..##.#.##..#.#","#o.............o#","#################"
]
const MARKET=[
	"#################","#o..#.......#..o#","#.#..##.#.##..#.#",
	"#...............#","#.##..##.###.##.#","...#.##...##.....",
	"#.#.###...###.###","#....#######.#..#","#.##.#.###.#.##.#",
	".................","#.#..##.#.##..#.#","#o.............o#","#################"
]
const CORE=[
	"#################","#o......#......o#","#.##.##.#.##.##.#",
	"#...............#","#..#..##.###.#..#","....###...###....",
	"###..##...##..###","#.#..#######..#.#","#.##...###.#.##.#",
	"......#..........","#.##.##.#.##.##.#","#o..........#..o#","#################"
]
static func layout(index:int) -> Array:
	var maps=[PORTICO,GARDEN,REACTOR,RING,MARKET,CORE]
	return maps[clampi(index,0,5)].duplicate()

static func medal_count(mask:int) -> int:
	return int(bool(mask & 1)) + int(bool(mask & 2)) + int(bool(mask & 4))
