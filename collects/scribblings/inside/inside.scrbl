#lang scribble/doc
@(require "utils.ss")

@title[#:tag-prefix '(lib "scribblings/inside/inside.scrbl") 
       #:tag "top"]{@bold{Inside}: PLT Scheme C API}

This manual describes PLT Scheme's C interface, which allows the
interpreter to be extended by a dynamically-loaded library, or
embedded within an arbitrary C/C++ program. The manual assumes
familiarity with PLT Scheme as described in @|MzScheme|.

For an alternative way of dealing with foreign code, see
@other-manual['(lib "scribblings/foreign/foreign.scrbl")], which
describes the @schememodname[scheme/foreign] module for manipulating
low-level libraries and structures purely through Scheme code.

@table-of-contents[]

@; ------------------------------------------------------------------------

@include-section["overview.scrbl"]
@include-section["values.scrbl"]
@include-section["memory.scrbl"]
@include-section["namespaces.scrbl"]
@include-section["procedures.scrbl"]
@include-section["eval.scrbl"]
@include-section["exns.scrbl"]
@include-section["threads.scrbl"]
@include-section["params.scrbl"]
@include-section["contmarks.scrbl"]
@include-section["strings.scrbl"]
@include-section["numbers.scrbl"]
@include-section["ports.scrbl"]
@include-section["structures.scrbl"]
@include-section["security.scrbl"]
@include-section["custodians.scrbl"]
@include-section["misc.scrbl"]
@include-section["hooks.scrbl"]

@; ------------------------------------------------------------------------

@index-section[]
