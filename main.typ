#set document(
	title: "Szemeszter Összegző",
	date: datetime(year: 2026, month: 5, day: 18),
)

#set page(
	margin: 0pt,
)

#set text(
	font: ("IBM Plex Sans", "IBM Plex Math"),
	size: 12pt,
	lang: "hu",
)

#let fixed2(x) = {
	let y = calc.round(x * 100)
	let whole = calc.floor(y / 100)
	let frac = calc.abs(y - whole * 100)

	str(whole) + "." + if frac < 10 {
		"0" + str(frac)
	} else {
		str(frac)
	}
}

#let average(rows) = {
	let weighted = 0
	let credits = 0

	for r in rows {
		if type(r.grade) == int and r.credit > 0 {
			weighted += r.grade * r.credit
			credits += r.credit
		}
	}

	if credits == 0 {
		none
	} else {
		weighted / credits
	}
}

#let mark(x) = box(text(x, fill: white))

#let bool-cell(x) = {
	if x == true {
		table.cell(mark(sym.checkmark), fill: cmyk(86%, 25%, 100%, 12%))
	} else if x == false {
		table.cell(mark("X"), fill: cmyk(8%, 100%, 100%, 0%))
	} else {
		table.cell(mark[---], fill: cmyk(80%, 60%, 0%, 0%))
	}
}

#let grade-cell(x) = {
	if type(x) == int or type(x) == float {
		str(x)
	} else {
		[---]
	}
}

#let sem-table(nr, rows) = {
	let avg = average(rows)

	align(center, block(
		stroke: 1pt + black,
		inset: 1em,
		[
			#let orn = text("⚜", 2em)

			#place(orn)
			#place(right, orn)

			#v(0.5em)

			#align(center + horizon)[#nr. Szemeszter]

			#v(0.25em)

			#table(
				columns: (5cm, 2cm, 2cm, 2cm),
				align: (left, center, center, center),
				stroke: 1pt + black,
				inset: 0.666em,

				table.header(
					[*Tárgy*],
					[*Aláírás*],
					[*Vizsga*],
					[*Jegy*],
				),

				..rows.map(r => (
					[#r.subject],
					[#bool-cell(r.signature)],
					[#bool-cell(r.exam)],
					[#grade-cell(r.grade)],
				)).flatten(),

				table.cell(colspan: 3)[*Átlag*],
				table.cell(align: center)[
					#if avg == none {
						[?.??]
					} else {
						fixed2(avg)
					}
				],
			)
		],
	))
}

#let load-sem(nr) = json("sem" + str(nr) + ".json")

#let semesters = range(1, 7).map(load-sem)

#for i in range(0, semesters.len(), step: 2) {
	v(1fr)
	sem-table(i + 1, semesters.at(i))
	v(1fr)

	if i + 1 < semesters.len() {
		sem-table(i + 2, semesters.at(i + 1))
		v(1fr)
	}

	pagebreak(weak: true)
}
