

#import "template.typ": thesis
#import "sec/abstract.typ": abstract
#import "sec/acknowledgement.typ": acknowledgement
#import "sec/appendix.typ": appendix

/*
#let titlepage = [
	#set align(center+horizon)
	#text(size: 64pt)[Mün or bust]

	#text(size: 32pt)[A Thesis about absolutely nothing.]
]
*/

#let frontmatter = {
	abstract
	acknowledgement
}

#show: thesis.with(
	thesis_title: "Mün or bust",
	sub_title: "Some awesome thesis",
	authors: (
		"Jebediah Kerman",
		"Valentina Kerman",
	),
	university: "OST - Ostschweizer Fachhochschule, Campus Rapperswil",

	// titlepage: titlepage,
	frontmatter: frontmatter,
	appendix: appendix,
)


#include("sec/sec1.typ")
#include("sec/sec2.typ")
#include("sec/authorship.typ")