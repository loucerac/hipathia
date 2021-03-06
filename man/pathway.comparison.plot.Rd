% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chart.R
\name{pathway.comparison.plot}
\alias{pathway.comparison.plot}
\title{Plots pathway with colored significant paths}
\usage{
pathway.comparison.plot(comp, metaginfo, pathway, conf = 0.05,
  node.colors = NULL, colors = "classic")
}
\arguments{
\item{comp}{Comparison data frame as returned by the \code{do.wilcox}
function.}

\item{metaginfo}{Pathways object.}

\item{pathway}{Name of the pathway to be plotted.}

\item{conf}{Level of significance of the comparison for the adjusted
p-value. Default is 0.05.}

\item{node.colors}{List, named by the pathway name, including the
color of each node for each pathway.}

\item{colors}{Either a character vector with 3 colors (indicating,
in this order, down-regulation, non-significance and up-regulation colors)
or a key name indicating the color scheme to be used. Options are:}
}
\value{
Image in which a pathway is ploted. Edges are colored so that the
UP- and DOWN-activated subpathways are identified.
}
\description{
Plots the layout of a pathway, coloring the significant subpathways
in different colors depending on whether they are significantly up- or
down-regulated. Nodes may be also colored providing a suitable list of
colors for each node. Function \code{node.color.per.de}
assigns colors to the nodes depending on their differential expression.
}
\section{Slots}{

\describe{
\item{\code{classic}}{ColorBrewer blue, white and colorBrewer red.}

\item{\code{hipathia}}{Hipathia predefined color scheme: Green, white and orange.
By default \code{classic} color scheme is applied.}
}}

\examples{
data(comp)
pathways <- load.pathways(species = "hsa", pathways.list = c("hsa03320",
"hsa04012"))
pathway.comparison.plot(comp, metaginfo = pathways, pathway = "hsa03320")

data(results)
data(brca_design)
data(path_vals)
sample_group <- brca_design[colnames(path_vals),"group"]
colors_de <- node.color.per.de(results, pathways,
sample_group, "Tumor", "Normal")
pathway.comparison.plot(comp, metaginfo = pathways, pathway = "hsa04012",
node.colors = colors_de)

}
