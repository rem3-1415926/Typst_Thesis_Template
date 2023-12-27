

#let thesis(
	// Title of the thesis or work
	thesis_title: "Some Thesis",

	// A Short description below the title on the cover
	sub_title: "Engineering an advanced innovation",

	// Thesis author or authors. Use array syntax.
	authors: ("Author1", ),

	// Advisor or Professor. Use array syntax.
	advisors: ("Prof. Dr. Giv Goodgrade", ),

	// University
	university: "College of Winterhold",

	// Paper size. Must not be capitalized.
	paper: "a4",

	// Margins. Header and footer will cut somewhat into them
	margins: (
		top: 3.0cm,
		bottom: 2.5cm,
		outside: 1.5cm,
		inside: 2.5cm
	),

	// List of preferred fonts to use. First available will be taken.
	fonts: (
		"Trebuchet MS",
		"linux libertine",
	),

	// Default text font size
	font_size: 10pt,

	// For general language settings (https://typst.app/docs/reference/text/text/#parameters-lang)
	lang: "en", 

	// Optional, replaces the auto-generated if given
	titlepage: none,

	// Everything before the Table of Contents
	frontmatter: [],

	// Everything after main content,
	appendix: [],

	body
) = {  // Layout etc ----------------------------------------------------------
	set document(
		title: thesis_title,
		author: authors,
	)

	set par(justify: true)
	set text(
		font: fonts,
		size: font_size,
		lang: lang,
	)

	let header = locate(loc => {
		let currentpage = loc.page()
		let target_page = -1
		let next_heading = [
			#let elems = query(
				selector(heading.where(level: 1)).after(loc),
				loc
			)
			#if elems != () {
				target_page = elems.at(0).location().page()
				elems.first().body
			}
		]
		if (currentpage == target_page) { return }  // No header on Title page
		let last_heading = [
			#let elems = query(
				selector(heading.where(level: 1)).before(loc),
				loc
			)
			#if elems != () {
				target_page = elems.at(-1).location().page()
				elems.last().body
			}
		]
		grid(
			columns: (1fr, 1fr, 1fr),
			align(left)[
				#if calc.even(currentpage) [_ #last_heading _] else [_ #thesis_title _]],
			[],
			align(right)[
				#if calc.odd(currentpage) [_ #last_heading _] else [_ #thesis_title _]]
		)
		pad(y:-0.75em)[#line(length: 100%, stroke: 0.5pt)]
	})

	let footer = locate(loc => {
		let currentpage = counter(page).at(loc).at(0)
		// let total_pages = query(<document_end>, loc).at(0).location().page()
		let total_pages = counter(page).at(query(<document_end>, loc).at(0).location()).at(0)
		let numbering = [#currentpage / #total_pages]
		let txt_authors = [
				#for a in authors.slice(0,-1) [#a, ]
				#authors.at(-1)
		]
		let date = [#datetime.today().display("[day]. [Month repr:long]. [year]")]
		pad(y:-0.5em)[#line(length: 100%, stroke: 0.5pt)]
		grid(
			columns: (1fr, 1fr, 1fr),
			align(left)[#if calc.even(currentpage) [#numbering] else [#date]],
			align(center)[#txt_authors],
			align(right)[#if calc.odd(currentpage) [#numbering] else [#date]],
		)
	})

	let footer_front = locate(loc => {
		let page_counter = counter(page).at(loc).at(0)
		align(center)[#numbering("(I)", page_counter)]
	})

	set page(
		paper: "a4",
		binding: left,
		margin: margins,
		header: header,
		header-ascent: 30%,
		footer: footer,
		footer-descent: 30%,
	)

	set heading(
		supplement: "Chapter",
		numbering: (..numbers) =>
			if numbers.pos().len() <= 3 {
				return numbering("1.", ..numbers)
			}
	)

	show heading: it => block[
		#if it.level == 1{
			return{
				// pagebreak is defined locally
				text(size: 24pt)[#it]
				pad(top: -0.5em, bottom: 1em)[#line(length: 100%, stroke: 2pt)]
			}
		} else {
			it
		}
	]

	show outline.entry.where(
		level: 1
		): it => {
		v(12pt, weak: true)
		strong(it)
	}

	set math.equation(numbering: "(1)")


	// Title page -------------------------------------------------------------
	if (titlepage != none) {
		set page(header: none, footer: none)
		titlepage
	}
	else {
		set page(header: none, footer: none)
		align(center + horizon)[
			#text(3em)[*#thesis_title*]
			#v(1.5em, weak: true)	
			#text(2em, sub_title)
		] 
		align(left + bottom)[
			#set text(size: 12pt)
			*#if(authors.len() > 1) [Authors] else [Author]*
			#v(0.6em, weak: true)
			#for a in authors.slice(0,-1) [#a, ]
			#authors.at(-1)
			#v(0.6em, weak: true)
			*#if(advisors.len() > 1) [Advisors] else [Advisor]*
			#v(0.6em, weak: true)
			#for a in advisors.slice(0,-1) [#a, ]
			#advisors.at(-1)
			#v(1.2em, weak: true)
			#university
			#v(0.6em, weak: true)
		]
	}

	// Frontmatter ------------------------------------------------------------
	[
		#set page(footer: footer_front)
		#counter(page).update(1)

		// use odd side pagebreak for frontmatter
		#show heading: it => block[
			#if it.level == 1{
				return{pagebreak(weak: true, to: "odd"); it}
			} else {it}
		]

		#frontmatter

		#outline(
			depth: 2,
			indent: true
		)
	]

	// Main content -----------------------------------------------------------
	{
		// use any side pagebreak for main content
		show heading: it => block[
			#if it.level == 1{
				return{
					pagebreak(weak: true)
					it
				}
			} else {
				it
			}
		]

		// pagebreak(weak: true, to: "odd")  // yeah that does exactly nothing fml
		counter(page).update(1)

		body

		// Bibliography
		[= Bibliography]
		bibliography(
			title: none,  // doesn't follow heading formatting
			("bib/Hayagriva.yml", "bib/BibLaTex.bib"),
		)
		// v(15cm)
		// lorem(300)

		[#circle(radius: 0pt, stroke: none)
		// void structures help with pagebreaks. Very interesting.
		<bibliography_end>
		#circle(radius: 0pt, stroke: none)
		]
	}


	// Appendix ---------------------------------------------------------------
	{
		let app_entries = state("x", ())
		[
			#pagebreak(weak: true, to:"odd")
			= Appendix
			// #[#circle(radius: 0pt, stroke: none)]
			#text(size: 12pt, weight: "bold")[
				#locate(loc => {
					let all_app_entries = app_entries.at(query(<document_end>, loc)
						.first()
						.location()
					)
					return for (i, ae) in all_app_entries.enumerate() [
						#v(1em)
						#grid(columns: (1fr, 5em),
							[#numbering("A", i+1) #ae.at(0)], 
							align(right)[#ae.at(1)]
						)
					]
				})
			]
			// apparently does not work:
			// #outline(
			// 	title: "Appendix Contents",
			// 	target: heading.where(supplement: "Appendix ")
			// )
		] 

		counter(heading).update(0)
		set heading(
			supplement: "Appendix",
			outlined: false,
			bookmarked: true,
			numbering: (..numbers) =>
				if numbers.pos().len() <= 3 {
					return numbering("A.1.", ..numbers)
				},
		)
		show heading: it => block[
			#if it.level == 1{
				// use odd side pagebreak for main content. 
				// This is because pagebreak here kills manual pagebreaks needed for A3
				return{[#pagebreak(weak: true, to: "odd") #it #locate(loc => {
					let pn = counter(page).at(loc).at(0)
					// add entry to Appendix outline
					app_entries.update( x => {x.push((it.body, pn)); x}) 
					})
				]}
			} else{
				it
			}
		]

		appendix

		// void structure helps with this bug. (label otherwise on wrong page)
		[#circle(radius: 0pt, stroke: none)<document_end>] 
	}
}