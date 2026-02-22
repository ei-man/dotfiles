module.exports = grammar({
  name: "txtar",

  extras: () => [],

  rules: {
    source_file: ($) =>
      repeat(choice($.archive_file, $.comment, $.command_line, $.text_line, "\n")),

    archive_file: ($) => prec.right(seq($.file_marker, optional($.file_content))),

    file_marker: (_) => token(prec(10, /--[ \t]+[^\n]+[ \t]+--[ \t]*\n/)),

    file_content: ($) =>
      prec.right(
        repeat1(
          choice(
            alias($.comment, $.content_line),
            alias($._content_text, $.content_line),
            "\n",
          ),
        ),
      ),

    comment: (_) => prec(5, seq("#", /[^\n]*/, "\n")),

    command_line: ($) =>
      seq(
        optional(seq($.script_prefix, /[ \t]+/)),
        $.command,
        optional($.arguments),
        "\n",
      ),

    script_prefix: (_) => token("!"),

    command: (_) => token(/[A-Za-z][A-Za-z0-9_-]*/),

    arguments: (_) => token(/[ \t]+[^\n]*/),

    _content_text: (_) => token(/[^\n][^\n]*\n/),

    text_line: (_) => token(/[^A-Za-z#!\n][^\n]*\n/),
  },
});
