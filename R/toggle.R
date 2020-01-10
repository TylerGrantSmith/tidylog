toggle_env <- new.env()

toggle_tidylog <- function() {
    require("tidylog", warn.conflicts = F)
    if(!requireNamespace("conflicted",
                         quietly = T,
                         character.only = T)) {
        warning("Please install the `conflicted` package in order",
                "to toggle `tidylog`.\n")
        return()
    }

    if (is.null(toggle_env$toggle)) {
        toggle_env$toggle <- TRUE
    } else {
        toggle_env$toggle <- !toggle_env$toggle
    }

    if(toggle_env$toggle) {
        cat("Toggling tidylog [on]\n")
        for (nm in getNamespaceExports("tidylog")) {
            conflicted::conflict_prefer(nm, "tidylog",
                                        losers = c("dplyr", "tidyr"),
                                        quiet = T)
        }
    } else {
        cat("Toggling tidylog [off]\n")

        ## hacky solution until there is a better way to remove
        ## preferences in conflicted.

        for (nm in conflicted:::prefs_ls()) {
            if (conflicted:::prefs[[nm]][1] == "tidylog") {
                eval(substitute(remove(nm, envir = conflicted:::prefs)))
                pos = match(".conflicts", search())
                e = rlang::env_parent(globalenv(), pos - 1)
                if (nm %in% ls(e)) {
                    eval(substitute(remove(nm, envir = e)))
                }
            }
        }
        detach("package:tidylog")
    }
}
