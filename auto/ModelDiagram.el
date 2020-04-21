(TeX-add-style-hook
 "ModelDiagram"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("sfmath" "helvet")))
   (TeX-run-style-hooks
    "latex2e"
    "standalone"
    "standalone10"
    "tikz"
    "sfmath")
   (TeX-add-symbols
    "lav"
    "oran"
    "green")))

