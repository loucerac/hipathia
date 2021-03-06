##
## save.R
## Saving functions for package Hipathia
##
## Written by Marta R. Hidalgo, Jose Carbonell-Caballero
##
## Code style by Hadley Wickham (http://r-pkgs.had.co.nz/style.html)
## https://www.bioconductor.org/developers/how-to/coding-style/
##

##################################
# Save results
##################################

#' Save results to folder
#'
#' Saves results to a folder. In particular, it saves the matrix of subpathway
#' values, a table with the results of the provided comparison,
#' the accuracy of the results and the .SIF and attributes of the pathways.
#'
#' @param results Results object as returned by the \code{hipathia} function.
#' @param comp Comparison as returned by the \code{do.wilcoxon} function.
#' @param metaginfo Pathways object
#' @param output.folder Absolute path to the folder in which results will be
#' saved. If this folder does not exist, it will be created.
#' However, the parent folder must exist.
#'
#' @return Creates a folder in disk in which all the information to browse the
#' pathway results is stored.
#'
#' @examples
#' data(results)
#' data(comp)
#' pathways <- load.pathways(species = "hsa", pathways.list = c("hsa03320",
#' "hsa04012"))
#' save.results(results, comp, pathways, "output.results")
#'
#' @export
#'
save.results <- function(results, comp, metaginfo, output.folder){

    if(!file.exists(output.folder))
        dir.create(output.folder)
    # Write files
    utils::write.table(results$all$path.vals,
                       file = paste0(output.folder,"/all_path_vals.txt"),
                       col.names = TRUE,
                       row.names = TRUE,
                       quote = FALSE,
                       sep="\t")
    comp$path.name <- get.path.names(metaginfo, rownames(comp))
    utils::write.table(comp,
                       file = paste0(output.folder,"/all_path_stats.txt"),
                       col.names = TRUE,
                       row.names = TRUE,
                       quote = FALSE,
                       sep = "\t")

    if(!is.null( results$all$accuracy )){
        accu <- c(results$all$accuracy$total, results$all$accuracy$percent,
                  results$all$accuracy$by.path)
        names(accu) <- c("Accuracy", "Percent", names(accu)[3:length(accu)])
        utils::write.table(accu,
                           file = paste0(output.folder,"/accuracy.txt"),
                           col.names = TRUE,
                           row.names = TRUE,
                           quote = FALSE,
                           sep="\t")
    }

}


write.attributes <- function(this_comp, pathway, metaginfo, prefix,
                             moreatts_pathway=NULL, conf=0.05,
                             reverse_xref=NULL, exp=NULL){
    atts <- create.node.and.edge.attributes(this_comp, pathway, metaginfo,
                                            moreatts_pathway = moreatts_pathway,
                                            conf = conf,
                                            reverse_xref = reverse_xref,
                                            exp = exp)
    utils::write.table(atts$sif, file = paste0(prefix, ".sif"),
                       row.names = FALSE,
                       col.names = FALSE,
                       quote = FALSE,
                       sep = "\t")
    utils::write.table(atts$node_att, file = paste0(prefix, ".natt"),
                       row.names = FALSE,
                       col.names = TRUE,
                       quote = FALSE,
                       sep = "\t")
    utils::write.table(atts$edge_att, file = paste0(prefix, ".eatt"),
                       row.names = FALSE,
                       col.names = TRUE,
                       quote = FALSE,
                       sep = "\t")
}


create.node.and.edge.attributes <- function(comp, pathway, metaginfo,
                                            moreatts_pathway = NULL, conf=0.05,
                                            reverse_xref = NULL, exp = NULL){


    pathigraphs <- metaginfo$pathigraphs
    effector <- length(unlist(strsplit(rownames(comp)[1], split="-"))) == 3
    if(effector == TRUE){
        s <- pathigraphs[[pathway]]$effector.subgraphs
    }else{
        s <- pathigraphs[[pathway]]$subgraphs
    }
    ig <- pathigraphs[[pathway]]$graph

    if(is.null(V(ig)$type)) V(ig)$type <- "node"
    if(is.null(V(ig)$width)) V(ig)$width <- 15
    if(is.null(V(ig)$height)) V(ig)$height <- 5
    if(is.null(V(ig)$label.color)) V(ig)$label.color <- "black"
    if(is.null(V(ig)$label.cex)) V(ig)$label.cex <- 0.7
    # V(ig)$stroke.color <- find.node.colors(comp, s, ig, conf)[V(ig)$name]
    V(ig)$stroke.color <- "lightgrey"
    #V(ig)$stroke.color[grepl("func",V(ig)$name)] <- "white"
    V(ig)$stroke.size <- 2
    #V(ig)$stroke.size[grepl("func",V(ig)$name)] <- 0

    V(ig)$color <- "white"
    V(ig)$width[V(ig)$shape=="circle"] <- 15
    V(ig)$width[V(ig)$shape!="circle"] <- 22
    V(ig)$shape[V(ig)$shape=="rectangle" & !grepl("func", V(ig)$name)] <-
        "ellipse"
    V(ig)$shape[V(ig)$shape=="rectangle" & grepl("func", V(ig)$name)] <-
        "rectangle"
    V(ig)$width[grepl("func",V(ig)$name)] <- -1

    V(ig)$tooltip <- sapply(1:length(V(ig)), function(i){
        if(V(ig)$shape[i] == "ellipse"){
            paste(sapply(V(ig)$genesList[[i]], function(gen){
                if(!gen == "/"){
                    paste0("<a target='_blank' ",
                           "href='http://www.genome.jp/dbget-bin/www_bget?",
                           metaginfo$species, ":", gen, "'>", gen, "</a>")
                }else{
                    ""
                }
            }), collapse="<br>")
        }else if(V(ig)$shape[i] == "rectangle"){
            if(grepl("\n", V(ig)$label[i])){V(ig)$label[i]}else{""}
        }else if(V(ig)$shape[i] == "circle"){
            paste0("<a target='_blank' ",
                   "href='http://www.genome.jp/dbget-bin/www_bget?",
                   V(ig)$label[i], "'>", V(ig)$label[i], "</a>")
        }
    })

    natt <- cbind(V(ig)$name,
                  V(ig)$label,
                  10,
                  V(ig)$nodeX,
                  V(ig)$nodeY,
                  V(ig)$color,
                  V(ig)$stroke.color,
                  V(ig)$stroke.size,
                  V(ig)$shape,
                  V(ig)$type,
                  V(ig)$label.cex,
                  V(ig)$label.color,
                  V(ig)$width,
                  sapply(V(ig)$genesList, paste, collapse=","),
                  V(ig)$tooltip)
    colnames(natt) <- c("ID",
                        "label",
                        "labelSize",
                        "X",
                        "Y",
                        "color",
                        "strokeColor",
                        "strokeSize",
                        "shape",
                        "type",
                        "labelCex",
                        "labelColor",
                        "size",
                        "genesList",
                        "tooltip")
    rownames(natt) <- natt[,1]
    natt[,"label"] <- sapply(natt[,"label"], function(x){
        ul <- unlist(strsplit(x, split="\n"))
        if(length(ul) > 1){
            paste0(ul[1], ", ...")
        }else{
            ul[1]
        }
    })
    # Add
    if(!is.null(moreatts_pathway)){
        common.col <- colnames(moreatts_pathway)[colnames(moreatts_pathway)
                                                 %in% colnames(natt)]
        not.common.col <- colnames(moreatts_pathway)[!colnames(moreatts_pathway)
                                                     %in% colnames(natt)]
        for(col in common.col)
            natt[,col] <- moreatts_pathway[,col]
        if(!"strokeColor" %in% common.col){
            natt[,"strokeColor"] <- natt[,"color"]
            natt[natt[,"strokeColor"] == "white","strokeColor"] <- "lightgrey"
        }
        natt <- cbind(natt, moreatts_pathway[,not.common.col])
    }
    node_path_assoc <- matrix(0, nrow = nrow(natt), ncol = length(s))
    colnames(node_path_assoc) <- names(s)
    natt <- cbind(natt, node_path_assoc)

    sif <- c()
    eatt <- c()
    epath_assoc <- c()

    for(i in 1:length(s)){

        # get subgraph
        subgraph <- s[[i]]
        name <- names(s)[i]
        pname <- get.path.names(metaginfo, name)

        # sif
        raw_edges <- get.edgelist(subgraph)
        type <- c("activation","inhibition")[(E(subgraph)$relation == -1) + 1]
        edges <- cbind(raw_edges[,1], type, raw_edges[,2])
        sif <- rbind(sif, edges)

        # edge attributes
        eids <- apply(edges, 1, function(x) paste0(x, collapse = "_"))
        status <- comp[name,"UP/DOWN"]
        if("color" %in% colnames(comp)){
            color <- comp[name,"color"]
        } else {
            if( comp[name,"FDRp.value"] < conf){
                color <- c("#1f78b4","#e31a1c")[(status == "UP") + 1]
            } else {
                color <- "darkgrey"
            }
        }
        path_assoc <- matrix(0, nrow = nrow(edges), ncol = length(s))
        colnames(path_assoc) <- names(s)
        path_assoc[,name] <- 1
        edges_atts <- cbind(id = eids,
                            status = status,
                            color = color,
                            name = name,
                            pname = pname,
                            pvalue = comp[name,"p.value"],
                            adj.pvalue = comp[name,"FDRp.value"])
        eatt <- rbind(eatt, edges_atts)

        epath_assoc <- rbind(epath_assoc, path_assoc)

        # node attributes
        natt[get.vertex.attribute(subgraph, "name"), name] <- 1

    }

    # melt multi path interactions
    unique_edges <- unique(eatt[,1])
    def_eatt <- c()
    def_sif <- c()
    def_epath_assoc <- c()

    for(ue in unique_edges){

        indexes <- which(eatt[,1] == ue)
        subeatt <- eatt[indexes,,drop = FALSE]
        subepath_assoc <- epath_assoc[indexes,,drop = FALSE]
        subsif <- sif[indexes,,drop = FALSE]

        # up regulated
        upsig <- which(subeatt[,"status"] == "UP" &
                           as.numeric(subeatt[,"adj.pvalue"]) < conf)
        if(length(upsig) > 0){

            selected_subsif <- subsif[1,]
            selected_subsif[2] <- paste0(selected_subsif[2], ".up")
            def_sif <- rbind(def_sif, selected_subsif)

            mini_subeatt <- subeatt[upsig,,drop = FALSE]
            selected_subeatt <- mini_subeatt[1, c("id", "status", "color",
                                                  "pvalue", "adj.pvalue")]
            selected_subeatt["id"] <- paste(selected_subsif, collapse = "_")
            def_eatt <- rbind(def_eatt, selected_subeatt)

            selected_subepath_assoc <- subepath_assoc[upsig,,drop = FALSE]
            def_epath_assoc <- rbind(def_epath_assoc,
                                     colSums(selected_subepath_assoc) > 0)
        }

        # down regulated
        downsig <- which(subeatt[,"status"] == "DOWN" &
                             as.numeric(subeatt[,"adj.pvalue"]) < conf)
        if(length(downsig) > 0){

            selected_subsif <- subsif[1,]
            selected_subsif[2] <- paste0(selected_subsif[2], ".down")
            def_sif <- rbind(def_sif, selected_subsif)

            mini_subeatt <- subeatt[downsig,,drop = FALSE]
            selected_subeatt <- mini_subeatt[1,c("id",
                                                 "status",
                                                 "color",
                                                 "pvalue",
                                                 "adj.pvalue")]
            selected_subeatt["id"] <- paste(selected_subsif, collapse = "_")
            def_eatt <- rbind(def_eatt, selected_subeatt)

            selected_subepath_assoc <- subepath_assoc[downsig,,drop = FALSE]
            def_epath_assoc <- rbind(def_epath_assoc,
                                     colSums(selected_subepath_assoc) > 0)
        }

        # no sigs
        nosigs <- which(as.numeric(subeatt[,"adj.pvalue"]) >= conf)
        if(length(nosigs) > 0){

            selected_subsif <- subsif[1,]
            def_sif <- rbind(def_sif, selected_subsif)

            mini_subeatt <- subeatt[nosigs,,drop = FALSE]
            selected_subeatt <- mini_subeatt[1,c("id",
                                                 "status",
                                                 "color",
                                                 "pvalue",
                                                 "adj.pvalue")]
            def_eatt <- rbind(def_eatt, selected_subeatt)

            selected_subepath_assoc <- subepath_assoc[nosigs,,drop = FALSE]
            def_epath_assoc <- rbind(def_epath_assoc,
                                     colSums(selected_subepath_assoc) > 0)
        }
    }

    rownames(def_eatt) <- NULL
    def_eatt <- as.data.frame(def_eatt, stringsAsFactors = FALSE)
    def_epath_assoc <- as.data.frame(def_epath_assoc, stringsAsFactors = FALSE)
    rownames(def_sif) <- NULL
    def_sif <- as.data.frame(def_sif, stringsAsFactors = FALSE)

    def_eatt$shape <- c("inhibited", "directed")[grepl("activation",
                                                       def_sif[,2]) + 1]

    def_eatt <- cbind(def_eatt, (def_epath_assoc == TRUE) + 0)

    natt[,"label"] <- gsub("\\*", "", natt[,"label"])

    # Add functions
    #---------------------
    left <- which(grepl("func", get.edgelist(ig)[,2]))
    if(length(left) > 0 ){
        if(length(left) == 1){
            ids <- paste(get.edgelist(ig)[left,1], "activation",
                         get.edgelist(ig)[left,2], sep = "_")
        }else{
            ids <- apply(get.edgelist(ig)[left,], 1, function(x){
                paste(x[1], "activation", x[2], sep = "_")
            })
        }
        funejes <- as.data.frame(matrix(0,
                                        nrow = length(ids),
                                        ncol = ncol(def_eatt)),
                                 stringsAsFactors = FALSE)
        colnames(funejes) <- colnames(def_eatt)
        rownames(funejes) <- ids
        funejes$id <- ids
        funejes$status <- "DOWN"
        funejes$color <- "darkgrey"
        if("pvalue" %in% colnames(funejes))
            funejes$pvalue <- ids
        if("adj.pvalue" %in% colnames(funejes))
            funejes$adj.pvalue <- "DOWN"
        funejes$shape <- "directed"
        nods <- get.edgelist(ig)[left,1]
        names(nods) <- ids
        names(ids) <- nods
        funs <- t(apply(funejes, 1, function(x){
            lastnodes <- sapply(colnames(funejes), get.effnode.id)
            if(any(lastnodes == nods[x[[1]]])){
                x[which(lastnodes == nods[x[[1]]])] <- 1
                x
            }else{
                x
            }
        }))
        funs <- as.data.frame(funs, stringsAsFactors = FALSE)
        sif_funs <- data.frame(V1 = get.edgelist(ig)[left,1],
                               type = rep("activation", times = length(left)),
                               V3 = get.edgelist(ig)[left,2],
                               stringsAsFactors = FALSE)

        def_sif <- rbind(def_sif, sif_funs)
        def_eatt <- rbind(def_eatt, funs)
    }

    fun_indexes <- grep("_func", rownames(natt))
    fun_names <- rownames(natt)[fun_indexes]
    if(length(fun_indexes) > 0){
        for(i in 1:length(fun_names)){
            pp <- gsub("N", "P", gsub("_func", "", fun_names[i]))
            if(effector == TRUE){
                natt[fun_names[i],pp] <- 1
            } else {
                natt[fun_names[i], grep(paste0("- ", pp), colnames(natt))] <- 1
            }
        }
    }

    if(!is.null(reverse_xref)){
        sids <- strsplit(as.character(natt[,"genesList"]), split = ",")
        translate_ids <- function(ids){
            if(length(ids) > 0){
                ids <- setdiff(ids, "/")
                tids <- sapply(reverse_xref[ids],function(x){
                    if(is.null(x)){
                        return("?")
                    } else {
                        return(x)
                    }})
                return(paste(tids, collapse = ","))
            } else {
                return("?")
            }
        }
        natt <- cbind(natt, tids = sapply(sids, translate_ids))
    }
    if(!is.null(exp)){
        sids <- strsplit(as.character(natt[,"genesList"]), split = ",")
        ids_list <- as.list(1:nrow(exp))
        names(ids_list) <- rownames(exp)
        get_expr_ids <- function(ids){
            if(length(ids) > 0){
                ids <- setdiff(ids, "/")
                exp_values <- sapply(ids_list[ids],function(x){
                    if(is.null(x)){
                        return("?")
                    }else{
                        return(exp[x,])
                    }})
                return(paste(exp_values, collapse = ","))
            } else {
                return("?")
            }
        }
        natt <- cbind(natt, exp_values = sapply(sids, get_expr_ids))
    }

    return(list(sif = def_sif,
                edge_att = def_eatt,
                node_att = natt))
}



create.path.info <- function(all_comp, metaginfo){
    fpgs <- metaginfo$pathigraphs
    path_info <- lapply(fpgs, function(fpg){
        all_comp[names(fpg$effector.subgraphs),]})

    path_json_list <- lapply(names(path_info),function(x){
        out <- paste0("{\n\t\"id\":\"", x, "\",\n")
        out <- paste0(out, "\t\"name\":\"", fpgs[[x]]$path.name, "\",\n")
        anysig <- FALSE
        anyup <- FALSE
        anydown <- FALSE
        anysigup <- FALSE
        anysigdown <- FALSE
        anychanged <- FALSE
        for(i in 1:nrow(path_info[[x]])){
            if(path_info[[x]]$has_change[i] == TRUE)
                anychanged <- TRUE
            if(path_info[[x]]$FDRp.value[i] <= 0.05) {
                anysig <- TRUE
                if(path_info[[x]]$status[i] == "UP")
                    anysigup <- TRUE
                if(path_info[[x]]$status[i] == "DOWN")
                    anysigdown <- TRUE
            }
            if(path_info[[x]]$status[i] == "UP")
                anyup <- TRUE
            if(path_info[[x]]$status[i] == "DOWN")
                anydown <- TRUE
        }
        out <- paste0(out, "\t\"haschanged\":", tolower(anychanged), ",\n")
        out <- paste0(out, "\t\"sig\":", tolower(anysig), ",\n")
        out <- paste0(out, "\t\"up\":", tolower(anyup), ",\n")
        out <- paste0(out, "\t\"down\":", tolower(anydown), ",\n")
        out <- paste0(out, "\t\"upsig\":", tolower(anysigup), ",\n")
        out <- paste0(out, "\t\"downsig\":", tolower(anysigdown), ",\n")
        out <- paste0(out, "\t\"paths\":[\n")
        for(i in 1:nrow(path_info[[x]])){
            out <- paste0(out, "\t\t{")
            out <- paste0(out, "\"id\":\"", rownames(path_info[[x]])[i], "\", ")
            out <- paste0(out, "\"name\":\"",
                          get.path.names(metaginfo,
                                         rownames(path_info[[x]])[i]), "\", ")
            if(grepl("term_", metaginfo$pathigraphs[[1]]$path.id) == TRUE){
                out <- paste0(out, "\"shortname\":\"",
                              get.path.names(metaginfo,
                                             rownames(path_info[[x]])[i]),
                              "\", ")
            }else{
                out <- paste0(out, "\"shortname\":\"" ,
                              gsub("\\*", "", strsplit(get.path.names(
                                  metaginfo,
                                  rownames(path_info[[x]])[i]),": ")[[1]][2]),
                              "\", ")
            }
            out <- paste0(out, "\"pvalue\":", path_info[[x]]$FDRp.value[i],
                          ", ")
            out <- paste0(out, "\"status\":\"", path_info[[x]]$status[i],
                          "\", ")
            out <- paste0(out, "\"sig\":\"",
                          tolower(path_info[[x]]$FDRp.value[i] < 0.05), "\", ")
            out <- paste0(out, "\"haschanged\":",
                          tolower(path_info[[x]]$has_change[i]), ", ")
            out <- paste0(out, "\"up\":",
                          tolower(path_info[[x]]$status[i] == "UP"), ", ")
            out <- paste0(out, "\"down\":",
                          tolower(path_info[[x]]$status[i] == "DOWN"), ", ")
            out <- paste0(out, "\"upsig\":",
                          tolower(path_info[[x]]$status[i] == "UP" &
                                      path_info[[x]]$FDRp.value[i] < 0.05),
                          ", ")
            out <- paste0(out, "\"downsig\":",
                          tolower(path_info[[x]]$status[i] == "DOWN" &
                                      path_info[[x]]$FDRp.value[i] < 0.05),
                          ", ")
            out <- paste0(out, "\"color\":\"", path_info[[x]]$color[i], "\"")
            out <- paste0(out, "}")
            if(i == nrow(path_info[[x]])){
                out <- paste0(out, "\n")
            } else {
                out <- paste0(out, ",\n")
            }
        }
        out <- paste0(out, "\t]\n")
        out <- paste0(out, "}")
        out
    })
    path_json <- paste0("[\n", paste(path_json_list, collapse = ","), "\n]")
    return(path_json)
}


create.report.folders <- function(output.folder, home, clean_out_folder = TRUE){

    pv.folder <- paste0(output.folder,"/pathway-viewer")

    if(clean_out_folder == TRUE & file.exists(pv.folder)){
        unlink(pv.folder, recursive = TRUE)
        unlink(paste0(output.folder, "/index.html"), recursive = TRUE)
    }
    file.copy(paste0(home,"/pathway-viewer/"), output.folder, recursive = TRUE)
    report.path <- paste0(home, "/report-files/")
    png.files.copy <- list.files(path = report.path, pattern = ".png")
    png.files.copy <- paste0(home, "/report-files/", png.files.copy)
    file.copy(png.files.copy, pv.folder)

}

create.pathways.folder <- function(output.folder, metaginfo, comp, moreatts,
                                   conf, verbose = FALSE){

    pathways.folder <- paste0(output.folder, "/pathway-viewer/pathways/")
    if(!file.exists(pathways.folder))
        dir.create(pathways.folder)
    for(pathway in names(metaginfo$pathigraphs)){
        if(verbose == TRUE)
            cat(pathway)
        write.attributes(comp,
                         pathway,
                         metaginfo,
                         paste0(pathways.folder, pathway),
                         moreatts_pathway = moreatts[[pathway]],
                         conf = conf)
    }

    comp$status <- comp$"UP/DOWN"
    comp$has_changed <- TRUE
    path_json <- create.path.info(comp, metaginfo)
    write(path_json, file = paste0(output.folder,
                                   "/pathway-viewer/pathways/path_info.json"))

}


create.html.index <- function(home, output.folder,
                                template_name = "index_template.html",
                                output_name = "index.html"){


    index <- scan(paste0(home,'/report-files/',template_name),
                  comment.char = "", sep = "\n", what = "character",
                  quiet = TRUE)

    global_div <- c()

    global_div <- c(global_div, paste0("<pathway-viewer id='pathway-viewer'",
                                       " path-type='url' path='pathways'>",
                                       "</pathway-viewer>"))

    new_index <- gsub("PUT_HERE_YOUR_ELEMENTS",
                      paste(global_div, collapse = "\n"),
                      index)

    write(paste(new_index, collapse = "\n"),
          file = paste0(output.folder,"/pathway-viewer/",output_name))
}



#' Create visualization HTML
#'
#' Saves the results of a Wilcoxon comparison for the Hipathia pathway values
#' into a folder, and creates a HTML from which to visualize the results on
#' top of the pathways. The results are stored into the specified folder.
#' If this folder does not exist, it will be created. The parent folder must
#' exist.
#'
#' @examples
#' data(results)
#' data(comp)
#' data(brca_design)
#' data(path_vals)
#' pathways <- load.pathways(species = "hsa", pathways.list = c("hsa03320",
#' "hsa04012"))
#' create.report(results, comp, pathways, "save_results/")
#'
#' sample_group <- brca_design[colnames(path_vals),"group"]
#' colors.de <- node.color.per.de(results, pathways,
#' sample_group, "Tumor", "Normal")
#' create.report(results, comp, pathways, "save_results/",
#' node.colors = colors.de)
#'
#' @param comp Comparison object as given by the \code{do.wilcoxon} function
#' @param metaginfo Pathways object as returned by the \code{load.pathways}
#' function
#' @param output.folder Absolute path to the folder in which results will be
#' saved. If this folder does not exist, it will be created.
#' However, the parent folder must exist.
#' @param node.colors List of colors with which to paint the nodes of the
#' pathways, as returned by the
#' \code{node.color.per.de} function. Default is white.
#' @param group.by How to group the subpathways to be visualized. By default
#' they are grouped by the pathway to which they belong. Available groupings
#' include "uniprot", to group subpathways by their annotated Uniprot functions,
#' "GO", to group subpathways by their annotated GO terms, and "genes", to group
#' subpathways by the genes they include. Default is set to "pathway".
#' @param conf Level of significance. By default 0.05.
#' @param verbose Boolean, whether to show details about the results of the
#' execution
#'
#' @return Saves the results and creates a report to visualize them through
#' a server in the specified \code{output.folder}.
#'
#' @export
#'
create.report <- function(comp, metaginfo, output.folder, node.colors = NULL,
                          group.by = "pathway", conf=0.05, verbose = FALSE){

    if(group.by != "pathway" &
       length(unlist(strsplit(rownames(comp)[1], split = "-"))) == 4)
        stop("Grouping only available for effector subgraphs")

    if(!is.null(node.colors)){
        if(node.colors$group.by != group.by)
            stop("Grouping in node.colors must agree with group.by")
        moreatts <- summarize.atts(list(node.colors$colors), c("color"))
    }else{
        moreatts <- NULL
    }

    if(group.by != "pathway"){
        cat(paste0("Creating groupings by ", group.by, "...\n"))
        metaginfo <- get.pseudo.metaginfo(metaginfo, group.by = group.by)
    }

    if(!file.exists(output.folder))
        dir.create(output.folder)
    pv.path <- paste0(system.file("extdata", package="hipathia"))

    cat("Creating report folders...\n")
    create.report.folders(output.folder, pv.path, clean_out_folder = FALSE)

    cat("Creating pathways folder...\n")
    create.pathways.folder(output.folder, metaginfo, comp, moreatts, conf,
                           verbose)

    cat("Creating HTML index...\n")
    create.html.index(pv.path,
                      output.folder,
                      template_name = "index_template.html",
                      output_name = "index.html")

}


summarize.atts <- function(att.list, att.names){
    df.list <- c()
    for(pathway in names(att.list[[1]])){
        df <- sapply(att.list, function(l){l[[pathway]]})
        colnames(df) <- att.names
        df.list[[pathway]] <- df
    }
    return(df.list)
}

#'
#' Visualize a HiPathia report
#'
#' @param output.folder Folder in which results to visualize are stored
#' @param port Port to use
#'
#' @return The instructions to visualize a HiPathia report in a web browser
#'
#' @examples
#' data(results)
#' data(brca_design)
#' data(path_vals)
#' pathways <- load.pathways(species = "hsa", pathways.list = c("hsa03320",
#' "hsa04012"))
#' sample.group <- brca_design[colnames(path_vals),"group"]
#' colors.de <- node.color.per.de(results, pathways,
#' sample.group, "Tumor", "Normal")
#' create.report(results, comp, pathways, "~/save_results/",
#' node.colors = colors.de)
#' visualize.report("~/save_results/")
#' visualize.report("~/save_results/", port=5000)
#' \dontshow{servr::daemon_stop()}
#'
#' @import servr
#' @export
#'
visualize.report <- function(output.folder, port = 4000){
    servr::httd(paste0(output.folder, "/pathway-viewer"),
                port = port, browser = FALSE, daemon = TRUE)
    cat(paste0("Open a web browser and go to URL http://127.0.0.1:",
               port, "\n"))
}




###########################################

# PSEUDO META_GRAPH_INFORMATION

get.pseudo.metaginfo <- function(pathways, group.by){
    pseudo <- load.pseudo.mgi(pathways$species, group.by)
    rownames(pseudo$all.labelids) <- pseudo$all.labelids[,1]
    pathways.list <- names(pathways$pathigraphs)
    if(!all(unique(pseudo$all.labelids[,"path.id"]) %in% pathways.list))
        pseudo <- filter.pseudo.mgi(pseudo, pathways.list)
    return(pseudo)
}

filter.pseudo.mgi <- function(pseudo.meta, pathways.list){
    num.nodes <- sapply(names(pseudo.meta$pathigraphs), function(term){
        graph <- pseudo.meta$pathigraphs[[term]]$graph
        vs <- V(graph)[unlist(lapply(pathways.list, grep, V(graph)$name) )]
        length(vs)
    })
    tofilter <- names(pseudo.meta$pathigraphs)[num.nodes >= 1]
    mini.pathigraphs <- lapply(pseudo.meta$pathigraphs[tofilter],
                               function(pg){
        minipg <- NULL
        graph <- pg$graph
        vs <- V(graph)[unlist(lapply(pathways.list, grep, V(graph)$name) )]
        minipg$graph <- igraph::induced_subgraph(graph, vs)
        minipg$path.name <- pg$path.name
        minipg$path.id <- pg$path.id
        es.ind <- unlist(lapply(pathways.list, grep, pg$effector.subgraphs) )
        minipg$effector.subgraphs <- pg$effector.subgraphs[es.ind]
        minipg
                               })
    names(mini.pathigraphs) <- tofilter

    all.labels <- pseudo.meta$all.labelids
    filter.labelids <- all.labels[all.labels[,"path.id"] %in% pathways.list,]

    mini.pseudo <- NULL
    mini.pseudo$pathigraphs <- mini.pathigraphs
    mini.pseudo$species <- pseudo.meta$species
    mini.pseudo$all.labelids <- filter.labelids

    return(mini.pseudo)
}

