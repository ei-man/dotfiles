; Derive the injected language from the archive filename extension.
((archive_file
  (file_marker) @injection.filename
  (file_content) @injection.content)
  (#gsub! @injection.filename "^%-%-%s*" "")
  (#gsub! @injection.filename "%s*%-%-%s*$" "")
  (#set! injection.include-children)
)
