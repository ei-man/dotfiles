(archive_file
  header: (archive_header
    filename: (archive_filename) @injection.filename)
  body: (archive_body) @injection.content
  (#set! injection.include-children))

(bang_line
  arguments: (argument_list) @injection.content
  (#set! injection.language "bash")
  (#set! injection.include-children))
