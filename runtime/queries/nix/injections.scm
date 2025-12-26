;; extends

((comment) @injection.content
  (#set! injection.language "comment"))

;; =============================================================================
;; COMMENT-BASED LANGUAGE HINTS
;; Matches: /* lang */ "code" or # lang\n"code"
;; =============================================================================

; /* language */ "code"
((comment) @injection.language
  .
  [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#gsub! @injection.language "/%*%s*([%w%p]+)%s*%*/" "%1")
  (#set! injection.combined))

; # language
; "code"
((comment) @injection.language
  .
  [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#gsub! @injection.language "#%s*([%w%p]+)%s*" "%1")
  (#set! injection.combined))

;; =============================================================================
;; REGEX INJECTION
;; Matches: match, builtins.match
;; =============================================================================

; match function - start
(apply_expression
  function: (_) @_func
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#lua-match? @_func "^match$")
  (#set! injection.language "regex"))

; match function - after dot
(apply_expression
  function: (_) @_func
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#lua-match? @_func "%.match$")
  (#set! injection.language "regex"))

;; =============================================================================
;; BASH BUILD PHASES AND HOOKS - Pattern families (very frequent)
;; =============================================================================

; *Phase (buildPhase, installPhase, checkPhase, etc.)
(binding
  attrpath: (attrpath (identifier) @_path)
  expression: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#lua-match? @_path "^%w+Phase$")
  (#set! injection.language "bash"))

; *Hook (buildHook, installHook, etc.)
(binding
  attrpath: (attrpath (identifier) @_path)
  expression: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#lua-match? @_path "^%w+Hook$")
  (#set! injection.language "bash"))

; *Check
(binding
  attrpath: (attrpath (identifier) @_path)
  expression: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#lua-match? @_path "^%w+Check$")
  (#set! injection.language "bash"))

; pre* hooks (preInstall, prePatch, etc.)
(binding
  attrpath: (attrpath (identifier) @_path)
  expression: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#lua-match? @_path "^pre[A-Z]%w*$")
  (#set! injection.language "bash"))

; post* hooks (postInstall, postPatch, etc.)
(binding
  attrpath: (attrpath (identifier) @_path)
  expression: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#lua-match? @_path "^post[A-Z]%w*$")
  (#set! injection.language "bash"))

; script
(binding
  attrpath: (attrpath (identifier) @_path)
  expression: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#eq? @_path "script")
  (#set! injection.language "bash"))

;; =============================================================================
;; BASH SHELL SCRIPTS - writeShellApplication
;; =============================================================================

; writeShellApplication text attribute - start
(apply_expression
  function: (_) @_func
  argument: (_
    (_)*
    (_
      (_)*
      (binding
        attrpath: (attrpath (identifier) @_path)
        expression: [
          (string_expression (string_fragment) @injection.content)
          (indented_string_expression (string_fragment) @injection.content)
        ])))
  (#lua-match? @_func "^writeShellApplication$")
  (#lua-match? @_path "^text$")
  (#set! injection.language "bash"))

; writeShellApplication text attribute - after dot
(apply_expression
  function: (_) @_func
  argument: (_
    (_)*
    (_
      (_)*
      (binding
        attrpath: (attrpath (identifier) @_path)
        expression: [
          (string_expression (string_fragment) @injection.content)
          (indented_string_expression (string_fragment) @injection.content)
        ])))
  (#lua-match? @_func "%.writeShellApplication$")
  (#lua-match? @_path "^text$")
  (#set! injection.language "bash"))

;; =============================================================================
;; BASH SHELL SCRIPTS - runCommand variants (smart grouping, rare)
;; =============================================================================

(apply_expression
  function: (apply_expression
    function: (apply_expression
      function: (_) @_func))
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ]
  (#match? @_func "(^|\\.)runCommand(No)?CC(Local)?$")
  (#set! injection.language "bash"))

;; =============================================================================
;; BASH SHELL SCRIPTS - Common write functions (split for performance)
;; =============================================================================

; writeBash - start
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "^writeBash$")
  (#set! injection.language "bash"))

; writeBash - after dot
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "%.writeBash$")
  (#set! injection.language "bash"))

; writeBashBin - start
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "^writeBashBin$")
  (#set! injection.language "bash"))

; writeBashBin - after dot
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "%.writeBashBin$")
  (#set! injection.language "bash"))

; writeDash - start
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "^writeDash$")
  (#set! injection.language "bash"))

; writeDash - after dot
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "%.writeDash$")
  (#set! injection.language "bash"))

; writeDashBin - start
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "^writeDashBin$")
  (#set! injection.language "bash"))

; writeDashBin - after dot
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "%.writeDashBin$")
  (#set! injection.language "bash"))

; writeShellScript - start
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "^writeShellScript$")
  (#set! injection.language "bash"))

; writeShellScript - after dot
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "%.writeShellScript$")
  (#set! injection.language "bash"))

; writeShellScriptBin - start
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "^writeShellScriptBin$")
  (#set! injection.language "bash"))

; writeShellScriptBin - after dot
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#lua-match? @_func "%.writeShellScriptBin$")
  (#set! injection.language "bash"))

;; =============================================================================
;; LANGUAGE-SPECIFIC SCRIPTS - Smart grouping (infrequent)
;; =============================================================================

; Fish scripts
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#match? @_func "(^|\\.)writeFish(Bin)?$")
  (#set! injection.language "fish"))

; Haskell scripts
((apply_expression
  function: (apply_expression
    function: (apply_expression
      function: (_) @_func))
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#match? @_func "(^|\\.)writeHaskell(Bin)?$")
  (#set! injection.language "haskell"))

; JavaScript scripts
((apply_expression
  function: (apply_expression
    function: (apply_expression
      function: (_) @_func))
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#match? @_func "(^|\\.)writeJS(Bin)?$")
  (#set! injection.language "javascript"))

; Perl scripts
((apply_expression
  function: (apply_expression
    function: (apply_expression
      function: (_) @_func))
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#match? @_func "(^|\\.)writePerl(Bin)?$")
  (#set! injection.language "perl"))

; Python scripts (PyPy and Python 2/3 variants)
((apply_expression
  function: (apply_expression
    function: (apply_expression
      function: (_) @_func))
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#match? @_func "(^|\\.)(writePyPy|writePython)[23](Bin)?$")
  (#set! injection.language "python"))

; Rust scripts
((apply_expression
  function: (apply_expression
    function: (apply_expression
      function: (_) @_func))
  argument: [
    (string_expression (string_fragment) @injection.content)
    (indented_string_expression (string_fragment) @injection.content)
  ])
  (#match? @_func "(^|\\.)writeRust(Bin)?$")
  (#set! injection.language "rust"))

;; =============================================================================
;; NIXOS TEST SCRIPTS
;; =============================================================================

((binding
  attrpath: (attrpath) @_attr_name
  (#eq? @_attr_name "nodes"))
  (binding
    attrpath: (attrpath) @_func_name
    (#eq? @_func_name "testScript")
    (_
      (string_fragment) @injection.content
      (#set! injection.language "python")))
  (#set! injection.combined))

;; =============================================================================
;; HOME-MANAGER NEOVIM PLUGIN CONFIG
;; =============================================================================

(attrset_expression
  (binding_set
    (binding
      attrpath: (attrpath) @_ty_attr
      (_
        (string_fragment) @_ty)
      (#eq? @_ty_attr "type")
      (#eq? @_ty "lua"))
    (binding
      attrpath: (attrpath) @_cfg_attr
      (_
        (string_fragment) @injection.content
        (#set! injection.language "lua"))
      (#eq? @_cfg_attr "config")))
  (#set! injection.combined))
