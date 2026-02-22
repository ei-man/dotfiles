module.exports = grammar({
  name: 'txtar',

  extras: _ => [/[ \t]+/],

  externals: $ => [$.archive_body_line],

  rules: {
    source_file: $ => repeat($._line),

    _line: $ =>
      choice(
        prec(4, $.archive_file),
        prec(3, $.comment_line),
        prec(3, $.bang_line),
        prec(3, $.command_line),
        prec(1, $.generic_line),
        $.empty_line
      ),

    empty_line: _ => /\r?\n/,

    comment_line: $ => seq($.comment, $.newline),

    bang_line: $ =>
      seq(
        field('bang', $.bang),
        optional(field('arguments', $.argument_list)),
        optional(field('inline_comment', $.inline_comment)),
        $.newline
      ),

    command_line: $ =>
      seq(
        field('command', $.command),
        optional(field('arguments', $.argument_list)),
        optional(field('inline_comment', $.inline_comment)),
        $.newline
      ),

    generic_line: $ =>
      seq(
        field('name', $.line_word),
        optional(field('arguments', $.argument_list)),
        optional(field('inline_comment', $.inline_comment)),
        $.newline
      ),

    archive_file: $ =>
      seq(
        field('header', $.archive_header),
        $.newline,
        optional(field('body', $.archive_body))
      ),

    archive_header: $ =>
      seq(
        field('open', $.archive_delim),
        $._header_ws,
        field('filename', $.archive_filename),
        $._header_ws,
        field('close', $.archive_delim)
      ),

    archive_body: $ => repeat1($.archive_body_line),

    comment: _ => /#[^\n]*/,
    inline_comment: _ => /#[^\n]*/,

    bang: _ => '!',
    command: _ => token(prec(1, choice('run', 'write-file', 'assert-file'))),

    argument_list: $ => repeat1($.argument),
    argument: $ => choice($.archive_ref, $.word),
    archive_ref: _ => /@[^\s\n]+/,
    word: _ => /[^#\s\n][^\s\n]*/,
    line_word: _ => /[^#!\s\n-][^\s\n]*/,

    archive_delim: _ => '--',
    archive_filename: _ => /[^\s\n]+/,

    newline: _ => /\r?\n/,
    _header_ws: _ => token.immediate(/[ \t]+/),
  },
})
